# Estructuras de Datos - Modulo Expedientes

## Plantillas y Configuracion

### Plantillas Globales

```sql
-- Plantillas base compartidas entre municipios (schema public)
CREATE TABLE public.global_case_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL,
    description VARCHAR(150),
    acronym VARCHAR(6) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    audit_data JSONB DEFAULT '{}'::jsonb
);

-- Implementaciones especificas por municipio (schema del tenant)
CREATE TABLE case_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    global_case_template_id UUID NOT NULL
        REFERENCES public.global_case_templates(id),
    type_name VARCHAR(100) NOT NULL,
    acronym VARCHAR(6) UNIQUE NOT NULL,
    description TEXT,
    creation_channel case_creation_channel NOT NULL DEFAULT 'web',
    filing_department_id UUID NOT NULL REFERENCES departments(id),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reparticiones habilitadas para crear cada tipo de expediente
CREATE TABLE case_template_allowed_departments (
    case_template_id UUID NOT NULL REFERENCES case_templates(id),
    department_id UUID NOT NULL REFERENCES departments(id),
    PRIMARY KEY (case_template_id, department_id)
);
```

## Expedientes y Documentos

### Expedientes

```sql
-- Tabla principal de expedientes
CREATE TABLE cases (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    case_number VARCHAR(50) UNIQUE NOT NULL,
    reference VARCHAR(250) NOT NULL,
    status status_case NOT NULL DEFAULT 'inactive',
    case_template_id UUID NOT NULL REFERENCES case_templates(id),
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    owner_department_id UUID NOT NULL REFERENCES departments(id),
    owner_sector_id UUID REFERENCES sectors(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ai_summary TEXT,
    ai_summary_updated_at TIMESTAMPTZ
);
```

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico del expediente. |
| `case_number` | `varchar(50)` | Numero de expediente unico (ej. EE-2025-000001-TNV-DGCO). |
| `reference` | `varchar(250)` | Asunto o caratula del expediente. |
| `status` | `status_case` | Estado del expediente: inactive, active, archived. |
| `case_template_id` | `uuid` | **FK** - Tipo de expediente (`case_templates`). |
| `created_by_user_id` | `uuid` | **FK** - Usuario que creo el expediente (`users`). |
| `owner_department_id` | `uuid` | **FK** - Reparticion administradora actual (`departments`). |
| `owner_sector_id` | `uuid` | **FK** - Sector administrador actual (`sectors`). |
| `created_at` | `timestamptz` | Fecha de creacion. |
| `ai_summary` | `text` | Resumen generado por IA del contenido del expediente. |
| `ai_summary_updated_at` | `timestamptz` | Ultima actualizacion del resumen IA. |

### Documentos Oficiales Vinculados

```sql
CREATE TABLE case_official_documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    case_id UUID NOT NULL REFERENCES cases(id),
    official_document_id UUID NOT NULL REFERENCES official_documents(id),
    linking_user_id UUID NOT NULL REFERENCES users(id),
    order_number INT NOT NULL,
    linking_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT true,
    deactivated_at TIMESTAMPTZ,
    deactivated_by_user_id UUID REFERENCES users(id)
);
```

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico. |
| `case_id` | `uuid` | **FK** - Expediente al que se vincula (`cases`). |
| `official_document_id` | `uuid` | **FK** - Documento oficial vinculado (`official_documents`). |
| `linking_user_id` | `uuid` | **FK** - Usuario que realizo la vinculacion. |
| `order_number` | `int` | Numero de orden dentro del expediente. |
| `linking_date` | `timestamptz` | Fecha de vinculacion. |
| `is_active` | `boolean` | `true` si la vinculacion esta activa. |
| `deactivated_at` | `timestamptz` | Fecha de desactivacion (si aplica). |
| `deactivated_by_user_id` | `uuid` | Usuario que desactivo la vinculacion. |

### Documentos Propuestos/Borradores

```sql
CREATE TABLE case_proposed_documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    case_id UUID NOT NULL REFERENCES cases(id),
    document_draft_id UUID NOT NULL REFERENCES document_draft(id),
    proposing_user_id UUID NOT NULL REFERENCES users(id),
    proposing_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT true
);
```

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico. |
| `case_id` | `uuid` | **FK** - Expediente al que se propone el documento (`cases`). |
| `document_draft_id` | `uuid` | **FK** - Borrador propuesto (`document_draft`). |
| `proposing_user_id` | `uuid` | **FK** - Usuario que propuso el documento. |
| `proposing_date` | `timestamptz` | Fecha de la propuesta. |
| `is_active` | `boolean` | `true` si la propuesta esta activa. |
