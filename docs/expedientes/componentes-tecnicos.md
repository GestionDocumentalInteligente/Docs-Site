# Componentes Técnicos del Sistema

## Arquitectura del Módulo Expedientes

El Módulo de Expedientes está construido sobre una arquitectura de microservicios que garantiza escalabilidad, mantenibilidad y robustez en el procesamiento de trámites administrativos.

## Componentes Principales

| **Componente** | **Función Principal** |
|----------------|-----------------------|
| **Expedient Manager** | Motor central de gestión de expedientes y flujos de trabajo |
| **Document Linker** | Servicio de vinculación de documentos existentes al expediente |
| **Task Orchestrator** | Orquestador de solicitudes de actuación inter-áreas |
| **AI Assistant Engine** | Motor de inteligencia artificial para consultas conversacionales |
| **Access Control Manager** | Gestión granular de permisos (RBAC y ACLs) para expedientes |
| **OFICIAL NUMBER** | Servicio de numeración oficial para expedientes y carátulas |
| **PDF Generator** | Generador automático de carátulas y reportes de expedientes |

## Servicios de Integración

### Expedient Manager
- **Responsabilidad**: Coordina el ciclo de vida completo del expediente
- **Funciones**: Creación, asignación, transferencia y gestión de estados
- **Interfaces**: API REST para operaciones CRUD y flujos de trabajo

**Referencia de Tabla SQL**
| Campo | Tipo | Descripción |
|-------|------|-------------|
|       |      |             |

### Document Linker
- **Responsabilidad**: Gestiona la vinculación bidireccional con el Módulo Documentos
- **Funciones**: Vinculación, subsanación y trazabilidad de documentos
- **Interfaces**: Comunicación asíncrona con el servicio de documentos

**Referencia de Tabla SQL**
| Campo | Tipo | Descripción |
|-------|------|-------------|
|       |      |             |

### Task Orchestrator
- **Responsabilidad**: Coordina solicitudes de actuación entre sectores
- **Funciones**: Creación, asignación, seguimiento y finalización de tareas
- **Interfaces**: Sistema de notificaciones y workflows dinámicos

**Referencia de Tabla SQL**
| Campo | Tipo | Descripción |
|-------|------|-------------|
|       |      |             |

### AI Assistant Engine
- **Responsabilidad**: Proporciona capacidades de inteligencia artificial
- **Funciones**: Análisis conversacional, resúmenes y sugerencias contextuales
- **Interfaces**: API de procesamiento de lenguaje natural

**Referencia de Tabla SQL**
| Campo | Tipo | Descripción |
|-------|------|-------------|
|       |      |             |

### Access Control Manager
- **Responsabilidad**: Gestiona permisos granulares y control de acceso
- **Funciones**: Validación de permisos, RBAC y ACLs por expediente
- **Interfaces**: Middleware de autorización y auditoría

**Referencia de Tabla SQL**
| Campo | Tipo | Descripción |
|-------|------|-------------|
|       |      |             |

### OFICIAL NUMBER
- **Responsabilidad**: Genera identificadores únicos oficiales
- **Funciones**: Numeración secuencial, validación de unicidad
- **Interfaces**: Servicio transaccional con garantías de atomicidad

**Referencia de Tabla SQL**
| Campo | Tipo | Descripción |
|-------|------|-------------|
|       |      |             |

### PDF Generator
- **Responsabilidad**: Genera documentos PDF automáticamente
- **Funciones**: Carátulas, reportes y visualizaciones de expedientes
- **Interfaces**: Templates dinámicos y renderizado en tiempo real

**Referencia de Tabla SQL**
| Campo | Tipo | Descripción |
|-------|------