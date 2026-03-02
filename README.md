# MEMORIA TÉCNICA - PHOENIX PARKINGS

## Sistema de Gestión Integral de Aparcamientos Inteligentes

Este documento contiene la visión técnica, el modelo de datos detallado, las reglas de negocio inteligentes y las conclusiones finales desarrolladas del proyecto.

---

### 1. INTRODUCCIÓN: LA REVOLUCIÓN EN LA GESTIÓN DE APARCAMIENTOS

En el contexto actual de las Smart Cities, la movilidad urbana se ha convertido en uno de los retos más complejos y dinámicos para las administraciones y empresas privadas. La gestión de aparcamientos ha dejado de ser una simple cuestión de "alquiler de espacio" para transformarse en un servicio crítico que requiere precisión, seguridad y, sobre todo, una inteligencia operativa que maximice la eficiencia del suelo urbano.

Bajo esta premisa nace **PHOENIX PARKINGS**, una solución integral de ingeniería de software diseñada para transformar la operativa tradicional de los parkings en un ecosistema digital inteligente. El objetivo central de este proyecto no es solo registrar la entrada y salida de vehículos, sino orquestar una red de infraestructuras interconectadas que sea capaz de autogestionarse, proteger su rentabilidad y ofrecer una transparencia total tanto al gestor como al usuario final.

Este proyecto surge como respuesta a la necesidad de blindar el negocio ante el fraude, optimizar el uso de los recursos mediante sensores IoT y garantizar que cada plaza de aparcamiento contribuya de forma predecible al flujo de caja de la empresa. A través de una arquitectura robusta y una lógica de negocio profundamente integrada en el núcleo del sistema, PHOENIX PARKINGS se posiciona como el estándar de referencia para la gestión de parkings del siglo XXI.

---

### 2. CONCEPTO Y VISIÓN DEL PROYECTO

PHOENIX PARKINGS representa un cambio de paradigma en la gestión de infraestructuras de movilidad urbana. Más allá de un simple almacén de datos, el sistema se ha diseñado como un motor de decisiones autónomo que protege la rentabilidad del negocio y garantiza la transparencia fiscal.

#### REGLAS DE ORO DEL SISTEMA (Lógica Embebida)

- **Ajuste de Cuota Mínima**: Siguiendo estrictas directrices de viabilidad económica, el sistema garantiza un ingreso de 20€ mensuales por cada abonado. El proceso de facturación audita cada cuenta y, si el consumo acumulado no alcanza este umbral, genera automáticamente una línea de ajuste por la diferencia, asegurando la cobertura de costes fijos.
- **Inteligencia de Fallback (Gestión de Excesos)**: Para evitar el uso fraudulento de suscripciones únicas, el sistema monitoriza en tiempo real el cupo de plazas por contrato. Si un abonado intenta ocupar una plaza adicional sin contrato disponible, el trigger de entrada reasigna la estancia automáticamente a la tarifa "Ocasional" (pago por minuto / PORMINUTO), maximizando el ingreso por rotación.
- **Blindaje de Tarifas Ocasionales**: Los usuarios no registrados quedan restringidos exclusivamente a tarifas proporcionales al tiempo de uso, eliminando la posibilidad de aplicar descuentos o tarifas especiales reservadas para fidelización.
- **Trazabilidad Inmutable**: El sistema de auditoría ("Caja Negra") registra cada interacción física (sensores) y lógica (pagos), vinculándolos a matrículas y abonados de forma permanente.

---

### 3. MODELO ENTIDAD-RELACIÓN (CONCEPTO ACADÉMICO)

El diseño conceptual se articula sobre una estructura jerárquica de cinco niveles que garantiza la normalización y la escalabilidad nacional.

#### CARDINALIDADES Y RELACIONES CLAVE

- **Provincias y Localidades (1 a N)**: Estructura geográfica que permite una segmentación regional precisa.
- **Parkings y Zonas (1 a N)**: División modular de la infraestructura física por plantas o áreas funcionales.
- **Zonas y Estaciones (1 a N)**: Identificación única de cada plaza de aparcamiento mediante sensores IoT integrados.
- **Vehículos y Categorías (N a 1)**: Clasificación técnica para la aplicación diferenciada de tarifas (Coche, Moto, Furgoneta).
- **Estancia y Factura (1 a 1)**: Relación biunívoca para usuarios ocasionales que garantiza el cumplimiento del ticket fiscal.
- **Factura y Líneas (1 a N)**: Desglose granular de conceptos para una transparencia total hacia el cliente.

---

### 4. MODELO RELACIONAL (DICCIONARIO DE TABLAS)

#### BLOQUE I: INFRAESTRUCTURA FÍSICA

- **PARKINGS**: Entidad central del negocio. Gestiona la disponibilidad y el histórico de cada centro operativo.
- **ZONAS**: Estructura interna definida por tipos (Planta Alta, Baja, Sótano) mediante restricciones CHECK.
- **ESTACIONES**: Representación digital de la plaza física. Incorpora el control de estado (L, O, M) y el enlace al sensor.

#### BLOQUE II: GESTIÓN DE CLIENTES Y TARIFAS

- **ABONADOS**: Registro maestro de clientes con identificadores comerciales únicos (PHX-xxxx).
- **VEHÍCULOS**: Control de flota. Incluye procesos de normalización automática de matrículas (mayúsculas, sin guiones).
- **TARIFAS_BASE/PARKING**: Sistema de plantillas y precios finales. Permite la convivencia de precios centralizados con ajustes locales por parking.
- **CONTRATOS_ABONO**: Gestión del ciclo de vida de la suscripción y control de periodos de facturación.

