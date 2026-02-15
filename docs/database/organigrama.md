# Modelo de Datos: Modulo de Organigrama

Este documento detalla la estructura de las tablas principales que componen el modulo de Organigrama en GDI, responsable de la gestion de la estructura municipal, usuarios y jerarquias.

---

## Tabla: `municipalities`

**Proposito:** Almacena la informacion de cada municipio o entidad que utiliza la plataforma. Es el nivel mas alto de la jerarquia. Vive en el schema `public`.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id_municipality` | `uuid` | **PK** - Identificador unico del municipio. |
| `name` | `varchar` | Nombre oficial del municipio. |
| `country` | `country_enum` | Pais al que pertenece (AR, BR, UY, CL). |
| `acronym` | `varchar` | Sigla unica para el municipio (ej. "TNV"). |
| `schema_name` | `varchar` | Nombre del esquema de base de datos asignado. |
| `tax_identifier` | `varchar` | Identificador fiscal del municipio (CUIT/RUC). |
| `is_active` | `boolean` | `true` si el municipio esta activo en la plataforma. |
| `created_at` | `timestamp` | Fecha de creacion del registro. |
| `audit_data` | `jsonb` | Metadatos de auditoria. |
| `created_by` | `uuid` | **FK** - Usuario que registro el municipio. |

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

**Proposito:** Define las reparticiones, secretarias o direcciones que componen la estructura principal del municipio. Cada reparticion puede tener un titular (`head_user_id`) asignado.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `department_id` | `uuid` | **PK** - Identificador unico de la reparticion. |
| `name` | `varchar` | Nombre completo de la reparticion. |
| `acronym` | `varchar` | Sigla unica de la reparticion. |
| `parent_jurisdiction_id` | `uuid` | **FK** - ID de la reparticion padre para crear jerarquias. |
| `rank_id` | `uuid` | **FK** - Nivel jerarquico o rango (`ranks`). |
| `head_user_id` | `uuid` | **FK** - Usuario titular o responsable de la reparticion (`users`). |
| `is_active` | `boolean` | `true` si la reparticion esta operativa. |
| `start_date` | `timestamp` | Fecha de inicio de actividades. |
| `end_date` | `timestamp` | Fecha de cese de actividades. |
| `primary_color` | `varchar(7)` | Color visual asociado (formato hex, ej. "#3A3A9A"). |
| `audit_data` | `jsonb` | Metadatos de auditoria. |
| `municipality_id` | `uuid` | **FK** - Municipio al que pertenece (`municipalities`). |

```sql
CREATE TABLE departments (
    department_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    acronym character varying(20),
    parent_jurisdiction_id uuid,
    rank_id uuid,
    head_user_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    start_date timestamp without time zone DEFAULT CURRENT_DATE NOT NULL,
    end_date timestamp without time zone,
    primary_color varchar(7),
    audit_data jsonb,
    municipality_id uuid,
    CONSTRAINT departments_pkey PRIMARY KEY (department_id),
    CONSTRAINT departments_rank_fkey FOREIGN KEY (rank_id) REFERENCES ranks(rank_id)
);
```

---

## Tabla: `sectors`

**Proposito:** Representa las subdivisiones o equipos de trabajo dentro de una reparticion.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `sector_id` | `uuid` | **PK** - Identificador unico del sector. |
| `department_id` | `uuid` | **FK** - Reparticion a la que pertenece el sector (`departments`). |
| `acronym` | `varchar` | Sigla unica del sector dentro de su reparticion. |
| `is_active` | `boolean` | `true` si el sector esta operativo. |
| `start_date` | `timestamp` | Fecha de inicio de actividades. |
| `end_date` | `timestamp` | Fecha de cese de actividades. |
| `primary_color` | `varchar(7)` | Color visual asociado (formato hex). |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE sectors (
    sector_id uuid NOT NULL,
    department_id uuid NOT NULL,
    acronym character varying(50) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone,
    primary_color varchar(7),
    audit_data jsonb,
    CONSTRAINT sectors_pkey PRIMARY KEY (sector_id)
);
```

---

## Tabla: `users`

**Proposito:** Almacena la informacion de todos los usuarios del sistema, vinculandolos a la estructura organizacional y al sistema de autenticacion.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `user_id` | `uuid` | **PK** - Identificador unico del usuario en la aplicacion. |
| `auth_id` | `varchar` | ID del usuario en el sistema de autenticacion (Supabase Auth). |
| `full_name` | `varchar` | Nombre completo del usuario. |
| `email` | `varchar` | Correo electronico unico del usuario. |
| `cuit` | `varchar` | CUIT/CUIL del usuario. |
| `profile_picture_id` | `uuid` | **FK** - Referencia a la imagen de perfil (`media_files`). |
| `sector_id` | `uuid` | **FK** - Sector principal al que pertenece el usuario (`sectors`). |
| `is_active` | `boolean` | `true` si el usuario puede acceder al sistema. |
| `last_access` | `timestamp` | Fecha y hora del ultimo acceso. |
| `created_at` | `timestamp` | Fecha de creacion del usuario. |
| `identity_check` | `jsonb` | Datos de verificacion de identidad (RENAPER, etc.). |
| `audit_data` | `jsonb` | Metadatos de auditoria. |
| `default_seal_id` | `bigint` | ID del sello por defecto para las firmas del usuario. |

```sql
CREATE TABLE users (
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
    default_seal_id bigint,
    CONSTRAINT users_pkey PRIMARY KEY (user_id)
);
```

---

## Tabla: `ranks`

**Proposito:** Define los niveles jerarquicos o rangos funcionales (ej. Intendente, Secretario, Director) para asignarlos a las reparticiones. Esta tabla es per-tenant (vive en el schema del municipio).

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `rank_id` | `uuid` | **PK** - Identificador unico del rango. |
| `name` | `varchar` | Nombre del rango (ej. "Secretaria"). |
| `level` | `integer` | Nivel jerarquico numerico (menor = mas alto). |
| `head_signature` | `varchar` | Cargo que aparecera en la firma (ej. "Secretario"). |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE ranks (
    rank_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    level integer,
    head_signature character varying(255) NOT NULL,
    audit_data jsonb,
    CONSTRAINT ranks_pkey PRIMARY KEY (rank_id)
);
```

---

## Tabla: `user_sector_permissions`

**Proposito:** Otorga permisos especiales a un usuario sobre un sector especifico, mas alla de los permisos de su rol. Permite que un usuario opere en sectores adicionales al suyo principal.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `user_id` | `uuid` | **PK, FK** - Referencia al usuario (`users`). |
| `sector_id` | `uuid` | **PK, FK** - Referencia al sector (`sectors`). |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE user_sector_permissions (
    user_id uuid NOT NULL,
    sector_id uuid NOT NULL,
    audit_data jsonb,
    CONSTRAINT user_sector_permissions_pkey PRIMARY KEY (user_id, sector_id)
);
```
