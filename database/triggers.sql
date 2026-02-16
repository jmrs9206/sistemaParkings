-- ==========================================
-- GESTIÓN DE PARKINGS - TRIGGERS Y AUTOMATIZACIÓN (V10.5)
-- DOCUMENTACIÓN EXHAUSTIVA LÍNEA POR LÍNEA
-- ==========================================

-- 1. FUNCIÓN: Sincroniza el cierre de estancia con el cálculo automático de Base Imponible.
CREATE OR REPLACE FUNCTION fn_validate_estancia_close() RETURNS TRIGGER AS $$
BEGIN
    -- Detectar si se está proporcionando la salida por primera vez (OLD.salida era NULL).
    IF (NEW.fecha_salida IS NOT NULL AND OLD.fecha_salida IS NULL) THEN
        -- Seguridad: La tarifa debe estar fijada desde la entrada.
        IF (NEW.precio_aplicado_minuto IS NULL) THEN
            RAISE EXCEPTION 'Error de Completitud: Estancia sin precio fijado en entrada.';
        END IF;
        
        -- CÁLCULO V10.4: Determinar Base Imponible automática.
        -- Transformamos diferencia de tiempo a segundos -> minutos completos (CEIL) -> euros.
        NEW.coste_total := ROUND(
            CEIL(EXTRACT(EPOCH FROM (NEW.fecha_salida - NEW.fecha_entrada)) / 60) * NEW.precio_aplicado_minuto, 
            2 -- Redondeo estándar a 2 decimales contables.
        );

        -- Validación temporal: No se puede salir antes de entrar.
        IF (NEW.coste_total < 0) THEN
            RAISE EXCEPTION 'Incoherencia temporal: Fecha de salida menor a entrada.';
        END IF;
    END IF;
    RETURN NEW; -- Continuar con la actualización si todo es correcto.
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Dispara la función previa antes de cualquier actualización de salida en ESTANCIAS.
CREATE TRIGGER trg_validate_close BEFORE UPDATE OF fecha_salida ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_validate_estancia_close();

-- 2. FUNCIÓN: Verifica que el parking de la factura coincida con el parking de la estancia.
CREATE OR REPLACE FUNCTION fn_validate_factura_parking() RETURNS TRIGGER AS $$
DECLARE
    parking_estancia INT; -- ID del parking real donde está el coche.
    parking_factura INT;  -- ID del parking que emite la factura.
BEGIN
    -- Validar solo si se está asignando una factura a una estancia.
    IF (NEW.id_factura IS NOT NULL) THEN
        -- Consultar origen de la factura.
        SELECT id_parking INTO parking_factura FROM FACTURAS WHERE id_factura = NEW.id_factura;
        -- Consultar ubicación real de la plaza de la estancia.
        SELECT p.id_parking INTO parking_estancia 
        FROM ESTACIONES e 
        JOIN ZONAS z ON e.id_zona = z.id_zona 
        JOIN PARKINGS p ON z.id_parking = p.id_parking
        WHERE e.id_estacion = NEW.id_estacion;
        
        -- Bloqueo si hay fraude o error administrativo de cruce de parkings.
        IF (parking_factura <> parking_estancia) THEN
            RAISE EXCEPTION 'Fraude/Error: Factura de otro parking asignada a esta estancia.';
        END IF;
    END IF;
    RETURN NEW; -- OK.
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Vigila la vinculación estancia <-> factura.
CREATE TRIGGER trg_validate_factura_parking BEFORE INSERT OR UPDATE OF id_factura ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_validate_factura_parking();

-- 3. FUNCIÓN: Fuerza a los abonados con contrato a usar solo domiciliaciones bancarias (SEPA).
CREATE OR REPLACE FUNCTION fn_enforce_direct_debit() RETURNS TRIGGER AS $$
DECLARE
    tipo_m VARCHAR(20); -- Almacena si el método es puntual (cash) o recurrente (IBAN).
