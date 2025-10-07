# Modelo de Datos: Módulo de Organigrama

Este documento detalla la estructura de las tablas principales que componen el módulo de Organigrama en GDI, responsable de la gestión de la estructura municipal, usuarios y jerarquías.

---

## Tabla: `municipalities`

**Propósito:** Almacena la información de cada municipio o entidad que utiliza la plataforma. Es el nivel más alto de la jerarquía.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id_municipality` | `uuid` | **PK** - Identificador único del municipio. |
| `name` | `varchar` | Nombre oficial del municipio. |
| `country` | `country_enum` | País al que pertenece (AR, BR, UY, CL). |
| `acronym` | `varchar` | Sigla única para el municipio (ej. "TNV"). |
| `schema_name` | `varchar` | Nombre del esquema de base de datos asignado. |
| `tax_identifier` | `varchar` | Identificador fiscal del municipio (CUIT/RUC). |
| `is_active` | `boolean` | `true` si el municipio está activo en la plataforma. |
| `created_at` | `timestamp` | Fecha de creación del registro. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |
| `created_by` | `uuid` | **FK** - Usuario que registró el municipio. |

```sql
CREATE TABLE public.municipalities (
    id_municipality uuid NOT NULL,
    name character varying(50) NOT NULL,
    country public.country_enum NOT NULL,
    acronym character varying(10) NOT NULL,
    schema_name character varying(50) NOT NULL,
    tax_identifier character varying(20),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    audit_data jsonb,
    created_by uuid NOT NULL
);
```

---

## Tabla: `departments`

**Propósito:** Define las reparticiones, secretarías o direcciones que componen la estructura principal del municipio.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `department_id` | `uuid` | **PK** - Identificador único de la repartición. |
| `name` | `varchar` | Nombre completo de la repartición. |
| `acronym` | `varchar` | Sigla única de la repartición. |
| `parent_jurisdiction_id` | `uuid` | **FK** - ID de la repartición padre para crear jerarquías. |
| `rank_id` | `uuid` | **FK** - Nivel jerárquico o rango (`ranks`). |
| `head_user_id` | `uuid` | **FK** - Usuario titular o responsable de la repartición (`users`). |
| `is_active` | `boolean` | `true` si la repartición está operativa. |
| `start_date` | `timestamp` | Fecha de inicio de actividades. |
| `end_date` | `timestamp` | Fecha de cese de actividades. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |
| `municipality_id` | `uuid` | **FK** - Municipio al que pertenece (`municipalities`). |

```sql
CREATE TABLE public.departments (
    department_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    acronym character varying(20),
    parent_jurisdiction_id uuid,
    rank_id uuid,
    head_user_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    start_date timestamp without time zone DEFAULT CURRENT_DATE NOT NULL,
    end_date timestamp without time zone,
    audit_data jsonb,
    municipality_id uuid
);
```

---

## Tabla: `sectors`

**Propósito:** Representa las subdivisiones o equipos de trabajo dentro de una repartición.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `sector_id` | `uuid` | **PK** - Identificador único del sector. |
| `department_id` | `uuid` | **FK** - Repartición a la que pertenece el sector (`departments`). |
| `acronym` | `varchar` | Sigla única del sector dentro de su repartición. |
| `is_active` | `boolean` | `true` si el sector está operativo. |
| `start_date` | `timestamp` | Fecha de inicio de actividades. |
| `end_date` | `timestamp` | Fecha de cese de actividades. |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.sectors (
    sector_id uuid NOT NULL,
    department_id uuid NOT NULL,
    acronym character varying(50) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone,
    audit_data jsonb
);
```

---

## Tabla: `users`

**Propósito:** Almacena la información de todos los usuarios del sistema, vinculándolos a la estructura organizacional y al sistema de autenticación.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `user_id` | `uuid` | **PK** - Identificador único del usuario en la aplicación. |
| `auth_id` | `varchar` | ID del usuario en el sistema de autenticación (Supabase Auth). |
| `full_name` | `varchar` | Nombre completo del usuario. |
| `email` | `varchar` | Correo electrónico único del usuario. |
| `cuit` | `varchar` | CUIT/CUIL del usuario. |
| `profile_picture_id` | `uuid` | **FK** - Referencia a la imagen de perfil (`media_files`). |
| `sector_id` | `uuid` | **FK** - Sector principal al que pertenece el usuario (`sectors`). |
| `is_active` | `boolean` | `true` si el usuario puede acceder al sistema. |
| `last_access` | `timestamp` | Fecha y hora del último acceso. |
| `created_at` | `timestamp` | Fecha de creación del usuario. |
| `identity_check` | `jsonb` | Datos de verificación de identidad (RENAPER, etc.). |
| `audit_data` | `jsonb` | Metadatos de auditoría. |
| `default_seal_id` | `bigint` | ID del sello por defecto para las firmas del usuario. |

```sql
CREATE TABLE public.users (
    user_id uuid NOT NULL,
    auth_id character varying(100) NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    cuit character varying(20),
    profile_picture_id uuid,
    sector_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    last_access timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    identity_check jsonb,
    audit_data jsonb,
    default_seal_id bigint
);
```

---

## Tabla: `ranks`

**Propósito:** Define los niveles jerárquicos o rangos funcionales (ej. Intendente, Secretario, Director) para asignarlos a las reparticiones y controlar permisos.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `rank_id` | `uuid` | **PK** - Identificador único del rango. |
| `rank_name` | `varchar` | Nombre del rango (ej. "Secretaría"). |
| `head_signature` | `varchar` | Cargo que aparecerá en la firma (ej. "Secretario"). |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.ranks (
    rank_id uuid NOT NULL,
    rank_name character varying(100) NOT NULL,
    head_signature character varying(255) NOT NULL,
    audit_data jsonb
);
```
