-- Insertar Tarifa Nocturna Base
INSERT INTO TARIFAS_BASE (nombre_tarifa, tipo_cliente, id_categoria, hora_inicio, hora_fin) 
VALUES ('Tarifa Nocturna', 'OCASIONAL', 1, '20:00:00', '07:00:00');

-- Vincular Tarifa Nocturna al Parking 1 (Centro Sol)
-- Precio reducido: 0.03€/min (vs 0.05€ standard)
INSERT INTO TARIFAS_PARKING (id_tarifa_base, id_parking, precio_minuto) 
VALUES ((SELECT id_tarifa_base FROM TARIFAS_BASE WHERE nombre_tarifa = 'Tarifa Nocturna'), 1, 0.03);
INSERT INTO CATEGORIAS_VEHICULOS (nombre) VALUES ('Furgoneta');
