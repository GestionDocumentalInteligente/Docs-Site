# Backoffice GDI - Configuración de API Keys

## Propósito de la Sección

La **Configuración de API Keys** es el repositorio centralizado donde los Administradores gestionan todas las **credenciales y tokens** que GDI necesita para conectarse a servicios externos. Funciona como un **administrador de credenciales** seguro, similar a plataformas como OpenAI o AWS Console.

### Objetivos principales:

- **Centralizar credenciales**: Gestionar todas las API Keys desde un solo lugar
- **Seguridad robusta**: Almacenar credenciales de forma cifrada y segura
- **Control granular**: Gestionar permisos y límites por credencial
- **Monitoreo de uso**: Supervisar consumo y detectar anomalías
- **Gestión del ciclo de vida**: Crear, rotar, revocar y renovar credenciales

### Relación con Integraciones:

```
INTEGRACIONES: "¿Qué servicios quieres usar?"
↓
API KEYS: "¿Cuáles son las credenciales para acceder?"
```

## Gestión de API Keys

### Funcionalidades Principales

| **Función** | **Descripción** |
|-------------|-----------------|
| **Crear API Key** | Generar nueva credencial para servicios externos |
| **Ver API Keys** | Listar todas las credenciales configuradas |
| **Ocultar/Revelar** | Mostrar/ocultar valores sensibles por seguridad |
| **Renovar/Rotar** | Generar nueva versión de credencial existente |
| **Revocar** | Eliminar credencial permanentemente del sistema |
| **Configurar límites** | Establecer quotas y restricciones de uso |

### Ciclo de Vida de Credenciales

```
CREADA → [Configurar] → ACTIVA → [Usar] → ACTIVA
↓
[Renovar] → NUEVA_VERSIÓN
↓
[Revocar] → REVOCADA
```

### Categorías de Servicios

#### Servicios de IA

- API Keys para servicios de inteligencia artificial
- Tokens para procesamiento de lenguaje natural
- Credenciales para análisis de documentos
- Keys para servicios de automatización

#### Servicios Gubernamentales

- Certificados para validación de identidad
- Tokens para consulta de datos fiscales
- Credenciales para servicios ciudadanos
- Keys para sistemas de seguridad social

#### Servicios de Comunicación

- API Keys para envío de emails
- Tokens de autenticación para SMS
- Credenciales para mensajería empresarial
- Keys para servicios de notificación

#### Servicios de Almacenamiento

- Credenciales para almacenamiento en la nube
- Keys para servicios de backup
- Tokens para sincronización de archivos
- Credenciales para gestión de documentos

## Tipos de Credenciales

### API Key Simple

**Formato**: sk-1234567890abcdef...
**Uso**: Servicios con autenticación por token único
**Ejemplos**: Servicios de IA, plataformas de email, gateways de pago

### Key + Secret

**Formato**:
- Access Key: AKIA1234567890
- Secret Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

**Uso**: Servicios que requieren par de credenciales
**Ejemplos**: Servicios de almacenamiento, APIs de redes sociales, aplicaciones OAuth

### Certificados Digitales

**Formato**: Archivos .p12, .pem, .crt
**Uso**: Servicios gubernamentales y firma digital
**Ejemplos**: Validación de identidad, servicios fiscales, certificados SSL

### Tokens JWT/Bearer

**Formato**: eyJhbGciOiJIUzI1NiIs...
**Uso**: Servicios con autenticación temporal
**Ejemplos**: APIs gubernamentales, servicios de Microsoft, plataformas empresariales

## Estados y Monitoreo

### Estados de API Keys

| **Estado** | **Descripción** | **Indicador** | **Acciones Disponibles** |
|------------|-----------------|---------------|---------------------------|
| **ACTIVA** | Funcionando correctamente | 🟢 Verde | Ver, Configurar, Renovar, Revocar |
| **EXPIRADA** | Venció por tiempo o uso | 🟡 Amarillo | Renovar, Reemplazar, Revocar |
| **ERROR** | Problemas de autenticación | 🔴 Rojo | Verificar, Renovar, Reemplazar |
| **REVOCADA** | Eliminada permanentemente | ⚫ Gris | Solo visualizar historial |
| **LIMITADA** | Alcanzó quotas configuradas | 🟠 Naranja | Configurar límites, Upgrade |

### Métricas de Uso

#### Por API Key:

- **Requests totales**: Número de llamadas realizadas
- **Requests último mes**: Uso reciente
- **Última utilización**: Timestamp de último uso
- **Rate limit actual**: Límites configurados vs. usados
- **Errores**: Número de fallos de autenticación

#### Dashboard General:

- **Keys activas**: Total de credenciales funcionando
- **Uso total**: Requests agregados de todas las keys
- **Alertas**: Keys próximas a expirar o con errores
- **Costos estimados**: Basado en tarifas de servicios

## Operaciones de Gestión

### Crear Nueva API Key

#### Información Requerida:

