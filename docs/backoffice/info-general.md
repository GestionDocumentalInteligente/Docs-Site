# Configuración de Información General

## 1. Propósito de la Sección

La sección de **Información General** es el primer y más fundamental paso en la configuración de una nueva instancia de GDI. Permite al Administrador establecer la identidad oficial y la apariencia visual del municipio u organismo, asegurando que estos elementos se apliquen de manera consistente en todo el sistema.

## 2. Información Institucional

Este apartado agrupa los datos básicos que definen legal y administrativamente a la entidad. Esta información se utilizará en encabezados de documentos, carátulas de expedientes y otras comunicaciones oficiales.

### 2.1 Tabla de Campos y Descripciones

| **Campo en Pantalla** | **Descripción** | **Ejemplo** | **Reglas y Validaciones** |
|----------------------|-----------------|-------------|---------------------------|
| **Tipo de entidad** | Define el contexto legal y administrativo del organismo. | Municipio | Campo de selección (dropdown o texto fijo). (posible `municipalities.type` o campo similar) |
| **Nombre de la ciudad** | El nombre oficial completo del ente/ecosistema. | Municipalidad de Terranova | Texto libre. Campo obligatorio. (`municipalities.name`) |
| **Acrónimo** | Sigla o código corto que identifica a la entidad en la numeración de documentos y expedientes. | MDT | Texto corto (ej. 3-5 caracteres). Único en el sistema. (`municipalities.acronym`) |
| **Domicilio fiscal** | Campo de búsqueda de direcciones autocompletado. Permite seleccionar la dirección legal principal de la entidad de forma estandarizada, utilizando un servicio de geolocalización. | Avenida del Centro 1234 | No es texto libre. Valida y estructura la dirección (calle, número, ciudad, país). (`municipalities_settings.adress`) |
| **Nro. Identificación Tributaria** | El identificador fiscal de la entidad (CUIT, RUC, etc., según el país). | 01010101010101 | Formato numérico. (`municipalities.tax_identifier`) |

## 3. Identidad Visual

Esta sección personaliza la apariencia de GDI para que coincida con la imagen de marca de la institución, garantizando una experiencia de usuario coherente y profesional.

### 3.1 Tabla de Elementos Visuales

| **Campo en Pantalla** | **Descripción** | **Especificaciones Técnicas** |
|----------------------|-----------------|-------------------------------|
| **Logo Institucional** | El logo principal que aparecerá en la esquina superior de la interfaz y en todos los documentos oficiales. | Formato: PNG, JPG, GIF. Tamaño Máx: 5MB. Se recomienda PNG con fondo transparente. (`municipalities_settings.logo_id`) |
| **Color Institucional** | El color primario de la marca, usado en botones, enlaces y elementos destacados de la interfaz. | Selector de color con código hexadecimal (ej. #3A3A9A). (`municipalities_settings.primary_color`) |
| **Isologo Institucional** | Una versión compacta o alternativa del logo, a menudo sin texto (el puro símbolo). Puede usarse en áreas donde el logo completo no cabe. | Formato: PNG, JPG, GIF. Tamaño Máx: 5MB. (`municipalities_settings.isologo_id`) |
| **Imagen portada** | Imagen de fondo o bienvenida que se muestra en pantallas de inicio de sesión o en procesos de incorporación de nuevos usuarios. | Formato: PNG, JPG, GIF. Tamaño Máx: 5MB. (`municipalities_settings.cover_image_id`) |
| **Frase anual (opcional)** | Un lema o frase que se puede incluir en los encabezados de los documentos, a menudo relacionado con el año en curso. | Texto libre. Su uso se define en las plantillas de documentos. (`municipalities_settings.annual_slogan`) |

## 4. Flujo de Configuración y Validaciones

### Proceso paso a paso:

1. **Completar Campos**: El Administrador rellena todos los campos de "Información Institucional" y sube los archivos de "Identidad Visual".

2. **Validaciones**: El sistema valida que los campos obligatorios (como Nombre y Acrónimo) no estén vacíos y que los archivos subidos cumplan con las restricciones de formato y tamaño.

3. **Guardar Cambios**: Al presionar el botón "Guardar Cambios", la configuración se aplica de forma inmediata en toda la plataforma, afectando:

### Efectos inmediatos:

- **Interfaz Web**: El Logo Institucional y el Color Institucional se actualizan en tiempo real.
- **Módulos Documentos y Expedientes**: Todos los nuevos documentos y carátulas generados a partir de este momento utilizarán la nueva información y logos. Los documentos existentes no se modifican para preservar su integridad histórica.