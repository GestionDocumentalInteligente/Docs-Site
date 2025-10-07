# 🏛️ Módulo Organigrama GDI

## 1. ¿Qué es el Módulo Organigrama?

El módulo de Organigrama es el componente central para la gestión de la estructura jerárquica de la municipalidad, abarcando **departments** (reparticiones), **sectors** (sectores) y **users** (usuarios). Su propósito es reflejar la realidad organizacional y definir el contexto operativo de cada usuario dentro del sistema.

### 📊 Estructura Implementada en Base de Datos:

```
municipalities (Municipios)
    ↓
departments (Reparticiones/Secretarías) 
    ↓
sectors (Sectores/Áreas)
    ↓
users (Usuarios/Empleados)
    ↓
roles + permissions (Sistema RBAC)
```

### ✅ Características principales (IMPLEMENTADAS):

- **Gestión descentralizada**: Los titulares (`head_user_id` en `departments`) administran su propia repartición
- **Visibilidad controlada**: Control mediante `user_sector_permissions` y sistema RBAC
- **Integración total**: Base fundamental para módulos Documentos (mediante `enabled_document_types_by_department` y `document_types_allowed_by_rank`)
- **Estructura jerárquica**: Municipality → Departments → Sectors → Users
- **Niveles de autoridad**: Sistema de `ranks` para definir jerarquías

### 🎯 Funcionalidades principales:

- **Sección Mi Equipo**: Vista de los usuarios dentro de una repartición (basado en `department_id` y `sector_id`)
- **Gestión de usuarios**: Alta, baja y activación de usuarios (campo `is_active` en `users`)
- **Gestión de titulares**: Asignación mediante `head_user_id` en `departments`
- **Control de permisos**: Sistema RBAC completo con `roles`, `permissions`, `user_roles` y `role_permissions`

## 2. Casos de Uso Clave

| **Funcionalidad** | **Descripción** | **Implementación en BD** | **Quién puede usarla** |
|-------------------|-----------------|--------------------------|------------------------|
| **Consultar Mi Equipo** | Ver usuarios de la propia repartición | Query: `users` JOIN `sectors` WHERE `department_id` = usuario actual | Todos los usuarios |
| **Gestionar Usuarios** | Dar de alta, baja o activar/desactivar usuarios | UPDATE `users` SET `is_active` = true/false | Solo Titulares (`head_user_id`) |
| **Ver Estructura Organizacional** | Consultar departments y sectors | SELECT FROM `departments` JOIN `sectors` | Según permisos en `user_roles` |
| **Buscar Personal** | Localizar usuarios específicos | SELECT FROM `users` WHERE `full_name` LIKE o `email` = | Según permisos |
| **Asignar Responsables** | Designar head de department | UPDATE `departments` SET `head_user_id` = | Administrador o según permisos |
| **Gestionar Jerarquías** | Definir niveles de autoridad | Usar tabla `ranks` con `rank_id` en departments | Admin del sistema |

## 3. Entidades Principales del Sistema

### 🏢 **Municipalities** (municipalities)
- **Campos clave**: `id_municipality`, `name`, `acronym`, `country`
- **Propósito**: Define el municipio al que pertenece toda la estructura

### 🏛️ **Departments** (departments)  
- **Campos clave**: `department_id`, `name`, `acronym`, `head_user_id`, `rank_id`
- **Relación padre-hijo**: `parent_jurisdiction_id` para crear jerarquías
- **Estado**: `is_active`, `start_date`, `end_date`

### 📁 **Sectors** (sectors)
- **Campos clave**: `sector_id`, `department_id`, `acronym`
- **Estado**: `is_active`, `start_date`, `end_date`
- **Propósito**: Subdivisiones dentro de cada department

### 👤 **Users** (users)
- **Campos clave**: `user_id`, `full_name`, `email`, `cuit`, `sector_id`
- **Autenticación**: `auth_id` (integración con Supabase Auth)
- **Estado**: `is_active`, `last_access`

### 🎖️ **Ranks** (ranks)
- **Campos clave**: `rank_id`, `rank_name`, `head_signature`
- **Propósito**: Define niveles jerárquicos y autoridad para firmas

## 4. Sistema de Permisos (RBAC)

### 📋 Tablas de Control de Acceso:

1. **roles**: Define roles del sistema
   - Ejemplos: "Administrador", "Titular de Repartición", "Agente"

2. **permissions**: Permisos específicos del sistema
   - Ejemplos: "crear_usuario", "editar_department", "ver_estructura"

3. **role_permissions**: Asignación de permisos a roles

4. **user_roles**: Asignación de roles a usuarios

5. **user_sector_permissions**: Permisos especiales por sector

## 5. Integraciones con Otros Módulos

### 📄 Con Módulo Documentos:
- **`enabled_document_types_by_department`**: Define qué tipos de documentos puede crear cada department
- **`document_types_allowed_by_rank`**: Define qué documentos puede firmar cada rank

### 🗂️ Con Módulo Expedientes (Futuro):
- Estructura lista para cuando se implemente
- ENUMs ya definidos: `estado_expediente_enum`, `tipo_inicio_enum`

## 6. Estados y Ciclo de Vida

### Estados de Usuario (`users.is_active`):
- ✅ `true`: Usuario activo, puede acceder al sistema
- ❌ `false`: Usuario inactivo/suspendido

### Estados de Department/Sector:
- ✅ `is_active = true`: Operativo
- ❌ `is_active = false`: Inactivo/Histórico
- 📅 Control temporal: `start_date`, `end_date`

---