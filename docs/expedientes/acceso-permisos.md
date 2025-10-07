# Reglas de Acceso y Permisos

## Condiciones para Gestionar un Expediente

Un usuario puede gestionar un expediente bajo las siguientes condiciones:

### 1. Si pertenece al sector administrador del expediente:

El sector administrador es la repartición#sector que tiene la propiedad principal del expediente. Los usuarios que pertenecen a este sector tienen permisos completos para gestionar el expediente, incluyendo la vinculación de documentos, la asignación de tareas y la transferencia de propiedad y Asistente.

**Lógica de Acceso**: El sistema verifica si el user_id del usuario autenticado pertenece a un sector_id que coincide con el admin_sector_id del expediente.

### 2. Si su sector tiene una actuación asignada dentro del expediente:

Cuando el sector de un usuario ha recibido una Task o Actuación específica dentro de un expediente, los usuarios de ese sector obtienen permisos temporales o específicos para gestionar aspectos relacionados con esa actuación. Esto no implica una gestión completa del expediente, sino la capacidad de realizar las acciones necesarias para completar la tarea asignada (ej., crear y vincular un documento solicitado al expediente).

Si tiene solo visualizar solo puede ver la solapa "Documentos y Acciones (pero no operar chat ni acciones." ni agregar documento.

**Lógica de Acceso**: El sistema verifica si existe una Task activa donde el recipient_sector_id coincide con el sector_id del usuario autenticado y si el user_id tiene los permisos de write o manage_task sobre esa actuación específica. Estos permisos se propagan al expediente para las acciones relacionadas con la actuación.

## Repartición Administradora

La Repartición #Sector Administradora es la unidad organizacional que inicia la creación de un expediente. Por defecto, se asigna al sector del usuario creador. Esto incluye la capacidad de:

- **Gestionar el expediente**: Realizar todas las operaciones inherentes al ciclo de vida del expediente, cómo añadir documentos, cargar información, y seguir su tramitación

- **Crear solicitudes**: Generar nuevas solicitudes de actuación dentro del expediente, impulsando su avance y las interacciones con otras reparticiones

- **Transferir el expediente**: Mover el expediente a otra repartición#Sector para su continuidad o resolución. Al ejecutarse la transferencia, la Repartición Administradora original pierde ese rol, y la repartición#sector receptor pasa a ser la Repartición Administradora del expediente

Este rol central asegura que la repartición que origina el expediente mantenga el control y la supervisión sobre su desarrollo inicial y las acciones fundamentales que se desprenden del mismo.

## Reparticiones Actuantes

Las Reparticiones Actuantes son aquellos repartición#sector que, son autorizados para intervenir en su tramitación en momentos específicos. Su participación se activa cuando se le solicita una intervención en la sección de Acciones, lo que se puede reflejar en el expediente como una solicitud de actuación.

Las funciones principales de las reparticiones actuantes incluyen:

- **Vincular documentos**: Realizar la tarea solicitada y vincular el documento con la información que les ha sido solicitada dentro del marco del expediente

- **Solicitar actuaciones**: Trabajar en conjunto con la Repartición Administradora y otras reparticiones para asegurar el correcto avance del expediente como por ejemplo, solicitar una actuación a otro sector específico

- **Registro de actuaciones**: Dejar constancia de sus intervenciones y acciones dentro del expediente, garantizando la trazabilidad y transparencia del proceso