- **Nombre/Descripción**: Identificador interno (ej. "OpenAI Producción")
- **Servicio**: A qué integración pertenece
- **Tipo de credencial**: Simple, Key+Secret, Certificado, etc.
- **Valor(es)**: La credencial actual
- **Límites**: Quotas y restricciones
- **Fecha de expiración**: Si aplica

#### Proceso:

1. Admin → [Crear Nueva Key]
2. Completar formulario → [Validar formato]
3. Test de conectividad → [Verificar funcionamiento]
4. Guardar cifrado → [Confirmar creación]

### Gestión de Credenciales Existentes

#### Operaciones Disponibles:

| **Operación** | **Cuándo Usar** | **Resultado** |
|---------------|-----------------|---------------|
| **Ver** | Consultar valor (parcial) | Muestra primeros/últimos caracteres |
| **Copiar** | Usar en configuración | Copia valor completo al portapapeles |
| **Editar** | Cambiar límites o descripción | Actualiza metadatos |
| **Renovar** | Key próxima a expirar | Genera nueva versión |
| **Rotar** | Compromiso de seguridad | Invalida anterior, crea nueva |
| **Revocar** | Ya no se necesita | Elimina permanentemente |

### Configuración de Límites

#### Tipos de Límites:

- **Rate Limiting**: Requests por minuto/hora/día
- **Quota Límits**: Máximo uso mensual
- **Scope Restrictions**: Qué funciones puede usar
- **IP Restrictions**: Desde qué IPs puede usarse (si el servicio lo soporta)
- **Time Restrictions**: Horarios permitidos de uso

## Interfaz de Usuario

### Lista Principal de API Keys

Imagen pantalla lista API keys

**Estructura sugerida:**

- Nombre/Descripción de la credencial
- Servicio asociado e integración
- Estado visual con indicadores de color
- Fecha de último uso
- Acciones disponibles (Ver/Editar/Renovar/Revocar)

### Formulario de Creación/Edición

Imagen formulario API key

**Campos principales:**

- Nombre descriptivo interno
- Servicio asociado (dropdown con integraciones disponibles)
- Tipo de credencial (Simple, Key+Secret, Certificado, Token)
- Valor(es) de la credencial con validación de formato
- Configuración de límites y quotas
- Test de conectividad automático

### Dashboard de Monitoreo

Imagen pantalla dashboard monitoreo

**Métricas incluidas:**

- Resumen de estados por categoría
- Uso y consumo por servicio
- Alertas y notificaciones activas
- Estimación de costos por credencial
- Calendario de próximas expiraciones

## Consideraciones de Seguridad

### Almacenamiento Seguro

#### Cifrado de Credenciales:

- **En reposo**: AES-256 para valores almacenados
- **En tránsito**: TLS 1.3 para todas las comunicaciones
- **En memoria**: Valores cifrados hasta uso inmediato
- **Backup**: Copias de seguridad cifradas

#### Control de Acceso:

- **Principio de menor privilegio**: Solo Admins
- **Separación de responsabilidades**: Auditoría de accesos
- **Logs detallados**: Quién accedió a qué credencial
- **Alertas de seguridad**: Accesos inusuales o masivos

### Mejores Prácticas

#### Gestión de Credenciales:

- **Rotación regular**: Renovar keys cada 90 días
- **Uso específico**: Una key por servicio/ambiente
- **Monitoreo continuo**: Detectar uso anómalo
- **Revocación inmediata**: Ante cualquier compromiso

#### Validación y Testing:

- **Test automático**: Verificar conectividad al crear/editar
- **Monitoreo de salud**: Checks periódicos de validez
- **Alertas tempranas**: Notificar expiraciones próximas
- **Backup de continuidad**: Keys de respaldo para servicios críticos

### Auditoría y Compliance

#### Logs de Auditoría:

Tabla SQL de auditoría

#### Reportes de Compliance:

- **Inventario de credenciales**: Lista completa actualizada
- **Estado de rotación**: Keys que necesitan renovación
- **Uso y accesos**: Patrones de utilización
- **Incidentes de seguridad**: Fallos de autenticación

## Integración con el Sistema

### Flujo de Uso Operativo:

1. **Admin configura API Key** en Backoffice
2. **Sistema valida credencial** con test de conectividad
3. **Integración usa credencial** para llamadas externas
4. **Monitoreo registra uso** y métricas
5. **Alertas notifican** problemas o límites

### Casos de Uso Comunes:

#### Configurar IA para Asistente:

1. Crear API Key de servicio de IA en esta sección
2. Activar integración de IA en sección Integraciones
3. Asistente AI funciona en expedientes

#### Habilitar Validación de Identidad:

1. Subir certificado de validación en esta sección
2. Configurar integración gubernamental
3. Validación automática en trámites ciudadanos

## Documentos Relacionados

- Backoffice - Configuración de Integraciones
- Backoffice - Accesos y Control
- Manual de Seguridad del Sistema
- Guía de Integración de Servicios Externos