BEGIN
    -- Obtener la naturaleza del método de pago que el abonado intenta registrar.
    SELECT tipo_cobro INTO tipo_m FROM METODOS_PAGO WHERE id_metodo_pago = NEW.id_metodo_pago;
    
    -- Si el cliente tiene contratos de abono activos:
    IF EXISTS (SELECT 1 FROM CONTRATOS_ABONO WHERE id_abonado = NEW.id_abonado) THEN
        -- No permitir cash/pago puntual para cuotas de suscripción recurrente.
        IF (tipo_m <> 'RECURRENTE' AND tipo_m <> 'AMBOS') THEN
            RAISE EXCEPTION 'Política de Empresa: Los abonados requieren domiciliación (RECURRENTE).';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Dispara en la tabla de credenciales de pago del cliente.
CREATE TRIGGER trg_pago_domiciliado BEFORE INSERT OR UPDATE ON DATOS_PAGO_ABONADO
FOR EACH ROW EXECUTE FUNCTION fn_enforce_direct_debit();

-- 4. FUNCIÓN: Bloquea la entrada física si el abono no está pagado por adelantado.
CREATE OR REPLACE FUNCTION fn_validate_advance_payment() RETURNS TRIGGER AS $$
DECLARE
    v_requiere_adelantado BOOLEAN; -- ¿La tarifa asignada es prepago?
    v_id_abonado INT;              -- Quién es el dueño del coche.
    v_ultimo_pago_ok BOOLEAN;      -- ¿Tiene facturas pendientes este mes?
BEGIN
    -- Comprobar configuración de la tarifa elegida para la entrada.
    SELECT tb.requiere_adelantado INTO v_requiere_adelantado 
    FROM TARIFAS_PARKING tp 
    JOIN TARIFAS_BASE tb ON tp.id_tarifa_base = tb.id_tarifa_base 
    WHERE tp.id_tarifa_parking = NEW.id_tarifa_parking;

    -- Si el contrato exige prepago (Abonos):
    IF (v_requiere_adelantado = TRUE) THEN
        -- Identificar titular.
        SELECT id_abonado INTO v_id_abonado FROM VEHICULOS WHERE id_vehiculo = NEW.id_vehiculo;
        
        -- Buscar facturas de tipo ABONO (comienzan por ABO-) ya liquidadas.
        SELECT EXISTS (
            SELECT 1 FROM FACTURAS 
            WHERE id_abonado = v_id_abonado 
            AND pago_confirmado = TRUE 
            AND numero_factura LIKE 'ABO%' 
        ) INTO v_ultimo_pago_ok;

        -- No abrir barrera si no está al día.
        IF (NOT v_id_abonado IS NULL AND NOT v_ultimo_pago_ok) THEN
            RAISE EXCEPTION 'Acceso Denegado: Su cuota mensual no está confirmada (Impago).';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Vigila cada intento de entrada (INSERT) en ESTANCIAS.
CREATE TRIGGER trg_check_adelantado BEFORE INSERT ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_validate_advance_payment();

-- 5. FUNCIÓN: Evita que un coche ocasional se cuente como abonado por error.
CREATE OR REPLACE FUNCTION fn_validate_subscriber_tariff() RETURNS TRIGGER AS $$
DECLARE
    v_tipo_tarifa VARCHAR(20); -- Segmento de la tarifa.
    v_id_abo_veh INT;          -- Dueño del vehículo.
