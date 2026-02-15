# Modulo Notas - Introduccion y Casos de Uso

## Que son las Notas en GDI?

El modulo de **Notas** es el sistema de **comunicacion oficial inter-sectorial** de GDI, disenado para facilitar el intercambio formal de mensajes entre sectores dentro de una organizacion gubernamental. A diferencia de un sistema de mensajeria informal, las Notas garantizan **trazabilidad completa**, **registro historico** y **formalidad institucional** en cada comunicacion.

### Definicion de Nota en GDI

Una **Nota** es una comunicacion oficial digital enviada desde un sector a uno o mas sectores destinatarios, que contiene un asunto, un cuerpo de mensaje y opcionalmente documentos adjuntos. Cada nota queda registrada en el sistema con informacion completa de emisor, destinatarios, fechas y estado de lectura.

Es la unidad fundamental de comunicacion institucional sobre la cual se construye la trazabilidad de las interacciones entre areas de gobierno.

!!! note "Diferencia con otros modulos"
    Las Notas **no son documentos oficiales** (no tienen circuito de firma ni numeracion oficial) y **no son expedientes** (no agrupan tramites). Son comunicaciones formales entre sectores, con un ciclo de vida propio centrado en el envio, recepcion, lectura y archivo.

## Propuesta de Valor

### Caracteristicas Diferenciadoras

- **Comunicacion Formal**: Canal oficial con registro y trazabilidad, reemplazando medios informales
- **Multi-destinatario**: Envio simultaneo a multiples sectores en una sola operacion
- **Adjuntos Oficiales**: Posibilidad de vincular documentos oficiales del sistema a la nota
- **Gestion de Bandejas**: Organizacion en bandeja de entrada, enviados y archivados
- **Trazabilidad de Lectura**: Registro de cuando cada destinatario leyo la nota
- **Integracion Organizacional**: Respeta la estructura de departments y sectores del organigrama

---

## Casos de Uso Principales

### 1. Comunicacion Formal entre Sectores

**Actor**: Empleado municipal
**Objetivo**: Enviar una comunicacion oficial a otro sector

**Flujo**:
1. Accede al modulo de Notas desde el menu principal
2. Crea una nueva nota indicando asunto y cuerpo
3. Selecciona uno o mas sectores destinatarios
4. Opcionalmente adjunta documentos oficiales
5. Envia la nota

**Resultado**: Nota registrada en el sistema, visible en la bandeja de entrada de los destinatarios

### 2. Consulta de Notas Recibidas

**Actor**: Empleado municipal
**Objetivo**: Revisar comunicaciones recibidas por su sector

**Flujo**:
1. Accede a la bandeja de entrada de Notas
2. Visualiza listado de notas recibidas (leidas y sin leer)
3. Selecciona una nota para ver su detalle completo
4. El sistema marca la nota como leida automaticamente

**Resultado**: Nota consultada con registro de lectura

### 3. Archivo de Notas

**Actor**: Empleado municipal
**Objetivo**: Organizar notas procesadas moviéndolas al archivo

**Flujo**:
1. Desde la bandeja de entrada, selecciona una nota
2. Ejecuta la accion de archivar
3. La nota se mueve a la bandeja de archivados
4. Puede consultarla posteriormente desde esa bandeja

**Resultado**: Nota archivada, bandeja de entrada organizada

### 4. Seguimiento de Notas Enviadas

**Actor**: Empleado municipal (emisor)
**Objetivo**: Verificar el estado de las notas que envio

**Flujo**:
1. Accede a la bandeja de notas enviadas
2. Visualiza listado con estado de lectura por destinatario
3. Identifica que sectores han leido la nota y cuales no

**Resultado**: Visibilidad completa del alcance de la comunicacion

### 5. Envio de Nota con Documentos Adjuntos

**Actor**: Empleado municipal
**Objetivo**: Comunicar informacion acompanada de documentacion oficial

**Flujo**:
1. Crea una nueva nota con asunto y cuerpo
2. Selecciona sectores destinatarios
3. Adjunta uno o mas documentos oficiales existentes en el sistema
4. Envia la nota con los adjuntos vinculados

**Resultado**: Nota enviada con documentos oficiales accesibles por los destinatarios

---

## Componentes del Modulo

### Interfaz de Usuario (Frontend)

| Componente | Descripcion |
|------------|-------------|
| **Bandeja de Entrada** | Listado de notas recibidas por el sector del usuario, con indicador de leida/sin leer |
| **Bandeja de Enviados** | Listado de notas enviadas por el usuario, con estado de lectura por destinatario |
| **Bandeja de Archivados** | Notas archivadas por el usuario para referencia futura |
| **Formulario de Creacion** | Interfaz para redactar nueva nota con selector de destinatarios y adjuntos |
| **Vista de Detalle** | Visualizacion completa de una nota con su cuerpo, adjuntos e historial |

### Logica de Negocio (Backend)

| Componente | Descripcion |
|------------|-------------|
| **Notes Service** | Gestion de creacion, envio y consulta de notas |
| **Recipients Manager** | Administracion de destinatarios y estados de lectura |
| **Attachments Handler** | Vinculacion de documentos oficiales a las notas |
| **Inbox/Outbox Engine** | Motor de bandejas con filtros y paginacion |

### Almacenamiento

| Recurso | Uso |
|---------|-----|
| **PostgreSQL** | Tablas `notes`, `note_recipients`, `note_attachments` |
| **Indices** | Optimizacion de consultas por sector, estado y fecha |

---

## Trazabilidad y Auditoria

### Campos de Auditoria

Todas las tablas del modulo incluyen:
- **`created_at`**: Timestamp de creacion del registro
- **`read_at`**: Timestamp de primera lectura (en destinatarios)
- **`archived_at`**: Timestamp de archivo
- **User tracking**: Identificacion del usuario emisor y sector

### Registro Completo

- Creacion: usuario emisor, sector, timestamp
- Envio: sectores destinatarios, fecha de envio
- Lectura: fecha y hora en que cada destinatario abrio la nota
- Archivo: fecha en que cada destinatario archivo la nota
