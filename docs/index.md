# GDI - Gestion Documental Inteligente

**Documentacion oficial de GDI, el sistema de gestion documental inteligente para gobiernos de America Latina.**

---

## Que es GDI?

**GDI (Gestion Documental Inteligente)** es una plataforma open source que digitaliza y moderniza la gestion documental de organismos publicos en America Latina. Transforma procesos administrativos rigidos en flujos de trabajo dinamicos, flexibles y colaborativos, eliminando burocracia y reduciendo drasticamente los tiempos de procesamiento.

!!! info "Objetivo Principal"
    Proveer a gobiernos LATAM de una herramienta moderna, abierta y soberana para gestionar documentos, expedientes y procesos administrativos con inteligencia artificial integrada.

---

## Caracteristicas Principales

<div class="grid cards" markdown>

-   :material-api:{ .lg .middle } __API-First__

    ---

    Arquitectura basada en APIs REST y estandares abiertos para maxima interoperabilidad entre sistemas.

-   :material-open-source-initiative:{ .lg .middle } __Open Source (AGPLv3)__

    ---

    Software libre que elimina costos de licencias, garantiza soberania tecnologica y evita vendor lock-in.

-   :material-account-multiple:{ .lg .middle } __Multi-Tenant__

    ---

    Schemas separados por organizacion en PostgreSQL. Una instancia sirve a multiples entidades de forma aislada.

-   :material-robot:{ .lg .middle } __IA Integrada (RAG)__

    ---

    Agente de IA con busqueda semantica (RAG) para asistencia de redaccion, clasificacion y consulta de expedientes.

-   :material-file-certificate:{ .lg .middle } __Firma Digital PAdES__

    ---

    Firma digital con plena validez juridica sobre documentos PDF, compatible con estandares internacionales.

-   :material-map-marker-path:{ .lg .middle } __LATAM-First__

    ---

    Disenado especificamente para las necesidades regulatorias y operativas de America Latina.

</div>

---

## Modulos del Sistema

### Documentos
Creacion, colaboracion y formalizacion de documentos electronicos con plena validez legal. Ciclo de vida completo desde borrador hasta archivo definitivo.

[Explorar Documentos](documentos/introduccion-casos-uso.md){ .md-button }

---

### Expedientes
Contenedor digital para la gestion integral de tramites y procesos administrativos con trazabilidad completa y movimientos entre areas.

[Explorar Expedientes](expedientes/casos-uso.md){ .md-button }

---

### Notas
Sistema de comunicaciones internas entre usuarios y sectores, con destinatarios, estados y trazabilidad.

[Explorar Notas](notas/introduccion.md){ .md-button }

---

### BackOffice
Panel de administracion y configuracion del sistema: tipos de documento, tipos de expediente, organigrama, roles, permisos y API keys.

[Explorar BackOffice](backoffice/introduccion-acceso.md){ .md-button }

---

### Base de Datos
Modelo relacional completo del sistema, estructura de schemas multi-tenant y configuracion de almacenamiento.

[Explorar Base de Datos](database/readme.md){ .md-button }

---

## Stack Tecnologico

| Capa | Tecnologias |
|------|-------------|
| **Frontend** | Next.js 15, React 18, TypeScript, Tailwind CSS, shadcn/ui |
| **Backend** | FastAPI, SQLAlchemy async, Pydantic v2, Auth0 JWT |
| **Base de Datos** | PostgreSQL 17 + pgvector |
| **IA** | LangGraph, OpenRouter, RAG con pgvector |
| **Firma Digital** | pyHanko, PyMuPDF (PAdES) |
| **Almacenamiento** | Cloudflare R2 (S3-compatible) |
| **Infraestructura** | Railway (PaaS) |

---

## Comenzar a Explorar

!!! tip "Para nuevos integrantes"
    Recomendamos empezar por la [Vision General](introduccion-vision/vision-general.md) para comprender el sistema completo.

!!! example "Para desarrolladores"
    Consulta la [Arquitectura de la Solucion](introduccion-vision/arquitectura-solucion-gdi.md) y el [Modelo de Datos](database/readme.md).

!!! question "Terminos desconocidos?"
    Revisa nuestro [Glosario](glosario.md) completo de terminos tecnicos.

---

## Audiencia

Esta documentacion esta dirigida a:

- Desarrolladores de software (nuevos y existentes)
- Ingenieros de QA
- Arquitectos de software
- Lideres tecnicos
- Sistemas de Inteligencia Artificial

---

## Repositorio y Contribuciones

GDI es un proyecto **open source** bajo licencia AGPLv3.

[:fontawesome-brands-github: Ver en GitHub](https://github.com/GestionDocumentalInteligente/Producto){ .md-button .md-button--primary }

---

<small>Copyright &copy; 2026 GDI Latam - Gestion Documental Inteligente</small>
