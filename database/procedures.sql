-- ==========================================
-- GESTIÓN DE PARKINGS - PROCEDIMIENTOS Y UTILIDADES (V10.5)
-- DOCUMENTACIÓN EXHAUSTIVA LÍNEA POR LÍNEA
-- ==========================================

-- 1. FUNCIÓN HELPER: Facilita consultas sobre el bitmask de días activos.
-- Útil para BI: ¿Está esta tarifa activa el día de la semana X?
CREATE OR REPLACE FUNCTION fn_is_day_active(p_bitmask INT, p_day INT) RETURNS BOOLEAN AS $$
BEGIN
    -- Lógica bitwise: Comprobar si el bit correspondiente al día p_day está encendido.
    -- Muestreo: 1=Lun, 2=Mar, 4=Mie, 8=Jue, 16=Vie, 32=Sab, 64=Dom.
    RETURN (p_bitmask & p_day) > 0; -- Retorna true si el día está incluido.
END;
$$ LANGUAGE plpgsql;

-- 2. PROCEDIMIENTO: Motor de facturación masiva mensual para abonados.
-- Diseñado para ejecutarse vía Cron al inicio de cada mes.
CREATE OR REPLACE PROCEDURE pr_generate_subscriber_monthly_invoices(p_fecha_proceso DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    r_contrato RECORD;        -- Fila del contrato actual en el bucle.
    v_total_base NUMERIC(10,2); -- Base imponible calculada.
    v_total_iva NUMERIC(10,2);  -- IVA calculado.
    v_total_factura NUMERIC(10,2); -- Suma final.
    v_numero_factura VARCHAR(50);  -- Código serie ABO-YYYYMM-ID.
    v_id_factura INT;              -- ID de la factura recién creada.
    v_id_metodo_pago_dom INT;      -- ID del método RECURRENTE.
    v_id_dato_pago_dom INT;        -- ID de las credenciales de domiciliación.
BEGIN
    -- Bucle: Recorrer todos los contratos que no están dados de baja y necesitan facturación.
    FOR r_contrato IN 
        SELECT c.*, tp.precio_mensual, tp.id_parking, b.porcentaje_iva
        FROM CONTRATOS_ABONO c
        JOIN TARIFAS_PARKING tp ON c.id_tarifa_parking = tp.id_tarifa_parking
        JOIN TARIFAS_BASE b ON tp.id_tarifa_base = b.id_tarifa_base
        WHERE c.fecha_baja IS NULL -- Solo contratos activos.
          AND c.fecha_ultima_facturacion < p_fecha_proceso -- Evitar duplicar facturas en el mismo ciclo.
    LOOP
        -- Cálculo de importes (Base Imponible V10.4).
        v_total_base := r_contrato.precio_mensual;
        v_total_iva := ROUND(v_total_base * (r_contrato.porcentaje_iva / 100), 2);
        v_total_factura := v_total_base + v_total_iva;
        -- Formateo de número de factura contable.
        v_numero_factura := 'ABO-' || TO_CHAR(p_fecha_proceso, 'YYYYMM') || '-' || r_contrato.id_contrato;

        -- 1. PERSISTENCIA: Crear la factura oficial como borrador (pago_confirmado = FALSE).
        INSERT INTO FACTURAS (numero_factura, total_base, total_iva, porcentaje_iva_historico, total_factura, id_abonado, id_parking, pago_confirmado)
        VALUES (v_numero_factura, v_total_base, v_total_iva, r_contrato.porcentaje_iva, v_total_factura, r_contrato.id_abonado, r_contrato.id_parking, FALSE)
        RETURNING id_factura INTO v_id_factura; -- Recuperar ID para la transacción.

        -- 2. COBRO AUTOMÁTICO: Buscar si el cliente tiene domiciliación activa por defecto.
        SELECT dpa.id_metodo_pago, dpa.id_dato_pago 
        INTO v_id_metodo_pago_dom, v_id_dato_pago_dom
        FROM DATOS_PAGO_ABONADO dpa
        WHERE dpa.id_abonado = r_contrato.id_abonado AND dpa.es_metodo_por_defecto = TRUE;

        -- 3. GESTIÓN DE TRANSACCIÓN:
        IF v_id_metodo_pago_dom IS NOT NULL THEN
            -- Caso OK: Generar transacción 'PENDIENTE' para remesa bancaria.
            INSERT INTO TRANSACCIONES_PAGO (id_factura, id_metodo_pago, id_dato_pago, importe, estado)
            VALUES (v_id_factura, v_id_metodo_pago_dom, v_id_dato_pago_dom, v_total_factura, 'PENDIENTE');
        ELSE
            -- Gestión de Error (Mejora V10.4): Registrar alerta para administración.
            INSERT INTO LOG_ERRORES_SISTEMA (modulo, mensaje, id_referencia)
            VALUES ('FACTURACION_ABONADOS', 'Crítico: El cliente (' || r_contrato.id_abonado || ') no tiene método de pago SEPA definido.', v_id_factura);
        END IF;

        -- 4. CIERRE DE CICLO: Actualizar el contrato para que no se vuelva a facturar hasta el próximo mes.
        UPDATE CONTRATOS_ABONO SET fecha_ultima_facturacion = p_fecha_proceso WHERE id_contrato = r_contrato.id_contrato;

    END LOOP;
END;
$$;
