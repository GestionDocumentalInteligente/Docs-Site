# Modelo de Datos: Plantillas de Documentos y Expedientes

Este documento detalla la estructura de las tablas utilizadas para definir y gestionar las plantillas de documentos y expedientes en GDI.

---

## Tabla: `global_document_types`

**Proposito:** Funciona como un catalogo maestro de tipos de documentos estandar que pueden ser adoptados y utilizados por cualquier municipio en la plataforma. Vive en el schema `public`. Actualmente contiene 61 tipos globales (basados en el estandar GDE).

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `integer` | **PK** - Identificador unico de la plantilla global. |
| `name` | `varchar` | Nombre estandar del tipo de documento (ej. "Informe"). |
| `acronym` | `varchar` | Sigla estandar y unica (ej. "IF"). |
| `description` | `text` | Descripcion de la finalidad del tipo de documento. |
| `signature_type` | `varchar` | Tipo de firma requerida (required, optional). |
| `is_visible` | `boolean` | `true` si el tipo es visible para los usuarios. |
| `is_active` | `boolean` | `true` si la plantilla esta disponible para ser usada. |
| `type` | `document_type_source` | Tipo de fuente: HTML, Importado o NOTA. |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE public.global_document_types (
    id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    acronym VARCHAR(20) NOT NULL,
    description TEXT,
    signature_type VARCHAR(20),
    is_visible BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    type document_type_source NOT NULL DEFAULT 'HTML',
    audit_data JSONB,
    CONSTRAINT global_document_types_pkey PRIMARY KEY (id)
);
```

---

## Tabla: `document_types`

**Proposito:** Representa la implementacion local o especifica de un tipo de documento para un municipio. Hereda de una plantilla global y se configura localmente.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `integer` | **PK** - Identificador unico del tipo de documento local. |
| `global_document_type_id` | `integer` | **FK** - Referencia a una plantilla de `global_document_types`. |
| `name` | `varchar` | Nombre descriptivo que veran los usuarios en el municipio. |
| `acronym` | `varchar` | Sigla que se usara en la numeracion de documentos en el municipio. |
| `description` | `text` | Descripcion y uso especifico dentro del municipio. |
| `required_signature` | `required_signature_enum` | Define el nivel de firma requerido (electronica, digital). |
| `is_active` | `boolean` | `true` si el tipo esta activo y disponible para creacion. |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE document_types (
    id INTEGER NOT NULL,
    global_document_type_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    acronym VARCHAR(20) NOT NULL,
    description TEXT,
    required_signature required_signature_enum,
    is_active BOOLEAN DEFAULT true,
    audit_data JSONB,
    CONSTRAINT document_types_pkey PRIMARY KEY (id),
    CONSTRAINT document_types_global_fkey FOREIGN KEY (global_document_type_id)
        REFERENCES public.global_document_types (id)
);
```

---

## Tabla: `global_case_templates`

**Proposito:** Catalogo maestro de tipos de expedientes estandar. Vive en el schema `public`. Actualmente contiene 30 tipos globales.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico de la plantilla global. |
| `type_name` | `varchar` | Nombre del tipo de expediente (ej. "Habilitacion Comercial"). |
| `acronym` | `varchar(6)` | Sigla estandar y unica (ej. "HABI"). |
| `description` | `varchar(150)` | Descripcion del proposito del expediente. |
| `is_active` | `boolean` | `true` si la plantilla esta disponible. |
| `created_at` | `timestamptz` | Fecha de creacion. |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE public.global_case_templates (
    id UUID DEFAULT gen_random_uuid() NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    description VARCHAR(150),
    acronym VARCHAR(6) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    audit_data JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT global_case_templates_pkey PRIMARY KEY (id)
);
```

---

## Tabla: `case_templates`

**Proposito:** Implementacion local de plantillas de expedientes para un municipio. Define que tipos de expedientes se pueden crear, a traves de que canales, y que reparticion los administra.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico de la plantilla local. |
| `global_case_template_id` | `uuid` | **FK** - Referencia a `global_case_templates`. |
| `type_name` | `varchar` | Nombre del tipo de expediente en el municipio. |
| `acronym` | `varchar(6)` | Sigla unica para numeracion. |
| `description` | `text` | Descripcion local del tipo de expediente. |
| `creation_channel` | `case_creation_channel` | Canal de creacion permitido: web, api o both. |
| `filing_department_id` | `uuid` | **FK** - Reparticion cuya sigla aparece en la numeracion del expediente. |
| `is_active` | `boolean` | `true` si el tipo de expediente puede ser creado. |
| `created_at` | `timestamptz` | Fecha de creacion. |

```sql
CREATE TABLE case_templates (
    id UUID DEFAULT gen_random_uuid() NOT NULL,
    global_case_template_id UUID NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    acronym VARCHAR(6) NOT NULL,
    description TEXT,
    creation_channel case_creation_channel NOT NULL DEFAULT 'web',
    filing_department_id UUID NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT case_templates_pkey PRIMARY KEY (id),
    CONSTRAINT case_templates_acronym_unique UNIQUE (acronym),
    CONSTRAINT case_templates_global_fkey FOREIGN KEY (global_case_template_id)
        REFERENCES public.global_case_templates (id)
);
```

---

## Tabla: `case_template_allowed_departments`

**Proposito:** Define que reparticiones estan habilitadas para crear expedientes de un tipo determinado.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `case_template_id` | `uuid` | **PK, FK** - Referencia a la plantilla de expediente (`case_templates`). |
| `department_id` | `uuid` | **PK, FK** - Referencia a la reparticion habilitada (`departments`). |

```sql
CREATE TABLE case_template_allowed_departments (
    case_template_id UUID NOT NULL,
    department_id UUID NOT NULL,
    CONSTRAINT ctad_pkey PRIMARY KEY (case_template_id, department_id),
    CONSTRAINT ctad_case_template_fkey FOREIGN KEY (case_template_id)
        REFERENCES case_templates (id),
    CONSTRAINT ctad_department_fkey FOREIGN KEY (department_id)
        REFERENCES departments (id)
);
```
