# Configuracion del Organigrama

## Proposito de la Seccion

La seccion de Organigrama del Backoffice es donde los **Administradores** crean y gestionan toda la estructura organizacional de la municipalidad. Desde aqui se construye el arbol jerarquico completo: **Reparticiones**, **Sectores** y **Usuarios**, asignando responsables (titulares) que tendran capacidad de gestion dentro del sistema GDI.

Para entender el modelo conceptual del organigrama (jerarquias, reglas de negocio, sistema de permisos), consulte las secciones dedicadas:

- **Introduccion y Casos de Uso**: Descripcion general del modulo y funcionalidades
- **Estructura Organizacional**: Modelo de datos y entidades principales
- **Flujos de Gestion**: Vistas de "Mi Equipo", alta/baja de usuarios
- **Roles y Permisos**: Matriz de funcionalidades por rol
- **Modelo de Datos**: Tablas de base de datos del organigrama
- **Sistema de Sellos**: Sellos institucionales y su asignacion

Esta pagina se enfoca en las **operaciones de configuracion** que realiza el Administrador desde el Backoffice.

## Funcionalidades de Configuracion

### 1. Gestion de Reparticiones

#### Crear Nueva Reparticion

**Acceso**: Solo Administradores

**Campos Obligatorios:**

| Campo | Descripcion | Validacion |
|-------|-------------|------------|
| **Nombre** | Denominacion oficial completa (ej: "Secretaria de Gobierno") | Texto, unico en el sistema |
| **Acronimo** | Codigo corto unico global (ej: "SEGOB") | Formato `[A-Z]{3,8}`, unico globalmente |

**Campos Opcionales:**

| Campo | Descripcion |
|-------|-------------|
| **Descripcion** | Texto explicativo del proposito de la reparticion |
| **Responsable (Titular)** | Usuario que sera el responsable principal |
| **Delegados de Gestion** | Usuarios adicionales con permisos de gestion |
| **Tipo de Reparticion** | Dropdown (Secretaria, Direccion, Subsecretaria, etc.) |

#### Editar Reparticion

- Modificar informacion basica (nombre, descripcion)
- Cambiar titular/responsable
- Agregar o quitar delegados de gestion
- Actualizar estado (Activo/Inactivo)

#### Asignar Titular y Delegados

- Buscar usuario en el sistema para asignar como titular
- El titular tiene permisos de gestion sobre toda su reparticion (seccion "Mi Equipo")
- Los delegados pueden realizar las mismas acciones que el titular
- Se registra en la tabla `department_heads`

### 2. Gestion de Sectores

#### Crear Nuevo Sector

**Prerrequisito**: Debe existir al menos una reparticion padre.

**Campos Obligatorios:**

| Campo | Descripcion | Validacion |
|-------|-------------|------------|
| **Reparticion padre** | A que reparticion pertenece | Seleccion de reparticion existente |
| **Nombre** | Denominacion del sector (ej: "Departamento de Tesoreria") | Texto |
| **Acronimo** | Identificador unico global (ej: "TESO") | Formato `[A-Z]{3,4}[0-9]{0,2}`, unico globalmente |

**Campos Opcionales:**

| Campo | Descripcion |
|-------|-------------|
| **Responsable (Jefe de Sector)** | Usuario responsable del sector |
| **Descripcion** | Proposito del sector |

#### Algoritmo de Generacion de Codigos

1. Identificar palabra clave funcional del nombre
2. Generar abreviacion estandar (3-4 primeras letras)
3. Aplicar numeracion secuencial si es necesario
4. Validar unicidad global en todo el sistema

### 3. Carga Masiva de Usuarios

**Acceso**: Solo Administradores desde Backoffice

#### Proceso

1. **Descargar template**: CSV o Excel con formato predefinido
2. **Completar datos**: CUIL, Email, Nombre, Apellido, DNI, Reparticion, Sector, Cargo
3. **Subir archivo**: Validacion automatica de estructura
4. **Procesamiento**: Creacion en lotes de 50 usuarios en estado "pendiente_activacion"
5. **Invitaciones**: Envio automatico de emails con link de activacion
6. **Activacion**: Cada usuario completa datos personales y activa su cuenta

#### Formato del Archivo CSV

```csv
CUIL,Email,Nombre,Apellido,DNI,Reparticion_Acronimo,Sector_Codigo,Cargo
20123456789,juan.perez@terranova.gob.ar,Juan,Perez,12345678,SEGOB,MESA,Administrativo
```

#### Validaciones

- CUIL unico en el sistema
- Email unico en el sistema
- Reparticion y sector existentes y activos
- Formato de datos basicos correcto

## Interfaz de Usuario

### Vista Principal del Organigrama

**Panel Central - Gestion de Reparticiones:**

- Lista expandible/colapsable de reparticiones con sus sectores
- Estructura jerarquica visual
- Indicadores de estado (activo/inactivo)
- Contadores de empleados, reparticiones y sectores

**Panel Derecho - Informacion del Responsable:**

- Datos del titular actual
- ID del usuario
- Acciones de edicion

### Tabs de Navegacion

- **Usuarios**: Gestion de usuarios del sistema
- **Sectores**: Vista y gestion de sectores organizacionales

## Reglas de Negocio

### Reparticiones

1. **Unicidad de Acronimos**: Cada acronimo debe ser unico en todo el sistema
2. **Titular Unico**: Una reparticion solo puede tener un titular principal
3. **Delegacion de Gestion**: El titular puede designar delegados con capacidad de gestion
4. **Estado Cascada**: Al desactivar una reparticion, se desactivan sus sectores
5. **Validacion de Nombres**: No se permiten nombres duplicados

### Sectores

1. **Dependencia de Reparticion**: Todo sector debe pertenecer a una reparticion
2. **Codigos Unicos Globales**: Los codigos de sector son unicos en todo el sistema
3. **Responsable Opcional**: Un sector puede no tener jefe asignado
4. **Usuarios Multiples**: Los usuarios pueden pertenecer a varios sectores

### Usuarios

1. **Asignacion Multiple**: Un usuario puede estar en varios sectores
2. **Titular Unico**: Un usuario solo puede ser titular de una reparticion
3. **Estados Validos**: Activo, Dado de Baja, En Pausa, Pendiente Activacion

## Flujo de Configuracion Inicial

```
1. Crear Reparticiones Principales
   └─ Secretarias, Direcciones, Subsecretarias
       │
2. Asignar Titulares
   └─ Buscar usuarios existentes, asignar como responsables
       │
3. Crear Sectores
   └─ Dentro de cada reparticion, con codigos unicos
       │
4. Cargar Usuarios
   └─ Individual o carga masiva CSV
       │
5. Validacion Final
   └─ Verificar estructura completa, confirmar asignaciones
```

## Base de Datos

La estructura organizacional se persiste en las siguientes tablas principales:

| Tabla | Proposito |
|-------|-----------|
| `municipalities` | Municipio o entidad (nivel mas alto) |
| `departments` | Reparticiones |
| `sectors` | Sectores dentro de reparticiones |
| `users` | Usuarios del sistema |
| `user_sectors` | Relacion N:M entre usuarios y sectores |
| `department_heads` | Titulares de reparticiones |
| `ranks` | Niveles jerarquicos |

Para detalles completos del modelo de datos, consulte la seccion **Modelo de Datos** del organigrama y la documentacion de **Base de Datos**.
