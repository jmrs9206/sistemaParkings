-- ==========================================
-- GESTIÓN DE PARKINGS - TABLAS Y RESTRICCIONES (V10.5)
-- DOCUMENTACIÓN EXHAUSTIVA LÍNEA POR LÍNEA
-- ==========================================

-- 1. TABLA PROVINCIAS: Almacena las regiones administrativas superiores.
CREATE TABLE PROVINCIAS (
    id_provincia SERIAL PRIMARY KEY,              -- Identificador único autoincremental.
    nombre VARCHAR(100) NOT NULL UNIQUE,          -- Nombre único de la provincia (ej. Madrid).
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP -- Sello de tiempo de creación automática.
);

-- 2. TABLA LOCALIDADES: Municipios vinculados a una provincia.
CREATE TABLE LOCALIDADES (
    id_localidad SERIAL PRIMARY KEY,              -- Clave primaria autoincremental.
    nombre VARCHAR(100) NOT NULL,                 -- Nombre del municipio.
    id_provincia INT NOT NULL,                    -- Referencia a la provincia (FK).
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Sello de creación.
    CONSTRAINT fk_loc_prov FOREIGN KEY (id_provincia) REFERENCES PROVINCIAS(id_provincia) ON DELETE RESTRICT, -- Integridad: No borrar provincia con municipios.
    UNIQUE(nombre, id_provincia)                  -- Evita duplicar el mismo municipio en la misma provincia.
);

-- 3. TABLA PARKINGS: Entidades físicas de estacionamiento.
CREATE TABLE PARKINGS (
    id_parking SERIAL PRIMARY KEY,                -- ID de parking.
    nombre VARCHAR(100) NOT NULL UNIQUE,          -- Nombre comercial del parking.
    id_localidad INT NOT NULL,                    -- Ubicación física del parking.
    activo BOOLEAN DEFAULT TRUE,                  -- Flag de borrado lógico (soft-delete).
    fecha_baja DATE NULL,                         -- Fecha efectiva de cese de actividad.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Sello de alta.
    CONSTRAINT fk_park_loc FOREIGN KEY (id_localidad) REFERENCES LOCALIDADES(id_localidad) ON DELETE RESTRICT -- Bloquea borrado de localidad con parking.
);

-- 4. TABLA ZONAS: Divisiones internas (Planta 0, VIP, Eléctricos).
CREATE TABLE ZONAS (
    id_zona SERIAL PRIMARY KEY,                   -- Clave primaria.
    nombre VARCHAR(50) NOT NULL,                  -- Etiqueta de la zona.
    id_parking INT NOT NULL,                      -- Parking al que pertenece.
    activo BOOLEAN DEFAULT TRUE,                  -- Estado operativo.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Fecha de registro.
    CONSTRAINT fk_zona_parking FOREIGN KEY (id_parking) REFERENCES PARKINGS(id_parking) ON DELETE CASCADE, -- Si se borra el parking, desaparecen sus zonas.
    UNIQUE(nombre, id_parking)                    -- Nombre único dentro de un mismo parking.
);

-- 5. TABLA ESTACIONES: Plazas individuales con sensor.
CREATE TABLE ESTACIONES (
    id_estacion SERIAL PRIMARY KEY,               -- Identificador de plaza.
    codigo_estacion VARCHAR(10) NOT NULL UNIQUE,  -- Código humano (ej. P1-A23).
    id_sensor VARCHAR(50) NOT NULL UNIQUE,        -- ID técnico del hardware del sensor.
    estado_actual CHAR(1) DEFAULT 'L' CHECK (estado_actual IN ('L','O','M')), -- L:Libre, O:Ocupada, M:Mantenimiento.
    id_zona INT NOT NULL,                         -- Zona donde se ubica la plaza.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Sello de alta.
    CONSTRAINT fk_est_zona FOREIGN KEY (id_zona) REFERENCES ZONAS(id_zona) ON DELETE RESTRICT -- Evita zonas huérfanas con plazas.
);

