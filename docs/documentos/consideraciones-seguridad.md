# 🔒 Consideraciones de Seguridad - GDI Framework

## Introducción

La seguridad en el módulo de Documentos de GDI se basa en el control estricto de estados, permisos organizacionales y trazabilidad. El sistema garantiza integridad y autenticidad a través de transiciones controladas y validaciones automáticas basadas en la estructura municipal implementada.

---

## 📊 Seguridad por Estado del Documento

### Estado `draft` (En Edición)

**Control de Acceso:**
- ✅ Solo creador y usuarios de su department pueden acceder
- ✅ Validación automática por pertenencia organizacional
- 🚧 Sistema ACL en `audit_data` (estructura preparada, lógica pendiente)

**Protecciones Implementadas:**
- **Eliminación lógica**: `is_deleted = true` preserva integridad referencial
- **Validación de contenido**: Campo `content` JSONB no puede estar vacío
- **Validación de referencia**: Campo `reference` obligatorio (máx. 254 caracteres)

### Estado `sent_to_sign` (En Circuito de Firmas)

**Inmutabilidad Automática:**
- ✅ Contenido bloqueado tras transición `draft` → `sent_to_sign`
- ✅ Campo `sent_to_sign_at` registra momento exacto de bloqueo
- ✅ Solo firmantes asignados pueden interactuar con el documento

**Control de Firmantes:**
- ✅ Lista cerrada en tabla `document_signers`
- ✅ Validación secuencial por `signing_order`
- ✅ Estados individuales: `pending` → `signed` o `rejected`

### Estado `signed` (Documento Oficial)

**Protección Permanente:**
- ✅ Documento completamente inmutable
- ✅ Entrada automática en tabla `official_documents`
- ✅ Número oficial único con constraint `UNIQUE`
- ✅ PDF firmado almacenado en `signed_pdf_url`

---

## 🏛️ Seguridad Organizacional

### Control por Department

**Reglas Implementadas:**
```sql
-- Acceso basado en estructura organizacional
users.sector_id → sectors.department_id → departments
```

**Validaciones Automáticas:**
- ✅ `enabled_document_types_by_department`: Controla qué tipos puede usar cada repartición
- ✅ `document_types_allowed_by_rank`: Controla qué jerarquías pueden firmar
- ✅ Solo usuarios autorizados pueden ser numeradores

### Sistema RBAC

**Roles Implementados:**
- Tablas: `roles`, `permissions`, `role_permissions`, `user_roles`
- Validación por tipo de documento y repartición
- Control granular de operaciones (crear, editar, firmar, numerar)

---

## 🔢 Seguridad en Numeración Oficial

### Prevención de Duplicados

**Constraints de Base de Datos:**
```sql
-- Implementados en Supabase
CONSTRAINT unique_official_number UNIQUE (official_number)
CONSTRAINT unique_reserved_number UNIQUE (reserved_number)
```

**Proceso Atómico:**
- ✅ Reserva secuencial en tabla `numeration_requests`
- ✅ Validación de formato: `<TIPO>-<AAAA>-<NNNNNN>-<SIGLA_ECO>-<SIGLA_DEPT>`
- ✅ Confirmación solo tras firma exitosa del numerador

### Control de Concurrencia

**Problemas Identificados:**
- 🚧 Sistema actual vulnerable a condiciones de carrera
- 🚧 Múltiples usuarios numerando simultáneamente el mismo tipo

**Mitigaciones Implementadas:**
- ✅ Constraint de unicidad en base de datos
- ✅ Estados de validación: `pending`, `valid`, `invalid`

---

## 📋 Auditoría y Trazabilidad

### Campo `audit_data` (JSONB)

**Información Registrada:**
```json
{
  "created_by": "user_id",
  "created_at": "timestamp",
  "modified_by": "user_id",
  "last_modified_at": "timestamp",
  "state_transitions": [
    {
      "from": "draft",
      "to": "sent_to_sign", 
      "timestamp": "...",
      "user": "..."
    }
  ]
}
```