BEGIN
    -- Obtener segmento de la tarifa solicitada.
    SELECT tb.tipo_cliente INTO v_tipo_tarifa 
    FROM TARIFAS_PARKING tp 
    JOIN TARIFAS_BASE tb ON tp.id_tarifa_base = tb.id_tarifa_base 
    WHERE tp.id_tarifa_parking = NEW.id_tarifa_parking;

    -- Obtener titular del coche según matrícula.
    SELECT id_abonado INTO v_id_abo_veh FROM VEHICULOS WHERE id_vehiculo = NEW.id_vehiculo;

    -- Si la tarifa es barata (ABONADO) y el coche no tiene dueño registrado: Bloqueo.
    IF (v_tipo_tarifa = 'ABONADO' AND v_id_abo_veh IS NULL) THEN
        RAISE EXCEPTION 'Fraude: Un vehículo sin perfil de abonado no puede usar tarifas de abono.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Validador de segmento comercial en la entrada.
CREATE TRIGGER trg_valida_uso_abono BEFORE INSERT ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_validate_subscriber_tariff();

-- 6. MATRÍCULAS: Saneamiento automático (MAYÚSCULAS y sin caracteres raros).
CREATE OR REPLACE FUNCTION fn_sanitize_matricula() RETURNS TRIGGER AS $$
BEGIN
    -- Limpiar espacios y guiones, pasar a mayúsculas para evitar '1234 abc' <> '1234ABC'.
    NEW.matricula := UPPER(REPLACE(REPLACE(NEW.matricula, ' ', ''), '-', ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_clean_matricula BEFORE INSERT OR UPDATE OF matricula ON VEHICULOS
FOR EACH ROW EXECUTE FUNCTION fn_sanitize_matricula();

-- 7. SOFT DELETE: Control de integridad al dar de baja Parkings o Coches.
CREATE OR REPLACE FUNCTION fn_safe_soft_delete() RETURNS TRIGGER AS $$
BEGIN
    -- Solo actuar si el flag 'activo' pasa de TRUE (activo) a FALSE (baja).
    IF (OLD.activo = TRUE AND NEW.activo = FALSE) THEN
        -- Caso VEHÍCULOS: No permitir baja si están dentro del parking actualmente.
        IF (TG_TABLE_NAME = 'VEHICULOS') THEN
            IF EXISTS (SELECT 1 FROM ESTANCIAS WHERE id_vehiculo = NEW.id_vehiculo AND fecha_salida IS NULL) THEN
                RAISE EXCEPTION 'Error: No se puede desactivar un vehículo que está dentro del parking.';
            END IF;
            NEW.fecha_baja := CURRENT_DATE; -- Registrar fecha de baja.
        END IF;
        -- Caso PARKINGS: No cerrar si aún hay coches dentro.
        IF (TG_TABLE_NAME = 'PARKINGS') THEN
            IF EXISTS (SELECT 1 FROM ESTACIONES e JOIN ZONAS z ON e.id_zona = z.id_zona JOIN ESTANCIAS est ON e.id_estacion = est.id_estacion WHERE z.id_parking = NEW.id_parking AND est.fecha_salida IS NULL) THEN
                RAISE EXCEPTION 'Error: No se puede cerrar el parking con vehículos dentro.';
            END IF;
            NEW.fecha_baja := CURRENT_DATE;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGERS: Escoltas del borrado lógico.
CREATE TRIGGER trg_safe_delete_vehiculo BEFORE UPDATE OF activo ON VEHICULOS
FOR EACH ROW EXECUTE FUNCTION fn_safe_soft_delete();

CREATE TRIGGER trg_safe_delete_parking BEFORE UPDATE OF activo ON PARKINGS
FOR EACH ROW EXECUTE FUNCTION fn_safe_soft_delete();

-- 8. ESTADOS: Control de mantenimiento y apertura de parkings.
CREATE OR REPLACE FUNCTION fn_validate_estancia_op() RETURNS TRIGGER AS $$
DECLARE
    estado_plaza CHAR(1);
    activo_veh BOOLEAN;
    activo_park BOOLEAN;
    cat_vehiculo INT;
    cat_tarifa INT;
BEGIN
    -- 1. ¿Está la plaza rota o en mantenimiento?
    SELECT estado_actual INTO estado_plaza FROM ESTACIONES WHERE id_estacion = NEW.id_estacion;
    IF (estado_plaza = 'M') THEN RAISE EXCEPTION 'No disponible: Plaza en mantenimiento.'; END IF;

    -- 2. ¿El vehículo está dado de baja?
    SELECT activo INTO activo_veh FROM VEHICULOS WHERE id_vehiculo = NEW.id_vehiculo;
    IF (activo_veh = FALSE) THEN RAISE EXCEPTION 'Error: El coche no tiene acceso (Baja).'; END IF;

    -- 3. ¿El parking entero está clausurado?
    SELECT p.activo INTO activo_park FROM ESTACIONES e JOIN ZONAS z ON e.id_zona = z.id_zona JOIN PARKINGS p ON z.id_parking = p.id_parking WHERE e.id_estacion = NEW.id_estacion;
    IF (activo_park = FALSE) THEN RAISE EXCEPTION 'Error: El parking está cerrado temporalmente.'; END IF;

    -- 4. Coherencia de Categoría (Turismo en Turismo, Moto en Moto).
    SELECT id_categoria INTO cat_vehiculo FROM VEHICULOS WHERE id_vehiculo = NEW.id_vehiculo;
    SELECT tb.id_categoria INTO cat_tarifa FROM TARIFAS_PARKING tp JOIN TARIFAS_BASE tb ON tp.id_tarifa_base = tb.id_tarifa_base WHERE tp.id_tarifa_parking = NEW.id_tarifa_parking;
    IF (cat_vehiculo <> cat_tarifa) THEN RAISE EXCEPTION 'Categoría Incorrecta: Tarifa no apta para este vehículo.'; END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_valida_estancia_op BEFORE INSERT OR UPDATE ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_validate_estancia_op();

-- 9. SENSORES: Sincronización automática de L (Libre) / O (Ocupada).
CREATE OR REPLACE FUNCTION fn_sync_estacion_estado() RETURNS TRIGGER AS $$
BEGIN
    -- Al entrar: Cambiar a Ocupada.
    IF (TG_OP = 'INSERT') THEN
        UPDATE ESTACIONES SET estado_actual = 'O' WHERE id_estacion = NEW.id_estacion;
    -- Al salir (Detección de fecha_salida): Cambiar a Libre.
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.fecha_salida IS NOT NULL AND OLD.fecha_salida IS NULL) THEN
            UPDATE ESTACIONES SET estado_actual = 'L' WHERE id_estacion = NEW.id_estacion;
        END IF;
    END IF;
    RETURN NULL; -- AFTER triggers terminan con NULL.
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Reflejo en tiempo real del mapa de estaciones.
CREATE TRIGGER trg_sync_estacion AFTER INSERT OR UPDATE ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_sync_estacion_estado();

-- 10. PRECIOS: Congelar precios y tipos de IVA en el momento de entrar.
CREATE OR REPLACE FUNCTION fn_estancia_congelar_precios() RETURNS TRIGGER AS $$
DECLARE
    p_min NUMERIC(10,4); -- Precio minuto vigente hoy.
    p_iva NUMERIC(5,2);  -- IVA vigente hoy.
BEGIN
    -- Obtener la foto actual de los precios maestros.
    SELECT tp.precio_minuto, COALESCE(tp.porcentaje_iva_aplicable, tb.porcentaje_iva)
    INTO p_min, p_iva
    FROM TARIFAS_PARKING tp
    JOIN TARIFAS_BASE tb ON tp.id_tarifa_base = tb.id_tarifa_base
    WHERE tp.id_tarifa_parking = NEW.id_tarifa_parking;

    -- Guardar copia en la estancia por si la tarifa maestra cambia mañana.
    NEW.precio_aplicado_minuto := p_min;
    NEW.porcentaje_iva_aplicado := p_iva;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_congelar_precios BEFORE INSERT ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_estancia_congelar_precios();
