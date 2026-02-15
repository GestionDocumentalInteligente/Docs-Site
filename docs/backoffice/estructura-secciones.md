# Estructura y Secciones del Backoffice

## 1. Secciones Principales

El Backoffice esta organizado en **7 secciones principales**, cada una disenada para configurar aspectos especificos del sistema:

| **Seccion** | **Proposito** | **Elementos Configurables** |
|-------------|---------------|------------------------------|
| **Informacion General** | Datos oficiales e identidad visual de la municipalidad | Nombre oficial, tipo de entidad, datos fiscales, logotipo, colores institucionales, frase anual (en `municipalities_settings`) |
| **Accesos y Control** | Gestion de usuarios administradores y permisos | Usuarios administrador (via `user_roles` y `roles`) |
| **Organigrama** | Estructura organizacional completa | Reparticiones, sectores, responsables, sellos (via `departments`, `sectors`, `users`, `department_heads`, `ranks`) |
| **Documentos** | Tipos de documentos disponibles | Plantillas, configuracion de firma, numeracion (via `document_types`) |
| **Expedientes** | Tipos de expedientes del sistema | Configuracion de tramites, caratulacion, numeracion (via `record_templates`) |
| **Integraciones** | Conectores con servicios externos | APIs de IA, servicios gubernamentales, comunicaciones, firma digital |
| **API Keys** | Gestion de credenciales de servicios externos | Credenciales, tokens, certificados para integraciones |

## 2. Navegacion y Layout

### Estructura de la Interfaz

```
┌─────────────────────────────────────────────────────┐
│  Logo GDI    │     Backoffice - [Nombre Municipio]  │
├──────────────┼──────────────────────────────────────┤
│              │                                      │
│ ■ Info Gral  │                                      │
│ ■ Accesos    │        AREA DE CONTENIDO             │
│ ■ Organigrama│        PRINCIPAL                     │
│ ■ Documentos │                                      │
│ ■ Expedientes│        (Cambia segun seccion          │
│ ■ Integrac.  │         seleccionada)                │
│ ■ API Keys   │                                      │
│              │                                      │
├──────────────┴──────────────────────────────────────┤
│  Usuario: admin@municipio.gob.ar     [Cerrar Sesion]│
└─────────────────────────────────────────────────────┘
```

- **Sidebar izquierdo**: Menu de navegacion con las 7 secciones
- **Area principal**: Contenido dinamico segun la seccion seleccionada
- **Header**: Logo institucional y nombre del municipio
- **Footer**: Usuario activo y opciones de sesion

## 3. Impacto de las Configuraciones

Las configuraciones realizadas en el Backoffice tienen impacto directo e inmediato en el sistema GDI principal:

### Efectos Inmediatos

| Seccion | Efecto en el Sistema Principal |
|---------|-------------------------------|
| **Informacion General** | Logo, colores y datos institucionales se actualizan en tiempo real en toda la interfaz |
| **Accesos y Control** | Cambios en administradores se aplican en la siguiente sesion |
| **Organigrama** | Estructura de usuarios, permisos y jerarquias se actualizan inmediatamente |
| **Documentos** | Nuevos tipos aparecen instantaneamente en el dropdown de creacion |
| **Expedientes** | Tipos configurados se habilitan de inmediato para caratulacion |
| **Integraciones** | Conexiones se establecen o desconectan inmediatamente |
| **API Keys** | Credenciales se activan o revocan al momento |

### Flujo de Configuracion Recomendado

Para una nueva instalacion, se recomienda configurar las secciones en este orden:

```
1. Informacion General  ──► Establecer identidad del municipio
      │
2. Organigrama          ──► Crear reparticiones, sectores y usuarios
      │
3. Accesos y Control    ──► Configurar administradores adicionales
      │
4. Documentos           ──► Definir tipos de documentos disponibles
      │
5. Expedientes          ──► Configurar tipos de expedientes
      │
6. Integraciones        ──► Conectar servicios externos
      │
7. API Keys             ──► Registrar credenciales necesarias
```

## 4. Modelo de Datos Subyacente

Cada seccion del Backoffice opera sobre tablas especificas de la base de datos:

| Seccion | Tablas Principales |
|---------|--------------------|
| **Informacion General** | `municipalities`, `municipalities_settings` |
| **Accesos y Control** | `users`, `roles`, `user_roles` |
| **Organigrama** | `departments`, `sectors`, `users`, `user_sectors`, `department_heads`, `ranks`, `global_seals`, `city_seals`, `user_seals`, `rank_allowed_seals` |
| **Documentos** | `document_types`, `enabled_document_types_by_department`, `document_types_allowed_by_rank` |
| **Expedientes** | `record_templates` |
| **Integraciones** | Configuracion interna del sistema |
| **API Keys** | Almacenamiento cifrado de credenciales |

## 5. Permisos y Seguridad

Todas las secciones del Backoffice comparten las mismas restricciones:

- **Acceso exclusivo**: Solo usuarios con rol "Administrador"
- **Privilegios equitativos**: Todos los administradores tienen identicos permisos sobre todas las secciones
- **Auditoria completa**: Cada accion queda registrada con usuario, fecha y detalle del cambio
- **Validaciones de integridad**: El sistema previene configuraciones inconsistentes (ej: no permite eliminar una reparticion con usuarios activos)
