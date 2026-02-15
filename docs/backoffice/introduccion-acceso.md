# Introduccion y Acceso al Backoffice

## 1. Que es el Backoffice de GDI

El **Backoffice de GDI** es el panel de administracion y configuracion central del sistema. Se trata de una **aplicacion web independiente** con su propio dominio, disenada para que los Administradores adapten y personalicen cada instancia de GDI segun las necesidades de su municipio u organismo.

### Arquitectura Tecnica

El Backoffice opera como un stack separado del sistema principal:

| Componente | Tecnologia | Puerto | Descripcion |
|------------|-----------|--------|-------------|
| **Frontend** | Next.js 15 | `:3013` | Interfaz administrativa (GDI-BackOffice-Front) |
| **Backend** | FastAPI (Python) | `:8010` | API de configuracion (GDI-BackOffice-Back) |
| **Base de Datos** | PostgreSQL + pgvector | Compartida | Misma BD que el sistema principal, tablas de configuracion |
| **Autenticacion** | Auth0 | -- | Proveedor de identidad externo |

```
GDI-BackOffice-Front (:3013)  ──────►  GDI-BackOffice-Back (:8010)
         │                                        │
         │  Auth0 (Autenticacion)                  │
         │                                        ▼
         └──────────────────────────►  PostgreSQL (BD compartida)
```

### Proposito Principal

Establecer las **reglas de negocio**, la **identidad visual**, la **estructura organizacional** y los **parametros operativos** que gobiernan el comportamiento de GDI para todos los usuarios del sistema principal.

### Caracteristicas Principales

- **Interfaz Separada**: Dominio independiente del sistema principal de GDI
- **Configuracion Centralizada**: Un lugar unico para todas las configuraciones del sistema
- **Personalizacion Completa**: Adapta GDI a la identidad y necesidades de cada municipalidad
- **Control Total**: Define reglas y parametros que afectan a todos los usuarios
- **Monitoreo Integral**: Visualizacion del uso y rendimiento del sistema

## 2. Acceso y Autenticacion

### 2.1 Rol Administrador

El acceso al Backoffice esta **exclusivamente restringido** a usuarios con el rol de **Administrador** (definido en `roles.role_name`). Este es un rol de maximo privilegio, asignado a traves de la tabla `user_roles`, disenado para un numero limitado de personas de confianza dentro de la institucion.

#### Responsabilidades del Administrador:

- Acceso completo a todas las configuraciones del sistema
- Capacidad de modificar parametros criticos y reglas de negocio
- Responsabilidad sobre la integridad de la configuracion institucional
- Gestion de la estructura organizacional (reparticiones, sectores, usuarios)
- Control sobre tipos de documentos y expedientes disponibles
- Administracion de integraciones y API Keys

### 2.2 Flujo de Autenticacion

El Backoffice utiliza **Auth0** como proveedor de identidad. El flujo de acceso es:

1. El Administrador accede a la URL del Backoffice (`:3013`)
2. Se redirige a Auth0 para autenticacion
3. Auth0 valida credenciales y retorna un token JWT
4. El frontend envia el token al backend (`:8010`) en cada request
5. El backend valida el token y verifica el rol "Administrador" en `user_roles`
6. Si el usuario no tiene rol Administrador, se deniega el acceso

### 2.3 Restricciones de Acceso

| Medida | Descripcion |
|--------|-------------|
| **Rol obligatorio** | Solo usuarios con rol "Administrador" en `user_roles` |
| **Dominio separado** | URL independiente del sistema principal |
| **Autenticacion via Auth0** | Proveedor de identidad externo robusto |
| **Logs de auditoria** | Todas las acciones se registran en `audit_data` o `system_audit_log` |
| **Timeout de sesion** | Sesiones con expiracion automatica por seguridad |

### 2.4 Limite de Administradores

El sistema establece un **maximo de 6 Administradores** activos simultaneamente. Este limite garantiza un control estricto sobre los roles con mayores privilegios. Las cuentas suspendidas o revocadas no se contabilizan en este limite.

## 3. Relacion con el Sistema Principal

Las configuraciones realizadas en el Backoffice tienen impacto directo e inmediato en el sistema GDI principal (`:3003` / `:8000`):

```
BACKOFFICE ────────────────────► SISTEMA GDI PRINCIPAL
    │
    ├── Informacion General ────► Identidad visual y datos institucionales
    ├── Organigrama ────────────► Estructura de usuarios y permisos
    ├── Documentos ─────────────► Tipos disponibles en creacion
    ├── Expedientes ────────────► Tipos disponibles en caratulacion
    ├── Accesos y Control ──────► Gestion de administradores
    ├── Integraciones ──────────► Servicios externos conectados
    └── API Keys ───────────────► Credenciales para integraciones
```

Los cambios se reflejan de forma inmediata: un nuevo tipo de documento aparece instantaneamente en el dropdown de creacion, una modificacion en el organigrama actualiza permisos en tiempo real, y los ajustes de identidad visual se aplican al momento.
