# Estructura del Backoffice

## 3.1 Secciones Principales

El Backoffice está organizado en **7 secciones principales**, cada una diseñada para configurar aspectos específicos del sistema:

| **Sección** | **Propósito** | **Elementos Configurables** |
|-------------|---------------|------------------------------|
| **Información General** | Datos oficiales e identidad visual de la municipalidad | Nombre oficial, tipo de entidad, datos fiscales, logotipo, colores institucionales, frase anual (almacenado en `municipalities_settings`) |
| **Accesos y Control** | Gestión de usuarios y permisos | Usuarios de administrador (gestionado vía `user_roles` y `roles`) |
| **Organigrama** | Estructura organizacional | Reparticiones, sectores, responsables (gestionado vía `departments`, `sectors`, `users`, `department_heads`) |
| **Documentos** | Tipos de documentos disponibles | Plantillas, firmas, numeración (gestionado vía `document_types`) |
| **Expedientes** | Tipos de expedientes del sistema | Configuración de trámites y procesos (gestionado vía `record_templates`) |
| **Integraciones** | Conectores externos | APIs, servicios terceros, autenticaciones (gestionado vía `integraciones_config_table`) |
| **API KEY** | Gestión de credenciales de servicios externos | Credenciales y tokens de acceso (gestionado vía `api_keys_table`) |

## 3.2 Impacto de las Configuraciones

Las configuraciones realizadas en el Backoffice tienen un impacto directo e inmediato en el sistema GDI principal:

```
BACKOFFICE -----> SISTEMA GDI PRINCIPAL
    │
    ├── Información General ────► Identidad visual y datos institucionales (en `municipalities_settings`)
    ├── Organigrama ───────────► Estructura de usuarios y permisos (en `departments`, `sectors`, `users`, `user_roles`)  
    ├── Documentos ────────────► Tipos disponibles en creación (en `document_types`)
    ├── Expedientes ───────────► Tipos disponibles en caratulación (en `record_templates`)
    ├── Accesos y Control ─────► Gestión de administradores (en `user_roles`, `roles`)
    ├── Integraciones ─────────► Servicios externos conectados (en `integraciones_config_table`)
    └── API Keys ──────────────► Credenciales para integraciones (en `api_keys_table`)
```

### Efectos Inmediatos:

- **Cambios en Información General**: Se reflejan inmediatamente en logos, colores y datos de la interfaz principal
- **Modificaciones en Organigrama**: Actualizan la estructura de usuarios y permisos en tiempo real  
- **Configuración de Documentos**: Los nuevos tipos aparecen instantáneamente en los dropdowns de creación
- **Ajustes en Expedientes**: Los tipos configurados se habilitan de inmediato para caratulación
- **Gestión de Accesos**: Los cambios en administradores se aplican en la siguiente sesión
- **Integraciones y API Keys**: Las conexiones se establecen o cortan inmediatamente