-- 6. TABLA ABONADOS: Clientes recurrentes con contrato.
CREATE TABLE ABONADOS (
    id_abonado SERIAL PRIMARY KEY,                -- ID de cliente.
    nombre_razon_social VARCHAR(150) NOT NULL,    -- Nombre completo o empresa.
    dni_cif VARCHAR(20) NOT NULL UNIQUE,          -- Identificación fiscal única.
    email VARCHAR(100) NOT NULL UNIQUE,           -- Correo de contacto y login.
    telefono VARCHAR(20),                         -- Contacto telefónico.
    id_localidad INT NOT NULL,                    -- Residencia del abonado.
    activo BOOLEAN DEFAULT TRUE,                  -- Estado del cliente.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Fecha de alta en el sistema.
    CONSTRAINT fk_abo_loc FOREIGN KEY (id_localidad) REFERENCES LOCALIDADES(id_localidad) ON DELETE RESTRICT -- Bloqueo geográfico.
);

-- 7. TABLA CATEGORIAS_VEHICULOS: Clasificación por tamaño/tipo.
CREATE TABLE CATEGORIAS_VEHICULOS (
    id_categoria SERIAL PRIMARY KEY,              -- ID de categoría.
    nombre VARCHAR(50) NOT NULL UNIQUE,           -- Ejemplo: Turismo, Moto, Eléctrico.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP -- Fecha de creación.
);

-- 8. TABLA TARIFAS_BASE: Plantillas de precios y reglas comerciales.
CREATE TABLE TARIFAS_BASE (
    id_tarifa_base SERIAL PRIMARY KEY,            -- ID de plantilla.
    nombre_tarifa VARCHAR(50) NOT NULL,           -- Descripción operativa.
    tipo_cliente VARCHAR(20) NOT NULL CHECK (tipo_cliente IN ('ABONADO','OCASIONAL')), -- Segmento objetivo.
    id_categoria INT NOT NULL,                    -- A qué vehículo aplica.
    hora_inicio TIME NULL,                        -- Franja horaria de inicio (opcional).
    hora_fin TIME NULL,                           -- Franja horaria de fin (opcional).
    bitmask_dias INT DEFAULT 127 NOT NULL CHECK (bitmask_dias BETWEEN 1 AND 127), -- Días activos (1=Lun, 64=Dom).
    porcentaje_iva NUMERIC(5,2) DEFAULT 21.00 NOT NULL, -- IVA por defecto.
    requiere_adelantado BOOLEAN DEFAULT FALSE,    -- Flag para pagos antes de entrada (abonos).
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Creación.
    CONSTRAINT fk_tar_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS_VEHICULOS(id_categoria) ON DELETE RESTRICT, -- Bloqueo de categoría.
    UNIQUE(nombre_tarifa, id_categoria, tipo_cliente) -- Evita duplicidad de plantillas idénticas.
);

-- 9. TABLA TARIFAS_PARKING: Precios aplicados en parkings específicos.
CREATE TABLE TARIFAS_PARKING (
    id_tarifa_parking SERIAL PRIMARY KEY,         -- PK única.
    id_tarifa_base INT NOT NULL,                  -- Origen de la plantilla.
    id_parking INT NOT NULL,                      -- Parking donde se aplica.
    precio_minuto NUMERIC(10,4) NOT NULL CHECK (precio_minuto >= 0), -- Coste por minuto (BI).
    precio_mensual NUMERIC(10,2) DEFAULT 0 CHECK (precio_mensual >= 0), -- Cuota fija si aplica.
    porcentaje_iva_aplicable NUMERIC(5,2) NULL,    -- IVA específico si difiere de la base.
    activo BOOLEAN DEFAULT TRUE,                  -- Estado de la tarifa.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Sello temporal.
    CONSTRAINT fk_tp_base FOREIGN KEY (id_tarifa_base) REFERENCES TARIFAS_BASE(id_tarifa_base) ON DELETE RESTRICT,
    CONSTRAINT fk_tp_parking FOREIGN KEY (id_parking) REFERENCES PARKINGS(id_parking) ON DELETE RESTRICT
);

