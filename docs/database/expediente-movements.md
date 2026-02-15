# Sistema de Movimientos - Modulo Expedientes

## Tipos de Movimiento

```sql
-- Enum para tipos de movimiento
CREATE TYPE movement_type AS ENUM (
    'creation',           -- Creacion inicial del expediente
    'transfer',           -- Transferencia a otro sector administrador
    'assignment',         -- Asignacion de permisos a sector
    'assignment_close',   -- Cierre de asignacion
    'status_change',      -- Cambio de estado del expediente
    'document_link',      -- Vinculacion de documento oficial al expediente
    'subsanacion',        -- Subsanacion de documento erroneo
    'document_proposal',  -- Propuesta de documento borrador
    'document_proposal_reject'  -- Rechazo de propuesta de documento
);
```

## Estructura de Movimientos

```sql
CREATE TABLE case_movements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    case_id UUID NOT NULL REFERENCES cases(id),
    type movement_type NOT NULL,
    user_id UUID REFERENCES users(id),
    creator_sector_id UUID NOT NULL REFERENCES sectors(id),
    admin_sector_id UUID NOT NULL REFERENCES sectors(id),
    assigned_sector_id UUID REFERENCES sectors(id),
    assigned_user_id UUID REFERENCES users(id),
    reason VARCHAR(200) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    closed_at TIMESTAMPTZ,
    closing_reason VARCHAR(200),
    closed_by UUID REFERENCES users(id),
    supporting_document_id UUID REFERENCES official_documents(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico del movimiento. |
| `case_id` | `uuid` | **FK** - Expediente al que pertenece (`cases`). |
| `type` | `movement_type` | Tipo de movimiento realizado. |
| `user_id` | `uuid` | **FK** - Usuario que realizo el movimiento (`users`). |
| `creator_sector_id` | `uuid` | **FK** - Sector que inicio el movimiento (`sectors`). |
| `admin_sector_id` | `uuid` | **FK** - Sector administrador actual del expediente (`sectors`). |
| `assigned_sector_id` | `uuid` | **FK** - Sector al que se asigna (si aplica). |
| `assigned_user_id` | `uuid` | **FK** - Usuario al que se asigna (si aplica). |
| `reason` | `varchar(200)` | Motivo del movimiento. |
| `is_active` | `boolean` | `true` si el movimiento esta activo. |
| `closed_at` | `timestamptz` | Fecha de cierre del movimiento. |
| `closing_reason` | `varchar(200)` | Razon del cierre. |
| `closed_by` | `uuid` | Usuario que cerro el movimiento. |
| `supporting_document_id` | `uuid` | **FK** - Documento oficial de respaldo (ej. Caratula, Pase de Vista). |
| `created_at` | `timestamptz` | Fecha de creacion del movimiento. |

## Indices de Rendimiento

```sql
CREATE INDEX idx_case_movements_case ON case_movements(case_id);
CREATE INDEX idx_case_movements_assigned ON case_movements(assigned_sector_id);
CREATE INDEX idx_case_movements_case_at ON case_movements(case_id, created_at DESC);
```

## Ejemplos de Movimientos

### 1. Creacion de Expediente
```json
{
  "case_id": "550e8400-...",
  "type": "creation",
  "user_id": "123e4567-...",
  "creator_sector_id": "f47ac10b-...",
  "admin_sector_id": "f47ac10b-...",
  "reason": "Cargar documentacion",
  "is_active": false,
  "closed_at": "2025-08-26T09:15:01Z",
  "closing_reason": "Creacion completada automaticamente",
  "supporting_document_id": "550e8400-..."
}
```

### 2. Transferencia de Expediente
```json
{
  "case_id": "550e8400-...",
  "type": "transfer",
  "user_id": "123e4567-...",
  "creator_sector_id": "f47ac10b-...",
  "admin_sector_id": "b2c3d4e5-...",
  "reason": "Transferencia para dictamen legal",
  "is_active": false,
  "closed_at": "2025-08-26T14:30:01Z",
  "closing_reason": "Transferencia completada automaticamente",
  "supporting_document_id": "550e8400-..."
}
```

### 3. Asignacion de Sector
```json
{
  "case_id": "550e8400-...",
  "type": "assignment",
  "user_id": "123e4567-...",
  "creator_sector_id": "f47ac10b-...",
  "admin_sector_id": "f47ac10b-...",
  "assigned_sector_id": "c3d4e5f6-...",
  "assigned_user_id": "d4e5f6g7-...",
  "reason": "Asignacion para informe tecnico",
  "is_active": true
}
```

### 4. Vinculacion de Documento
```json
{
  "case_id": "550e8400-...",
  "type": "document_link",
  "user_id": "123e4567-...",
  "creator_sector_id": "f47ac10b-...",
  "admin_sector_id": "f47ac10b-...",
  "reason": "Vinculacion de informe tecnico IF-2025-000042",
  "supporting_document_id": "770e8400-...",
  "is_active": false,
  "closed_at": "2025-08-26T16:00:01Z"
}
```
