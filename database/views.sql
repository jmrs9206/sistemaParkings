-- =============================================================================
-- PHOENIX PARKINGS - VISTAS PARA EL CONTROL DEL NEGOCIO
-- He preparado estas vistas para que sea facilísimo sacar informes y
-- ver qué está pasando en los parkings ahora mismo.
-- =============================================================================

-- 1. HISTORIAL DE ACTIVIDAD (Log de negocio)
-- Aquí he montado un log para ver entradas y salidas como si fueran llamadas.
CREATE OR REPLACE VIEW v_registro_actividad AS
SELECT 
    e.fecha_evento AS fecha,
    e.tipo_evento AS accion,
    e.entidad_afectada AS tipo,
    e.matricula,
    a.nombre_razon_social AS cliente,
    st.codigo_estacion AS plaza,
    e.descripcion
FROM EVENTOS_SISTEMA e
LEFT JOIN ABONADOS a ON e.id_abonado = a.id_abonado
LEFT JOIN ESTACIONES st ON e.id_estacion = st.id_estacion
ORDER BY e.fecha_evento DESC;

-- 2. CONTROL DE ABONADOS Y COCHES
-- Para tener un listado rápido de qué coches tiene cada cliente y su cuota.
CREATE OR REPLACE VIEW v_detalle_abonados AS
SELECT 
    a.id_abonado,
    a.codigo_abonado,
    a.nombre_razon_social AS titular,
    c.id_contrato,
    p.nombre AS parking_sede,
    tt.nombre AS tarifa,
    tp.precio_mensual AS cuota,
    string_agg(v.matricula, ', ') AS matrículas
FROM ABONADOS a
JOIN CONTRATOS_ABONO c ON a.id_abonado = c.id_abonado
JOIN TARIFAS_PARKING tp ON c.id_tarifa_parking = tp.id_tarifa_parking
JOIN PARKINGS p ON tp.id_parking = p.id_parking
JOIN TARIFAS_BASE tb ON tp.id_tarifa_base = tb.id_tarifa_base
JOIN TIPOS_TARIFA tt ON tb.id_tipo_tarifa = tt.id_tipo_tarifa
LEFT JOIN VEHICULOS v ON c.id_contrato = v.id_contrato
GROUP BY a.id_abonado, a.codigo_abonado, a.nombre_razon_social, c.id_contrato, p.nombre, tt.nombre, tp.precio_mensual;

-- 3. OCUPACIÓN EN TIEMPO REAL
-- Para saber cuántas plazas hay libres y ocupadas por parking y planta.
CREATE OR REPLACE VIEW v_ocupacion_actual AS
SELECT 
    p.nombre AS parking,
    z.nombre AS zona,
    COUNT(e.id_estacion) AS plazas_totales,
    SUM(CASE WHEN e.estado_actual = 'O' THEN 1 ELSE 0 END) AS ocupadas,
    SUM(CASE WHEN e.estado_actual = 'L' THEN 1 ELSE 0 END) AS libres,
    ROUND((SUM(CASE WHEN e.estado_actual = 'O' THEN 1 ELSE 0 END)::NUMERIC / COUNT(e.id_estacion)::NUMERIC) * 100, 2) AS porcentaje
FROM PARKINGS p
JOIN ZONAS z ON p.id_parking = z.id_parking
JOIN ESTACIONES e ON z.id_zona = e.id_zona
GROUP BY p.nombre, z.nombre;

-- 4. DETALLE DE FACTURAS
-- Para ver qué hemos cobrado y si hay ajustes de cuota mínima.
CREATE OR REPLACE VIEW v_resumen_facturas AS
SELECT 
    f.numero_factura,
    f.fecha_emision,
    a.nombre_razon_social AS abonado,
    l.concepto,
    l.subtotal_linea AS importe,
    f.pago_confirmado
FROM FACTURAS f
LEFT JOIN ABONADOS a ON f.id_abonado = a.id_abonado
JOIN LINEAS_FACTURA l ON f.id_factura = l.id_factura;