-- 10. TABLA CONTRATOS_ABONO: Relación formal entre abonado y tarifa.
CREATE TABLE CONTRATOS_ABONO (
    id_contrato SERIAL PRIMARY KEY,               -- ID de contrato único.
    id_abonado INT NOT NULL,                      -- Quién contrata.
    id_tarifa_parking INT NOT NULL,               -- Qué tarifa paga.
    fecha_alta DATE NOT NULL DEFAULT CURRENT_DATE, -- Inicio de contrato.
    fecha_baja DATE NULL,                         -- Fin previsto o real.
    fecha_ultima_facturacion DATE NOT NULL DEFAULT CURRENT_DATE, -- Control de ciclos de cobro.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Sello técnico.
    CONSTRAINT fk_cont_abo FOREIGN KEY (id_abonado) REFERENCES ABONADOS(id_abonado) ON DELETE RESTRICT,
    CONSTRAINT fk_cont_tarifa FOREIGN KEY (id_tarifa_parking) REFERENCES TARIFAS_PARKING(id_tarifa_parking) ON DELETE RESTRICT,
    CONSTRAINT chk_fechas_contrato CHECK (fecha_baja IS NULL OR fecha_baja >= fecha_alta) -- Lógica temporal.
);

-- 11. TABLA VEHICULOS: Matrículas autorizadas.
CREATE TABLE VEHICULOS (
    id_vehiculo SERIAL PRIMARY KEY,               -- PK.
    matricula VARCHAR(15) NOT NULL UNIQUE,        -- Placa única sans espacios/guiones.
    id_abonado INT NULL,                          -- Dueño (NULL para ocasionales).
    id_categoria INT NOT NULL,                    -- Tipo de coche.
    es_discapacitado BOOLEAN NOT NULL DEFAULT FALSE, -- Flag para plazas PMR.
    id_contrato_principal INT NULL,               -- Contrato que paga el parking de este coche.
    activo BOOLEAN DEFAULT TRUE,                  -- Soft-delete.
    fecha_baja DATE NULL,                         -- Sello de baja.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Creación.
    CONSTRAINT fk_veh_abo FOREIGN KEY (id_abonado) REFERENCES ABONADOS(id_abonado) ON DELETE RESTRICT,
    CONSTRAINT fk_veh_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS_VEHICULOS(id_categoria) ON DELETE RESTRICT,
    CONSTRAINT fk_veh_contrato FOREIGN KEY (id_contrato_principal) REFERENCES CONTRATOS_ABONO(id_contrato) ON DELETE SET NULL -- Si el contrato se borra, el coche queda libre.
);

-- 12. TABLA METODOS_PAGO: Catálogo de formas de cobro.
CREATE TABLE METODOS_PAGO (
    id_metodo_pago SERIAL PRIMARY KEY,            -- ID técnico.
    nombre_metodo VARCHAR(50) NOT NULL UNIQUE,    -- Ej: Visa, IBAN, Cash.
    tipo_cobro VARCHAR(20) NOT NULL CHECK (tipo_cobro IN ('RECURRENTE','PUNTUAL','AMBOS')), -- Modo de uso.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP -- Sello.
);

-- 13. TABLA DATOS_PAGO_ABONADO: Tokens y credenciales de pago.
CREATE TABLE DATOS_PAGO_ABONADO (
    id_dato_pago SERIAL PRIMARY KEY,              -- PK.
    id_abonado INT NOT NULL,                      -- Titular.
    id_metodo_pago INT NOT NULL,                  -- Tipo.
    token_pasarela VARCHAR(255) NOT NULL,         -- Referencia externa (tokenizada).
    es_metodo_por_defecto BOOLEAN DEFAULT FALSE,  -- Prioridad para remesas.
    activo BOOLEAN DEFAULT TRUE,                  -- Vigencia.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Sello temporal.
    CONSTRAINT fk_dpa_abo FOREIGN KEY (id_abonado) REFERENCES ABONADOS(id_abonado) ON DELETE RESTRICT,
    CONSTRAINT fk_dpa_metodo FOREIGN KEY (id_metodo_pago) REFERENCES METODOS_PAGO(id_metodo_pago) ON DELETE RESTRICT
);
-- Índice para que solo haya UN método por defecto activo por abonado.
CREATE UNIQUE INDEX idx_metodo_def_unq ON DATOS_PAGO_ABONADO(id_abonado) WHERE es_metodo_por_defecto = TRUE AND activo = TRUE;

