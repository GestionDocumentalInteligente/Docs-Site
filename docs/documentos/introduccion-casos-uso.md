# 📋 Módulo Documentos GDI - Introducción y Casos de Uso

## ¿Qué es el Módulo Documentos?

El módulo de **Documentos** es el **corazón de GDI**, diseñado para la **creación, gestión, colaboración y formalización** de documentos electrónicos con **plena validez legal**. Se divide en dos aspectos clave: su **configuración en el Backoffice** y su **uso operativo** por parte de los usuarios.

### Definición de Documento en GDI

Un **Documento** es cualquier entidad digitalizada que contiene información estructurada o no estructurada (texto, imágenes, tablas, etc.), generada o incorporada al sistema, con un propósito definido y que puede **adquirir validez legal** mediante procesos de firma y numeración.

Es la unidad fundamental de información sobre la cual se construyen los expedientes y las comunicaciones oficiales.

## 🎯 Propuesta de Valor Técnica

### Características Diferenciadoras

- **📝 Editor Colaborativo Nativo**: Múltiples usuarios pueden editar simultáneamente el mismo documento en tiempo real
- **🔄 Gestión Inteligente de Rechazos**: Sistema robusto de correcciones y mejoras iterativas
- **🗄️ Preservación de Integridad**: Eliminación lógica que mantiene trazabilidad histórica
- **⚖️ Validez Legal Garantizada**: Solo documentos en estado `signed` tienen plena validez jurídica
- **🏛️ Integración Organizacional**: Respeta la estructura de departments y jerarquías municipales

### Arquitectura Dual de Documentos

El sistema implementa una **separación clara** entre documentos en proceso y documentos oficiales:

**`document_draft`** → Documentos en creación, edición y firma  
**`official_documents`** → Documentos finalizados con validez legal

---

## 📖 Diccionario de Campos Clave: Documentos

Para entender mejor el ciclo de vida de un documento, estos son algunos de los campos más importantes de la base de datos y lo que representan para el negocio:

*   **`document_draft.status`**: Representa la etapa exacta del ciclo de vida del documento (`Borrador`, `Enviado a Firmar`, `Firmado`, etc.) y es lo que determina qué acciones puede o no puede hacer un usuario en la pantalla.

*   **`document_signers.is_numerator`**: Este campo booleano (`true`/`false`) es crucial porque marca al firmante que tiene la responsabilidad final de oficializar el documento y asignarle un número. No es un firmante más, es quien cierra el proceso.

*   **La diferencia entre `created_by` y `sent_by`**: Es importante distinguirlos para la auditoría. `created_by` es el autor intelectual del borrador, mientras que `sent_by` es el usuario que toma la responsabilidad de iniciar formalmente el circuito de firmas (pueden ser personas distintas).

---

## 🔄 Estados del Documento - Implementación Real

### Estados Principales
```
📝 draft → 📤 sent_to_sign → ✅ signed → 📦 archived
   ↓           ↓              ↑
   🗑️ deleted  ❌ rejected → 🔄 (corrección)
               ↓
              🚫 cancelled
```

### Descripción de Estados

| Estado | Descripción | Acciones Permitidas |
|--------|-------------|-------------------|
| **`draft`** | En edición colaborativa | Editar contenido, asignar firmantes |
| **`sent_to_sign`** | Enviado al circuito de firmas | Firmar, rechazar, observaciones |
| **`signed`** | Firmado y con validez legal | Solo lectura, descarga, archivo |
| **`rejected`** | Rechazado por algún firmante | Revisar motivos, corregir, reenviar |
| **`cancelled`** | Cancelado antes de completar | Solo consulta histórica |
| **`archived`** | Archivado post-finalización | Solo consulta, no modificable |



## ❌ Gestión de Rechazos y Correcciones

### Sistema de Rechazos (`document_rejections`)

Cuando un firmante rechaza un documento:

1. **📋 Registro del rechazo** con motivo detallado
2. **🔄 Cambio de estado** a `rejected`
3. **📧 Notificación** al creador y equipo
4. **🛠️ Proceso de corrección** habilitado

### Tabla de Rechazos
```sql
CREATE TABLE public.document_rejections (
    rejection_id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid NOT NULL,
    rejected_by uuid NOT NULL,
    reason text,
    rejected_at timestamp without time zone DEFAULT now(),
    audit_data jsonb
);
```

## 📊 Casos de Uso Principales

### 1. Creación de Documento Colaborativo

**Actor**: Empleado municipal  
**Objetivo**: Crear documento oficial con colaboración de equipo

**Flujo**:
1. Selecciona tipo de documento para su confección
2. Define referencia/motivo del documento
3. Edita el contenido con el editor de texto enriquecido
4. Finaliza contenido y configura firmantes

**Resultado**: Documento en estado `draft` listo para firma

### 2. Proceso de Firma Secuencial

**Actor**: Firmantes asignados
**Objetivo**: Formalizar documento con firmas digitales ordenadas

**Flujo**:
1. Documento llega con estado `sent_to_sign`
2. Firmante revisa contenido y preview con marca de agua "BORRADOR"
3. Decide: Firmar o Rechazar
4. Si firma: GDI-Notary (:8001) aplica firma digital (pyHanko PAdES/CAdES) con firma visual
5. Si rechaza: ingresa observaciones, documento vuelve a `draft` (historial en `document_rejections`)
6. Sistema progresa al siguiente firmante segun `signing_order`

