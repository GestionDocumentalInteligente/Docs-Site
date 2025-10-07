# Documentación del Modelo de Datos

Este directorio contiene todos los documentos que describen la estructura de la base de datos de la aplicación GDI. La documentación está organizada en los siguientes archivos:

## Archivos de Documentación

- **[Configuracion_y_Media.md](./Configuracion_y_Media.md)**: Describe las tablas para la configuración visual y la gestión de archivos.
    - `municipalities_settings`: Almacena la configuración de personalización (colores, logos, etc.) para cada municipio.
    - `media_files`: Repositorio central para todos los archivos multimedia subidos al sistema.

- **[Documentos.md](./Documentos.md)**: Detalla el modelo de datos completo para el módulo de gestión de documentos.
    - `document_draft`: Tabla principal para los documentos en proceso de creación y firma.
    - `official_documents`: Contiene la versión final y legalmente válida de los documentos.
    - `document_signers`: Gestiona la lista de firmantes y el orden de firma de un documento.
    - `document_rejections`: Historial de los rechazos de un documento.
    - `numeration_requests`: Administra la reserva de números oficiales para garantizar la secuencialidad.

- **[Organigrama.md](./Organigrama.md)**: Describe las tablas de la estructura organizacional principal.
    - `municipalities`: Tabla raíz que define cada municipio en la plataforma.
    - `departments`: Define las reparticiones o secretarías de un municipio.
    - `sectors`: Representa los equipos o áreas dentro de una repartición.
    - `users`: Almacena la información de todos los usuarios del sistema.
    - `ranks`: Define los niveles jerárquicos o rangos (Intendente, Secretario, etc.).

- **[Plantillas.md](./Plantillas.md)**: Contiene la documentación de las tablas de plantillas para documentos y expedientes.
    - `global_document_types`: Catálogo maestro de tipos de documentos estándar.
    - `document_types`: Implementación local de los tipos de documento para un municipio.
    - `tipos_expediente`: Define los diferentes tipos de trámites que se pueden gestionar.

- **[Roles_y_Permisos.md](./Roles_y_Permisos.md)**: Explica las tablas del sistema de control de acceso (RBAC) y sellos institucionales.
    - `roles`: Define los roles funcionales (Administrador, Agente).
    - `permissions`: Catálogo de acciones específicas que se pueden realizar.
    - `role_permissions` y `user_roles`: Asignan permisos a los roles y roles a los usuarios.
    - `global_seals` y `city_seals`: Gestionan los sellos institucionales para las firmas.

## Directorios Adicionales

- **DumpTEST/**: Contiene volcados (`dumps`) completos de la base de datos utilizados como fuente para generar esta documentación.

- **Tablas Expediente/**: Contendrá la documentación para el módulo de expedientes *(actualmente pendiente de elaboración)*.
