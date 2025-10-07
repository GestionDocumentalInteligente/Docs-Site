# Backoffice GDI - Configuración de Accesos y Control

## Propósito de la Sección

La **Configuración de Accesos y Control** permite a los Administradores gestionar el acceso al Backoffice de GDI, controlando quién puede administrar el sistema y configurar sus parámetros críticos. Esta sección implementa un modelo de **administración distribuida** donde múltiples Administradores pueden colaborar en la gestión del sistema.

### Objetivos principales:

- **Control de acceso granular**: Gestionar quién puede acceder al Backoffice
- **Administración colaborativa**: Permitir múltiples Administradores con iguales privilegios
- **Seguridad robusta**: Implementar mejores prácticas de autenticación y autorización
- **Auditoría completa**: Mantener trazabilidad de todas las acciones administrativas
- **Gestión simplificada**: Proveer herramientas intuitivas para administrar accesos

### Características principales:

- **Límite controlado**: Máximo 6 Administradores por instalación
- **Igualdad de privilegios**: Todos los Administradores tienen los mismos permisos
- **Gestión mutua**: Los Administradores pueden gestionar otros Administradores
- **Invitaciones seguras**: Sistema de invitación por email con expiración temporal
- **Flexibilidad de usuarios**: Soporte para usuarios nuevos y existentes

## Gestión de Administradores

### Características del Sistema

#### Modelo de Privilegios Equitativos

- **Todos los Administradores tienen idénticos permisos**
- **No existe jerarquía** entre Administradores
- **Cualquier Admin puede gestionar otros Admins**
- **Decisiones por consenso** (no hay "super usuario principal")

#### Límites del Sistema

- **Máximo 6 Administradores simultáneos**
- **Límite aplicado a nivel de aplicación y base de datos**
- **Restricción configurable** (ajustable en configuración del sistema)

### Operaciones Disponibles

#### Gestión de Usuarios Administrador

| **Acción** | **Descripción** | **Quién puede ejecutarla** |
|------------|-----------------|----------------------------|
| **Invitar Admin** | Enviar invitación por email | Cualquier Admin activo |
| **Reactivar Admin** | Activar cuenta suspendida | Cualquier Admin activo |
| **Suspender Admin** | Suspender temporalmente acceso | Cualquier Admin activo |
| **Revocar acceso** | Eliminar permanentemente acceso | Cualquier Admin activo |
| **Ver auditoría** | Consultar logs de actividad | Cualquier Admin activo |

#### Restricciones de Auto-Gestión

- **Un Admin NO puede suspenderse a sí mismo**
- **Un Admin NO puede revocarse acceso a sí mismo**
- **Un Admin SÍ puede ver su propia auditoría**

## Flujo de Invitación y Registro

### Proceso de Invitación

#### Paso 1: Crear Invitación

```
Administrador → [Invitar Nuevo Admin]
├── Ingresa email del invitado
├── Sistema valida email único
├── Sistema verifica límite de 6 Admins
└── Sistema genera token de invitación único
```

#### Paso 2: Envío de Invitación

```
Sistema → [Envío Automático de Email]
├── Email con enlace de activación
├── Token con expiración de 48 horas
├── Instrucciones de activación
└── Datos de contacto de soporte
```

#### Paso 3: Activación por Invitado

```
Usuario → [Acceso a enlace de invitación]
├── Validación de token no expirado
├── Formulario de activación
└── Dos escenarios posibles:
    ├── Usuario NUEVO → Crear cuenta completa
    └── Usuario EXISTENTE → Vincular cuenta existente
```

### Escenarios de Activación

#### Escenario A: Usuario Nuevo

```
Formulario de Registro Completo:
├── Datos personales obligatorios:
│   ├── Nombre completo
│   ├── Email (pre-completado)
│   ├── Teléfono
│   └── Cargo/Función en la institución
├── Configuración de acceso:
│   ├── Contraseña (mínimo 12 caracteres)
│   ├── Confirmar contraseña
│   └── Pregunta de seguridad (opcional)
└── Aceptación de términos y condiciones
```

#### Escenario B: Usuario Existente

```
Formulario de Vinculación:
├── Identificación de cuenta existente:
│   ├── Email confirmado (pre-completado)
│   ├── Contraseña actual
│   └── Verificación de identidad
├── Confirmación de elevación de privilegios
└── Aceptación de responsabilidades adicionales
```

### Estados de Invitación

| **Estado** | **Descripción** | **Duración** | **Acciones Disponibles** |
|------------|-----------------|--------------|---------------------------|
| **PENDIENTE** | Invitación enviada, no activada | 48 horas | Reenviar, Cancelar |
| **EXPIRADA** | Token venció sin activación | Permanente | Reenviar nueva |
| **ACTIVADA** | Usuario completó registro | Permanente | Gestionar usuario |
| **CANCELADA** | Invitación anulada manualmente | Permanente | Crear nueva |

## Estados y Gestión de Accesos

