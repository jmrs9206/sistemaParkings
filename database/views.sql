-- ==========================================
-- GESTIÓN DE PARKINGS - VISTAS ANALÍTICAS Y BI (V10.5)
-- DOCUMENTACIÓN EXHAUSTIVA LÍNEA POR LÍNEA
-- ==========================================

-- 1. VISTA: Rentabilidad bruta por Parking y Categoría.
-- Objetivo: Ver qué segmento (Moto, Coche) deja más dinero neto en cada centro.
CREATE OR REPLACE VIEW V_KPI_RENTABILIDAD AS
SELECT 
    p.nombre AS parking,                              -- Nombre del centro.
    cv.nombre AS categoria,                            -- Tipo de vehículo.
    COUNT(e.id_estancia) AS total_estancias,           -- Volumen de ocupaciones.
    SUM(e.coste_total) AS ingresos_totales_base,       -- Facturación neta (Base Imponible).
    -- Duración media por estancia convirtiendo intervalos a minutos.
    ROUND(AVG(EXTRACT(EPOCH FROM (e.fecha_salida - e.fecha_entrada))/60)::numeric, 2) AS tiempo_medio_minutos
FROM ESTANCIAS e
JOIN ESTACIONES est ON e.id_estacion = est.id_estacion
JOIN ZONAS z ON est.id_zona = z.id_zona
JOIN PARKINGS p ON z.id_parking = p.id_parking
JOIN VEHICULOS v ON e.id_vehiculo = v.id_vehiculo
JOIN CATEGORIAS_VEHICULOS cv ON v.id_categoria = cv.id_categoria
WHERE e.fecha_salida IS NOT NULL                      -- Solo estancias finalizadas.
GROUP BY p.nombre, cv.nombre;

-- 2. VISTA: Listado de abonados con facturas pendientes (Deuda Técnica).
-- Objetivo: Toma de decisiones en gerencia para bloqueos de acceso o reclamaciones.
CREATE OR REPLACE VIEW V_BI_DEUDA_ABONADOS AS
SELECT 
    a.dni_cif,                                        -- ID Fiscal para reclamación.
    a.nombre_razon_social AS titular,                 -- Nombre del moroso.
    a.email,                                          -- Contacto rápido.
    COUNT(f.id_factura) AS facturas_pendientes,       -- Número de recibos sin pagar.
    SUM(f.total_factura) AS importe_deuda_total       -- Dinero total adeudado.
FROM ABONADOS a
JOIN FACTURAS f ON a.id_abonado = f.id_abonado
WHERE f.pago_confirmado = FALSE                       -- Filtrar solo impagos.
GROUP BY a.dni_cif, a.nombre_razon_social, a.email
HAVING SUM(f.total_factura) > 0;

-- 3. VISTA: Mapa de Calor de Ocupación por Hora.
-- Objetivo: Detectar horas punta para optimizar personal o subir precios dinámicos.
CREATE OR REPLACE VIEW V_BI_MAPA_CALOR_ENTRADAS AS
SELECT 
    p.nombre AS parking,                              -- Centro analizado.
    EXTRACT(HOUR FROM e.fecha_entrada) AS hora_dia,   -- Franja horaria (0 a 23).
    COUNT(e.id_estancia) AS volumen_entradas          -- Intensidad de tráfico.
FROM ESTANCIAS e
JOIN ESTACIONES est ON e.id_estacion = est.id_estacion
JOIN ZONAS z ON est.id_zona = z.id_zona
JOIN PARKINGS p ON z.id_parking = p.id_parking
GROUP BY p.nombre, EXTRACT(HOUR FROM e.fecha_entrada)
ORDER BY parking, hora_dia;

-- 4. VISTA: Eficiencia y Rotación por Plaza (Puntos Calientes).
-- Objetivo: Detectar plazas que nunca se usan (pueden estar rotas o mal señalizadas).
CREATE OR REPLACE VIEW V_BI_EFICIENCIA_PLAZAS AS
SELECT 
    p.nombre AS parking,                              -- Parking.
    est.codigo_estacion AS plaza,                     -- Código de la plaza.
    COUNT(e.id_estancia) AS veces_ocupada,            -- Popularidad de la plaza.
    SUM(e.coste_total) AS facturacion_generada        -- Rentabilidad específica por punto.
FROM ESTACIONES est
JOIN ZONAS z ON est.id_zona = z.id_zona
JOIN PARKINGS p ON z.id_parking = p.id_parking
LEFT JOIN ESTANCIAS e ON est.id_estacion = e.id_estacion -- Incluir plazas sin uso.
GROUP BY p.nombre, est.codigo_estacion
ORDER BY veces_ocupada DESC;

-- 5. VISTA: Tendencia Mensual de Ingresos.
-- Objetivo: Ver el crecimiento del negocio mes a mes.
CREATE OR REPLACE VIEW V_BI_TENDENCIA_MENSUAL AS
SELECT 
    p.nombre AS parking,                              -- Parking.
    TO_CHAR(f.fecha_emision, 'YYYY-MM') AS periodo,   -- Mes/Año de la factura.
    SUM(f.total_base) AS total_base_mensual,          -- Ingresos netos.
    SUM(f.total_factura) AS total_bruto_mensual       -- Ingresos totales.
FROM FACTURAS f
JOIN PARKINGS p ON f.id_parking = p.id_parking
WHERE f.pago_confirmado = TRUE                        -- Solo dinero real recaudado.
GROUP BY p.nombre, TO_CHAR(f.fecha_emision, 'YYYY-MM')
ORDER BY periodo DESC;
