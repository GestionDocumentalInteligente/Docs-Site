# Modelo de Datos: Plantillas de Documentos y Expedientes

Este documento detalla la estructura de las tablas utilizadas para definir y gestionar las plantillas de documentos y expedientes en GDI.

---

## Tabla: `global_document_types`

**Propósito:** Funciona como un catálogo maestro de tipos de documentos estándar que pueden ser adoptados y utilizados por cualquier municipio en la plataforma. Promueve la estandarización.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `global_document_type_id` | `uuid` | **PK** - Identificador único de la plantilla global. |
| `name` | `varchar` | Nombre estándar del tipo de documento (ej. "Informe"). |
| `acronym` | `varchar` | Sigla estándar y única (ej. "IF"). |
| `description` | `text` | Descripción de la finalidad del tipo de documento. |
| `is_active` | `boolean` | `true` si la plantilla está disponible para ser usada. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.global_document_types (
    global_document_type_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    acronym character varying(20) NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    audit_data jsonb
);
```

---

## Tabla: `document_types`

**Propósito:** Representa la implementación local o específica de un tipo de documento para un municipio. Puede heredar de una plantilla global o ser una definición completamente nueva y personalizada.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `document_type_id` | `uuid` | **PK** - Identificador único del tipo de documento local. |
| `global_document_type_id` | `uuid` | **FK** - Referencia opcional a una plantilla de `global_document_types`. |
| `name` | `varchar` | Nombre descriptivo que verán los usuarios en el municipio. |
| `acronym` | `varchar` | Sigla que se usará en la numeración de documentos en el municipio. |
| `description` | `text` | Descripción y uso específico dentro del municipio. |
| `required_signature` | `required_signature_enum` | Define el nivel de firma requerido (electrónica, digital, etc.). |
| `is_active` | `boolean` | `true` si el tipo está activo y disponible para creación. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.document_types (
    document_type_id uuid NOT NULL,
    global_document_type_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    acronym character varying(20) NOT NULL,
    description text,
    required_signature public.required_signature_enum,
    is_active boolean DEFAULT true,
    audit_data jsonb
);
```

---

## Tabla: `tipos_expediente` (Schema: arg_terranova)

**Propósito:** Define los diferentes tipos de expedientes o trámites que se pueden iniciar y gestionar en el sistema, junto con sus reglas de negocio.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador único del tipo de expediente. |
| `tipo_expediente` | `varchar` | Nombre completo del tipo de trámite (ej. "Licitación Pública"). |
| `detalle` | `text` | Descripción sobre el propósito y alcance del expediente. |
| `tipo_inicio` | `tipo_inicio_enum` | Define si el trámite es `interno` o `externo`. |
| `habilitada_caratular` | `jsonb` | JSON que define qué reparticiones pueden crear este expediente. |
| `id_reparticion_caratuladora` | `uuid` | **FK** - Repartición que administra y cuya sigla aparece en el número de expediente. |
| `activo` | `boolean` | `true` si este tipo de expediente puede ser creado. |
| `fecha_creacion` | `timestamp` | Fecha de creación del registro. |

```sql
CREATE TABLE arg_terranova.tipos_expediente (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tipo_expediente character varying(140) NOT NULL,
    detalle text,
    tipo_inicio public.tipo_inicio_enum NOT NULL,
    habilitada_caratular jsonb,
    id_reparticion_caratuladora uuid,
    activo boolean DEFAULT true,
    fecha_creacion timestamp without time zone DEFAULT now()
);
```
