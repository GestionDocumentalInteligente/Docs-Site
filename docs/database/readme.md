# Documentacion del Modelo de Datos

Este directorio contiene todos los documentos que describen la estructura de la base de datos de GDI. La documentacion esta organizada en los siguientes archivos:

## Archivos de Documentacion

- **[documentos.md](./documentos.md)**: Detalla el modelo de datos completo para el modulo de gestion de documentos.
    - `document_draft`: Tabla principal para los documentos en proceso de creacion y firma.
    - `official_documents`: Contiene la version final y legalmente valida de los documentos.
    - `document_signers`: Gestiona la lista de firmantes y el orden de firma de un documento.
    - `document_rejections`: Historial de los rechazos de un documento.
    - `document_chunks`: Chunks de documentos oficiales con embeddings para busqueda semantica (RAG).
    - `notes_recipients` y `notes_openings`: Sistema de notas oficiales con destinatarios y tracking de lectura.
    - Numeracion oficial: mecanismo `global_sequence` y advisory lock `888888`.

- **[organigrama.md](./organigrama.md)**: Describe las tablas de la estructura organizacional principal.
    - `municipalities`: Tabla raiz que define cada municipio en la plataforma.
    - `departments`: Define las reparticiones o secretarias de un municipio.
    - `sectors`: Representa los equipos o areas dentro de una reparticion.
    - `users`: Almacena la informacion de todos los usuarios del sistema.
    - `ranks`: Define los niveles jerarquicos o rangos (Intendente, Secretario, etc.).
    - `user_sectors`: Permisos de usuario por sector (via `user_sector_permissions`).

- **[plantillas.md](./plantillas.md)**: Contiene la documentacion de las tablas de plantillas para documentos y expedientes.
    - `global_document_types`: Catalogo maestro de tipos de documentos estandar.
    - `document_types`: Implementacion local de los tipos de documento para un municipio.
    - `case_templates`: Plantillas de expedientes por municipio, vinculadas a `global_case_templates`.

- **[roles-y-permisos.md](./roles-y-permisos.md)**: Explica las tablas del sistema de control de acceso (RBAC) y sellos institucionales.
    - `roles`: Define los roles funcionales (Administrador, Agente).
    - `permissions`: Catalogo de acciones especificas que se pueden realizar.
    - `role_permissions` y `user_roles`: Asignan permisos a los roles y roles a los usuarios.
    - `city_seals` y `user_seals`: Gestionan los sellos institucionales para las firmas.

- **[expediente-tables.md](./expediente-tables.md)**: Describe las tablas principales del modulo de expedientes.
    - `cases`: Tabla principal de expedientes.
    - `case_official_documents`: Documentos oficiales vinculados a un expediente.
    - `case_proposed_documents`: Documentos propuestos/borradores vinculados a un expediente.
    - `case_templates` y `case_template_allowed_departments`: Configuracion de plantillas.

- **[expediente-movements.md](./expediente-movements.md)**: Detalla el sistema de movimientos y trazabilidad de expedientes.
    - `case_movements`: Registra todos los movimientos de un expediente (creacion, transferencia, asignacion, etc.).
    - Tipos de movimiento: creation, transfer, assignment, assignment_close, status_change, document_link, subsanacion.

- **[configuracion-y-media.md](./configuracion-y-media.md)**: Describe las tablas para la configuracion visual y la gestion de archivos.
    - `settings`: Almacena la configuracion de personalizacion (colores, logos, ciudad, etc.) para cada municipio.
    - `media_files`: Repositorio central para todos los archivos multimedia subidos al sistema.
