# Consideraciones de Seguridad

## 11.1 Control de Acceso Granular

### Nivel de Expediente:

- **Verificación de pertenencia**: Validación automática de que el usuario pertenece al sector administrador o actuante

- **Permisos diferenciales**: Distintos niveles de acceso según el rol (administrador total vs. actuante específico)

- **Auditoría de accesos**: Registro de todos los accesos y operaciones sobre expedientes

### Nivel de Sección:

- **Documentos**: Solo usuarios con permisos de gestión pueden vincular/subsanar

- **Acciones**: Permisos específicos para crear, asignar y finalizar tareas

- **Asistente AI**: Chat privado por usuario, sin acceso cruzado a conversaciones

## 11.2 Integridad de Datos

### Carátula Automática:

- **Firma digital inmutable**: La firma automática del creador no puede ser alterada

- **Timestamp certificado**: Hora oficial del sistema para garantizar veracidad temporal

- **Hash de integridad**: Verificación criptográfica de que la carátula no fue modificada

### Vinculación de Documentos:

- **Verificación de existencia**: Validación de que el documento existe y es accesible

- **Control de versiones**: Registro de la versión específica vinculada al momento de la asociación

- **Trazabilidad de cambios**: Log completo de vinculaciones y subsanaciones

## 11.3 Auditoría y Trazabilidad

### Log de Expediente:

- **Creación**: Usuario, timestamp, datos iniciales

- **Modificaciones**: Cambios en asignaciones, transferencias, vinculaciones

- **Accesos**: Quién accedió, cuándo y qué secciones consultó

- **Acciones**: Todas las solicitudes de actuación y sus respuestas

### Seguridad de Transferencias:

- **Validación de sectores**: Verificación de que el sector destinatario existe y está activo

- **Registro de cambio de propiedad**: Log inmutable del cambio de administración

- **Notificación automática**: Comunicación a ambos sectores involucrados

## 11.4 Protección de Información Sensible

### Datos de Iniciadores Externos:

- **Cifrado de CUIT/CUIL**: Datos fiscales protegidos con cifrado específico

- **Validación API**: Verificación contra fuentes oficiales sin almacenar datos innecesarios

- **Acceso restringido**: Solo usuarios autorizados pueden ver datos completos de iniciadores externos

### Asistente AI:

- **Aislamiento de conversaciones**: Cada usuario tiene acceso solo a sus propias interacciones

- **Filtrado de información sensible**: El AI no expone datos de otros usuarios o expedientes no autorizados

- **Logs de consultas**: Registro de todas las interacciones para auditoría de uso

## 11.5 Cumplimiento Normativo

### Retención de Datos:

- **Políticas de archivo**: Definición de tiempos de retención según tipo de expediente

- **Backup seguro**: Respaldos cifrados con acceso controlado

- **Recuperación controlada**: Procedimientos seguros para restauración de expedientes