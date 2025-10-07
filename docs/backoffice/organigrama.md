# Backoffice GDI - Configuración de Organigrama

## Propósito de la Sección

El Backoffice de Organigrama es la sección del sistema administrativo donde los **Administradores** crean y gestionan toda la estructura organizacional de la municipalidad. Esta funcionalidad permite construir el árbol jerárquico que incluye **Reparticiones** y **Sectores**, asignando responsables (titulares) que tendrán poder de gestión dentro del sistema GDI.

## Objetivos Principales

- **Estructurar la organización**: Crear el árbol organizacional completo de la municipalidad
- **Delegar responsabilidades**: Asignar titulares a cada repartición para gestión descentralizada
- **Establecer jerarquías**: Definir la relación entre reparticiones y sectores
- **Facilitar la gestión**: Proveer herramientas para mantener actualizada la estructura organizacional

## Arquitectura Conceptual

### Modelo Jerárquico de Tres Niveles

```
MUNICIPALIDAD
├── REPARTICIÓN (Nivel 1)
│   ├── Representa: Unidades organizacionales formales
│   ├── Ejemplos: Secretarías, Direcciones Generales, Subsecretarías
│   └── Propósito: Agrupación normativa y administrativa
│
├── SECTOR (Nivel 2)
│   ├── Representa: Subdivisiones operativas de reparticiones
│   ├── Ejemplos: Equipo Mesa, Equipo Legal, Equipo Cobranzas
│   └── Propósito: Grupos de trabajo específicos
│
└── USUARIO (Nivel 3)
    ├── Representa: Individuos dentro de la estructura
    ├── Ejemplos: Funcionarios, Agentes, Empleados
    └── Propósito: Recursos humanos asignados a sectores
```

## Funcionalidades Principales

### 1. Gestión de Reparticiones

#### Crear Nueva Repartición

**Acceso**: Solo Administradores

**Campos Obligatorios:**

- **Nombre Repartición**: Denominación oficial completa (ej: "Secretaría de Gobierno")
- **Acrónimo**: Código corto único global (ej: "SEGOB")
  - Formato: Alfabético mayúsculas únicamente
  - Longitud: Mínimo 3 caracteres, máximo 8 caracteres
  - Patrón: [A-Z]{3,8}
  - Validación: Único en todo el sistema

**Campos Opcionales:**

- **Descripción**: Texto explicativo del propósito de la repartición
- **Responsable (Titular)**: Usuario que será el responsable principal
- **Delegados de Gestión**: Usuarios adicionales con permisos de gestión sobre la repartición
- **Tipo de Repartición**: Dropdown con opciones predefinidas (Secretaría, Dirección, etc.)

#### Editar Repartición Existente

- Modificar información básica
- Cambiar titular/responsable
- Actualizar estado (Activo/Inactivo)

#### Asignar/Cambiar Titular y Delegados

- Buscar usuario en el sistema para asignar como titular
- Asignar usuarios adicionales como delegados con permisos de gestión
- El titular y los delegados tendrán permisos de gestión sobre toda su repartición
- Los delegados pueden realizar las mismas acciones que el titular en "Mi Equipo"

### 2. Gestión de Sectores

#### Crear Nuevo Sector

**Prerrequisito**: Debe existir al menos una repartición padre

**Campos Obligatorios:**

- **Repartición a la que pertenece**: Selección de repartición padre
- **Nombre Sector**: Denominación del sector
- **Acrónimo**: Identificador único dentro de la repartición
  - Formato: Alfanumérico con separadores opcionales
  - Longitud: Mínimo 3 caracteres, máximo 20 caracteres
  - Patrón: [A-Z]{3,4}[0-9]{0,2} o [A-Z]{2,3}-[A-Z]{2,3}
  - Validación: Único globalmente en todo el sistema

**Campos Opcionales:**

- **Responsable (Jefe de Sector)**: Usuario responsable del sector
- **Descripción**: Propósito del sector

