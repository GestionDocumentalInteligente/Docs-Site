# Modelo de Datos: Modulo de Documentos

Este documento detalla la estructura de las tablas principales que componen el modulo de Documentos en GDI, basado en el esquema de la base de datos.

---

## Tabla: `document_draft`

**Proposito:** Almacena los documentos mientras estan en proceso de creacion, edicion o firma. Es la tabla de trabajo principal del modulo.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico del documento. |
| `document_type_id` | `int` | **FK** - Referencia al tipo de documento (`document_types`). |
| `created_by` | `uuid` | **FK** - Usuario que creo el documento (`users`). |
| `reference` | `varchar(100)` | Asunto o referencia principal del documento. |
| `content` | `jsonb` | Contenido completo del documento en formato JSON. |
| `status` | `document_status` | Estado actual del flujo (draft, sent_to_sign, signed, rejected). |
| `sent_to_sign_at` | `timestamptz` | Fecha y hora en que se envio a firmar. |
| `last_modified_at` | `timestamptz` | Ultima fecha de modificacion. |
| `is_deleted` | `boolean` | Marca para borrado logico (soft delete). |
| `audit_data` | `jsonb` | Metadatos de auditoria (quien creo, modifico, etc.). |
| `sent_by` | `uuid` | **FK** - Usuario que envio el documento a firmar (`users`). |
| `resume` | `text` | Resumen libre del documento. |

```sql
CREATE TABLE document_draft (
    id UUID DEFAULT gen_random_uuid() NOT NULL,
    document_type_id INT NOT NULL,
    created_by UUID NOT NULL,
    reference VARCHAR(100) NOT NULL,
    content JSONB NOT NULL,
    status document_status DEFAULT 'draft' NOT NULL,
    sent_to_sign_at TIMESTAMPTZ,
    last_modified_at TIMESTAMPTZ DEFAULT NOW(),
    is_deleted BOOLEAN DEFAULT false,
    audit_data JSONB,
    sent_by UUID,
    resume TEXT,
    CONSTRAINT documents_pkey PRIMARY KEY (id)
);
```

---

## Tabla: `official_documents`

**Proposito:** Almacena la version final y legalmente valida de los documentos que han completado el ciclo de firma y numeracion.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico del documento. |
| `document_type_id` | `int` | **FK** - Referencia al tipo de documento (`document_types`). |
| `reference` | `varchar(100)` | Asunto o referencia del documento. |
| `content` | `jsonb` | Contenido final y congelado del documento. |
| `official_number` | `varchar(50)` | Numero oficial asignado (ej. IF-2025-000001-TNV-DGCO). |
| `year` | `smallint` | Anio de la numeracion. |
| `department_id` | `uuid` | **FK** - Departamento que numera el documento (`departments`). |
| `numerator_id` | `uuid` | **FK** - Usuario que asigno el numero oficial (`users`). |
| `signed_at` | `timestamptz` | Fecha y hora de la firma final que oficializa el documento. |
| `signers` | `jsonb` | JSON con los datos consolidados de todos los firmantes. |
| `global_sequence` | `int` | Numero secuencial global unico por municipio (asignado con advisory lock). |
| `signer_sector_ids` | `uuid[]` | Array de sector_ids de todos los firmantes (para busqueda eficiente). |
| `resume` | `text` | Resumen libre del documento (copiado desde draft al firmar). |
| `created_at` | `timestamptz` | Fecha de creacion del registro. |

```sql
CREATE TABLE official_documents (
    id UUID NOT NULL,
    document_type_id INT NOT NULL,
    reference VARCHAR(100) NOT NULL,
    content JSONB NOT NULL,
    official_number VARCHAR(50) NOT NULL,
    year SMALLINT NOT NULL,
    department_id UUID NOT NULL,
    numerator_id UUID NOT NULL,
    signed_at TIMESTAMPTZ NOT NULL,
    signers JSONB,
    global_sequence INT,
    signer_sector_ids UUID[],
    resume TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT official_documents_pkey PRIMARY KEY (id)
);
```

### Mecanismo de Numeracion: `global_sequence` y Advisory Lock

La columna `global_sequence` en `official_documents` es un numero secuencial unico por schema (municipio) que se asigna al firmar un documento. Para garantizar la unicidad bajo concurrencia, el sistema utiliza un **advisory lock** de PostgreSQL con el ID `888888`:

```python
# En GDI-Backend/shared/numbering.py
OFFICIAL_DOCUMENTS_LOCK_ID = 888888

# El proceso de numeracion:
# 1. Se adquiere pg_advisory_xact_lock(888888)
# 2. Se lee el MAX(global_sequence) del schema
# 3. Se asigna el siguiente numero
# 4. Se libera el lock al finalizar la transaccion
```