-- 14. TABLA FACTURAS: Documentos contables finales.
CREATE TABLE FACTURAS (
    id_factura SERIAL PRIMARY KEY,                -- ID de factura universal.
    numero_factura VARCHAR(50) NOT NULL UNIQUE,   -- Serie numérica fiscal.
    fecha_emision TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Emisión oficial.
    total_base NUMERIC(10,2) NOT NULL CHECK (total_base >= 0), -- Base Imponible (neto).
    total_iva NUMERIC(10,2) NOT NULL CHECK (total_iva >= 0),   -- Importe de impuestos.
    porcentaje_iva_historico NUMERIC(5,2) NOT NULL, -- IVA aplicado en ese momento.
    total_factura NUMERIC(10,2) NOT NULL CHECK (total_factura >= 0), -- Suma final.
    pago_confirmado BOOLEAN DEFAULT FALSE,        -- Estado financiero.
    id_abonado INT NULL,                          -- Destinatario (NULL si es ticket anónimo).
    id_parking INT NOT NULL,                      -- Parking que emite.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Registro técnico.
    CONSTRAINT fk_fac_abo FOREIGN KEY (id_abonado) REFERENCES ABONADOS(id_abonado) ON DELETE RESTRICT,
    CONSTRAINT fk_fac_parking FOREIGN KEY (id_parking) REFERENCES PARKINGS(id_parking) ON DELETE RESTRICT,
    CONSTRAINT chk_cuadre_fiscal CHECK (ABS(total_factura - (total_base + total_iva)) < 0.01) -- Validador de suma.
);

-- 15. TABLA ESTANCIAS: Registro de ocupación en tiempo real e histórico.
CREATE TABLE ESTANCIAS (
    id_estancia SERIAL PRIMARY KEY,               -- ID de estancia.
    fecha_entrada TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Apertura de puerta.
    fecha_salida TIMESTAMPTZ NULL,                -- Cierre de puerta.
    precio_aplicado_minuto NUMERIC(10,4) NULL,    -- Precio congelado al entrar.
    porcentaje_iva_aplicado NUMERIC(5,2) NULL,    -- IVA congelado al entrar.
    coste_total NUMERIC(10,2) DEFAULT 0 CHECK (coste_total >= 0), -- Base Imponible total (calc automático).
    id_vehiculo INT NOT NULL,                     -- Vehículo en plaza.
    id_estacion INT NOT NULL,                     -- Plaza ocupada.
    id_tarifa_parking INT NOT NULL,               -- Tarifa vigente asignada.
    id_factura INT NULL,                          -- Vínculo a la factura generada.
    facturado BOOLEAN DEFAULT FALSE,              -- Flag operativo.
    fuente_entrada VARCHAR(20) DEFAULT 'SENSOR' CHECK (fuente_entrada IN ('SENSOR','APP','MANUAL','QR')), -- Canal.
    es_cobro_ocasional BOOLEAN DEFAULT FALSE,      -- Indica si es rotativo (pago directo).
    pago_confirmado BOOLEAN DEFAULT FALSE,        -- Indica si ya se ha pagado esa estancia.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Sello técnico.
    CONSTRAINT fk_est_veh FOREIGN KEY (id_vehiculo) REFERENCES VEHICULOS(id_vehiculo) ON DELETE RESTRICT,
    CONSTRAINT fk_est_estacion FOREIGN KEY (id_estacion) REFERENCES ESTACIONES(id_estacion) ON DELETE RESTRICT,
    CONSTRAINT fk_est_tarifa FOREIGN KEY (id_tarifa_parking) REFERENCES TARIFAS_PARKING(id_tarifa_parking) ON DELETE RESTRICT,
    CONSTRAINT fk_est_factura FOREIGN KEY (id_factura) REFERENCES FACTURAS(id_factura) ON DELETE RESTRICT
);
-- Un vehículo no puede tener dos estancias simultáneas.
CREATE UNIQUE INDEX idx_veh_activo ON ESTANCIAS(id_vehiculo) WHERE fecha_salida IS NULL;
-- Una estación no puede tener dos vehículos a la vez.
CREATE UNIQUE INDEX idx_est_ocupada ON ESTANCIAS(id_estacion) WHERE fecha_salida IS NULL;

