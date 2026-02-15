# Consideraciones de Seguridad

## Control de Acceso Granular

### Nivel de Expediente

- **Verificacion de pertenencia**: Validacion automatica de que el usuario pertenece al sector administrador o actuante

- **Permisos diferenciales**: Distintos niveles de acceso segun el rol (administrador total vs. actuante especifico vs. solo lectura)

- **Auditoria de accesos**: Registro de todos los accesos y operaciones sobre expedientes

### Nivel de Seccion

| Seccion | Regla de Acceso |
|---------|-----------------|
| **Documentos** | Solo usuarios con permisos de gestion (write) pueden vincular y subsanar |
| **Acciones** | Permisos especificos para crear, asignar y finalizar tareas |
| **Asistente AI** | Chat privado por usuario, sin acceso cruzado a conversaciones |

---

## Integridad de Datos

### Caratula Automatica

- **Firma digital inmutable**: La firma automatica del creador no puede ser alterada post-generacion

- **Timestamp certificado**: Hora oficial del sistema para garantizar veracidad temporal

- **Hash de integridad**: Verificacion criptografica de que la caratula no fue modificada

### Vinculacion de Documentos

- **Verificacion de existencia**: Validacion de que el documento existe y es accesible antes de vincularlo

- **Control de versiones**: Registro de la version especifica vinculada al momento de la asociacion

- **Trazabilidad de cambios**: Log completo de vinculaciones y subsanaciones con usuario, fecha y motivo

---

## Auditoria y Trazabilidad

### Registro de Movimientos

Toda accion sobre un expediente queda registrada en la tabla `case_movements`:

| Evento | Datos Registrados |
|--------|-------------------|
| **Creacion** | Usuario creador, timestamp, datos iniciales, sector administrador |
| **Vinculacion de documento** | Usuario, documento vinculado, order_number, timestamp |
| **Solicitud de actuacion** | Usuario solicitante, sector destino, motivo, timestamp |
| **Transferencia** | Sector emisor, sector receptor, PV generado, timestamp |
| **Asignacion** | Usuario que asigna, usuario asignado, timestamp |
| **Subsanacion** | Usuario, documento original, documento nuevo, justificacion |

### Seguridad de Transferencias

- **Validacion de sectores**: Verificacion de que el sector destinatario existe y esta activo en el organigrama

- **Registro de cambio de propiedad**: Log inmutable del cambio de administracion

- **Notificacion automatica**: Comunicacion a ambos sectores involucrados en la transferencia

- **Generacion de PV**: Documento formal (Pase de Vista) que certifica la transferencia

---

## Proteccion de Informacion Sensible

### Datos de Iniciadores Externos

- **Proteccion de CUIT/CUIL**: Datos fiscales almacenados con restricciones de acceso

- **Validacion via API**: Verificacion contra fuentes oficiales sin almacenar datos innecesarios

- **Acceso restringido**: Solo usuarios autorizados pueden ver datos completos de iniciadores externos

### Asistente AI

- **Aislamiento de conversaciones**: Cada usuario tiene acceso solo a sus propias interacciones con el asistente

- **Filtrado de informacion**: El AI no expone datos de otros usuarios o expedientes no autorizados

- **Registro de consultas**: Todas las interacciones quedan registradas para auditoria de uso

---

## Cumplimiento Normativo

### Retencion de Datos

- **Politicas de archivo**: Definicion de tiempos de retencion segun tipo de expediente

- **Backup seguro**: Respaldos cifrados con acceso controlado

- **Recuperacion controlada**: Procedimientos seguros para restauracion de expedientes

### Multi-Tenancy

- **Aislamiento por schema**: Cada organizacion opera en su propio schema de PostgreSQL, garantizando separacion total de datos

- **Validacion de tenant**: Toda consulta a la base de datos incluye validacion del schema correspondiente

- **Auditoria por tenant**: Logs separados por organizacion para cumplimiento regulatorio independiente
