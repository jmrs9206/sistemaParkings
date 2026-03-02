-- =============================================================================
-- PHOENIX PARKINGS - AUTOMATISMOS Y TRIGGERS
-- Aquí he metido toda la lógica para que el sistema funcione solo y
-- no tengamos que estar haciendo cálculos a mano.
-- =============================================================================

-- 1. CÓDIGO DE ABONADO AUTOMÁTICO
-- Para que cada cliente tenga un código único y profesional al registrarse.
CREATE OR REPLACE FUNCTION fn_crear_codigo_abonado() RETURNS TRIGGER AS $$
BEGIN
    NEW.codigo_abonado := 'PHX' || lpad(NEW.id_abonado::text, 4, '0') || NEW.dni_cif;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_codigo_abonado ON ABONADOS;
CREATE TRIGGER trg_codigo_abonado BEFORE INSERT ON ABONADOS
FOR EACH ROW EXECUTE FUNCTION fn_crear_codigo_abonado();

-- 2. CÓDIGO DE PLAZA AUTOMÁTICO
-- Para que las plazas se identifiquen solas por su zona (Planta Alta, Sótano, etc.)
CREATE OR REPLACE FUNCTION fn_crear_codigo_plaza() RETURNS TRIGGER AS $$
DECLARE
    v_prefijo CHAR(2);
BEGIN
    IF (NEW.codigo_estacion IS NULL) THEN
        SELECT tipo_zona INTO v_prefijo FROM ZONAS WHERE id_zona = NEW.id_zona;
        NEW.codigo_estacion := v_prefijo || '-' || lpad(NEW.id_estacion::text, 3, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_codigo_plaza ON ESTACIONES;
CREATE TRIGGER trg_codigo_plaza BEFORE INSERT ON ESTACIONES
FOR EACH ROW EXECUTE FUNCTION fn_crear_codigo_plaza();

-- 3. AUDITORÍA DE MOVIMIENTOS
-- Esto es fundamental para saber quién entra y sale. He querido que guarde
-- la matrícula y el abonado para que podamos filtrar luego.
CREATE OR REPLACE FUNCTION fn_guardar_evento_movimiento() RETURNS TRIGGER AS $$
DECLARE
    v_matricula VARCHAR(15);
    v_id_abonado INT;
BEGIN
    SELECT matricula, id_abonado INTO v_matricula, v_id_abonado 
    FROM VEHICULOS WHERE id_vehiculo = NEW.id_vehiculo;

    IF (TG_OP = 'INSERT') THEN
        INSERT INTO EVENTOS_SISTEMA (tipo_evento, entidad_afectada, matricula, id_abonado, id_estacion, descripcion, id_registro_relacionado)
        VALUES ('ENTRADA', 'VEHICULO', v_matricula, v_id_abonado, NEW.id_estacion, 
                'Coche ' || v_matricula || ' aparcado en la plaza ' || NEW.id_estacion, NEW.id_estancia);
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.fecha_salida IS NOT NULL AND OLD.fecha_salida IS NULL) THEN
            INSERT INTO EVENTOS_SISTEMA (tipo_evento, entidad_afectada, matricula, id_abonado, id_estacion, descripcion, id_registro_relacionado)
            VALUES ('SALIDA', 'VEHICULO', v_matricula, v_id_abonado, NEW.id_estacion, 
                    'Coche ' || v_matricula || ' ha salido. Cobrado: ' || NEW.coste_total || '€', NEW.id_estancia);
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_evento_estancia ON ESTANCIAS;
CREATE TRIGGER trg_evento_estancia AFTER INSERT OR UPDATE ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_guardar_evento_movimiento();

