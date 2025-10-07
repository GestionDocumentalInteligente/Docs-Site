# Estructuras de Datos - Módulo Expedientes

## 🗂️ Plantillas y Configuración

### Plantillas Globales
```sql
-- Plantillas base compartidas entre municipios
CREATE TABLE public.global_record_templates (
    -- Identificador único de la plantilla
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Nombre descriptivo del tipo (ej: "Expediente de Compras")
    type_name VARCHAR NOT NULL,
    
    -- Descripción detallada del propósito
    description VARCHAR(150),
    
    -- Sigla única para numeración (ej: "COMP")
    acronym VARCHAR(6) UNIQUE NOT NULL,
    
    -- Controla disponibilidad de la plantilla
    is_active BOOLEAN DEFAULT true,
    
    -- Auditoría básica
    created_at TIMESTAMPTZ DEFAULT NOW(),
    audit_data JSONB DEFAULT '{}'::jsonb
);

-- Implementaciones específicas por municipio
CREATE TABLE public.record_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    global_template_id UUID REFERENCES global_record_templates(id),
    type_name VARCHAR NOT NULL,
    description VARCHAR(150),
    acronym VARCHAR(6) UNIQUE NOT NULL,
    
    -- Determina cómo se pueden crear expedientes
    creation_channel VARCHAR CHECK (creation_channel IN ('web', 'api', 'both')) DEFAULT 'web',
    
    -- Sectores habilitados para usar la plantilla
    enabled_departments JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- Sector que define la sigla en numeración
    filing_department_id UUID NOT NULL,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    audit_data JSONB DEFAULT '{}'::jsonb
);
```

## 📑 Expedientes y Documentos

### Expedientes
```sql
-- Tabla principal de expedientes
CREATE TABLE public.records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    record_number VARCHAR UNIQUE NOT NULL,
    reference VARCHAR(250) NOT NULL,
    template_id UUID NOT NULL REFERENCES record_templates(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR CHECK (status IN ('inactive', 'active', 'archived')) DEFAULT 'inactive',
    
    
    -- Metadatos y auditoría
    audit_data JSONB DEFAULT '{}'::jsonb
);

-- Documentos oficiales vinculados
CREATE TABLE public.record_official_documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    record_id UUID NOT NULL REFERENCES records(id),
    official_document_id UUID NOT NULL REFERENCES official_documents(id),
    order_number INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY,
    linking_date TIMESTAMPTZ DEFAULT NOW(),
    linking_user_id UUID NOT NULL REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    deactivated_by_user_id UUID REFERENCES users(id),
    deactivated_at TIMESTAMPTZ,
    
    -- Mantiene orden único e incremental por expediente
    UNIQUE(record_id, order_number),
    -- Evita duplicados 
    UNIQUE(record_id, official_document_id)
);

-- Documentos propuestos/borradores
CREATE TABLE public.record_proposed_documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    record_id UUID NOT NULL REFERENCES records(id),
    document_draft_id UUID NOT NULL REFERENCES document_draft(id),
    proposing_date TIMESTAMPTZ DEFAULT NOW(),
    proposing_user_id UUID NOT NULL REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    
    -- Evita duplicados activos
    UNIQUE(record_id, document_draft_id, is_active)
);
```

### Movimientos > 02-Movimientos