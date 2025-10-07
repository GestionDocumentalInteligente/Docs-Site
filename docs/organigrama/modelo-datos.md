# Modelo de Datos

## Estructura de Base de Datos

El módulo Organigrama se basa en  tablas principales que definen la estructura jerárquica y las relaciones entre usuarios, sectores y reparticiones.

## Tabla: usuarios

<!-- [COMPLETAR: Estructura de tabla usuarios desde Supabase] -->

**Campos principales esperados:**
- Identificador único (UUID)
- Datos personales (CUIL, DNI, nombre, apellido)
- Datos de contacto (email, celular)
- Datos del sistema (username, estado, fechas)

*(Ver estructura detallada en `06-DataBase/Organigrama.md`)*

## Tabla: reparticiones

<!-- [COMPLETAR: Estructura de tabla reparticiones desde Supabase] -->

**Campos principales esperados:**
- Identificador único (UUID)
- Información básica (nombre, acrónimo)
- Estado y metadatos

*(Ver estructura detallada en `06-DataBase/Organigrama.md`)*

## Tabla: sectores

<!-- [COMPLETAR: Estructura de tabla sectores desde Supabase] -->

**Campos principales esperados:**
- Identificador único (UUID)
- Relación con repartición padre
- Información del sector (nombre, código, acrónimo)

*(Ver estructura detallada en `06-DataBase/Organigrama.md`)*

## Tabla: usuario_sectores

<!-- [COMPLETAR: Estructura de tabla usuario_sectores desde Supabase] -->

**Relación muchos-a-muchos entre usuarios y sectores.**

*(Ver estructura detallada en `06-DataBase/Organigrama.md`)*

## Tabla: reparticion_titulares

<!-- [COMPLETAR: Estructura de tabla reparticion_titulares desde Supabase] -->

**Relación muchos-a-muchos entre usuarios y reparticiones como titulares.**

*(Ver estructura detallada en `06-DataBase/Organigrama.md`)*

## Relaciones y Constraints

### Relaciones Principales:
- **Usuario → Sectores**: Un usuario puede pertenecer a múltiples sectores (N:M)
- **Usuario → Reparticiones**: Un usuario puede ser titular de múltiples reparticiones (N:M)
- **Repartición → Sectores**: Una repartición tiene múltiples sectores (1:N)
- **Sector → Usuarios**: Un sector puede tener múltiples usuarios (N:M)

### Constraints de Integridad:
<!-- [COMPLETAR: Constraints específicos desde Supabase] -->
- CUIL debe ser único globalmente
- Email debe ser único globalmente
- Acrónimo de repartición debe ser único globalmente
- Otros constraints por definir según implementación en Supabase