-- ==========================================
-- GESTIÓN DE PARKINGS - DATOS ELEMENTALES (DML V10.5)
-- DOCUMENTACIÓN EXHAUSTIVA LÍNEA POR LÍNEA
-- ==========================================

-- 1. DATOS MAESTROS: Configuración regional del sistema.
INSERT INTO PROVINCIAS (nombre) VALUES ('Madrid'), ('Barcelona'), ('Valencia'); -- Provincias base.
-- Localidades vinculadas a sus provincias (1:Madrid, 2:Barcelona, 3:Valencia).
INSERT INTO LOCALIDADES (nombre, id_provincia) VALUES ('Madrid', 1), ('Barcelona', 2), ('Torrent', 3);
-- Categorización de vehículos para aplicar tarifas diferenciadas.
INSERT INTO CATEGORIAS_VEHICULOS (nombre) VALUES ('Turismo'), ('Motocicleta');
-- Catálogo de métodos de pago con su comportamiento recurrente o puntual.
INSERT INTO METODOS_PAGO (nombre_metodo, tipo_cobro) VALUES 
('CONTACTLESS', 'PUNTUAL'),    -- Para cobros en ventanilla/app.
('DOMICILIADO', 'RECURRENTE'), -- Para cuotas de abono mensuales.
('EFECTIVO', 'PUNTUAL');       -- Para máquinas de cobro físicas.

-- 2. INFRAESTRUCTURA: Definición física de los parkings.
INSERT INTO PARKINGS (nombre, id_localidad) VALUES ('Parking Centro Sol', 1); -- Parking principal.
INSERT INTO ZONAS (nombre, id_parking) VALUES ('Planta 0', 1);                -- División interna.
-- Estaciones con sensor único para control de ocupación real.
INSERT INTO ESTACIONES (codigo_estacion, id_sensor, id_zona) VALUES 
('P0-01', 'SENS-001', 1), 
('P0-02', 'SENS-002', 1);

-- 3. TARIFAS: Reglas de precio para diferentes perfiles.
INSERT INTO TARIFAS_BASE (nombre_tarifa, tipo_cliente, id_categoria, requiere_adelantado) VALUES 
('Ocasional Standard', 'OCASIONAL', 1, FALSE), -- Pago al final del servicio.
('Abono Mensual', 'ABONADO', 1, TRUE);        -- Pago antes de permitir acceso.

-- Aplicación de precios específicos en el parking (Centro Sol).
INSERT INTO TARIFAS_PARKING (id_tarifa_base, id_parking, precio_minuto, precio_mensual) VALUES 
(1, 1, 0.05, 0.00),     -- 0,05€/min para rotación.
(2, 1, 0.02, 100.00);   -- 100€/mes + 0,02€/min de exceso (si aplica) para abonados.

-- 4. ABONADOS Y CONTRATOS: Perfiles de clientes de larga estancia.
INSERT INTO ABONADOS (nombre_razon_social, dni_cif, email, id_localidad, id_parking, matricula_principal, codigo_abonado) VALUES 
('Juan Pérez', '12345678X', 'juan@email.com', 1, 1, '1234-BBB', 'PHX-01-240101-0001'),
('Abonado Sin Pago', '00000000E', 'error@email.com', 1, 1, '0000-BAD', 'PHX-01-240101-0002');

-- Juan registra su domiciliación SEPA (Metodo 2: IBAN).
INSERT INTO DATOS_PAGO_ABONADO (id_abonado, id_metodo_pago, token_pasarela, es_metodo_por_defecto) 
VALUES (1, 2, 'tok_iban_juan', TRUE);

-- El segundo abonado no registra método (provocará error en la facturación automática).

-- Creación de contratos de abono (con fecha de última facturación en el pasado).
INSERT INTO CONTRATOS_ABONO (id_abonado, id_tarifa_parking, fecha_alta, fecha_ultima_facturacion) VALUES 
(1, 2, '2024-01-01', '2023-12-31'), -- Juan.
(2, 2, '2024-01-01', '2023-12-31'); -- Error Log Test.

-- Registro de vehículos vinculados a contratos para reconocimiento de matrícula.
INSERT INTO VEHICULOS (matricula, id_abonado, id_categoria, id_contrato_principal) VALUES 
('1234-BBB', 1, 1, 1), -- Coche de Juan.
('MOTO-123', NULL, 1, NULL); -- Coche ocasional anónimo.

-- ==========================================
-- ESCENARIO OPERATIVO V10.5
-- ==========================================

-- 5.1. FACTURACIÓN AUTOMÁTICA: Ejecución del motor masivo.
-- Genera facturas ABO para contratos vigentes.
CALL pr_generate_subscriber_monthly_invoices('2024-01-01');

-- Paso Administrativo: Confirmamos que Juan ha pagado su recibo (ABO) para que el sensor le deje entrar.
UPDATE FACTURAS SET pago_confirmado = TRUE WHERE id_abonado = 1;

-- 5.2. FLUJO DE ENTRADAS: Simulación de acceso físico.
-- Juan entra: El trigger check_adelantado valida su prepago.
INSERT INTO ESTANCIAS (id_vehiculo, id_estacion, id_tarifa_parking, es_cobro_ocasional)
VALUES (1, 1, 2, FALSE);

-- El vehículo ocasional entra por sensor (sin abonado asociado).
INSERT INTO ESTANCIAS (id_vehiculo, id_estacion, id_tarifa_parking, es_cobro_ocasional)
VALUES (2, 2, 1, TRUE);

-- 5.3. FLUJO DE SALIDAS: Simulación de abandono de plaza.
-- El trigger validate_close calcula el 'coste_total' (Base Imponible) automáticamente.
UPDATE ESTANCIAS SET fecha_salida = fecha_entrada + INTERVAL '120 minutes' WHERE id_vehiculo = 1;
UPDATE ESTANCIAS SET fecha_salida = fecha_entrada + INTERVAL '60 minutes' WHERE id_vehiculo = 2;

-- 5.4. VERIFICACIÓN DE INTELIGENCIA DE NEGOCIO (Vistazos rápidos a las vistas V10.5)
-- Ver deuda técnica de abonados que no han pagado sus cuotas.
-- SELECT * FROM V_BI_DEUDA_ABONADOS;

-- Ver el log de errores de facturación (aquí aparecerá el Abonado Sin Pago).
-- SELECT * FROM LOG_ERRORES_SISTEMA;

-- Ver rentabilidad acumulada por parking.
-- SELECT * FROM V_KPI_RENTABILIDAD;

-- Ver qué plazas están "más calientes" (mayor rotación).
-- SELECT * FROM V_BI_EFICIENCIA_PLAZAS;

-- FIN DEL SCRIPT COMENTADO V10.5
