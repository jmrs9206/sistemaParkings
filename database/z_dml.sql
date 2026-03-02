-- =============================================================================
-- PHOENIX PARKINGS - CARGA DE DATOS DE PRUEBA
-- Este script puebla el sistema con datos realistas para demostrar todas
-- las funcionalidades: desde la rotación ocasional hasta abonos mensuales.
-- =================================--
-- NOTA: Se usan subconsultas para evitar errores con IDs autoincrementales.
-- =============================================================================

-- 1. GEOGRAFÍA BÁSICA
INSERT INTO PROVINCIAS (nombre) VALUES ('Madrid');

INSERT INTO LOCALIDADES (nombre, id_provincia) 
VALUES ('Madrid', (SELECT id_provincia FROM PROVINCIAS WHERE nombre = 'Madrid'));

-- 2. CONFIGURACIÓN DE VEHÍCULOS Y TARIFAS
INSERT INTO CATEGORIAS_VEHICULOS (nombre) VALUES ('COCHE'), ('MOTO'), ('FURGONETA');
INSERT INTO TIPOS_TARIFA (nombre) VALUES ('PORMINUTO'), ('24HORAS'), ('NOCTURNA'), ('LABORAL');

INSERT INTO METODOS_PAGO (nombre_metodo, tipo_cobro) 
VALUES ('DOMICILIADO', 'RECURRENTE'), ('CONTACTLESS', 'PUNTUAL'), ('EFECTIVO', 'PUNTUAL');

-- 3. NUESTRA RED DE 15 PARKINGS EN MADRID
INSERT INTO PARKINGS (nombre, id_localidad) 
SELECT n, (SELECT id_localid FROM LOCALIDADES WHERE nombre = 'Madrid')
FROM (VALUES 
    ('P. Plaza Mayor'), ('P. Puerta del Sol'), ('P. Gran Vía'),
    ('P. Retiro'), ('P. Atocha'), ('P. Chamartín'),
    ('P. Castellana 1'), ('P. Castellana 2'), ('P. Serrano'),
    ('P. Goya'), ('P. Embajadores'), ('P. Moncloa'),
    ('P. Chamberí'), ('P. Salesas'), ('P. Chueca')
) AS t(n);