#### Algoritmo de Generación de Códigos de Sector

**ENTRADA**: Nombre de sector + Repartición padre

**PROCESO**:
1. Identificar palabra clave funcional
2. Generar abreviaciones estándar (3-4 primeras letras)
3. Aplicar numeración secuencial si es necesario
4. Validar unicidad GLOBAL en todo el sistema
5. Aplicar prefijo de repartición padre si es necesario

**SALIDA**: Código único de sector

### 3. Interfaz de Usuario del Backoffice

#### Vista Principal del Organigrama

**Panel Central - Gestión de Reparticiones:**

- Lista expandible/colapsable de reparticiones
- Estructura jerárquica visual
- Indicadores de estado (activo/inactivo)
- Contadores de empleados, reparticiones y sectores

**Panel Derecho - Información del Responsable:**

- Foto y datos del responsable actual
- ID del usuario
- Funciones de edición

#### Tabs de Navegación

- **Usuarios**: Gestión de usuarios del sistema
- **Sectores**: Vista y gestión de sectores organizacionales

### 4. Flujos de Trabajo

#### Flujo de Configuración Inicial

1. **Crear Reparticiones Principales**
   - Secretarías principales
   - Direcciones generales
   - Subsecretarías

2. **Asignar Titulares**
   - Buscar usuarios existentes
   - Asignar como responsables
   - Configurar permisos

3. **Crear Sectores**
   - Dentro de cada repartición
   - Asignar códigos únicos
   - Definir responsables de sector

4. **Validación Final**
   - Verificar estructura completa
   - Confirmar asignaciones
   - Activar organigrama

#### Flujo de Mantenimiento

- **Agregar Nueva Repartición**: Proceso guiado para crear nueva estructura organizacional
- **Modificar Estructura Existente**: Edición de reparticiones y sectores
- **Reasignar Responsables**: Cambio de titulares y jefes de sector
- **Gestionar Estados**: Activar/desactivar unidades organizacionales

## Carga Masiva de Usuarios

### Funcionalidad de Importación CSV/Excel

**Acceso**: Solo Administradores desde Backoffice
**Alcance**: Organización completa (todas las reparticiones)

### Proceso Simplificado:

1. **Cargar Archivo**
   - Formato: CSV o Excel
   - Template predefinido disponible para descarga
   - Validación automática de estructura

2. **Validaciones Esenciales**
   - CUIL único en el sistema
   - Email único en el sistema
   - Existencia de repartición y sector
   - Formato de datos básicos

3. **Procesamiento**
   - Creación en lotes de 50 usuarios
   - Estado inicial: "pendiente_activacion"
   - Log detallado del proceso

4. **Sistema de Invitaciones**
   - Envío automático de emails
   - Link de activación personalizado
   - Usuario completa datos personales
   - Validación CUIL vs datos ingresados

### Estructura del Archivo CSV:

```csv
CUIL,Email,Nombre,Apellido,DNI,Reparticion_Acronimo,Sector_Codigo,Cargo
20123456789,juan.perez@terranova.gob.ar,Juan,Pérez,12345678,SEGOB,MESA,Administrativo
```

### API Endpoint:

```
POST /api/backoffice/usuarios/carga-masiva
- Archivo multipart/form-data
- Respuesta: ID de proceso de carga
- Status endpoint para seguimiento
```

## Reglas de Negocio

### Reparticiones

1. **Unicidad de Acrónimos**: Cada acrónimo debe ser único en todo el sistema
2. **Titular Único**: Una repartición solo puede tener un titular principal
3. **Delegación de Gestión**: El titular puede designar a otros usuarios capacidad de gestión sobre su repartición
4. **Estado Cascada**: Al desactivar una repartición, se desactivan sus sectores
5. **Validación de Nombres**: No se permiten nombres duplicados

### Sectores

