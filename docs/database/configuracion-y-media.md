# Modelo de Datos: Configuración y Multimedia

Este documento detalla la estructura de las tablas utilizadas para la configuración general de los municipios y la gestión de archivos multimedia.

---

## Tabla: `municipalities_settings`

**Propósito:** Almacena toda la configuración de personalización para cada municipio, como su identidad visual, datos de contacto y otros parámetros específicos.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id_municipality` | `uuid` | **PK, FK** - Referencia al municipio (`municipalities`). |
| `adress` | `varchar` | Domicilio principal de la entidad. |
| `contact_email` | `varchar` | Correo electrónico de contacto oficial. |
| `website_url` | `varchar` | Sitio web institucional. |
| `primary_color` | `varchar` | Color primario de la marca en formato hexadecimal (ej. "#3A3A9A"). |
| `annual_slogan` | `varchar` | Lema o frase anual que puede usarse en documentos. |
| `logo_id` | `uuid` | **FK** - Referencia al logo institucional en `media_files`. |
| `isologo_id` | `uuid` | **FK** - Referencia al isologo en `media_files`. |
| `cover_image_id` | `uuid` | **FK** - Referencia a la imagen de portada en `media_files`. |
| `timezone` | `varchar` | Zona horaria para el municipio (ej. "America/Argentina/Buenos_Aires"). |
| `audit_data` | `jsonb` | Metadatos de auditoría. |

```sql
CREATE TABLE public.municipalities_settings (
    id_municipality uuid NOT NULL,
    adress character varying(150),
    contact_email character varying(100),
    website_url character varying(150),
    primary_color character varying(7),
    annual_slogan character varying(255),
    logo_id uuid,
    isologo_id uuid,
    cover_image_id uuid,
    timezone character varying(50) NOT NULL,
    audit_data jsonb
);
```

---

## Tabla: `media_files`

**Propósito:** Actúa como un repositorio central para todos los archivos multimedia subidos al sistema, como logos, isologos, imágenes de portada, etc.

| Columna | Tipo de Dato | Descripción |
|---|---|---|
| `id` | `uuid` | **PK** - Identificador único del archivo. |
| `name` | `varchar` | Nombre descriptivo del archivo. |
| `url` | `varchar` | URL pública o interna donde se almacena el archivo. |
| `type` | `varchar` | Tipo de archivo (ej. "logo", "profile_picture"). |
| `uploaded_by` | `uuid` | **FK** - Usuario que subió el archivo (`users`). |
| `uploaded_at` | `timestamp` | Fecha y hora de la subida. |
| `metadata` | `jsonb` | Metadatos adicionales como tamaño, dimensiones, etc. |

```sql
CREATE TABLE public.media_files (
    id uuid NOT NULL,
    name character varying(150) NOT NULL,
    url character varying(255) NOT NULL,
    type character varying(50) NOT NULL,
    uploaded_by uuid,
    uploaded_at timestamp without time zone DEFAULT now(),
    metadata jsonb
);
```
