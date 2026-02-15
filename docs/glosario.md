# Glosario de Terminos Clave

Este glosario proporciona definiciones de la terminologia fundamental utilizada en la gestion municipal y el gobierno digital, esencial para comprender el contexto y las funcionalidades del Sistema de Gestion Documental Inteligente (GDI).

---

## Normas y Decisiones en la Gestion Municipal

### Ordenanza
Norma general y obligatoria sancionada por el Concejo Deliberante para regir dentro del municipio. Entra en vigor tras promulgacion y publicacion oficial. Jerarquia: inferior a Constitucion y leyes provinciales; superior a decretos y resoluciones. Se reglamenta por decreto y se deroga por otra ordenanza o norma superior.

### Acto Administrativo
Decision formal, unilateral y obligatoria dictada por un organo de la Administracion competente, en ejercicio de la funcion administrativa, que crea, modifica o extingue derechos u obligaciones. Puede ser desde un Decreto, una Resolucion o un Permiso de Habilitacion. Goza de presuncion de legitimidad y es ejecutoria hasta su revocacion o anulacion.

### Decreto (Intendente)
Acto del Ejecutivo que reglamenta ordenanzas o dispone medidas de gestion; de alcance general o particular, tiene numeracion especial.

### Resolucion
Acto de secretarias/direcciones que decide asuntos concretos dentro de su competencia. Tiene numeracion especial.

### Permiso / Registro
Acto individual que autoriza o reconoce cumplimiento normativo; puede tener condiciones, plazo y numeracion especial.

### Digesto Municipal
Conjunto organizado y actualizado de todas las ordenanzas, decretos y resoluciones vigentes que regulan el funcionamiento de la ciudad.

---

## Estructura del Gobierno Municipal

### Intendente o Alcalde
Autoridad maxima del municipio, encargada de ejecutar las ordenanzas y gestionar los servicios municipales.

### Concejo Deliberante
Organo legislativo compuesto por concejales, responsable de crear y aprobar ordenanzas.

### Funcionario Municipal
Responsables de areas especificas como Obras Publicas, Finanzas o Planeamiento, toman decisiones relacionadas con la gestion.

### Agente Municipal
Personal encargado de realizar tramites, verificar cumplimiento de normas y tareas administrativas generales.

### Reparticion
En el contexto de GDI y el organigrama municipal, una Reparticion es una unidad organizacional dentro de la municipalidad (ej., una Secretaria, Direccion General o Subsecretaria). Agrupa a uno o varios Sectores y es responsable de un area funcional especifica de la gestion publica. Cada Reparticion tiene (o puede estar vacante) un Titular asignado y puede gestionar sus propios recursos y personal. Estan constituidos legalmente.

### Sector
En el contexto de GDI y el organigrama municipal, un Sector es un equipo de trabajo informal dentro de una Reparticion (ej., Mesa de Entradas, Equipo Legal, etc.). Es una unidad operativa granular que agrupa a un conjunto de usuarios y realiza tareas especificas dentro de su Reparticion padre. Cada Sector pertenece a una unica Reparticion. No se constituyen legalmente.

---

## Mecanismos y Herramientas de Gestion Municipal

### Tasa Municipal
Impuestos locales que ciudadanos y empresas abonan por servicios municipales (alumbrado, limpieza, recoleccion de residuos, etc.). Definidos en la Ordenanza Fiscal e Impositiva anual.

### Boletin Oficial
Publicacion oficial donde el municipio informa sobre nuevas normas, resoluciones y decisiones de gobierno.

### Mesa de Entrada
Area de la municipalidad donde los ciudadanos presentan tramites y documentacion para solicitar permisos o autorizaciones.

### Firma Digital
Herramienta electronica que valida documentos oficiales sin necesidad de imprimirlos. En GDI se utiliza firma PAdES sobre PDFs.

### Sello Institucional
Imagen oficial del organismo (escudo, logo, etc.) usada junto a la firma digital en documentos oficiales. Cada municipio define sus propios sellos (`city_seals`) y los asigna a usuarios.

---

## Documentos y Comunicaciones