Esto previene race conditions cuando multiples usuarios firman documentos simultaneamente.

---

## Tabla: `document_signers`

**Proposito:** Gestiona la lista de usuarios que deben firmar un documento, su orden y el estado de su firma.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico de la asignacion de firma. |
| `document_id` | `uuid` | **FK** - Documento al que pertenece la firma (`document_draft`). |
| `user_id` | `uuid` | **FK** - Usuario firmante (`users`). |
| `is_numerator` | `boolean` | `true` si este firmante es el que asigna el numero oficial. |
| `signing_order` | `integer` | Orden secuencial de firma. `1` para el numerador. |
| `status` | `document_signer_status` | Estado de la firma individual (pending, signed, rejected). |
| `signed_at` | `timestamptz` | Fecha y hora en que el usuario firmo. |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE document_signers (
    id UUID DEFAULT gen_random_uuid() NOT NULL,
    document_id UUID NOT NULL,
    user_id UUID NOT NULL,
    is_numerator BOOLEAN DEFAULT false,
    signing_order INTEGER,
    status document_signer_status,
    signed_at TIMESTAMPTZ,
    audit_data JSONB,
    CONSTRAINT document_signers_pkey PRIMARY KEY (id),
    CONSTRAINT unique_signer_per_document UNIQUE (document_id, user_id)
);
```

---

## Tabla: `document_rejections`

**Proposito:** Registra un historial de todos los rechazos que ha tenido un documento durante el ciclo de firma.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `rejection_id` | `uuid` | **PK** - Identificador unico del rechazo. |
| `document_id` | `uuid` | **FK** - Documento que fue rechazado (`document_draft`). |
| `rejected_by` | `uuid` | **FK** - Usuario que realizo el rechazo (`users`). |
| `reason` | `text` | Motivo o justificacion del rechazo. |
| `rejected_at` | `timestamptz` | Fecha y hora del rechazo. |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE document_rejections (
    rejection_id UUID DEFAULT gen_random_uuid() NOT NULL,
    document_id UUID NOT NULL,
    rejected_by UUID NOT NULL,
    reason TEXT,
    rejected_at TIMESTAMPTZ DEFAULT NOW(),
    audit_data JSONB,
    CONSTRAINT document_rejections_pkey PRIMARY KEY (rejection_id)
);
```

---

## Tabla: `document_chunks`

**Proposito:** Almacena fragmentos (chunks) de documentos oficiales con sus embeddings vectoriales para busqueda semantica (RAG). Utiliza la extension pgvector.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico del chunk. |
| `official_document_id` | `uuid` | **FK** - Documento oficial al que pertenece (`official_documents`). |
| `chunk_index` | `integer` | Indice secuencial del chunk dentro del documento. |
| `chunk_text` | `text` | Texto del fragmento. |
| `embedding` | `vector(1536)` | Vector de embedding generado por el modelo de IA. |
| `embedding_model` | `varchar(100)` | Modelo usado para generar el embedding (default: `text-embedding-3-small`). |
| `indexed_at` | `timestamptz` | Fecha y hora en que se genero el embedding. |

```sql
CREATE TABLE document_chunks (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    official_document_id UUID NOT NULL,
    chunk_index INTEGER NOT NULL,
    chunk_text TEXT NOT NULL,
    embedding vector(1536),
    embedding_model VARCHAR(100) NOT NULL DEFAULT 'text-embedding-3-small',
    indexed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT document_chunks_pkey PRIMARY KEY (id),
    CONSTRAINT document_chunks_official_fkey FOREIGN KEY (official_document_id)
        REFERENCES official_documents (id),
    CONSTRAINT document_chunks_unique UNIQUE (official_document_id, chunk_index)
);
```

---

## Tablas de Notas

Las notas son documentos oficiales con destinatarios (TO/CC/BCC) y tracking de lectura. El documento en si se almacena en `document_draft` / `official_documents` con tipo NOTA. Las siguientes tablas gestionan los destinatarios y el tracking.

### Tabla: `notes_recipients`

**Proposito:** Define los sectores destinatarios de una nota oficial, con tipo de destinatario (TO, CC, BCC) y soporte para archivado.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico. |
| `document_id` | `uuid` | **FK** - Documento de la nota (`document_draft`). |
| `sector_id` | `uuid` | **FK** - Sector destinatario (`sectors`). |
| `recipient_type` | `varchar(3)` | Tipo de destinatario: `TO`, `CC` o `BCC`. |
| `sender_sector_id` | `uuid` | **FK** - Sector que envio la nota (`sectors`). |
| `is_archived` | `boolean` | `true` si el destinatario archivo la nota. |
| `archived_at` | `timestamptz` | Fecha y hora de archivado. |

