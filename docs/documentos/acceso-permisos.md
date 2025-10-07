# 🔐 Reglas de Acceso y Permisos - Estado Real del Sistema

El sistema de acceso y permisos de GDI está diseñado para garantizar la seguridad y privacidad de los documentos, mientras permite la colaboración necesaria entre usuarios y reparticiones. El control se basa en la pertenencia organizacional, el estado del documento y permisos específicos otorgados.

## 📊 Estado Actual de Implementación

#### Estructura Organizacional
```sql
-- Tablas existentes verificadas
municipalities (municipios)
    ↓
departments (reparticiones) 
    ↓
sectors (sectores)
    ↓
users (usuarios)
```

#### Sistema de Roles y Permisos
```sql
-- Tablas RBAC implementadas
roles                    ✅ Tabla de roles del sistema
permissions             ✅ Tabla de permisos disponibles  
role_permissions        ✅ Relación roles-permisos
user_roles              ✅ Asignación roles a usuarios
```

#### Control de Acceso por Department
```sql
-- Tablas de control implementadas
enabled_document_types_by_department    ✅ Tipos permitidos por department
document_types_allowed_by_rank         ✅ Tipos permitidos por jerarquía
user_sector_permissions               ✅ Permisos adicionales por sector
```

### 🚧 **PENDIENTE DE IMPLEMENTACIÓN:**
- Funciones SQL de validación automática
- Triggers de control de permisos
- Sistema ACL en audit_data
- Integración completa con flujo de documentos

---

## 🏛️ Reglas Generales de Visibilidad

### 7.1 Acceso por Pertenencia (IMPLEMENTADO)

**Regla Base**: Usuarios de una reparticion ven únicamente los documentos de su reparticion (department)

**Implementación en BD:**
```sql
-- Estructura 
users.sector_id → sectors.sector_id
sectors.department_id → departments.department_id

-- Query base (DEBE IMPLEMENTARSE)
SELECT dd.* 
FROM document_draft dd
JOIN users creator ON dd.created_by = creator.user_id
JOIN sectors creator_sector ON creator.sector_id = creator_sector.sector_id
JOIN departments creator_dept ON creator_sector.department_id = creator_dept.department_id
WHERE creator_dept.department_id = (
    SELECT user_dept.department_id 
    FROM users current_user
    JOIN sectors user_sector ON current_user.sector_id = user_sector.sector_id  
    JOIN departments user_dept ON user_sector.department_id = user_dept.department_id
    WHERE current_user.user_id = ? -- usuario actual
);
```

### 7.2 Búsqueda General (IMPLEMENTADO)

**Regla**: Los documentos de otras reparticiones solo son accesibles mediante búsqueda por número oficial cuando están en estado `signed`.

**Implementación en BD:**
```sql
-- Tabla official_documents existe en Supabase
SELECT od.official_number, dd.reference, od.signed_at
FROM official_documents od
JOIN document_draft dd ON od.document_id = dd.document_id
WHERE od.official_number = ?
  AND dd.status = 'signed'; -- Solo documentos oficiales
```

### 7.3 Privacidad por Defecto (IMPLEMENTADO)

**Regla**: El sistema garantiza que los documentos en desarrollo no sean visibles fuera del department.

**Estados implementados en BD:**
```sql
-- document_status enum real en Supabase
'draft'        -- En desarrollo, solo department
'sent_to_sign' -- En firma, solo firmantes
'signed'       -- Oficial, búsqueda pública
'rejected'     -- En corrección, solo department
'cancelled'    -- Cancelado, solo department  
'archived'     -- Archivado, búsqueda limitada
```

---

## 🤝 Funcionalidad de Compartir (PENDIENTE DE IMPLEMENTACIÓN)

### 7.4 Sistema ACL - Access Control Lists

**Regla de Negocio**: Documentos pueden compartirse explícitamente con usuarios específicos independientemente de su department de origen.

**Estado Actual**: 
- ✅ Campo `audit_data` (JSONB) existe en `document_draft`
- 🚧 Lógica ACL pendiente de implementación

