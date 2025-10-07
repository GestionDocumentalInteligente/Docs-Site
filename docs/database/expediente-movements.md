# Sistema de Movimientos - Módulo Expedientes

## Tipos de Movimiento

```sql
-- Enum para tipos de movimiento
CREATE TYPE movement_type AS ENUM (
    'creation',          -- Creación inicial del expediente
    'transfer',          -- Transferencia a otro sector administrador
    'assignment',        -- Asignación de permisos a sector
    'status_change'      -- Cambio de estado del expediente

);

-- Tabla para etiquetas en español
CREATE TABLE movement_labels (
    movement_type movement_type PRIMARY KEY,
    display_name VARCHAR NOT NULL
);

INSERT INTO movement_labels (movement_type, display_name) VALUES
    ('creation', 'Creación'),
    ('transfer', 'Transferencia'),
    ('assignment', 'Asignación'),
    ('status_change', 'Cambio de Estado');
```

## Estructura de Movimientos

```sql
CREATE TABLE public.record_movements (
    -- Identificación
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    record_id UUID NOT NULL REFERENCES records(id),
    movement_type movement_type NOT NULL,
    
    -- Quién realizó el movimiento
    user_id UUID REFERENCES users(id),
    external_user_id UUID REFERENCES external_users(id),
    
    -- Sectores involucrados
    creator_sector_id UUID NOT NULL REFERENCES departments(id),
    admin_sector_id UUID NOT NULL REFERENCES departments(id),
    assigned_sector_id UUID REFERENCES departments(id),
    
    -- Usuario asignado
    assigned_user_id UUID REFERENCES users(id),
    
    -- Fechas y estados
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    closed_at TIMESTAMPTZ,
    closing_reason VARCHAR(100),
    closed_by UUID REFERENCES users(id),
    
    -- Documento respaldatorio
    supporting_document_id UUID REFERENCES official_documents(id),
    
    -- Motivo del movimiento
    reason VARCHAR(100) NOT NULL,
    
    -- Datos de auditoría
    audit JSONB NOT NULL DEFAULT '{}'::jsonb
);
```

## Ejemplos de Movimientos

### 1. Creación de Expediente
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "record_id": "550e8400-e29b-41d4-a716-446655440010",
  "movement_type": "creation",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "external_user_id": null,
  "creator_sector_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "admin_sector_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "assigned_sector_id": null,
  "assigned_user_id": null,
  "created_at": "2025-08-26T09:15:00Z",
  "is_active": false,
  "closed_at": "2025-08-26T09:15:01Z",
  "closing_reason": "Creación completada automáticamente",
  "closed_by": "SYSTEM",
  "supporting_document_id": "550e8400-e29b-41d4-a716-446655440099",
  "reason": "Cargar documentación",
  "audit": {
    "template_used": "LICPUB",
    "generated_number": "EE-2025-001000-TN-DGCO",
    "auto_closed": true,
    "closed_at": "2025-08-26T09:15:01Z"
  }
}
```

### 2. Transferencia de Expediente
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "record_id": "550e8400-e29b-41d4-a716-446655440010",
  "movement_type": "transfer",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "external_user_id": null,
  "creator_sector_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "admin_sector_id": "b2c3d4e5-f6g7-890h-ijkl-234567890123",
  "assigned_sector_id": null,
  "assigned_user_id": null,
  "created_at": "2025-08-26T14:30:00Z",
  "is_active": false,
  "closed_at": "2025-08-26T14:30:01Z",
  "closing_reason": "Transferencia completada automáticamente",
  "closed_by": "SYSTEM",
  "supporting_document_id": "550e8400-e29b-41d4-a716-446655440098",
  "reason": "Transferencia para dictamen legal",
  "audit": {
    "previous_admin": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "new_admin": "b2c3d4e5-f6g7-890h-ijkl-234567890123",
    "auto_closed": true,
    "closed_at": "2025-08-26T14:30:01Z"
  }
}
```

### 3. Asignación de Sector
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440003",
  "record_id": "550e8400-e29b-41d4-a716-446655440010",
  "movement_type": "assignment",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "external_user_id": null,
  "creator_sector_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "admin_sector_id": null,
  "assigned_sector_id": "c3d4e5f6-g7h8-901i-jklm-345678901234",
  "assigned_user_id": "d4e5f6g7-h8i9-012j-klmn-456789012345",
  "created_at": "2025-08-26T15:45:00Z",
  "is_active": true,
  "closed_at": null,
  "closing_reason": null,
  "closed_by": null,
  "supporting_document_id": null,
  "reason": "Asignación para informe técnico",
  "audit": {
    "permission_type": "assigned_edit",
    
  }
}
```