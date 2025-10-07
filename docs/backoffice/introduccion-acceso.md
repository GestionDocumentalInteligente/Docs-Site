# Módulo Backoffice GDI

## 1. ¿Qué es el Backoffice de GDI?

El **Backoffice de GDI** es el centro neurálgico de administración y configuración del sistema. Es una **interfaz web separada**, con su propio dominio de acceso, diseñada específicamente para que los Administradores puedan adaptar y personalizar cada instancia de GDI a las necesidades específicas de su municipio.

### Propósito Principal

Establecer las **reglas de negocio**, la **identidad visual**, la **estructura organizacional** y los **parámetros operativos** que gobernarán el comportamiento de GDI para todos los usuarios finales del sistema principal.

### Características Principales

- **Interfaz Separada**: Dominio independiente del sistema principal de GDI
- **Configuración Centralizada**: Un lugar único para todas las configuraciones del sistema
- **Personalización Completa**: Adapta GDI a la identidad y necesidades de cada municipalidad
- **Control Total**: Define reglas y parámetros que afectan a todos los usuarios
- **Monitoreo Integral**: Visualización del uso y rendimiento del sistema

## 2. Acceso y Permisos

### 2.1 Rol Administrador

El acceso al Backoffice está **exclusivamente restringido** a usuarios con el rol de **Administrador** (definido en `roles.role_name`). Este es un rol de máximo privilegio, asignado a través de la tabla `user_roles`, diseñado para un número limitado de personas de confianza dentro de la institución, responsables de la configuración y funcionamiento de la plataforma.

#### Características del Administrador:

- Acceso completo a todas las configuraciones del sistema
- Capacidad de modificar parámetros críticos y reglas de negocio
- Responsabilidad sobre la integridad de la configuración institucional
- Gestión de usuarios y estructura organizacional
- Control sobre tipos de documentos y expedientes disponibles

### 2.2 Restricciones de Acceso

#### Medidas de Seguridad:

- Solo usuarios con rol "Administrador" (registrado en `user_roles`) pueden acceder
- Dominio separado del sistema principal de GDI
- Autenticación adicional requerida
- Logs de auditoría completos para todas las acciones realizadas (almacenados en `audit_data` o `system_audit_log` si está implementado).
- Sesiones con timeout de seguridad