### Nota
Comunicacion oficial entre sectores dentro del sistema. Se crea como un documento tipo NOTA con destinatarios (TO, CC, BCC) y soporte para tracking de lectura. Es el mecanismo principal de comunicacion interna en GDI.

### Caratula (CAEX)
Documento PDF auto-generado que identifica un expediente. Se crea automaticamente al caratular un expediente y contiene los datos basicos del tramite (numero, referencia, fecha, reparticion caratuladora).

### Pase de Vista (PV)
Documento auto-generado al transferir un expediente de un sector a otro. Registra la transferencia y sirve como constancia del movimiento.

---

## Tramites y Procedimientos Administrativos

### Expediente
Conjunto ordenado de documentos, agrupados en una carpeta unica, que tramitan hasta su decision y guardado. En GDI, es el **contenedor digital** con trazabilidad completa.

El **expediente electronico** es el instrumento central del sistema GDI. Permite integrar, organizar y tramitar digitalmente toda la documentacion vinculada a un procedimiento administrativo, asegurando trazabilidad, transparencia y eficiencia.

### Plazo Administrativo
Tiempo que tiene la municipalidad para resolver un tramite o responder una solicitud.

### Notificacion
Comunicacion oficial (Nota o Memo) que envia la municipalidad para informar sobre una resolucion, un error en un tramite o una nueva normativa.

---

## Sistemas de Referencia

### GDE (Gestion Documental Electronica)
Sistema utilizado por entidades gubernamentales de Argentina para tramitar digitalmente y administrar documentos de manera electronica. Facilita la caratula, numeracion, seguimiento y registro de todas las actuaciones y expedientes. GDI toma como referencia el estandar GDE para sus acronimos y tipos de documento.

### GEDO (Generador Electronico de Documentos Oficiales)
Componente de GDE que permite la creacion, firma y gestion electronica de documentos oficiales.

---

## Arquitectura y Tecnologia

### Multi-tenant
Arquitectura donde cada organismo (municipio) tiene su propio schema separado en la base de datos. Esto aisla completamente los datos de cada municipio, garantizando seguridad y privacidad. En GDI, cada municipio opera en un schema PostgreSQL independiente (ej. `100_test`, `arg_terranova`).

### Schema
Espacio de nombres en PostgreSQL que aisla datos por organismo. Cada municipio tiene su propio schema con todas las tablas necesarias (documentos, expedientes, usuarios, etc.), mas un schema global `public` con datos compartidos (tipos de documento globales, roles, etc.).

### MCP (Model Context Protocol)
Protocolo abierto para conectar asistentes de IA externos al sistema. Permite que herramientas como Claude interactuen con GDI a traves de una API estandarizada, ejecutando consultas y acciones con contexto del usuario autenticado.

### RAG (Retrieval-Augmented Generation)
Tecnica que combina busqueda semantica con generacion de texto por IA. En GDI, los documentos oficiales se fragmentan en chunks, se generan embeddings vectoriales y se almacenan en `document_chunks` para permitir busquedas por significado (no solo por palabras exactas).

### PAdES (PDF Advanced Electronic Signatures)
Estandar europeo para firma digital avanzada sobre documentos PDF. GDI utiliza PAdES a traves del microservicio GDI-Notary para firmar documentos oficiales con validez legal.

### Advisory Lock
Mecanismo de PostgreSQL (`pg_advisory_xact_lock`) para prevenir race conditions. En GDI se usa el lock ID `888888` para garantizar la unicidad de la numeracion secuencial (`global_sequence`) de documentos oficiales, y el lock ID `999999` para la numeracion de expedientes.

### pgvector
Extension de PostgreSQL para almacenar y buscar vectores (embeddings). GDI usa vectores de 1536 dimensiones (generados con `text-embedding-3-small` de OpenAI) almacenados en la tabla `document_chunks` para habilitar busqueda semantica.

### R2
Servicio de almacenamiento de objetos de Cloudflare, compatible con la API de Amazon S3. GDI usa R2 para almacenar PDFs firmados (bucket `oficial`), PDFs en proceso de firma (bucket `tosign`) y archivos multimedia (logos, fotos de perfil, etc.).