**Implementación Requerida:**
```sql
-- Estructura propuesta para audit_data
{
  "shared_with": [
    {
      "user_id": "uuid",
      "permission": "editor|comentador|lector",
      "shared_by": "uuid", 
      "shared_at": "timestamp",
      "expires_at": "timestamp" // opcional
    }
  ],
  "access_log": [
    {
      "user_id": "uuid",
      "action": "view|edit|comment",
      "timestamp": "timestamp",
      "ip_address": "string"
    }
  ]
}

-- Query de validación ACL (DEBE IMPLEMENTARSE)
SELECT dd.*
FROM document_draft dd
WHERE dd.document_id = ?
  AND (
    dd.created_by = ? -- Es el creador
    OR
    -- Pertenece a su department (ya implementado)
    EXISTS (SELECT 1 FROM ... )
    OR  
    -- Tiene ACL específico (PENDIENTE)
    JSON_EXTRACT(dd.audit_data, '$.shared_with[*].user_id') @> CAST(? AS JSON)
  );
```

**Características del Sistema de Compartir:**

#### Estados Aplicables
- ✅ **Estado `draft`**: Compartir habilitado durante edición
- ❌ **Estados posteriores**: No se puede compartir una vez enviado a firma

#### Permisos Granulares (PENDIENTE)
- **Editor**: Puede modificar contenido y configuración
- **Comentador**: Puede agregar observaciones sin editar
- **Lector**: Solo visualización  
- **Sin acceso**: Revocar permisos específicos

#### Gestión Dinámica (PENDIENTE)
- Permisos modificables en tiempo real
- Revocación inmediata de accesos
- Notificaciones automáticas

#### Auditoría Completa (PARCIAL)
- ✅ Campo `audit_data` disponible
- 🚧 Registro de compartir pendiente
- 🚧 Logs de acceso pendientes

---

## 🔒 Control de Acceso por Estado del Documento

### 7.5 Matriz de Permisos por Estado

| Estado | Creador | Department | Firmantes | ACL Users | Externos |
|--------|---------|------------|-----------|-----------|----------|
| **`draft`** | ✅ Editar | ✅ Ver | ❌ No acceso | 🚧 Según ACL | ❌ No acceso |
| **`sent_to_sign`** | ✅ Ver | ✅ Ver | ✅ Firmar/Rechazar | 🚧 Solo lectura | ❌ No acceso |
| **`signed`** | ✅ Ver | ✅ Ver | ✅ Ver | ✅ Ver | ✅ Buscar por número |
| **`rejected`** | ✅ Editar | ✅ Ver | ✅ Ver motivos | 🚧 Según ACL | ❌ No acceso |
| **`cancelled`** | ✅ Ver | ✅ Ver | ✅ Ver | ❌ No acceso | ❌ No acceso |
| **`archived`** | ✅ Ver | ✅ Ver | ✅ Ver | ❌ No acceso | ✅ Búsqueda limitada |

**Leyenda:**
- ✅ Implementado en BD
- 🚧 Estructura existe, lógica pendiente  
- ❌ No implementado

---

## 👥 Sistema de Roles y Permisos (IMPLEMENTADO)

### 7.6 Estructura RBAC en Supabase

**Tablas Verificadas:**
```sql
roles {
    role_id: UUID
    role_name: VARCHAR (unique)
    description: TEXT
    audit_data: JSONB
}

permissions {
    permission_id: UUID  
    name: VARCHAR (unique)
    description: TEXT
    audit_data: JSONB
}

role_permissions {
    role_id: UUID (FK)
    permission_id: UUID (FK)
    audit_data: JSONB
}

user_roles {
    user_id: UUID (FK)
    role_id: UUID (FK) 
    audit_data: JSONB
}
```

**Consulta de Permisos Efectivos (DEBE IMPLEMENTARSE):**
```sql
-- Obtener permisos de un usuario
SELECT DISTINCT p.name
FROM users u
JOIN user_roles ur ON u.user_id = ur.user_id
JOIN role_permissions rp ON ur.role_id = rp.role_id  
JOIN permissions p ON rp.permission_id = p.permission_id
WHERE u.user_id = ?;
```