### Estados de Administrador

**ACTIVO**
- **Descripción:** Admin con acceso completo al Backoffice
- **Restricciones:** No puede auto-suspenderse o auto-revocar acceso

**REVOCADO**
- **Descripción:** Acceso eliminado permanentemente
- **Causa:** Cambio de personal, violación de políticas o decisión administrativa
- **Recuperación:** Nueva invitación desde cero (se crea cuenta nueva)

### Transiciones de Estado

```
INVITADO → [Activación exitosa] → ACTIVO
ACTIVO ↔ [Suspender/Reactivar] ↔ SUSPENDIDO
ACTIVO → [Inactivar] → INACTIVO
INACTIVO → [Reactivar] → ACTIVO
CUALQUIER_ESTADO → [Revocar] → REVOCADO
REVOCADO → [Nueva invitación] → INVITADO
```

### Gestión Automática

#### Inactividad Prolongada

- **Detección**: 90 días sin acceso al Backoffice
- **Acción**: Auto-suspensión temporal
- **Notificación**: Email al usuario y otros Admins
- **Recuperación**: Reactivación por otro Admin

#### Actividades Sospechosas

- **Múltiples intentos de acceso fallidos**
- **Acceso desde ubicaciones inusuales**
- **Modificaciones masivas en corto tiempo**
- **Acción**: Suspensión automática y alerta a otros Admins

## Auditoría y Trazabilidad

### Registro de Actividades

#### Eventos Auditados

| **Categoría** | **Eventos Registrados** |
|---------------|-------------------------|
| **Acceso** | Login exitoso/fallido, logout, sesión expirada |
| **Gestión de Usuarios** | Invitar, activar, suspender, revocar Admins |
| **Configuración** | Cambios en información general, organigrama, documentos |
| **Sistema** | Cambios en configuraciones críticas, integraciones |
| **Seguridad** | Intentos de acceso no autorizado, cambios de contraseña |

### Consulta y Reportes

#### Panel de Auditoría

- **Filtros disponibles**: Fecha, usuario, tipo de evento, categoría
- **Exportación**: CSV, PDF para análisis externos
- **Tiempo real**: Actualizaciones automáticas cada 30 segundos
- **Retención**: Mínimo 24 meses de historia

#### Alertas en Tiempo Real

- **Email inmediato**: Para eventos críticos de seguridad
- **Dashboard**: Notificaciones en interfaz del Backoffice
- **Frecuencia**: Resumen diario de actividades

## Interfaz de Usuario

### Panel Principal de Accesos

#### Vista de Lista de Administradores

Imagen de accesos y control

#### Estados Visuales

- 🟢 **ACTIVO**: Verde, acceso completo
- 🟡 **SUSPENDIDO**: Amarillo, acceso bloqueado temporalmente
- 🔴 **INACTIVO**: Rojo, cuenta deshabilitada
- ⚫ **REVOCADO**: Gris, acceso eliminado permanentemente

### Modal de Invitación

Imagen de flujo de invitación

Imagen de mail automático

### Panel de Invitaciones Pendientes

Imagen de estados de invitación

### Sección de Auditoría

Imagen de dashboard de auditoría

## Validaciones y Restricciones

### Validaciones de Negocio

#### Límite de Administradores

- **Restricción**: Se establece un máximo de 6 Administradores activos de forma simultánea para mantener un control estricto sobre los roles con mayores privilegios.
- **Validación**: Antes de poder enviar una nueva invitación para este rol, el sistema verifica automáticamente que el número de administradores activos no exceda el límite establecido.
- **Excepción**: Las cuentas que han sido suspendidas o cuyas invitaciones fueron revocadas no se contabilizan en este límite, permitiendo reemplazos sin demoras.

#### Email Único

- **Restricción**: Cada dirección de correo electrónico solo puede estar asociada a una única cuenta de Administrador, garantizando que cada cuenta pertenezca a una identidad única.
- **Validación**: El sistema comprueba la unicidad del email tanto al momento de enviar una invitación como en el paso final de activación de la cuenta.
- **Caso especial**: Si una cuenta es eliminada, la dirección de email asociada queda en un período de enfriamiento y solo podrá ser reutilizada para una nueva cuenta después de 30 días.

#### Auto-Gestión

- **Restricción**: Un Administrador no puede realizar acciones críticas sobre su propia cuenta, como suspenderla o revocar sus propios privilegios, para prevenir bloqueos accidentales o maliciosos.
- **Validación**: El sistema verifica que el identificador del usuario que realiza la acción no sea el mismo que el de la cuenta afectada antes de ejecutar operaciones críticas.
- **Excepción**: Esta restricción no aplica a la gestión de información personal; el usuario sí puede modificar sus propios datos o cambiar su contraseña libremente.

### Validaciones Técnicas

#### Formato de Email

- **Validación**: Se asegura de que la dirección de email cumpla con el estándar RFC 5322, garantizando una estructura y sintaxis correctas.
- **Restricciones adici