#### BLOQUE III: OPERATIVA Y CONTROL FINANCIERO

- **ESTANCIAS**: Tabla maestra de operaciones. Ejecuta la lógica de fallback y congela los precios al ingreso para seguridad del cliente.
- **FACTURAS**: Gestión fiscal de cobros. Incluye cabeceras y líneas desglosadas con cálculos automáticos de IVA.
- **EVENTOS_SISTEMA**: Diario de auditoría de solo inserción. Proporciona una visión histórica completa e inalterable del uso del sistema.

---

### 5. REGLAS DE INTEGRIDAD Y SEGURIDAD TÉCNICA

- **Integridad Referencial**: Implementación de "ON DELETE RESTRICT" para blindar el histórico. Los datos financieros y de uso nunca pueden quedar huérfanos.
- **Precisión de Datos**: Uso de "TIMESTAMPTZ" para eliminar errores derivados de cambios de zona horaria o ajustes estacionales verano/invierno.
- **Seguridad de Dominio**: Restricciones de tipo CHECK en todos los campos críticos para evitar estados de datos inconsistentes.

---

### 6. ANÁLISIS FINAL Y CONCLUSIONES: DEL DATO A LA DECISIÓN DE NEGOCIO

Este proyecto no solo representa una base de datos operativa, sino un sistema de soporte a la decisión (DSS) que orquestra el ciclo de vida completo de un parking inteligente. A continuación, se detalla qué hace cada parte y cómo impacta en el éxito del negocio:

#### 1. EL CICLO DE VIDA DEL CLIENTE (Operativa Humana y Digital)

El sistema comienza gestionando la entrada del cliente al ecosistema de PHOENIX PARKINGS.

- **Captación y Registro**: Cuando un usuario se convierte en abonado, el sistema no solo guarda su nombre; genera automáticamente un código profesional (PHX-) y vincula su tarjeta o cuenta bancaria.
- **Gestión de Flota Personal**: El cliente puede registrar varios vehículos, pero el sistema aplica una inteligencia crítica: solo le permite usar el abono en un coche a la vez.
- **Experiencia de Entrada (Toma de Decisiones)**: En el momento en que el coche llega al sensor, el sistema "decide" en milisegundos qué tarifa aplicarle. Si el cliente es abonado y tiene "cupo" libre, le abre la barrera con su contrato. Si el abonado ya tiene el parking ocupado o es un cliente nuevo, el sistema toma la decisión de tratarlo como "Ocasional", protegiendo así el inventario de plazas del parking.

#### 2. PROCESO OPERATIVO Y CONTROL DE INFRAESTRUCTURA

La capa física del proyecto (Parkings, Zonas y Estaciones) funciona como un gemelo digital del parking real.

- **Control de Sensores**: Cada plaza tiene un sensor vinculado. Esto permite al gestor saber, en tiempo real, no solo cuántos coches hay, sino dónde están exactamente y si alguna zona (como el Sótano VIP) es más rentable que otra.
- **Trazabilidad y Seguridad**: Cada movimiento genera un evento en la "Caja Negra". Esto no es solo para el cobro; es un análisis de flujo. Sabemos a qué hora entran más clientes y por qué puerta, lo que permite tomar decisiones sobre personal o iluminación para ahorrar costes.

#### 3. ANÁLISIS FINANCIERO Y OPTIMIZACIÓN DE INGRESOS

Esta es la parte donde el proyecto se convierte en una herramienta de management de alto nivel.

- **Motor de Facturación Inteligente**: A final de mes, el proceso de facturación automática analiza contrato por contrato. Aquí se aplica la lógica de los 20€ mínimos garantizados. El sistema detecta si un abonado ha usado poco el parking y, proactivamente, ajusta la factura para cumplir con el margen de beneficio necesario por contrato.
- **Análisis de Rentabilidad por Minuto**: Al "congelar" el precio al entrar, el sistema garantiza la transparencia fiscal y evita disputas legales, asegurando que el flujo de caja sea predecible y auditable.

#### 4. AUTOMATIZACIÓN Y TOMA DE DECISIONES AUTÓNOMA

Lo más potente de PHOENIX PARKINGS es que el administrador no tiene que intervenir en el día a día.

- **Decisiones Autónomas**: El sistema decide cuándo liberar una plaza, cuándo aplicar un recargo de exceso, cuándo estandarizar una matrícula mal escrita y cuándo emitir una factura de ajuste.
- **Visibilidad Estratégica**: Gracias a las vistas y el log de eventos detallado, el gestor tiene una radiografía total del negocio: ingresos por parking, ocupación media y comportamiento del cliente abonado vs ocasional.

#### CONCLUSIÓN FINAL

El éxito de PHOENIX PARKINGS reside en la integración total de la estrategia empresarial dentro del código. Hemos pasado de una gestión pasiva (esperar a que el cliente pague) a una gestión proactiva y blindada, donde la base de datos es la que asegura que el negocio sea rentable, seguro y escalable. Es un sistema diseñado para la era de las Smart Cities, donde la eficiencia y la automatización son las claves del liderazgo en el mercado de la movilidad.

---

_PHOENIX PARKINGS - Gestión inteligente para un mundo en movimiento._