```sql
CREATE TABLE notes_recipients (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL,
    sector_id UUID NOT NULL,
    recipient_type VARCHAR(3) NOT NULL,
    sender_sector_id UUID NOT NULL,
    is_archived BOOLEAN NOT NULL DEFAULT false,
    archived_at TIMESTAMPTZ NULL,
    CONSTRAINT notes_recipients_pkey PRIMARY KEY (id),
    CONSTRAINT notes_recipients_document_fkey FOREIGN KEY (document_id)
        REFERENCES document_draft (id),
    CONSTRAINT notes_recipients_type_check CHECK (recipient_type IN ('TO', 'CC', 'BCC')),
    CONSTRAINT notes_recipients_unique UNIQUE (document_id, sector_id)
);
```

### Tabla: `notes_openings`

**Proposito:** Registra cuando un usuario abre/lee una nota recibida. Tracking simple de si/no leyo.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico. |
| `document_id` | `uuid` | **FK** - Documento de la nota (`document_draft`). |
| `sector_id` | `uuid` | **FK** - Sector del usuario que abrio la nota (`sectors`). |
| `user_id` | `uuid` | **FK** - Usuario que abrio la nota (`users`). |
| `opened_at` | `timestamptz` | Fecha y hora de apertura. |

```sql
CREATE TABLE notes_openings (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL,
    sector_id UUID NOT NULL,
    user_id UUID NOT NULL,
    opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT notes_openings_pkey PRIMARY KEY (id),
    CONSTRAINT notes_openings_document_fkey FOREIGN KEY (document_id)
        REFERENCES document_draft (id),
    CONSTRAINT notes_openings_unique UNIQUE (document_id, user_id)
);
```

---

## Tipos ENUM

```sql
-- Estados posibles de un documento
CREATE TYPE document_status AS ENUM (
    'draft',        -- En edicion
    'sent_to_sign', -- Enviado a firmar
    'signed',       -- Firmado completamente
    'rejected'      -- Rechazado por algun firmante
);

-- Estados de firma individual
CREATE TYPE document_signer_status AS ENUM (
    'pending',  -- Esperando firma
    'signed',   -- Firmado
    'rejected'  -- Rechazado
);

-- Tipos de firma requerida
CREATE TYPE required_signature_enum AS ENUM (
    'electronic', -- Firma electronica
    'digital'     -- Firma digital (PAdES)
);

-- Estados de validacion de numeracion
CREATE TYPE validation_status_enum AS ENUM (
    'pending',  -- Pendiente de validacion
    'valid',    -- Validado y confirmado
    'invalid'   -- Invalidado
);
```

## Indices Importantes

```sql
-- Document Draft
CREATE INDEX idx_document_draft_created_by ON document_draft(created_by);
CREATE INDEX idx_document_draft_type ON document_draft(document_type_id);
CREATE INDEX idx_document_draft_created_by_at ON document_draft(created_by, created_at DESC);

-- Document Signers
CREATE INDEX idx_doc_signers_doc ON document_signers(document_id);
CREATE INDEX idx_doc_signers_user ON document_signers(user_id);
CREATE INDEX idx_doc_signers_status ON document_signers(status);

-- Official Documents
CREATE INDEX idx_official_docs_number ON official_documents(official_number);
CREATE INDEX idx_official_docs_signed_at ON official_documents(signed_at DESC);
CREATE INDEX idx_official_docs_department ON official_documents(department_id);
CREATE INDEX idx_official_docs_signer_sectors ON official_documents
    USING GIN (signer_sector_ids);

-- Notes
CREATE INDEX idx_notes_recipients_document ON notes_recipients(document_id);
CREATE INDEX idx_notes_recipients_sector ON notes_recipients(sector_id);
CREATE INDEX idx_notes_recipients_sender ON notes_recipients(sender_sector_id);
CREATE INDEX idx_notes_recipients_not_archived ON notes_recipients(sector_id)
    WHERE is_archived = false;
CREATE INDEX idx_notes_openings_document ON notes_openings(document_id);
```

## Estructura JSON de Contenido

### Contenido de Documento (`content`)
```json
{
  "version": "1.0",
  "template": "template_id",
  "title": "Titulo del documento",
  "body": {
    "sections": [
      {
        "id": "section1",
        "type": "text|table|list",
        "content": "Contenido de la seccion"
      }
    ]
  },
  "metadata": {
    "created_at": "2025-08-30T10:00:00Z",
    "last_modified": "2025-08-30T11:30:00Z"
  }
}
```

### Datos de Auditoria (`audit_data`)
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
