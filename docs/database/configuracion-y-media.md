# Modelo de Datos: Configuracion y Multimedia

Este documento detalla la estructura de las tablas utilizadas para la configuracion general de los municipios y la gestion de archivos multimedia.

---

## Tabla: `settings`

**Proposito:** Almacena toda la configuracion de personalizacion para cada municipio, como su identidad visual, datos de contacto y otros parametros especificos. Cada schema de municipio tiene exactamente una fila en esta tabla.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico del registro de configuracion. |
| `address` | `varchar` | Domicilio principal de la entidad. |
| `contact_email` | `varchar` | Correo electronico de contacto oficial. |
| `website_url` | `varchar` | Sitio web institucional. |
| `primary_color` | `varchar(6)` | Color primario de la marca en formato hex sin # (ej. "16158C"). |
| `annual_slogan` | `varchar` | Lema o frase anual que puede usarse en documentos. |
| `logo_url` | `text` | URL al logo institucional (almacenado en Cloudflare R2). |
| `isologo_url` | `text` | URL al isologo (almacenado en Cloudflare R2). |
| `cover_url` | `text` | URL a la imagen de portada (almacenado en Cloudflare R2). |
| `timezone` | `varchar` | Zona horaria para el municipio (ej. "America/Argentina/Buenos_Aires"). |
| `city` | `varchar(100)` | Ciudad del municipio, usada en sellos de firma digital. |
| `audit_data` | `jsonb` | Metadatos de auditoria. |

```sql
CREATE TABLE settings (
    id UUID DEFAULT gen_random_uuid() NOT NULL,
    address VARCHAR(150),
    contact_email VARCHAR(100),
    website_url VARCHAR(150),
    primary_color VARCHAR(6) DEFAULT '16158C',
    annual_slogan VARCHAR(255),
    logo_url TEXT,
    isologo_url TEXT,
    cover_url TEXT,
    timezone VARCHAR(50) NOT NULL,
    city VARCHAR(100) DEFAULT 'LATAM',
    audit_data JSONB,
    CONSTRAINT settings_pkey PRIMARY KEY (id)
);
```

---

## Tabla: `media_files`

**Proposito:** Actua como un repositorio central para todos los archivos multimedia subidos al sistema, como fotos de perfil de usuarios.

| Columna | Tipo de Dato | Descripcion |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador unico del archivo. |
| `name` | `varchar` | Nombre descriptivo del archivo. |
| `url` | `varchar` | URL publica o interna donde se almacena el archivo (Cloudflare R2). |
| `type` | `varchar` | Tipo de archivo (ej. "profile_picture"). |
| `uploaded_by` | `uuid` | **FK** - Usuario que subio el archivo (`users`). |
| `uploaded_at` | `timestamp` | Fecha y hora de la subida. |
| `metadata` | `jsonb` | Metadatos adicionales como tamanio, dimensiones, etc. |

```sql
CREATE TABLE media_files (
    id uuid NOT NULL,
    name character varying(150) NOT NULL,
    url character varying(255) NOT NULL,
    type character varying(50) NOT NULL,
    uploaded_by uuid,
    uploaded_at timestamp without time zone DEFAULT now(),
    metadata jsonb,
    CONSTRAINT media_files_pkey PRIMARY KEY (id)
);
```
