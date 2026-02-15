# Modelo de Datos: Roles, Permisos y Sellos

Este documento detalla la estructura de las tablas que gestionan el control de acceso basado en roles (RBAC) y el sistema de sellos institucionales en GDI.

---

## Sistema de Roles y Permisos (RBAC)

### Tabla: `roles`

**Proposito:** Define los roles funcionales que se pueden asignar a los usuarios (ej. Administrador, Agente, Gestor).

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `role_id` | `uuid` | **PK** - Identificador unico del rol. |
| `role_name` | `varchar` | Nombre unico del rol. |
| `description` | `text` | Descripcion de las responsabilidades del rol. |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

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

**Proposito:** Catalogo de todos los permisos o acciones especificas que se pueden realizar en el sistema.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `permission_id` | `uuid` | **PK** - Identificador unico del permiso. |
| `name` | `varchar` | Nombre unico del permiso (ej. "CREATE_DOCUMENT"). |
| `description` | `text` | Descripcion de lo que permite la accion. |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

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

**Proposito:** Tabla de union que asigna permisos especificos a cada rol, definiendo lo que cada rol puede hacer.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `role_id` | `uuid` | **PK, FK** - Referencia al rol (`roles`). |
| `permission_id` | `uuid` | **PK, FK** - Referencia al permiso (`permissions`). |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE public.role_permissions (
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    audit_data jsonb
);
```

---

### Tabla: `user_roles`

**Proposito:** Tabla de union que asigna uno o mas roles a cada usuario.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `user_id` | `uuid` | **PK, FK** - Referencia al usuario (`users`). |
| `role_id` | `uuid` | **PK, FK** - Referencia al rol (`roles`). |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    audit_data jsonb
);
```

---

### Tabla: `enabled_document_types_by_department`

**Proposito:** Habilita que tipos de documentos puede crear o gestionar cada reparticion. Es una regla de negocio clave.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `integer` | **PK** - Identificador unico de la regla. |
| `document_type_id` | `uuid` | **FK** - Referencia al tipo de documento (`document_types`). |
| `department_id` | `uuid` | **FK** - Referencia a la reparticion (`departments`). |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE enabled_document_types_by_department (
    id integer NOT NULL,
    document_type_id uuid NOT NULL,
    department_id uuid NOT NULL,
    audit_data jsonb
);
```

---

### Tabla: `document_types_allowed_by_rank`

**Proposito:** Define que jerarquia o rango (`rank`) es necesario para poder firmar ciertos tipos de documento.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `integer` | **PK** - Identificador unico de la regla. |
| `document_type_id` | `uuid` | **FK** - Referencia al tipo de documento (`document_types`). |
| `rank_id` | `uuid` | **FK** - Referencia al rango (`ranks`). |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE document_types_allowed_by_rank (
    id integer NOT NULL,
    document_type_id uuid NOT NULL,
    rank_id uuid NOT NULL,
    audit_data jsonb
);
```

---

## Sistema de Sellos Institucionales

Los sellos son per-tenant (viven en el schema del municipio). Ya no existen `global_seals` ni `rank_seals`.

### Tabla: `city_seals`

**Proposito:** Define los sellos institucionales disponibles para un municipio. Cada sello puede estar vinculado a un rango jerarquico.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico del sello municipal. |
| `acronym` | `text` | Sigla unica del sello en el municipio (ej. "INTEN"). |
| `name` | `text` | Nombre del sello para el municipio (ej. "Intendente Municipal"). |
| `description` | `text` | Descripcion local del sello. |
| `rank_id` | `uuid` | **FK** - Referencia opcional al rango (`ranks`). |
| `created_at` | `timestamp` | Fecha de creacion del registro. |

```sql
CREATE TABLE city_seals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    acronym text NOT NULL,
    name text NOT NULL,
    description text,
    rank_id uuid REFERENCES ranks(rank_id),
    created_at timestamp without time zone DEFAULT now()
);
```

---

### Tabla: `user_seals`

**Proposito:** Asigna un sello municipal especifico a un usuario individual, permitiendole usarlo en sus firmas. Cada usuario puede tener un solo sello.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico de la asignacion. |
| `user_id` | `uuid` | **FK** - Referencia al usuario (`users`). Unico. |
| `seal_id` | `uuid` | **FK** - Referencia al sello municipal (`city_seals`). |
| `created_at` | `timestamp` | Fecha de creacion del registro. |

```sql
CREATE TABLE user_seals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL UNIQUE,
    seal_id uuid NOT NULL REFERENCES city_seals(id),
    created_at timestamp without time zone DEFAULT now()
);
```