-- 4. CÁLCULO DE COSTE AL SALIR
-- Aquí calculamos cuánto tiene que pagar según el tiempo que ha estado.
CREATE OR REPLACE FUNCTION fn_calcular_coste_estancia() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.fecha_salida IS NOT NULL AND OLD.fecha_salida IS NULL) THEN
        IF (NEW.precio_aplicado_minuto IS NULL) THEN
            RAISE EXCEPTION 'Ojo: No se puede cobrar si no hay tarifa fijada.';
        END IF;
        
        NEW.coste_total := ROUND(
            CEIL(EXTRACT(EPOCH FROM (NEW.fecha_salida - NEW.fecha_entrada)) / 60) * NEW.precio_aplicado_minuto, 2
        );

        IF (NEW.coste_total < 0) THEN 
            RAISE EXCEPTION 'Error: La fecha de salida es anterior a la de entrada.'; 
        END IF;
        
        IF (NEW.es_cobro_ocasional = TRUE) THEN 
            NEW.facturado := TRUE; 
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_coste_estancia ON ESTANCIAS;
CREATE TRIGGER trg_coste_estancia BEFORE UPDATE OF fecha_salida ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_calcular_coste_estancia();

-- 5. ACTUALIZAR ESTADO DE LA PLAZA
-- Para que el sistema sepa si una plaza está libre u ocupada al momento.
CREATE OR REPLACE FUNCTION fn_cambiar_estado_plaza() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE ESTACIONES SET estado_actual = 'O' WHERE id_estacion = NEW.id_estacion;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.fecha_salida IS NOT NULL AND OLD.fecha_salida IS NULL) THEN
            UPDATE ESTACIONES SET estado_actual = 'L' WHERE id_estacion = NEW.id_estacion;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_estado_plaza ON ESTANCIAS;
CREATE TRIGGER trg_estado_plaza AFTER INSERT OR UPDATE ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_cambiar_estado_plaza();

-- 6. FIJAR PRECIO Y VALIDAR ABONADO AL ENTRAR
-- Esta es la lógica más importante de negocio:
-- 1. Si un coche no tiene contrato, se le aplica sí o sí la tarifa OCASIONAL de ese parking.
-- 2. Si un abonado ya tiene el parking ocupado y no tiene otro contrato libre, 
--    pasa a ser tratado como OCASIONAL (paga por minuto).
CREATE OR REPLACE FUNCTION fn_fijar_precio_entrada() RETURNS TRIGGER AS $$
DECLARE
    v_id_abonado INT;
    v_id_contrato INT;
    v_id_categoria INT;
    v_id_parking INT;
    v_precio_min NUMERIC(10,4);
    v_iva NUMERIC(5,2);
    v_id_tarifa_final INT;
    v_subs_activas INT;
    v_contratos_totales INT;
