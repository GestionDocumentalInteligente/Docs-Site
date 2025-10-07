# Modelo de Datos: Módulo de Documentos

Este documento detalla la estructura de las tablas principales que componen el módulo de Documentos en GDI, basado en el esquema de la base de datos.

---

## Tabla: `document_draft`

**Propósito:** Almacena los documentos mientras están en proceso de creación, edición o firma. Es la tabla de trabajo principal del módulo.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `document_id` | `uuid` | **PK** - Identificador único del documento. |
| `document_type_id` | `uuid` | **FK** - Referencia al tipo de documento (`document_types`). |
| `created_by` | `uuid` | **FK** - Usuario que creó el documento (`users`). |
| `reference` | `text` | Asunto o referencia principal del documento. |
| `content` | `jsonb` | Contenido completo del documento en formato JSON. |
| `status` | `document_status` | Estado actual del flujo (draft, sent_to_sign, signed, etc.). |
| `sent_to_sign_at` | `timestamp` | Fecha y hora en que se envió a firmar. |
| `last_modified_at`| `timestamp` | Última fecha de modificación. |
| `is_deleted` | `boolean` | Marca para borrado lógico (soft delete). |
| `audit_data` | `jsonb` | Metadatos de auditoría (quién creó, modificó, etc.). |
| `sent_by` | `uuid` | **FK** - Usuario que envió el documento a firmar (`users`). |
| `pad_id` | `varchar` | Identificador para la sesión de edición colaborativa. |

```sql
CREATE TABLE public.document_draft (
    document_id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_type_id uuid NOT NULL,
    created_by uuid NOT NULL,
    reference text NOT NULL,
    content jsonb NOT NULL,
    status public.document_status DEFAULT 'draft'::public.document_status NOT NULL,
    sent_to_sign_at timestamp without time zone,
    last_modified_at timestamp without time zone DEFAULT now(),
    is_deleted boolean DEFAULT false,
    audit_data jsonb,
    sent_by uuid,
    pad_id character varying(255) NOT NULL
);
```

---

## Tabla: `official_documents`

**Propósito:** Almacena la versión final y legalmente válida de los documentos que han completado el ciclo de firma y numeración.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `document_id` | `uuid` | **PK** - Identificador único del documento. |
| `document_type_id`| `uuid` | **FK** - Referencia al tipo de documento (`document_types`). |
| `numeration_requests_id` | `uuid` | **FK** - Referencia a la solicitud de numeración (`numeration_requests`). |
| `reference` | `varchar` | Asunto o referencia del documento. |
| `content` | `jsonb` | Contenido final y congelado del documento. |
| `official_number` | `varchar` | Número oficial asignado (ej. IF-2025-...). |
| `year` | `smallint` | Año de la numeración. |
| `department_id` | `uuid` | **FK** - Departamento que numera el documento (`departments`). |
| `numerator_id` | `uuid` | **FK** - Usuario que asignó el número oficial (`users`). |
| `signed_at` | `timestamp` | Fecha y hora de la firma final que oficializa el documento. |
| `signed_pdf_url` | `varchar` | URL al PDF firmado y almacenado. |
| `signers` | `jsonb` | JSON con los datos consolidados de todos los firmantes. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.official_documents (
    document_id uuid NOT NULL,
    document_type_id uuid NOT NULL,
    numeration_requests_id uuid NOT NULL,
    reference character varying(100) NOT NULL,
    content jsonb NOT NULL,
    official_number character varying(10) NOT NULL,
    year smallint NOT NULL,
    department_id uuid NOT NULL,
    numerator_id uuid NOT NULL,
    signed_at timestamp without time zone NOT NULL,
    signed_pdf_url character varying(255) NOT NULL,
    signers jsonb,
    audit_data jsonb
);
```

---

## Tabla: `document_signers`

**Propósito:** Gestiona la lista de usuarios que deben firmar un documento, su orden y el estado de su firma.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `document_signer_id` | `uuid` | **PK** - Identificador único de la asignación de firma. |
| `document_id` | `uuid` | **FK** - Documento al que pertenece la firma (`document_draft`). |
| `user_id` | `uuid` | **FK** - Usuario firmante (`users`). |
| `is_numerator` | `boolean` | `true` si este firmante es el que asigna el número oficial. |
| `signing_order` | `integer` | Orden secuencial de firma. `1` para el numerador. |
| `status` | `document_signer_status` | Estado de la firma individual (pending, signed, rejected). |
| `signed_at` | `timestamp` | Fecha y hora en que el usuario firmó. |
| `observations` | `text` | Comentarios u observaciones hechas por el firmante. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.document_signers (
    document_signer_id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid NOT NULL,
    user_id uuid NOT NULL,
    is_numerator boolean DEFAULT false,
    signing_order integer,
    status public.document_signer_status,
    signed_at timestamp without time zone,
    observations text,
    audit_data jsonb
);
```

---

## Tabla: `document_rejections`

**Propósito:** Registra un historial de todos los rechazos que ha tenido un documento durante el ciclo de firma.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `rejection_id` | `uuid` | **PK** - Identificador único del rechazo. |
| `document_id` | `uuid` | **FK** - Documento que fue rechazado (`document_draft`). |
| `rejected_by` | `uuid` | **FK** - Usuario que realizó el rechazo (`users`). |
| `reason` | `text` | Motivo o justificación del rechazo. |
| `rejected_at` | `timestamp` | Fecha y hora del rechazo. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

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

---

## Tabla: `document_types`