1. **Dependencia de Repartición**: Todo sector debe pertenecer a una repartición
2. **Códigos Únicos Globales**: Los códigos de sector son únicos en todo el sistema
3. **Responsable Opcional**: Un sector puede no tener jefe asignado
4. **Usuarios Múltiples**: Los usuarios pueden pertenecer a varios sectores

### Usuarios

1. **Asignación Múltiple**: Un usuario puede estar en varios sectores
2. **Titular Único**: Un usuario solo puede ser titular de una repartición
3. **Estados Válidos**: Activo, Dado de Baja, En Pausa

## Estructura de Base de Datos

La estructura organizacional del sistema GDI se persiste en varias tablas de la base de datos, diseñadas para reflejar la jerarquía de municipalidades, reparticiones, sectores y usuarios. A continuación, se resumen las tablas principales involucradas en el módulo de Organigrama. Para una descripción detallada de cada tabla, incluyendo sus columnas y relaciones, consulte el documento `06-DataBase/Organigrama.md`.

### Tablas Principales

- **`municipalities`**: Almacena la información de cada municipio o entidad que utiliza la plataforma. Es el nivel más alto de la jerarquía.
- **`departments`**: Define las reparticiones, secretarías o direcciones que componen la estructura principal del municipio.
- **`sectors`**: Representa las subdivisiones o equipos de trabajo dentro de una repartición.
- **`users`**: Almacena la información de todos los usuarios del sistema, vinculándolos a la estructura organizacional y al sistema de autenticación.
- **`ranks`**: Define los niveles jerárquicos o rangos funcionales (ej. Intendente, Secretario, Director) para asignarlos a las reparticiones y controlar permisos.
- **`department_heads`**: (Implícita en `departments.head_user_id` o una tabla de relación si es many-to-many) Relaciona usuarios con las reparticiones de las que son titulares.
- **`user_sectors`**: (Relación many-to-many) Asigna usuarios a uno o varios sectores.

## API Endpoints

### Reparticiones
Tabla de endpoints para reparticiones

### Sectores
Tabla de endpoints para sectores

### Usuarios (desde Backoffice)
Tabla de endpoints para usuarios

## Validaciones y Controles

### Validaciones de Entrada

- **Acrónimos**: Formato y unicidad
- **Nombres**: Longitud y caracteres permitidos
- **Referencias**: Existencia de usuarios y reparticiones padre
- **Estados**: Transiciones válidas entre estados

### Controles de Integridad

- **Referencias Foráneas**: Validación de relaciones
- **Cascada de Estados**: Propagación de cambios de estado
- **Historial de Cambios**: Auditoría de modificaciones
- **Respaldos**: Backup antes de cambios críticos

## Consideraciones de Seguridad

### Acceso Restringido

- Solo Administradores pueden acceder
- Autenticación robusta requerida
- Sesiones con timeout de seguridad
- Logs de auditoría completos

### Validación de Datos

- Sanitización de inputs
- Validación de tipos de datos
- Prevención de inyección SQL
- Verificación de permisos en cada operación

## Casos de Uso Especiales

### Reestructuración Organizacional

- **Fusión de Reparticiones**: Proceso para unir dos reparticiones
- **División de Sectores**: Crear nuevos sectores a partir de existentes
- **Migración de Usuarios**: Transferir usuarios entre estructuras
- **Mantenimiento de Historial**: Preservar trazabilidad de cambios

### Gestión de Períodos

- **Cambios de Gestión**: Rotación de titulares
- **Licencias**: Manejo de ausencias temporales
- **Reestructuraciones**: Cambios masivos en la organización
- **Archivado**: Preservación de estructuras históricas

## Reportes y Métricas

### Reportes Disponibles

- **Organigrama Completo**: Vista jerárquica total
- **Distribución de Personal**: Usuarios por repartición/sector
- **Vacantes**: Posiciones sin titular asignado
- **Histórico de Cambios**: Log de modificaciones organizacionales

### Métricas del Sistema

- Total de reparticiones activas
- Total de sectores por repartición
- Distribución de usuarios
- Porcentaje de cobertura de titulares