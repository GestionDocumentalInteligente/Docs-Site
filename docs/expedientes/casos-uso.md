# Casos de Uso - Módulo Expedientes

## 1. ¿Qué es el Módulo Expedientes?

El módulo de Expedientes es el contenedor digital central de GDI que organiza y gestiona el ciclo de vida completo de los trámites administrativos. Facilita la colaboración entre áreas y promueve una interacción más eficiente con los ciudadanos.

**Un Expediente electrónico** (EE) es un conjunto de documentos digitales vinculados entre sí que documentan un procedimiento administrativo específico, desde su inicio hasta su resolución, asegurando trazabilidad, transparencia y eficiencia.

GDI va más allá del expediente tradicional, rompiendo con la lógica lineal de tramitación, habilitando flujos simultáneos, colaborativos y dinámicos entre múltiples sectores.

## 2. Casos de Uso Clave

| **Funcionalidad** | **Descripción** |
|-------------------|------------------|
| **Creación de Expedientes** | Iniciación de nuevos expedientes. Este proceso completa los campos `reference`, `template_id` y `admin_department_id` en la tabla `records` para registrar el motivo, la plantilla utilizada y la repartición responsable. |
| **Generación de Carátula** | Creación automática de un documento PDF inicial con los datos principales del expediente |
| **Vinculación de Documentos** | Asociación de documentos existentes al expediente. Técnicamente, esta acción añade una nueva entrada al JSON del campo `linked_documents` en la tabla `records`, asegurando la trazabilidad. |
| **Gestión de Tareas y Asignaciones** | Asignación y solicitud de acciones a sectores dentro del expediente |
| **Seguimiento del Historial de Acciones** | Registro y visualización cronológica de todos los movimientos y solicitudes dentro del expediente y chat del expediente |
| **Consulta Inteligente con Asistente AI** | Interacción conversacional para obtener resúmenes, listar tareas pendientes y consultar datos específicos del expediente |
| **Colaboración Inter-áreas** | Facilitación de flujos de trabajo que involucran a múltiples sectores y usuarios |