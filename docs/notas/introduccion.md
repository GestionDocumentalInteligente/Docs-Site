# Modulo Notas - Introduccion y Casos de Uso

## Que son las Notas en GDI?

El modulo de **Notas** es el sistema de **comunicacion oficial inter-sectorial** de GDI. Una Nota es un **documento oficial** de tipo `NOTA` que pasa por el circuito completo de firma digital y recibe un numero oficial unico, igual que cualquier otro documento del sistema.

A diferencia de otros tipos documentales (Decretos, Resoluciones, Disposiciones), las Notas estan disenadas especificamente para la **comunicacion formal entre sectores**, con un sistema de destinatarios (TO, CC, BCC), tracking de lectura y bandejas organizativas.

### Definicion de Nota en GDI

Una **Nota** es un documento oficial digital con numero unico (ej: `NOTA-2026-000123-TN-LEGAL`), firmado digitalmente, enviado desde un sector a uno o mas sectores destinatarios. Contiene un asunto, un cuerpo HTML y pasa por el circuito de firma antes de ser visible para los destinatarios.

Es la unidad fundamental de comunicacion institucional oficial, con la misma validez legal que cualquier otro documento firmado del sistema.

!!! note "Nota como documento oficial"
    Las Notas **son documentos oficiales**: tienen numero oficial, circuito de firma digital (numerador + firmantes), y se almacenan en `official_documents` una vez firmadas. La diferencia con otros documentos es que se comunican a traves del modulo de Notas, con destinatarios, bandejas y tracking de lectura.

## Propuesta de Valor

### Caracteristicas Diferenciadoras

- **Documento oficial con firma**: Circuito completo de firma digital PAdES, con numerador y firmantes secuenciales
- **Numero oficial unico**: Formato estandar `NOTA-AAAA-NNNNNN-SIGLA_ECO-SIGLA_DEPT`
- **Multi-destinatario**: Envio a multiples sectores con tipos TO, CC y BCC
- **Privacidad BCC**: Los destinatarios en copia oculta solo son visibles para el emisor
- **Gestion de Bandejas**: Organizacion en bandeja de entrada, enviados y archivados
- **Trazabilidad de Lectura**: Registro de cuando cada destinatario abrio la nota
- **Integracion Organizacional**: Respeta la estructura de departments y sectores del organigrama
- **Multi-sector**: Un usuario con acceso a multiples sectores ve notas de todos ellos

---

## Casos de Uso Principales

### 1. Crear y Firmar una Nota

**Actor**: Empleado municipal
**Objetivo**: Enviar una comunicacion oficial firmada a otro sector

**Flujo**:
1. Crea un nuevo documento de tipo NOTA desde el modulo de Documentos
2. Define destinatarios: sectores TO (obligatorio), CC y BCC (opcionales)
3. Redacta el contenido (asunto + cuerpo HTML)
4. Asigna numerador y firmantes
5. Envia al circuito de firma
6. Numerador firma y asigna numero oficial
7. Firmantes completan la firma secuencialmente
8. Al completarse todas las firmas, la nota pasa a estado `official`
9. La nota aparece en la bandeja de entrada de los sectores destinatarios

**Resultado**: Nota oficial firmada, numerada y visible para los destinatarios

### 2. Consulta de Notas Recibidas

**Actor**: Empleado municipal
**Objetivo**: Revisar comunicaciones oficiales recibidas por su sector

**Flujo**:
1. Accede a la bandeja de entrada de Notas
2. Visualiza listado de notas recibidas (leidas y sin leer)
3. Filtra por fecha, busqueda de texto o estado de lectura
4. Selecciona una nota para ver su detalle completo
5. El sistema registra automaticamente la apertura

**Resultado**: Nota consultada con registro de lectura

### 3. Archivo y Desarchivo de Notas

**Actor**: Empleado municipal (destinatario)
**Objetivo**: Organizar notas procesadas

**Flujo**:
1. Desde la bandeja de entrada, selecciona una nota
2. Ejecuta la accion de archivar
3. La nota se mueve a la bandeja de archivados
4. Puede desarchivarla posteriormente para volver a la bandeja de entrada

**Resultado**: Nota archivada, bandeja organizada

!!! warning "Archivado por sector"
    El archivado es por sector. Si una nota fue enviada a 2 sectores del mismo usuario, archivarla en un sector no la archiva en el otro. El emisor no puede archivar sus propias notas.

### 4. Seguimiento de Notas Enviadas

**Actor**: Empleado municipal (emisor)
**Objetivo**: Verificar el estado de lectura de las notas enviadas

**Flujo**:
1. Accede a la bandeja de notas enviadas
2. Visualiza listado con estado de lectura por destinatario
3. Al abrir el detalle, ve exactamente quien abrio la nota y cuando
4. Identifica que sectores han leido la nota y cuales no

**Resultado**: Visibilidad completa del alcance de la comunicacion

### 5. Nota con Destinatarios BCC

**Actor**: Empleado municipal
**Objetivo**: Enviar comunicacion oficial con destinatarios en copia oculta

**Flujo**:
1. Crea nota con destinatarios TO y opcionalmente CC
2. Agrega destinatarios BCC (copia oculta)
3. Completa el circuito de firma
4. Los destinatarios TO/CC ven la nota y los destinatarios visibles
5. Los destinatarios BCC reciben la nota pero no son visibles para TO/CC
6. Solo el emisor puede ver la lista completa incluyendo BCC

**Resultado**: Comunicacion con privacidad parcial garantizada

---

## Componentes del Modulo

### Interfaz de Usuario (Frontend)

| Componente | Descripcion |
|------------|-------------|
| **Bandeja de Entrada** | Listado de notas recibidas por los sectores del usuario, con indicador de leida/sin leer |
| **Bandeja de Enviados** | Listado de notas enviadas por el usuario, con estado de lectura por destinatario |
| **Bandeja de Archivados** | Notas archivadas por el usuario para referencia futura |
| **Detalle de Nota** | Visualizacion completa con contenido HTML, firmantes, destinatarios y aperturas |

### Logica de Negocio (Backend)

| Componente | Descripcion |
|------------|-------------|
| **Notes Retrieval** | Consulta de notas recibidas, enviadas y archivadas con paginacion y filtros |
| **Recipients Manager** | Gestion de destinatarios TO/CC/BCC, validacion y visibilidad |
| **Tracking Service** | Registro de aperturas y estado de lectura |
| **Archiving Service** | Archivo y desarchivo de notas por sector |
| **Validation** | Validacion de recipients previo a firma |

### Almacenamiento

| Recurso | Uso |
|---------|-----|
| **PostgreSQL** | Tablas `notes_recipients`, `notes_openings` + tablas de documentos (`document_draft`, `official_documents`) |
| **Indices parciales** | Optimizacion de consultas por sector, estado de lectura y archivado |

---

## Trazabilidad y Auditoria

### Registro Completo

- **Creacion**: usuario creador, sector emisor, timestamp, tipo de documento NOTA
- **Firma**: circuito de firma digital con timestamp por firmante
- **Numeracion**: numero oficial unico asignado al firmar (advisory lock 888888)
- **Destinatarios**: registro de sectores TO/CC/BCC con sector emisor
- **Lectura**: fecha y hora de primera apertura por cada usuario (tabla `notes_openings`)
- **Archivo**: fecha de archivo/desarchivo por sector (en `notes_recipients`)