-- 16. TABLA TRANSACCIONES_PAGO: Movimientos de dinero específicos.
CREATE TABLE TRANSACCIONES_PAGO (
    id_transaccion SERIAL PRIMARY KEY,            -- ID de operación.
    id_estancia INT NULL,                         -- Vínculo a estancia (si aplica).
    id_factura INT NULL,                          -- Vínculo a factura.
    id_metodo_pago INT NOT NULL,                  -- Tipo de pago usado.
    id_dato_pago INT NULL,                        -- Credencial o token (opcional).
    importe NUMERIC(10,2) NOT NULL CHECK (importe >= 0), -- Cuánto se pagó.
    fecha_transaccion TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Momento del cargo.
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE' CHECK (estado IN ('PENDIENTE','AUTORIZADO','DENEGADO','ANULADO')), -- Situación transaccional.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Sello.
    CONSTRAINT fk_tran_est FOREIGN KEY (id_estancia) REFERENCES ESTANCIAS(id_estancia) ON DELETE RESTRICT,
    CONSTRAINT fk_tran_fac FOREIGN KEY (id_factura) REFERENCES FACTURAS(id_factura) ON DELETE RESTRICT,
    CONSTRAINT fk_tran_metodo FOREIGN KEY (id_metodo_pago) REFERENCES METODOS_PAGO(id_metodo_pago) ON DELETE RESTRICT,
    CONSTRAINT fk_tran_dato_pago FOREIGN KEY (id_dato_pago) REFERENCES DATOS_PAGO_ABONADO(id_dato_pago) ON DELETE RESTRICT,
    CONSTRAINT chk_tran_source CHECK (id_estancia IS NOT NULL OR id_factura IS NOT NULL) -- Debe pagar ALGO.
);

-- 17. TABLA LOG_OCUPACION: BI para snapshots de capacidad.
CREATE TABLE LOG_OCUPACION (
    id_log SERIAL PRIMARY KEY,                    -- PK.
    id_parking INT NOT NULL,                      -- Qué parking.
    plazas_ocupadas INT NOT NULL,                 -- Capacidad usada.
    plazas_totales INT NOT NULL,                  -- Capacidad nominal.
    fecha_registro TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Snapshot time.
    CONSTRAINT fk_log_parking FOREIGN KEY (id_parking) REFERENCES PARKINGS(id_parking) ON DELETE CASCADE
);

-- 18. TABLA LOG_ERRORES_SISTEMA: V10.4 Auditoría de procesos asíncronos.
CREATE TABLE LOG_ERRORES_SISTEMA (
    id_error SERIAL PRIMARY KEY,                  -- ID de error.
    modulo VARCHAR(50) NOT NULL,                  -- Origen (FACTURACIÓN, SENSORES...).
    mensaje TEXT NOT NULL,                        -- Descripción técnica.
    id_referencia INT NULL,                       -- ID del objeto fallido (contrato, factura...).
    fecha_error TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP -- Sello temporal.
);

-- OPTIMIZACIONES DASHBOARD (V10.3)
-- Acelera los cálculos de rotación y estancias pasadas.
CREATE INDEX idx_estancias_bi ON ESTANCIAS (id_estacion, id_vehiculo, fecha_salida) WHERE fecha_salida IS NOT NULL;
-- Acelera el reporte de cierres diarios y cierres por parking.
CREATE INDEX idx_facturas_bi ON FACTURAS (id_parking, fecha_emision, pago_confirmado);
