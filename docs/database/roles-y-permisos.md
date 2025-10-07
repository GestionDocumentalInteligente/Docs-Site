# Modelo de Datos: Roles, Permisos y Sellos

Este documento detalla la estructura de las tablas que gestionan el control de acceso basado en roles (RBAC) y el sistema de sellos institucionales en GDI.

---

## Sistema de Roles y Permisos (RBAC)

### Tabla: `roles`

**Propósito:** Define los roles funcionales que se pueden asignar a los usuarios (ej. Administrador, Agente, Gestor).

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `role_id` | `uuid` | **PK** - Identificador único del rol. |
| `role_name` | `varchar` | Nombre único del rol. |
| `description` | `text` | Descripción de las responsabilidades del rol. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.roles (
    role_id uuid NOT NULL,
    role_name character varying(100) NOT NULL,
    description text,
    audit_data jsonb
);
```

---

### Tabla: `permissions`

**Propósito:** Catálogo de todos los permisos o acciones específicas que se pueden realizar en el sistema.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `permission_id` | `uuid` | **PK** - Identificador único del permiso. |
| `name` | `varchar` | Nombre único del permiso (ej. "CREATE_DOCUMENT"). |
| `description` | `text` | Descripción de lo que permite la acción. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.permissions (
    permission_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    audit_data jsonb
);
```

---

### Tabla: `role_permissions`

**Propósito:** Tabla de unión que asigna permisos específicos a cada rol, definiendo lo que cada rol puede hacer.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `role_id` | `uuid` | **PK, FK** - Referencia al rol (`roles`). |
| `permission_id` | `uuid` | **PK, FK** - Referencia al permiso (`permissions`). |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.role_permissions (
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    audit_data jsonb
);
```

---

### Tabla: `user_roles`

**Propósito:** Tabla de unión que asigna uno o más roles a cada usuario.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `user_id` | `uuid` | **PK, FK** - Referencia al usuario (`users`). |
| `role_id` | `uuid` | **PK, FK** - Referencia al rol (`roles`). |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    audit_data jsonb
);
```

---

### Tabla: `enabled_document_types_by_department`

**Propósito:** Habilita qué tipos de documentos puede crear o gestionar cada repartición. Es una regla de negocio clave.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id` | `integer` | **PK** - Identificador único de la regla. |
| `document_type_id` | `uuid` | **FK** - Referencia al tipo de documento (`document_types`). |
| `department_id` | `uuid` | **FK** - Referencia a la repartición (`departments`). |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.enabled_document_types_by_department (
    id integer NOT NULL,
    document_type_id uuid NOT NULL,
    department_id uuid NOT NULL,
    audit_data jsonb
);
```

---

### Tabla: `document_types_allowed_by_rank`

**Propósito:** Define qué jerarquía o rango (`rank`) es necesario para poder firmar ciertos tipos de documento.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id` | `integer` | **PK** - Identificador único de la regla. |
| `document_type_id` | `uuid` | **FK** - Referencia al tipo de documento (`document_types`). |
| `rank_id` | `uuid` | **FK** - Referencia al rango (`ranks`). |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.document_types_allowed_by_rank (
    id integer NOT NULL,
    document_type_id uuid NOT NULL,
    rank_id uuid NOT NULL,
    audit_data jsonb
);
```

---

### Tabla: `user_sector_permissions`

**Propósito:** Otorga permisos especiales a un usuario sobre un sector específico, más allá de los permisos de su rol.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `user_id` | `uuid` | **PK, FK** - Referencia al usuario (`users`). |
| `sector_id` | `uuid` | **PK, FK** - Referencia al sector (`sectors`). |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.user_sector_permissions (
    user_id uuid NOT NULL,
    sector_id uuid NOT NULL,
    audit_data jsonb
);
```

---

## Sistema de Sellos Institucionales

### Tabla: `global_seals`

**Propósito:** Catálogo universal de sellos estándar (ej. "Intendente", "Secretario") que pueden ser usados por cualquier municipio.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador único del sello global. |
| `acronym` | `text` | Sigla única del sello (ej. "INTEN"). |
| `name` | `text` | Nombre descriptivo del sello (ej. "Intendente Municipal"). |
| `description` | `text` | Descripción funcional del sello. |
| `created_at` | `timestamp` | Fecha de creación del registro. |

```sql
CREATE TABLE public.global_seals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    acronym text NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now()
);
```

---

### Tabla: `city_seals`

**Propósito:** Implementación de un sello para un municipio específico, que puede heredar de un sello global o ser totalmente personalizado.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador único del sello municipal. |
| `global_seal_id` | `uuid` | **FK** - Referencia opcional a `global_seals`. |
| `acronym` | `text` | Sigla única del sello en el municipio. |
| `name` | `text` | Nombre del sello para el municipio. |
| `description` | `text` | Descripción local del sello. |
| `created_at` | `timestamp` | Fecha de creación del registro. |

```sql
CREATE TABLE public.city_seals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    global_seal_id uuid,
    acronym text NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now()
);
```

---

### Tabla: `rank_allowed_seals`

**Propósito:** Define qué rangos jerárquicos (`ranks`) están autorizados para utilizar un determinado sello municipal.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador único de la regla. |
| `rank_id` | `uuid` | **FK** - Referencia al rango (`ranks`). |
| `city_seal_id` | `uuid` | **FK** - Referencia al sello municipal (`city_seals`). |
| `created_at` | `timestamp` | Fecha de creación del registro. |

```sql
CREATE TABLE public.rank_allowed_seals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rank_id uuid NOT NULL,
    city_seal_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);
```

---

### Tabla: `user_seals`

**Propósito:** Asigna un sello municipal específico a un usuario individual, permitiéndole usarlo en sus firmas.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador único de la asignación. |
| `user_id` | `uuid` | **FK** - Referencia al usuario (`users`). |
| `city_seal_id` | `uuid` | **FK** - Referencia al sello municipal (`city_seals`). |
| `created_at` | `timestamp` | Fecha de creación del registro. |

```sql
CREATE TABLE public.user_seals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    city_seal_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);
```