-- 4. ESTRUCTURA INTERNA (Zonas y Plazas)
-- Creamos zonas en algunos parkings clave
INSERT INTO ZONAS (nombre, tipo_zona, id_parking) VALUES 
('Planta Calle - Sol', 'PB', (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol')),
('Sótano - Sol', 'SO', (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol')),
('Azotea - Retiro', 'PA', (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Retiro')),
('Parking 1 - Atocha', 'PB', (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Atocha')),
('Sótano VIP - Chamartín', 'SO', (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Chamartín'));

-- Plazas inteligentes con sensores
INSERT INTO ESTACIONES (id_sensor, id_zona) VALUES 
('SENS-SOL-001', (SELECT id_zona FROM ZONAS WHERE nombre = 'Planta Calle - Sol')),
('SENS-SOL-002', (SELECT id_zona FROM ZONAS WHERE nombre = 'Planta Calle - Sol')),
('SENS-SOL-003', (SELECT id_zona FROM ZONAS WHERE nombre = 'Sótano - Sol')),
('SENS-RET-001', (SELECT id_zona FROM ZONAS WHERE nombre = 'Azotea - Retiro')),
('SENS-ATO-001', (SELECT id_zona FROM ZONAS WHERE nombre = 'Parking 1 - Atocha')),
('SENS-CHA-001', (SELECT id_zona FROM ZONAS WHERE nombre = 'Sótano VIP - Chamartín')),
('SENS-SOL-004', (SELECT id_zona FROM ZONAS WHERE nombre = 'Planta Calle - Sol')),
('SENS-SOL-005', (SELECT id_zona FROM ZONAS WHERE nombre = 'Planta Calle - Sol'));

-- 5. POLÍTICA DE PRECIOS (Tarifas)
-- Definimos tarifas base para COCHE
INSERT INTO TARIFAS_BASE (id_tipo_tarifa, tipo_cliente, id_categoria, requiere_adelantado)
VALUES 
((SELECT id_tipo_tarifa FROM TIPOS_TARIFA WHERE nombre = 'PORMINUTO'), 'OCASIONAL', (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE'), FALSE),
((SELECT id_tipo_tarifa FROM TIPOS_TARIFA WHERE nombre = 'PORMINUTO'), 'ABONADO', (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE'), TRUE);

-- Precios específicos por parking
INSERT INTO TARIFAS_PARKING (id_tarifa_base, id_parking, precio_minuto, precio_mensual)
VALUES 
-- Sol: Caro por ser centro
((SELECT id_tarifa_base FROM TARIFAS_BASE WHERE tipo_cliente = 'OCASIONAL' AND id_categoria = (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE')), 
 (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol'), 0.06, 0.00),
((SELECT id_tarifa_base FROM TARIFAS_BASE WHERE tipo_cliente = 'ABONADO' AND id_categoria = (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE')), 
 (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol'), 0.02, 18.00), -- Ojo: 18€ se ajustarán a 20€ por trigger.

-- Atocha: Precio medio
((SELECT id_tarifa_base FROM TARIFAS_BASE WHERE tipo_cliente = 'OCASIONAL' AND id_categoria = (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE')), 
 (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Atocha'), 0.04, 0.00),
((SELECT id_tarifa_base FROM TARIFAS_BASE WHERE tipo_cliente = 'ABONADO' AND id_categoria = (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE')), 
 (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Atocha'), 0.015, 65.00);

-- 6. CLIENTES (Abonados)
INSERT INTO ABONADOS (nombre_razon_social, dni_cif, email, telefono, id_localidad, id_parking)
VALUES 
('Carlos García', '11223344J', 'carlos@p-parkings.es', '611222333', (SELECT id_localid FROM LOCALIDADES WHERE nombre = 'Madrid'), (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol')),
('Marta López', '55667788T', 'marta@p-parkings.es', '644555666', (SELECT id_localid FROM LOCALIDADES WHERE nombre = 'Madrid'), (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Atocha')),
('Javier Jiménez', '00000001P', 'profe@universidad.edu', '677888999', (SELECT id_localid FROM LOCALIDADES WHERE nombre = 'Madrid'), (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol')),
('Logística Madrid S.L.', 'B99887766', 'flota@logismad.es', '910000000', (SELECT id_localid FROM LOCALIDADES WHERE nombre = 'Madrid'), (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Atocha'));

-- 7. SUSCRIPCIONES Y VEHÍCULOS
-- Contratos
INSERT INTO CONTRATOS_ABONO (id_abonado, id_tarifa_parking) VALUES 
((SELECT id_abonado FROM ABONADOS WHERE dni_cif = '11223344J'), (SELECT id_tarifa_parking FROM TARIFAS_PARKING WHERE id_parking = (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol') AND precio_mensual > 0)),
((SELECT id_abonado FROM ABONADOS WHERE dni_cif = '55667788T'), (SELECT id_tarifa_parking FROM TARIFAS_PARKING WHERE id_parking = (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Atocha') AND precio_mensual > 0)),
((SELECT id_abonado FROM ABONADOS WHERE dni_cif = '00000001P'), (SELECT id_tarifa_parking FROM TARIFAS_PARKING WHERE id_parking = (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol') AND precio_mensual > 0)),
((SELECT id_abonado FROM ABONADOS WHERE dni_cif = 'B99887766'), (SELECT id_tarifa_parking FROM TARIFAS_PARKING WHERE id_parking = (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Atocha') AND precio_mensual > 0));

-- Vehículos vinculados
INSERT INTO VEHICULOS (matricula, id_abonado, id_categoria, id_contrato) VALUES 
('1234ABC', (SELECT id_abonado FROM ABONADOS WHERE dni_cif = '11223344J'), (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE'), (SELECT id_contrato FROM CONTRATOS_ABONO WHERE id_abonado = (SELECT id_abonado FROM ABONADOS WHERE dni_cif = '11223344J'))),
('5678DEF', (SELECT id_abonado FROM ABONADOS WHERE dni_cif = '55667788T'), (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE'), (SELECT id_contrato FROM CONTRATOS_ABONO WHERE id_abonado = (SELECT id_abonado FROM ABONADOS WHERE dni_cif = '55667788T'))),
('0000PRV', (SELECT id_abonado FROM ABONADOS WHERE dni_cif = '00000001P'), (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE'), (SELECT id_contrato FROM CONTRATOS_ABONO WHERE id_abonado = (SELECT id_abonado FROM ABONADOS WHERE dni_cif = '00000001P'))),
('FLOT-001', (SELECT id_abonado FROM ABONADOS WHERE dni_cif = 'B99887766'), (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'FURGONETA'), (SELECT id_contrato FROM CONTRATOS_ABONO WHERE id_abonado = (SELECT id_abonado FROM ABONADOS WHERE dni_cif = 'B99887766')));

-- Vehículo Ocasional (No tiene abonado ni contrato)
INSERT INTO VEHICULOS (matricula, id_categoria) VALUES ('9999XYZ', (SELECT id_categoria FROM CATEGORIAS_VEHICULOS WHERE nombre = 'COCHE'));

-- 8. SIMULACIÓN DE MOVIMIENTOS
-- El coche ocasional entra en Sol
INSERT INTO ESTANCIAS (id_vehiculo, id_estacion, id_tarifa_parking, es_cobro_ocasional)
VALUES (
    (SELECT id_vehiculo FROM VEHICULOS WHERE matricula = '9999XYZ'),
    (SELECT id_estacion FROM ESTACIONES WHERE id_sensor = 'SENS-SOL-001'),
    (SELECT id_tarifa_parking FROM TARIFAS_PARKING WHERE id_parking = (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol') AND precio_mensual = 0),
    TRUE
);

-- Carlos (Abonado) entra en Sol
INSERT INTO ESTANCIAS (id_vehiculo, id_estacion, id_tarifa_parking, es_cobro_ocasional)
VALUES (
    (SELECT id_vehiculo FROM VEHICULOS WHERE matricula = '1234ABC'),
    (SELECT id_estacion FROM ESTACIONES WHERE id_sensor = 'SENS-SOL-002'),
    (SELECT id_tarifa_parking FROM TARIFAS_PARKING WHERE id_parking = (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol') AND precio_mensual > 0),
    FALSE
);

-- Julio entra en Sol
INSERT INTO ESTANCIAS (id_vehiculo, id_estacion, id_tarifa_parking, es_cobro_ocasional)
VALUES (
    (SELECT id_vehiculo FROM VEHICULOS WHERE matricula = '0000PRV'),
    (SELECT id_estacion FROM ESTACIONES WHERE id_sensor = 'SENS-SOL-003'),
    (SELECT id_tarifa_parking FROM TARIFAS_PARKING WHERE id_parking = (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol') AND precio_mensual > 0),
    FALSE
);

-- Registramos un método de pago por defecto para el proceso mensual
INSERT INTO DATOS_PAGO_ABONADO (id_abonado, id_metodo_pago, token_pasarela, es_metodo_por_defecto)
VALUES ((SELECT id_abonado FROM ABONADOS WHERE dni_cif = '11223344J'), (SELECT id_metodo_pago FROM METODOS_PAGO WHERE nombre_metodo = 'DOMICILIADO'), 'TOKEN_TEST_123', TRUE);

-- 10. TEST DE REGLA DE NEGOCIO (FALLBACK)
-- Carlos ya tiene un coche en el parking (1234ABC).
-- Intentamos meter un SEGUNDO coche de Carlos (o el mismo) en otra plaza.
-- Al tener solo 1 contrato, el sistema debe marcar esta estancia como OCASIONAL automáticamente.
INSERT INTO ESTANCIAS (id_vehiculo, id_estacion, id_tarifa_parking, es_cobro_ocasional)
VALUES (
    (SELECT id_vehiculo FROM VEHICULOS WHERE matricula = 'FLOT-001'), -- Carlos usa un coche de empresa (por ejemplo)
    (SELECT id_estacion FROM ESTACIONES WHERE id_sensor = 'SENS-SOL-004'),
    (SELECT id_tarifa_parking FROM TARIFAS_PARKING WHERE id_parking = (SELECT id_parking FROM PARKINGS WHERE nombre = 'P. Puerta del Sol') AND precio_mensual > 0), -- Intentamos meterla como abono
    FALSE -- Intentamos meterla como abono
);
-- Nota: Si miras la tabla ESTANCIAS tras este insert, verás que es_cobro_ocasional se ha vuelto TRUE solo.

-- 11. CIERRE DE ESTANCIA Y FACTURACIÓN
-- Simulamos que el ocasional sale después de 45 minutos (calculado por trigger)
UPDATE ESTANCIAS 
SET fecha_salida = fecha_entrada + INTERVAL '45 minutes'
WHERE id_vehiculo = (SELECT id_vehiculo FROM VEHICULOS WHERE matricula = '9999XYZ');

-- Ejecutamos el cierre mensual (Generará facturas para Carlos y Julio con el ajuste de 20€)
CALL pr_facturar_mensualidad(now());