BEGIN
    -- Obtenemos datos del vehículo y del parking
    SELECT id_abonado, id_contrato, id_categoria INTO v_id_abonado, v_id_contrato, v_id_categoria
    FROM VEHICULOS WHERE id_vehiculo = NEW.id_vehiculo;

    SELECT id_parking INTO v_id_parking FROM ZONAS WHERE id_zona = (SELECT id_zona FROM ESTACIONES WHERE id_estacion = NEW.id_estacion);

    -- LÓGICA DE FALLBACK (Abonado ocupando extra)
    IF (v_id_contrato IS NOT NULL) THEN
        -- Contamos cuántas estancias activas tiene ya este abonado
        SELECT COUNT(*) INTO v_subs_activas FROM ESTANCIAS e
        JOIN VEHICULOS v ON e.id_vehiculo = v.id_vehiculo
        WHERE v.id_abonado = v_id_abonado AND e.fecha_salida IS NULL;

        -- Contamos cuántos contratos activos tiene el abonado
        SELECT COUNT(*) INTO v_contratos_totales FROM CONTRATOS_ABONO 
        WHERE id_abonado = v_id_abonado AND (fecha_baja IS NULL OR fecha_baja > now());

        -- Si ya tiene todo el cupo lleno, lo pasamos a OCASIONAL
        IF (v_subs_activas >= v_contratos_totales) THEN
            NEW.es_cobro_ocasional := TRUE;
            -- Buscamos la tarifa ocasional por minuto para este parking y categoría
            SELECT tp.id_tarifa_parking INTO v_id_tarifa_final
            FROM TARIFAS_PARKING tp
            JOIN TARIFAS_BASE tb ON tp.id_tarifa_base = tb.id_tarifa_base
            WHERE tp.id_parking = v_id_parking 
            AND tb.tipo_cliente = 'OCASIONAL' 
            AND tb.id_categoria = v_id_categoria
            LIMIT 1;

            IF (v_id_tarifa_final IS NULL) THEN
                RAISE EXCEPTION 'Error de negocio: No hay tarifa ocasional definida para este parking/categoría.';
            END IF;
            
            NEW.id_tarifa_parking := v_id_tarifa_final;
        ELSE
            -- Si tiene cupo, usamos la tarifa de su contrato
            SELECT id_tarifa_parking INTO NEW.id_tarifa_parking
            FROM CONTRATOS_ABONO WHERE id_contrato = v_id_contrato;
        END IF;
    ELSE
        -- Si no tiene contrato (es ocasional puro), forzamos la tarifa ocasional
        -- por si el sistema intentó meterle otra.
        NEW.es_cobro_ocasional := TRUE;
        SELECT tp.id_tarifa_parking INTO v_id_tarifa_final
        FROM TARIFAS_PARKING tp
        JOIN TARIFAS_BASE tb ON tp.id_tarifa_base = tb.id_tarifa_base
        WHERE tp.id_parking = v_id_parking 
        AND tb.tipo_cliente = 'OCASIONAL' 
        AND tb.id_categoria = v_id_categoria
        LIMIT 1;
        NEW.id_tarifa_parking := v_id_tarifa_final;
    END IF;

    -- Finalmente, fijamos los precios para que queden "congelados"
    SELECT tp.precio_minuto, COALESCE(tp.porcentaje_iva_aplicable, tb.porcentaje_iva)
    INTO v_precio_min, v_iva
    FROM TARIFAS_PARKING tp
    JOIN TARIFAS_BASE tb ON tp.id_tarifa_base = tb.id_tarifa_base
    WHERE tp.id_tarifa_parking = NEW.id_tarifa_parking;

    NEW.precio_aplicado_minuto := v_precio_min;
    NEW.porcentaje_iva_aplicado := v_iva;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_precio_entrada ON ESTANCIAS;
CREATE TRIGGER trg_precio_entrada BEFORE INSERT ON ESTANCIAS
FOR EACH ROW EXECUTE FUNCTION fn_fijar_precio_entrada();

-- 7. REGLA DE NEGOCIO: TARIFAS OCASIONALES
-- Un cliente ocasional NO puede tener tarifas que no sean 'PORMINUTO'.
CREATE OR REPLACE FUNCTION fn_validar_tarifa_ocasional() RETURNS TRIGGER AS $$
DECLARE
    v_tipo_nombre VARCHAR(50);
BEGIN
    SELECT nombre INTO v_tipo_nombre FROM TIPOS_TARIFA WHERE id_tipo_tarifa = NEW.id_tipo_tarifa;
    
    IF (NEW.tipo_cliente = 'OCASIONAL' AND v_tipo_nombre != 'PORMINUTO') THEN
        RAISE EXCEPTION 'Regla de Negocio: Los clientes ocasionales solo pueden tener tarifas tipo PORMINUTO.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_tarifa_ocasional ON TARIFAS_BASE;
CREATE TRIGGER trg_validar_tarifa_ocasional BEFORE INSERT OR UPDATE ON TARIFAS_BASE
FOR EACH ROW EXECUTE FUNCTION fn_validar_tarifa_ocasional();

-- 8. LIMPIEZA DE MATRÍCULAS
-- Para que no nos entren matrículas con espacios o guiones raros.
CREATE OR REPLACE FUNCTION fn_limpiar_matricula() RETURNS TRIGGER AS $$
BEGIN
    NEW.matricula := UPPER(REPLACE(REPLACE(NEW.matricula, ' ', ''), '-', ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_limpiar_matricula ON VEHICULOS;
CREATE TRIGGER trg_limpiar_matricula BEFORE INSERT OR UPDATE OF matricula ON VEHICULOS
FOR EACH ROW EXECUTE FUNCTION fn_limpiar_matricula();