### Trazabilidad por Tabla

**`document_draft`**: Historial completo del documento
**`document_signers`**: Estado individual de cada firmante  
**`document_rejections`**: Motivos y usuarios que rechazaron
**`official_documents`**: Documento final con validez legal

---

## 🔐 Control de Permisos en Tiempo Real

### Validaciones Durante el Proceso

**Al Momento de Firma:**
- ✅ Verificación de que el usuario sigue activo
- ✅ Validación de pertenencia a repartición autorizada
- ✅ Confirmación de que es su turno en `signing_order`

**Gestión de Cambios Organizacionales:**
- ❌ Sistema actual no maneja cambios durante proceso activo
- ❌ No hay delegación temporal de firmas
- ❌ Procesos se detienen si firmante no está disponible

---

## 🛡️ Medidas de Protección Implementadas

### Integridad de Datos

**Estados Válidos:**
```sql
CREATE TYPE document_status AS ENUM (
    'draft', 'sent_to_sign', 'signed', 
    'rejected', 'cancelled', 'archived'
);
```

**Transiciones Controladas:**
- ✅ Solo transiciones válidas permitidas por lógica de negocio
- ✅ Timestamps automáticos en cada cambio de estado
- ✅ Preservación de historial completo

### Validaciones de Negocio

**Campos Obligatorios:**
- `reference` no puede estar vacío
- `content` debe tener información válida
- Al menos un firmante y un numerador requeridos

**Reglas de Consistencia:**
- Solo un numerador por documento (`is_numerator = true`)
- Orden de firma secuencial válido
- Numeración solo tras proceso completo

---

## 📞 Gestión de Incidentes

### Problemas Comunes y Resoluciones

**Documento Rechazado:**
- ✅ Automático: Estado cambia a `rejected`
- ✅ Registro en tabla `document_rejections`
- ✅ Posibilidad de corrección y reenvío

**Proceso Estancado:**
- ❌ Detección manual requerida
- ❌ Resolución por cancelación y reasignación
- ❌ Sin alertas automáticas implementadas

**Error en Numeración:**
- ✅ Constraint de BD previene duplicados
- ✅ Estados de validación para control
- 🚧 Procedimientos de corrección manuales

---

## 🔗 Integración con Normativa Argentina

### Cumplimiento Legal

**Ley 25.506 - Firma Digital:**
- ✅ Estructura preparada para firma digital
- ✅ Campo `required_signature` en tipos de documento
- 🚧 Integración con certificados digitales pendiente

**Ley 27.275 - Acceso a la Información Pública:**
- ✅ Documentos en estado `signed` son públicamente consultables
- ✅ Control de acceso diferencial por estado
- ✅ Trazabilidad completa para auditorías

---

## 📋 Checklist de Estado Actual

### ✅ **Implementado y Funcional:**
- [x] Control de estados con transiciones válidas
- [x] Sistema RBAC básico con roles organizacionales  
- [x] Control de acceso por repartición/department
- [x] Numeración secuencial with constraints de unicidad
- [x] Auditoría básica en campo `audit_data`
- [x] Validación de tipos de documento por repartición
- [x] Eliminación lógica que preserva integridad

### 🚧 **Estructura Preparada, Lógica Pendiente:**
- [ ] Sistema ACL completo en `audit_data` 
- [ ] Editor colaborativo en tiempo real (`pad_id`)
- [ ] Integración con certificados digitales oficiales
- [ ] Funciones SQL de validación automática

### ❌ **No Implementado:**
- [ ] Delegación temporal de firmas
- [ ] Escalación automática por inactividad  
- [ ] Alertas por procesos estancados
- [ ] Control de concurrencia robusto en numeración

---

*Este documento refleja el estado real del sistema GDI según la documentación técnica vigente. Las mejoras de seguridad adicionales requieren desarrollo específico según las necesidades operativas identificadas.*