---

## 🏢 Control por Department y Jerarquía

### 7.7 Permisos de Creación por Department (IMPLEMENTADO)

**Tabla**: `enabled_document_types_by_department`
```sql
{
    id: INTEGER (PK)
    document_type_id: UUID (FK)
    department_id: UUID (FK)
    audit_data: JSONB
}
```

**Validación de Creación (DEBE IMPLEMENTARSE):**
```sql
-- Verificar si usuario puede crear tipo de documento
SELECT EXISTS (
    SELECT 1 
    FROM enabled_document_types_by_department edtd
    JOIN departments d ON edtd.department_id = d.department_id
    JOIN sectors s ON d.department_id = s.department_id
    JOIN users u ON s.sector_id = u.sector_id
    WHERE u.user_id = ?                    -- usuario actual
      AND edtd.document_type_id = ?        -- tipo documento
) as can_create;
```

### 7.8 Permisos de Firma por Jerarquía (IMPLEMENTADO)

**Tabla**: `document_types_allowed_by_rank`
```sql
{
    id: INTEGER (PK)
    document_type_id: UUID (FK)
    rank_id: UUID (FK)
    audit_data: JSONB
}
```

**Validación de Firma (DEBE IMPLEMENTARSE):**
```sql
-- Verificar si usuario puede firmar tipo de documento
SELECT EXISTS (
    SELECT 1 
    FROM document_types_allowed_by_rank dtar
    JOIN departments d ON dtar.rank_id = d.rank_id
    JOIN sectors s ON d.department_id = s.department_id
    JOIN users u ON s.sector_id = u.sector_id
    WHERE u.user_id = ?                    -- firmante
      AND dtar.document_type_id = ?        -- tipo documento
) as can_sign;
```

---

## 🔧 Implementaciones Pendientes

### 7.9 Funciones de Validación (DEBE IMPLEMENTARSE)

```sql
-- Función principal de validación de acceso
CREATE OR REPLACE FUNCTION user_can_access_document(
    p_user_id UUID,
    p_document_id UUID,
    p_action TEXT -- 'view', 'edit', 'sign'
) RETURNS BOOLEAN AS $$
BEGIN
    -- Lógica de validación según reglas de negocio
    -- PENDIENTE DE IMPLEMENTACIÓN
END;
$$ LANGUAGE plpgsql;
```

### 7.10 Triggers de Control (DEBE IMPLEMENTARSE)

```sql
-- Trigger de validación antes de acceso
CREATE TRIGGER validate_document_access
    BEFORE SELECT ON document_draft
    FOR EACH ROW
    EXECUTE FUNCTION check_access_permissions();

-- PENDIENTE DE IMPLEMENTACIÓN
```

### 7.11 Sistema ACL Completo (DEBE IMPLEMENTARSE)

- Interfaz de compartir documentos
- Gestión de permisos granulares  
- Notificaciones de acceso compartido
- Logs de auditoría en tiempo real

---

## 📋 Checklist de Implementación

### ✅ **COMPLETADO:**
- [x] Estructura de departments, sectors, users
- [x] Tablas RBAC (roles, permissions, user_roles)
- [x] Control por department (enabled_document_types_by_department)
- [x] Control por jerarquía (document_types_allowed_by_rank)
- [x] Campo audit_data para ACLs

### 🚧 **EN DESARROLLO:**
- [ ] Funciones SQL de validación
- [ ] Triggers automáticos de permisos
- [ ] Sistema ACL en audit_data
- [ ] Interfaz de compartir documentos

### 📋 **PENDIENTE:**
- [ ] Integración completa con flujo de documentos
- [ ] Dashboard de permisos administrativo
- [ ] Alertas de seguridad automatizadas
- [ ] Reportes de auditoría de acceso

---

**📝 Nota**: Las implementaciones marcadas como "DEBE IMPLEMENTARSE" indican funcionalidades donde la estructura existe pero la lógica de negocio aún no está desarrollada.