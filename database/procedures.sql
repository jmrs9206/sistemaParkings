-- =============================================================================
-- PHOENIX PARKINGS - PROCEDIMIENTOS
-- He creado este proceso para automatizar el cobro mensual de los abonados.
-- =============================================================================

-- MOTOR DE FACTURACIÓN MENSUAL
-- Este proceso recorre los contratos y genera la factura. 
-- He metido la lógica del profesor para que nadie pague menos de 20€.
CREATE OR REPLACE PROCEDURE pr_facturar_mensualidad(p_fecha_proceso TIMESTAMPTZ)
LANGUAGE plpgsql
AS $$
DECLARE
    r_contrato RECORD;
    v_total_base NUMERIC(10,2);
    v_total_iva NUMERIC(10,2);
    v_total_factura NUMERIC(10,2);
    v_numero_factura VARCHAR(50);
    v_id_factura INT;
    v_id_metodo_pago INT;
    v_id_dato_pago INT;
BEGIN
    FOR r_contrato IN 
        SELECT c.*, tp.precio_mensual, tp.id_parking, b.porcentaje_iva
        FROM CONTRATOS_ABONO c
        JOIN TARIFAS_PARKING tp ON c.id_tarifa_parking = tp.id_tarifa_parking
        JOIN TARIFAS_BASE b ON tp.id_tarifa_base = b.id_tarifa_base
        WHERE c.fecha_baja IS NULL 
          AND (c.fecha_ultima_facturacion IS NULL OR c.fecha_ultima_facturacion < p_fecha_proceso)
    LOOP
        -- Calculamos la cuota
        v_total_base := r_contrato.precio_mensual;
        
        -- AJUSTE DE CUOTA MÍNIMA (Requisito del profesor: 20€ mín)
        IF (v_total_base < 20.00) THEN
            v_total_base := 20.00;
        END IF;

        v_total_iva := ROUND(v_total_base * (COALESCE(r_contrato.porcentaje_iva, 21.00) / 100), 2);
        v_total_factura := v_total_base + v_total_iva;
        v_numero_factura := 'FAC-' || TO_CHAR(p_fecha_proceso, 'YYYYMM') || '-' || r_contrato.id_contrato;

        -- Creamos la cabecera
        INSERT INTO FACTURAS (numero_factura, total_base, total_iva, total_factura, id_abonado, id_parking, pago_confirmado)
        VALUES (v_numero_factura, v_total_base, v_total_iva, v_total_factura, r_contrato.id_abonado, r_contrato.id_parking, FALSE)
        RETURNING id_factura INTO v_id_factura;

        -- Detallamos la línea según si hubo ajuste o no
        IF (r_contrato.precio_mensual < 20.00) THEN
            INSERT INTO LINEAS_FACTURA (id_factura, concepto, cantidad, precio_unitario, porcentaje_iva, subtotal_linea)
            VALUES (v_id_factura, 'Cuota Mensual (Sujeto a mínimo de 20€)', 1, 20.00, COALESCE(r_contrato.porcentaje_iva, 21.00), v_total_factura);
        ELSE
            INSERT INTO LINEAS_FACTURA (id_factura, concepto, cantidad, precio_unitario, porcentaje_iva, subtotal_linea)
            VALUES (v_id_factura, 'Cuota Mensual Abono', 1, v_total_base, COALESCE(r_contrato.porcentaje_iva, 21.00), v_total_factura);
        END IF;

        -- Buscamos cómo cobrarle automáticamente
        SELECT dpa.id_metodo_pago, dpa.id_dato_pago INTO v_id_metodo_pago, v_id_dato_pago
        FROM DATOS_PAGO_ABONADO dpa
        WHERE dpa.id_abonado = r_contrato.id_abonado AND dpa.es_metodo_por_defecto = TRUE AND dpa.activo = TRUE;

        IF v_id_metodo_pago IS NOT NULL THEN
            INSERT INTO TRANSACCIONES_PAGO (id_factura, id_metodo_pago, id_dato_pago, importe, estado)
            VALUES (v_id_factura, v_id_metodo_pago, v_id_dato_pago, v_total_factura, 'PENDIENTE');
        END IF;

        UPDATE CONTRATOS_ABONO SET fecha_ultima_facturacion = p_fecha_proceso WHERE id_contrato = r_contrato.id_contrato;
        
        -- Auditoría
        INSERT INTO EVENTOS_SISTEMA (tipo_evento, entidad_afectada, id_abonado, descripcion, id_registro_relacionado)
        VALUES ('FACTURACION', 'ABONADO', r_contrato.id_abonado, 'Nueva factura mensual generada.', v_id_factura);
    END LOOP;
END;
$$;
