# Vision General de GDI

## Proposito

**GDI (Gestion Documental Inteligente)** es una plataforma open source disenada para digitalizar y modernizar la gestion documental de organismos publicos en America Latina. Su objetivo es reemplazar procesos administrativos rigidos y burocraticos por flujos de trabajo dinamicos, transparentes y eficientes.

GDI nace como una evolucion de los sistemas de gestion documental electronica existentes en la region (SADE, GDE, GDEBA), abordando sus limitaciones estructurales con una arquitectura moderna, abierta y pensada para escalar.

---

## Propuesta de Valor

### Interoperabilidad y enfoque LATAM
Disenado con un modelo API-first y basado en estandares abiertos, GDI facilita la integracion con sistemas heterogeneos y promueve la estandarizacion a nivel regional. Permite el intercambio de datos entre diversas entidades, construyendo un ecosistema digital comun.

### Experiencia de Usuario optimizada
Interfaces modernas construidas con Next.js 15 y shadcn/ui, disenadas siguiendo estandares UI/UX actuales. La curva de adopcion es minima y la productividad se maximiza para todos los perfiles de usuario.

### Eficiencia de costos y sostenibilidad
Software libre bajo licencia AGPLv3 que elimina costos de licencias propietarias. Democratiza el acceso a tecnologia de punta, permitiendo a las jurisdicciones reinvertir recursos en otras areas criticas.

### Escalabilidad multi-tenant
Arquitectura multi-tenant con schemas separados en PostgreSQL, que permite servir a multiples organizaciones desde una misma instancia de forma aislada y segura. Se adapta a municipios de cualquier tamano.

### Soberania tecnologica
El codigo abierto garantiza control total sobre el stack tecnologico, eliminando vendor lock-in y fomentando la autonomia digital de las instituciones. Permite auditoria, personalizacion y evolucion por parte de la comunidad.

### Inteligencia Artificial integrada
Agente de IA nativo con capacidades RAG (Retrieval-Augmented Generation) para asistencia de redaccion, busqueda semantica en expedientes, clasificacion de documentos y generacion de informes.

### Firma Digital con validez juridica
Firma digital PAdES integrada a traves de pyHanko y PyMuPDF, garantizando la autenticidad e integridad de los documentos con plena validez legal.

---

## Modulos Principales

### 1. Documentos

El modulo central de GDI. Gestiona el ciclo de vida completo de documentos electronicos: creacion desde plantillas, edicion colaborativa, firma digital, numeracion automatica y archivo definitivo. Cada documento mantiene trazabilidad completa de acciones y estados.

### 2. Expedientes

Contenedor digital que agrupa documentos relacionados a un tramite o proceso administrativo. Soporta movimientos entre sectores (asignaciones y transferencias), vinculacion de documentos, providencias automaticas y trazabilidad completa del flujo.

### 3. Notas

Sistema de comunicaciones internas que permite enviar notas entre usuarios y sectores del organismo. Soporta destinatarios multiples, estados de lectura y archivo, y trazabilidad de envios.

### 4. BackOffice

Panel de administracion del sistema que centraliza la configuracion. Incluye:

- **Organigrama**: gestion de la estructura organizacional (reparticiones, sectores, cargos, usuarios y jerarquia)
- **Tipos de Documento**: definicion de templates con campos, permisos de firma y estados
- **Tipos de Expediente**: configuracion de categorias y metadatos de expedientes
- **Roles y Permisos**: control de acceso granular basado en roles
- **API Keys**: gestion de claves para integracion con sistemas externos

### 5. Base de Datos

Modelo relacional completo sobre PostgreSQL 17 con extension pgvector para busqueda semantica. Estructura multi-tenant con schemas separados por organizacion.

---

## Licencia

GDI se distribuye bajo la licencia **AGPLv3** (GNU Affero General Public License v3). Esto significa que:

- El codigo fuente esta disponible publicamente
- Cualquier modificacion desplegada debe compartir el codigo fuente
- Se fomenta la colaboracion y la mejora continua por parte de la comunidad
- Las instituciones mantienen soberania tecnologica total