**Propósito:** Define las plantillas y reglas de negocio para cada tipo de documento que se puede crear en el municipio.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `document_type_id` | `uuid` | **PK** - Identificador único del tipo de documento. |
| `global_document_type_id` | `uuid` | **FK** - Referencia a una plantilla global (`global_document_types`). |
| `name` | `varchar` | Nombre descriptivo del tipo de documento (ej. "Informe Técnico"). |
| `acronym` | `varchar` | Sigla única para la nomenclatura (ej. "IF"). |
| `description` | `text` | Descripción del propósito del documento. |
| `required_signature` | `required_signature_enum` | Define el tipo de firma requerida (electrónica, digital, etc.). |
| `is_active` | `boolean` | `true` si el tipo de documento está disponible para ser usado. |
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

## Tabla: `numeration_requests`

**Propósito:** Gestiona la reserva y confirmación de números oficiales para garantizar la secuencialidad y unicidad.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `numeration_requests_id` | `uuid` | **PK** - Identificador único de la solicitud de numeración. |
| `document_type_id` | `uuid` | **FK** - Tipo de documento para el cual se solicita número. |
| `user_id` | `uuid` | **FK** - Usuario que solicita la numeración (el numerador). |
| `department_id` | `uuid` | **FK** - Departamento que emite el número. |
| `year` | `smallint` | Año de la secuencia de numeración. |
| `reserved_number` | `varchar` | Número secuencial reservado. |
| `reserved_at` | `timestamp` | Fecha y hora de la reserva. |
| `is_confirmed` | `boolean` | `true` si el número fue utilizado y confirmado. |
| `confirmed_at` | `timestamp` | Fecha y hora de la confirmación. |
| `validation_status` | `validation_status_enum` | Estado de la solicitud (pending, valid, invalid). |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.numeration_requests (
    numeration_requests_id uuid NOT NULL,
    document_type_id uuid NOT NULL,
    user_id uuid NOT NULL,
    department_id uuid NOT NULL,
    year smallint NOT NULL,
    reserved_number character varying(100) NOT NULL,
    reserved_at timestamp without time zone NOT NULL,
    is_confirmed boolean DEFAULT false NOT NULL,
    confirmed_at timestamp without time zone,
    validation_status public.validation_status_enum NOT NULL,
    audit_data jsonb
);
```

---

## Tipos ENUM

```sql
-- Estados posibles de un documento
CREATE TYPE document_status AS ENUM (
    'draft',        -- En edición
    'sent_to_sign', -- Enviado a firmar
    'signed',       -- Firmado completamente
    'rejected'      -- Rechazado por algún firmante
);

-- Estados de firma individual
CREATE TYPE document_signer_status AS ENUM (
    'pending',  -- Esperando firma
    'signed',   -- Firmado
    'rejected'  -- Rechazado
);

-- Tipos de firma requerida
CREATE TYPE required_signature_enum AS ENUM (
    'electronic', -- Firma electrónica 
    'digital'     -- Firma digital 
);

-- Estados de validación de numeración
CREATE TYPE validation_status_enum AS ENUM (
    'pending',  -- Pendiente de validación
    'valid',    -- Validado y confirmado
    'invalid'   -- Invalidado
);
```

## Constraints e Índices Importantes

```sql
-- Document Draft
ALTER TABLE public.document_draft
    ADD CONSTRAINT documents_pkey PRIMARY KEY (document_id),
    ADD CONSTRAINT fk_document_type FOREIGN KEY (document_type_id) 
        REFERENCES public.document_types(document_type_id),
    ADD CONSTRAINT fk_created_by FOREIGN KEY (created_by) 
        REFERENCES auth.users(id),
    ADD CONSTRAINT fk_sent_by FOREIGN KEY (sent_by) 
        REFERENCES auth.users(id);

-- Document Signers
ALTER TABLE public.document_signers
    ADD CONSTRAINT document_signers_pkey PRIMARY KEY (document_signer_id),
    ADD CONSTRAINT unique_signer_per_document UNIQUE (document_id, user_id),
    ADD CONSTRAINT fk_document FOREIGN KEY (document_id) 
        REFERENCES public.document_draft(document_id),
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) 
        REFERENCES auth.users(id);

CREATE INDEX idx_doc_signers_doc_user ON public.document_signers(document_id, user_id);
CREATE INDEX ix_doc_signers_doc ON public.document_signers(document_id);
CREATE INDEX ix_doc_signers_user ON public.document_signers(user_id);
```

## Triggers Principales

```sql
-- Proteger campos críticos en documentos enviados a firma
CREATE TRIGGER protect_draft_fields
    BEFORE UPDATE ON document_draft
    FOR EACH ROW
    WHEN (OLD.status = 'sent_to_sign')
    EXECUTE FUNCTION fn_protect_draft_fields();

-- Actualizar estado de documento al completar firmas
CREATE TRIGGER update_document_status
    AFTER UPDATE ON document_signers
    FOR EACH ROW
    WHEN (NEW.status = 'signed')
    EXECUTE FUNCTION fn_check_all_signatures();
```

## Estructura JSON de Contenido

### Contenido de Documento (`content`)
```json
{
  "version": "1.0",
  "template": "template_id",
  "title": "Título del documento",
  "body": {
    "sections": [
      {
        "id": "section1",
        "type": "text|table|list",
        "content": "Contenido de la sección"
      }
    ]
  },
  "metadata": {
    "created_at": "2025-08-30T10:00:00Z",
    "last_modified": "2025-08-30T11:30:00Z"
  }
}
```

### Datos de Auditoría (`audit_data`)
```json
{
  "created": {
    "at": "2025-08-30T10:00:00Z",
    "by": "user_uuid",
    "ip": "192.168.1.1"
  },
  "modifications": [
    {
      "at": "2025-08-30T11:30:00Z",
      "by": "user_uuid",
      "fields": ["content", "reference"],
      "ip": "192.168.1.1"
    }
  ]
}
```


