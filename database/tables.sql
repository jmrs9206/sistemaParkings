-- =============================================================================
-- PHOENIX PARKINGS - ESTRUCTURA DE LA BASE DE DATOS
-- Este archivo contiene la creación de todas las tablas y sus restricciones.
-- He diseñado este modelo pensando en la escalabilidad y en tener un control
-- total de lo que pasa en cada parking.
-- =============================================================================

-- 1. PROVINCIAS: Para poder crecer a otras ciudades en el futuro.
CREATE TABLE PROVINCIAS (
    id_provincia SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- 2. LOCALIDADES: Relacionadas con su provincia para organizar la red.
CREATE TABLE LOCALIDADES (
    id_localid SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_provincia INT NOT NULL,
    CONSTRAINT fk_loc_prov FOREIGN KEY (id_provincia) REFERENCES PROVINCIAS(id_provincia) ON DELETE RESTRICT,
    UNIQUE(nombre, id_provincia)
);

-- 3. PARKINGS: La base de nuestro negocio.
CREATE TABLE PARKINGS (
    id_parking SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    id_localidad INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_baja TIMESTAMPTZ NULL,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_park_loc FOREIGN KEY (id_localidad) REFERENCES LOCALIDADES(id_localid) ON DELETE RESTRICT
);

-- 4. ZONAS: Cómo dividimos cada parking (Planta 0, Sótano, etc.)
CREATE TABLE ZONAS (
    id_zona SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    tipo_zona CHAR(2) NOT NULL CHECK (tipo_zona IN ('PA', 'PB', 'SO')), -- PA: Alta, PB: Baja, SO: Sótano.
    id_parking INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_zona_parking FOREIGN KEY (id_parking) REFERENCES PARKINGS(id_parking) ON DELETE CASCADE,
    UNIQUE(nombre, id_parking)
);

-- 5. ESTACIONES: Son las plazas de aparcamiento con su sensor.
CREATE TABLE ESTACIONES (
    id_estacion SERIAL PRIMARY KEY,
    codigo_estacion VARCHAR(20) UNIQUE,
    id_sensor VARCHAR(50) NOT NULL UNIQUE,
    estado_actual CHAR(1) DEFAULT 'L' CHECK (estado_actual IN ('L','O','M')), -- Libre, Ocupada, Mantenimiento.
    id_zona INT NOT NULL,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_est_zona FOREIGN KEY (id_zona) REFERENCES ZONAS(id_zona) ON DELETE RESTRICT
);

-- 6. ABONADOS: Clientes con contrato mensual.
CREATE TABLE ABONADOS (
    id_abonado SERIAL PRIMARY KEY,
    nombre_razon_social VARCHAR(150) NOT NULL,
    dni_cif VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    id_localidad INT NOT NULL,
    id_parking INT NULL, 
    codigo_abonado VARCHAR(50) UNIQUE,
    activo BOOLEAN DEFAULT TRUE,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_abo_loc FOREIGN KEY (id_localidad) REFERENCES LOCALIDADES(id_localid) ON DELETE RESTRICT,
    CONSTRAINT fk_abo_park FOREIGN KEY (id_parking) REFERENCES PARKINGS(id_parking) ON DELETE RESTRICT
);

-- 7. CATEGORIAS: Para diferenciar precios (Coche, Moto, etc.)
CREATE TABLE CATEGORIAS_VEHICULOS (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE CHECK (nombre IN ('COCHE','FURGONETA','MOTO')),
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 8. TIPOS DE TARIFA: Clasificación de los precios.
CREATE TABLE TIPOS_TARIFA (
    id_tipo_tarifa SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE -- PORMINUTO, LABORAL, 24HORAS, etc.
);

-- 9. TARIFAS BASE: Las reglas de cobro generales.
CREATE TABLE TARIFAS_BASE (
    id_tarifa_base SERIAL PRIMARY KEY,
    id_tipo_tarifa INT NOT NULL,
    tipo_cliente VARCHAR(20) NOT NULL CHECK (tipo_cliente IN ('ABONADO','OCASIONAL')),
    id_categoria INT NOT NULL,
    hora_inicio TIME NULL,
    hora_fin TIME NULL,
    bitmask_dias INT DEFAULT 127 NOT NULL CHECK (bitmask_dias BETWEEN 1 AND 127),
    porcentaje_iva NUMERIC(5,2) DEFAULT 21.00 NOT NULL,
    requiere_adelantado BOOLEAN DEFAULT FALSE,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tar_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS_VEHICULOS(id_categoria) ON DELETE RESTRICT,
    CONSTRAINT fk_tar_tipo FOREIGN KEY (id_tipo_tarifa) REFERENCES TIPOS_TARIFA(id_tipo_tarifa) ON DELETE RESTRICT,
    UNIQUE(id_tipo_tarifa, id_categoria, tipo_cliente)
);

-- 10. TARIFAS POR PARKING: Precios aplicados en cada centro.
CREATE TABLE TARIFAS_PARKING (
    id_tarifa_parking SERIAL PRIMARY KEY,
    id_tarifa_base INT NOT NULL,
    id_parking INT NOT NULL,
    precio_minuto NUMERIC(10,4) NOT NULL CHECK (precio_minuto >= 0),
    precio_mensual NUMERIC(10,2) DEFAULT 0 CHECK (precio_mensual >= 0),
    porcentaje_iva_aplicable NUMERIC(5,2) NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tp_base FOREIGN KEY (id_tarifa_base) REFERENCES TARIFAS_BASE(id_tarifa_base) ON DELETE RESTRICT,
    CONSTRAINT fk_tp_parking FOREIGN KEY (id_parking) REFERENCES PARKINGS(id_parking) ON DELETE RESTRICT
);

-- 11. CONTRATOS: La suscripción del abonado.
CREATE TABLE CONTRATOS_ABONO (
    id_contrato SERIAL PRIMARY KEY,
    id_abonado INT NOT NULL,
    id_tarifa_parking INT NOT NULL,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    fecha_baja TIMESTAMPTZ NULL,
    fecha_ultima_facturacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_cont_abo FOREIGN KEY (id_abonado) REFERENCES ABONADOS(id_abonado) ON DELETE RESTRICT,
    CONSTRAINT fk_cont_tarifa FOREIGN KEY (id_tarifa_parking) REFERENCES TARIFAS_PARKING(id_tarifa_parking) ON DELETE RESTRICT,
    CONSTRAINT chk_fechas_contrato CHECK (fecha_baja IS NULL OR fecha_baja >= fecha_alta)
);

-- 12. VEHICULOS: Los coches que entran al sistema.
CREATE TABLE VEHICULOS (
    id_vehiculo SERIAL PRIMARY KEY,
    matricula VARCHAR(15) NOT NULL UNIQUE,
    id_abonado INT NULL,
    id_categoria INT NOT NULL,
    es_discapacitado BOOLEAN NOT NULL DEFAULT FALSE,
    id_contrato INT NULL, -- Vínculo al contrato si es abonado.
    activo BOOLEAN DEFAULT TRUE,
    fecha_baja TIMESTAMPTZ NULL,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_veh_abo FOREIGN KEY (id_abonado) REFERENCES ABONADOS(id_abonado) ON DELETE RESTRICT,
    CONSTRAINT fk_veh_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS_VEHICULOS(id_categoria) ON DELETE RESTRICT,
    CONSTRAINT fk_veh_contrato FOREIGN KEY (id_contrato) REFERENCES CONTRATOS_ABONO(id_contrato) ON DELETE SET NULL
);

-- 13. METODOS DE PAGO: Cómo cobraremos.
CREATE TABLE METODOS_PAGO (
    id_metodo_pago SERIAL PRIMARY KEY,
    nombre_metodo VARCHAR(50) NOT NULL CHECK (nombre_metodo IN ('DOMICILIADO','CONTACTLESS','EFECTIVO')),
    tipo_cobro VARCHAR(20) NOT NULL CHECK (tipo_cobro IN ('RECURRENTE','PUNTUAL','AMBOS')),
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 14. DATOS DE PAGO: Para los cobros recurrentes de abonados.
CREATE TABLE DATOS_PAGO_ABONADO (
    id_dato_pago SERIAL PRIMARY KEY,
    id_abonado INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    token_pasarela VARCHAR(255) NOT NULL,
    es_metodo_por_defecto BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dpa_abo FOREIGN KEY (id_abonado) REFERENCES ABONADOS(id_abonado) ON DELETE RESTRICT,
    CONSTRAINT fk_dpa_metodo FOREIGN KEY (id_metodo_pago) REFERENCES METODOS_PAGO(id_metodo_pago) ON DELETE RESTRICT
);
CREATE UNIQUE INDEX idx_metodo_def_unq ON DATOS_PAGO_ABONADO(id_abonado) WHERE es_metodo_por_defecto = TRUE AND activo = TRUE;

-- 15. FACTURAS: Lo que emitimos al cliente.
CREATE TABLE FACTURAS (
    id_factura SERIAL PRIMARY KEY,
    numero_factura VARCHAR(50) NOT NULL UNIQUE,
    fecha_emision TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    total_base NUMERIC(10,2) NOT NULL DEFAULT 0,
    total_iva NUMERIC(10,2) NOT NULL DEFAULT 0,
    total_factura NUMERIC(10,2) NOT NULL DEFAULT 0,
    pago_confirmado BOOLEAN DEFAULT FALSE,
    id_abonado INT NULL,
    id_parking INT NOT NULL,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fac_abo FOREIGN KEY (id_abonado) REFERENCES ABONADOS(id_abonado) ON DELETE RESTRICT,
    CONSTRAINT fk_fac_parking FOREIGN KEY (id_parking) REFERENCES PARKINGS(id_parking) ON DELETE RESTRICT
);

-- 16. LINEAS DE FACTURA: Desglose del cobro.
CREATE TABLE LINEAS_FACTURA (
    id_linea SERIAL PRIMARY KEY,
    id_factura INT NOT NULL,
    concepto VARCHAR(255) NOT NULL,
    cantidad NUMERIC(10,2) DEFAULT 1,
    precio_unitario NUMERIC(10,2) NOT NULL,
    porcentaje_iva NUMERIC(5,2) NOT NULL,
    subtotal_linea NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_linea_factura FOREIGN KEY (id_factura) REFERENCES FACTURAS(id_factura) ON DELETE CASCADE
);

-- 17. ESTANCIAS: El registro de cada coche que entra y sale.
CREATE TABLE ESTANCIAS (
    id_estancia SERIAL PRIMARY KEY,
    fecha_entrada TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_salida TIMESTAMPTZ NULL,
    precio_aplicado_minuto NUMERIC(10,4) NULL,
    porcentaje_iva_aplicado NUMERIC(5,2) NULL,
    coste_total NUMERIC(10,2) DEFAULT 0,
    id_vehiculo INT NOT NULL,
    id_estacion INT NOT NULL,
    id_tarifa_parking INT NOT NULL,
    id_factura INT NULL,
    facturado BOOLEAN DEFAULT FALSE,
    fuente_entrada VARCHAR(20) DEFAULT 'SENSOR' CHECK (fuente_entrada IN ('SENSOR','APP','MANUAL','QR')),
    es_cobro_ocasional BOOLEAN DEFAULT FALSE,
    pago_confirmado BOOLEAN DEFAULT FALSE,
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_est_veh FOREIGN KEY (id_vehiculo) REFERENCES VEHICULOS(id_vehiculo) ON DELETE RESTRICT,
    CONSTRAINT fk_est_estacion FOREIGN KEY (id_estacion) REFERENCES ESTACIONES(id_estacion) ON DELETE RESTRICT,
    CONSTRAINT fk_est_tarifa FOREIGN KEY (id_tarifa_parking) REFERENCES TARIFAS_PARKING(id_tarifa_parking) ON DELETE RESTRICT,
    CONSTRAINT fk_est_factura FOREIGN KEY (id_factura) REFERENCES FACTURAS(id_factura) ON DELETE SET NULL
);
CREATE UNIQUE INDEX idx_veh_activo ON ESTANCIAS(id_vehiculo) WHERE fecha_salida IS NULL;
CREATE UNIQUE INDEX idx_est_ocupada ON ESTANCIAS(id_estacion) WHERE fecha_salida IS NULL;

-- 18. TRANSACCIONES: Control de los cobros realizados.
CREATE TABLE TRANSACCIONES_PAGO (
    id_transaccion SERIAL PRIMARY KEY,
    id_estancia INT NULL,
    id_factura INT NULL,
    id_metodo_pago INT NOT NULL,
    id_dato_pago INT NULL,
    importe NUMERIC(10,2) NOT NULL CHECK (importe >= 0),
    fecha_transaccion TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE' CHECK (estado IN ('PENDIENTE','AUTORIZADO','DENEGADO','ANULADO')),
    fecha_alta TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tran_est FOREIGN KEY (id_estancia) REFERENCES ESTANCIAS(id_estancia) ON DELETE RESTRICT,
    CONSTRAINT fk_tran_fac FOREIGN KEY (id_factura) REFERENCES FACTURAS(id_factura) ON DELETE RESTRICT,
    CONSTRAINT fk_tran_metodo FOREIGN KEY (id_metodo_pago) REFERENCES METODOS_PAGO(id_metodo_pago) ON DELETE RESTRICT,
    CONSTRAINT fk_tran_dato_pago FOREIGN KEY (id_dato_pago) REFERENCES DATOS_PAGO_ABONADO(id_dato_pago) ON DELETE RESTRICT
);

-- 19. EVENTOS: Nuestro log para saber qué ha pasado con coches, abonados y plazas.
CREATE TABLE EVENTOS_SISTEMA (
    id_evento SERIAL PRIMARY KEY,
    fecha_evento TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    tipo_evento VARCHAR(50) NOT NULL,             -- ENTRADA, SALIDA, PAGO, ALERTA.
    entidad_afectada VARCHAR(50),                 -- VEHICULO, ABONADO, PLAZA.
    matricula VARCHAR(15),
    id_abonado INT,
    id_estacion INT,
    descripcion TEXT NOT NULL,
    id_registro_relacionado INT,
    usuario_audit VARCHAR(100) DEFAULT 'SYSTEM',
    metadata_adicional JSONB,
    CONSTRAINT fk_evt_abo FOREIGN KEY (id_abonado) REFERENCES ABONADOS(id_abonado) ON DELETE SET NULL,
    CONSTRAINT fk_evt_estacion FOREIGN KEY (id_estacion) REFERENCES ESTACIONES(id_estacion) ON DELETE SET NULL
);

-- ÍNDICES: Para que las consultas vayan rápido.
CREATE INDEX idx_eventos_audit ON EVENTOS_SISTEMA (fecha_evento, tipo_evento, matricula);
CREATE INDEX idx_estancias_bi ON ESTANCIAS (id_estacion, id_vehiculo, fecha_salida) WHERE fecha_salida IS NOT NULL;
CREATE INDEX idx_facturas_bi ON FACTURAS (id_parking, fecha_emision, pago_confirmado);