**Resultado**: Documento `signed` o `rejected`

### 3. Gestión de Rechazo y Corrección

**Actor**: Creador del documento  
**Objetivo**: Corregir documento rechazado

**Flujo**:
1. Recibe notificación de rechazo
2. Revisa motivos en `document_rejections`
3. Reactiva editor colaborativo
4. Realiza correcciones necesarias
5. Reenvía a circuito de firmas

**Resultado**: Nueva versión mejorada del documento

### 4. Numeracion y Oficializacion

**Actor**: Numerador (ultimo firmante)
**Objetivo**: Asignar numero oficial y finalizar

**Flujo**:
1. Recibe documento para numeracion final
2. Sistema reserva numero en `numeration_requests` (advisory lock 888888, global_sequence compartida)
3. Firma y confirma numeracion
4. GDI-PDFComposer (:8002) genera el PDF final con estilos institucionales
5. GDI-Notary (:8001) aplica firma digital (pyHanko PAdES/CAdES) con firma visual (logo, fecha, numero, nombre)
6. PDF firmado se almacena en bucket `oficial` de Cloudflare R2
7. Genera `official_documents` entry con `signed_pdf_url`

**Resultado**: Documento con validez legal plena

### 5. Consulta de Documentos Oficiales

**Actor**: Empleado municipal o ciudadano
**Objetivo**: Acceder a documento oficial

**Flujo**:
1. Busca por numero oficial o criterios
2. Sistema valida permisos de acceso
3. Muestra documento desde `official_documents`
4. Genera URL firmada temporal para descarga segura del PDF desde Cloudflare R2

**Resultado**: Acceso controlado a documento oficial

## 🔧 Componentes Técnicos Principales

### Motor de Edición
- **Document Editor Engine**: Editor enriquecido colaborativo
- **Pad Synchronization Service**: Sincronización en tiempo real

### Gestión de Firmas
- **Signing Workflow Orchestrator**: Orquestador del flujo de firmas secuencial
- **GDI-Notary (:8001)**: Servicio de firma digital con pyHanko (PAdES/CAdES)
- **Firma Visual**: Logo institucional, fecha, numero oficial y nombre del firmante estampados en el PDF

### Generacion PDF
- **GDI-PDFComposer (:8002)**: Generacion de PDF via Gotenberg (headless Chrome)
- **HTML a PDF**: Conversion con estilos institucionales
- **Marca de agua**: "BORRADOR" en previews antes del envio a firma

### Almacenamiento
- **Cloudflare R2** (S3-compatible): Almacenamiento de documentos
- **Bucket `tosign`**: PDFs de preview/borrador
- **Bucket `oficial`**: Documentos firmados con validez legal
- **URLs firmadas**: Descarga segura con URLs temporales

### Numeracion Oficial
- **Servicio de numeracion secuencial**: global_sequence compartida entre todos los tipos de documento
- **Advisory lock 888888**: Prevencion de race conditions en asignacion de numeros

### Inteligencia Artificial
- **AI Drafting Assistant (Terra)**: Asistente para redacción
- **Content Analysis**: Análisis y sugerencias de contenido

## 🔍 Trazabilidad y Auditoría

### Campos de Auditoría

Todas las tablas incluyen:
- **`audit_data`** (JSONB): Metadatos de cambios
- **Timestamps**: Creación, modificación, firma
- **User tracking**: Quién realizó cada acción

### Historial Completo

- ✅ **Creación**: Usuario, timestamp, department
- ✅ **Ediciones**: Cambios en editor colaborativo
- ✅ **Firmas**: Orden, timestamps, certificados
- ✅ **Rechazos**: Motivos, usuarios, correcciones
- ✅ **Numeración**: Proceso oficial, validaciones

## 🎖️ Validez Legal

### Requisitos para Validez Legal

Un documento alcanza **plena validez legal** cuando:

1. ✅ **Estado**: `signed`
2. ✅ **Número oficial**: Asignado en `official_documents`
3. ✅ **Numerador**: Firmado por usuario autorizado
4. ✅ **PDF firmado**: Generado y almacenado
5. ✅ **Trazabilidad**: Historial completo de firmas

### Formato de Número Oficial

```
<TIPO>-<AAAA>-<NNNNNN>-<SIGLA_ECO>-<SIGLA_DEPARTMENT>
```

**Ejemplo**: `DECRE-2025-000123-TN-INTEN`
- DECRE: Tipo (Decreto)
- 2025: Año
- 000123: Número correlativo
- TN: Municipio (Terranova)
- INTEN: Department numerador (Intendencia)

## 🚀 Beneficios del Sistema

### Para Empleados Municipales
- **⚡ Colaboración eficiente**: Editor en tiempo real
- **🔄 Proceso claro**: Estados y flujos definidos
- **❌ Gestión de errores**: Sistema robusto de correcciones

### Para la Municipalidad
- **⚖️ Validez legal garantizada**: Cumplimiento normativo
- **📊 Trazabilidad completa**: Auditoría total del proceso
- **💰 Eficiencia operativa**: Reducción de tiempos y errores
- **🔐 Seguridad robusta**: Control de acceso granular

### Para los Ciudadanos
- **🔍 Transparencia**: Acceso controlado a documentos públicos
- **⏱️ Agilidad**: Procesos más rápidos
- **✅ Confiabilidad**: Documentos con validez legal certificada

---