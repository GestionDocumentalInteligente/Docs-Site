# Configuración de Expedientes

## 1. Propósito de la Sección

La Configuración de Expedientes permite a los Administradores definir y personalizar los parámetros fundamentales para la creación, gestión y tramitación de expedientes electrónicos dentro del sistema GDI. El objetivo es adaptar el comportamiento del módulo GDI-EXPEDIENTES a las necesidades específicas de cada municipalidad.

### Objetivos principales:

- **Definir tipos oficiales de expedientes**: Establecer qué tipos de trámites puede gestionar cada repartición
- **Configurar reparticiones administradoras**: Determinar qué área será responsable de cada tipo de expediente y **cuya sigla aparecerá en la numeración oficial**
- **Definir permisos de creación**: Especificar qué reparticiones pueden iniciar cada tipo de expediente
- **Asegurar flujos administrativos**: Garantizar que los expedientes sigan los procedimientos establecidos
- **Facilitar la gestión**: Proveer plantillas listas para usar y configuraciones personalizadas

## 2. El Objeto ExpedientTypeDefinition: Parámetros de Configuración

Cada tipo de expediente se define mediante un único objeto de configuración. A continuación se detallan todos sus parámetros.

### 2.1 Parámetros de Identificación (Inmutables una vez creados)

Estos campos definen la identidad única del tipo de expediente y no pueden ser modificados tras su creación.

| **Parámetro** | **Descripción y Uso** | **Validaciones / Opciones** |
|---------------|----------------------|------------------------------|
| **tipo_de_expediente** | Nombre completo y descriptivo del tipo de trámite. | Texto libre (máx. 100 caracteres). Obligatorio. |
| **acronimo (Trata)** | Código corto y único (ej. "LICPUB", "OBRA") que identifica el tipo de expediente en la numeración oficial. | 3-10 caracteres alfanuméricos en mayúsculas. Único globalmente. |

### 2.2 Parámetros de Comportamiento y Permisos (Modificables)

Estos campos definen la lógica de negocio del expediente y pueden ser ajustados por un Administrador.

| **Parámetro** | **Descripción y Uso** | **Validaciones / Opciones** |
|---------------|----------------------|------------------------------|
| **motivo_del_expediente** | Descripción opcional para orientar al usuario sobre el propósito del expediente. | Texto libre. |
| **tipo_de_inicio** | Define si el trámite es iniciado por un usuario interno del sistema o por un ciudadano externo. | Opciones: Interno (municipalidad), Externo (ciudadanos). |
| **reparticiones_habilitadas** | Define QUIÉN PUEDE CREAR el expediente. | Opciones: Todas, Selección Múltiple (solo reparticiones específicas). |
| **seleccion_multiple** | Lista de reparticiones específicas que pueden crear este tipo de expediente. | Condicional: Visible y obligatorio si Reparticiones Habilitadas es "Selección Múltiple". |
| **reparticion_caratuladora** | Define QUIÉN ADMINISTRA el expediente y qué sigla aparece en el número oficial. | Opciones: Repartición creadora (dinámica), Específica (fija). |
| **reparticion_especifica** | La repartición fija que siempre será la administradora de este tipo de expediente. | Condicional: Visible y obligatorio si Repartición Caratuladora es "Específica". |

## 3. Lógica de Caratulación y Reparticiones

Esta es la sección más crítica de la configuración, ya que define responsabilidades y la estructura de la numeración.

### 3.1 Diferencia Fundamental: Crear vs. Administrar

- **Crear**: Quién puede iniciar un expediente. Definido por reparticiones_habilitadas
- **Administrar**: Quién es el dueño responsable del expediente y cuya sigla aparece en el número oficial. Definido por reparticion_caratuladora
- **Actuar**: Quién puede realizar acciones específicas en el expediente (vincular documentos, etc.)

### 3.2 Configuración de Permisos de Creación (Reparticiones Habilitadas)

#### Todas
- Cualquier usuario de cualquier repartición puede crear el expediente
- Uso típico: Expedientes de gestión general (reclamos, solicitudes básicas)

#### Selección Múltiple
- Solo los usuarios de las reparticiones seleccionadas pueden crear el expediente
- Uso típico: Expedientes especializados que requieren conocimiento técnico específico

### 3.3 Configuración de Responsabilidad (Repartición Caratuladora)

#### Repartición creadora (Dinámica)
- Repartición del usuario creador = Repartición administradora del expediente
- **Sigla de la repartición creadora = Aparece en el número del expediente**
- **Características:**
  - Responsabilidad distribuida: Cada área administra sus propios expedientes
  - Numeración dinámica: La sigla varía según quién cree el expediente
  - Uso recomendado: Expedientes de temática variada donde cada área gestiona los suyos

#### Específica (Fija)
- Repartición fija predefinida = Repartición administradora del expediente
- **Sigla de la repartición específica = Siempre aparece en el número del expediente**
- **Características:**
  - Centralización especializada: Una sola área administra todos los expedientes del tipo
  - Numeración fija: Siempre la misma sigla independientemente del creador
  - Uso recomendado: Expedientes que requieren expertise específico o centralización

### 3.4 Ejemplo Práctico Completo: Habilitación Comercial

#### Configuración:
- Acrónimo: HABCOM
- Habilitadas para Caratular: Todas
- Repartición Caratuladora: Específica → "Dirección de Comercio (DICO)"

#### Flujo Operativo:
1. Marta López (de "Mesa de Entrada") crea el expediente HABCOM
2. El sistema asigna automáticamente la administración a "Dirección de Comercio"
3. **El expediente se numera como EX-2025-001234-TN-DICO. La sigla DICO es fija**
4. "Dirección de Comercio" gestiona el ciclo de vida, mientras que "Mesa de Entrada" queda como repartición actuante (puede vincular documentos)

## 4. Flujo de Configuración

### Proceso Paso a Paso

#### Paso 1: Selección de Vía
```
Crear Tipo de Expediente
├── Desde Cero
│   └── Configuración completa manual
└── Desde Plantilla
    └── Selección y ajuste de plantilla existente
```

#### Paso 2: Definición de Parámetros
1. Información básica (tipo, acrónimo, motivo)
2. Configuración de inicio (interno o externo)
3. Alcance organizacional (reparticiones habilitadas)
4. Responsabilidad administrativa (repartición caratuladora)

#### Paso 3: Guardado y Activación
- **Guardar y Previsualizar**: Guarda la configuración sin activar
- **Dar de Alta**: Activa el tipo de expediente, haciéndolo disponible para usuarios
- **Editar**: Modifica parámetros editables de tipos existentes

## 5. Plantillas Pre-configuradas

GDI incluye plantillas basadas en los expedientes más comunes de la administración pública municipal. Estas plantillas aceleran la implementación y aseguran el cumplimiento de procedimientos administrativos estándar.

### 5.1 Catálogo de Plantillas Completo

#### Contrataciones y Licitaciones

| **Tipo de expediente** | **Acrónimo** | **Tipo de Inicio** | **Habilitadas** | **Caratuladora** | **Repartición Específica** |
|------------------------|--------------|-------------------|-----------------|------------------|-----------------------------|
| Licitación Pública | LICPUB | Interno | Todas | Específica | Dirección de Compras |
| Registro de Proveedores | REGPRO | Interno | Todas | Específica | Dirección de Compras |

#### Tributos y Tasas

| **Tipo de expediente** | **Acrónimo** | **Tipo de Inicio** | **Habilitadas** | **Caratuladora** | **Repartición Específica** |
|------------------------|--------------|-------------------|-----------------|------------------|-----------------------------|
| Solicitud de Eximición de Tasas | EXTASA | Externo | Todas | Específica | Secretaría de Hacienda |

#### Obras y Construcción

| **Tipo de expediente** | **Acrónimo** | **Tipo de Inicio** | **Habilitadas** | **Caratuladora** | **Repartición Específica** |
|------------------------|--------------|-------------------|-----------------|------------------|-----------------------------|
| Permiso de Obra | OBRA | Externo | Selección Múltiple | Repartición creadora | --- |
| Permiso de Obra Menor | OBRAMEN | Externo | Selección Múltiple | Repartición creadora | --- |

#### Habilitaciones Comerciales

| **Tipo de expediente** | **Acrónimo** | **Tipo de Inicio** | **Habilitadas** | **Caratuladora** | **Repartición Específica** |
|------------------------|--------------|-------------------|-----------------|------------------|-----------------------------|
| Habilitación Comercial | HABCOM | Externo | Todas | Específica | Dirección de Comercio |
| Alta de Comercio Minorista | HABMIN | Externo | Selección Múltiple | Específica | Dirección de Comercio |

#### Servicios Públicos

| **Tipo de expediente** | **Acrónimo** | **Tipo de Inicio** | **Habilitadas** | **Caratuladora** | **Repartición Específica** |
|------------------------|--------------|-------------------|-----------------|------------------|-----------------------------|
| Solicitud de Espacio Público | ESPUB | Externo | Todas | Repartición creadora | --- |
| Solicitud de Espacio Público | ESPPUB | Externo | Todas | Repartición creadora | --- |
| Solicitud de Alumbrado | ALUM | Externo | Todas | Específica | Subsecretaría de Espacio Público |
| Reclamo de Servicios | RECSERV | Externo | Todas | Repartición creadora | --- |

#### Técnicos y Ambientales

| **Tipo de expediente** | **Acrónimo** | **Tipo de Inicio** | **Habilitadas** | **Caratuladora** | **Repartición Específica** |
|------------------------|--------------|-------------------|-----------------|------------------|-----------------------------|
| Pedido de Informe Técnico | INFTEC | Interno | Selección Múltiple | Específica | Dirección Técnica |
| Declaración Jurada Ambiental | DJAMB | Interno | Selección Múltiple | Específica | Medio Ambiente |

### 5.2 Personalización de Plantillas

Al seleccionar una plantilla, el Administrador puede ajustar:

- **Reparticiones habilitadas**: Cambiar qué reparticiones pueden crear el expediente
- **Repartición caratuladora**: Modificar qué repartición será la administradora y númere el expediente
- **Tipo de inicio**: Ajustar si es interno o externo
- **Motivo**: Personalizar la descripción según políticas locales
- **Campos no editables**: Acrónimo y tipo permanecen fijos para mantener compatibilidad

## 6. Relación con la Base de Datos

Las definiciones de tipos de expediente configuradas en el Backoffice se persisten en la base de datos, principalmente en la tabla `record_templates`. Cada parámetro de configuración (`tipo_de_expediente`, `acronimo`, `motivo_del_expediente`, `tipo_de_inicio`, `reparticiones_habilitadas`, `seleccion_multiple`, `reparticion_caratuladora`, `reparticion_especifica`) se mapea a un campo o conjunto de campos dentro de esta tabla (`type_name`, `acronym`, `description`, `creation_channel`, `enabled_departments`, `filing_department_id`), asegurando la integridad y persistencia de la configuración. Para más detalles sobre la estructura de la base de datos, consulte la documentación en `06-DataBase/Tablas Expediente/Expediente.md`.

## 7. Nomenclatura y Numeración de IDs

### 6.1 Formato Estándar de Numeración

La nomenclatura de los IDs de expedientes sigue un formato estandarizado para asegurar unicidad, trazabilidad y fácil identificación dentro del ecosistema:

```
EX-<AÑO>-<NÚMERO_CORRELATIVO>-<SIGLA_ECOSISTEMA>-<SIGLA_REPARTICIÓN>
│   │     │                    │                  │
│   │     │                    │                  └─→ Repartición caratuladora
│   │     │                    └─→ Jurisdicción (ej. "TN" = Terranova)
│   │     └─→ Contador correlativo (ej. "123")
│   └─→ Año de creación (YYYY)
└─→ Tipo de expediente ("EX" = Expediente)
```

**Ejemplo**: EX-2025-001234-TN-DICO

### 6.2 Componentes del Formato

| **Componente** | **Descripción** | **Ejemplo** | **Configuración** |
|----------------|-----------------|-------------|-------------------|
| **EX** | Identificador del tipo (EX = Expediente) | EX | Fijo del sistema |
| **2025** | Año de creación | 2025 | Automático |
| **001234** | Número correlativo del expediente (por año) | 001234 | Configurable por tipo |
| **TN** | Sigla del municipio o jurisdicción | TN (Terranova) | Configuración institucional |
| **DICO** | **Sigla de la repartición caratuladora** | DICO (Dir. Compras) | **Según configuración del tipo** |

**IMPORTANTE**: La sigla de repartición que aparece en la numeración oficial **siempre corresponde a la Repartición Caratuladora** configurada para ese tipo de expediente, no necesariamente a la repartición del usuario que lo crea.

## 7. Generación Automática de Carátula

### 7.1 Proceso Automático

Una vez completados los datos requeridos para la creación de un expediente, el sistema genera automáticamente la carátula en formato PDF. Este proceso se realiza a través de una **API interna**, que construye y devuelve el documento utilizando los datos ingresados por el usuario y las configuraciones definidas en el Backoffice.

**IMPORTANTE**: Esta carátula es en sí misma un **Tipo de documento llamado "Carátula de Expediente (CAEX)"**, con su propia numeración correlativa, y que coexiste con el número del expediente (EX) al que pertenece.

### 7.2 Información Generada Automáticamente

#### Encabezado
- **Tipo**: Carátula de Expediente (CAEX)
- **Número de documento**: Identificador único del informe de caratulación
  - Formato: CAEX-2025-005000-TN-DGCO
- **Referencia**: Nro. Expediente + motivo
- **Lugar y fecha**: Ciudad y fecha de generación de la carátula
  - Ejemplo: "Terranova, 03 de mayo de 2025"

#### Datos del Expediente
- **Fecha de caratulación**: Fecha del sistema al momento de crear el expediente (Ej. 03/05/2025)
- **Iniciador**: Indica el origen del trámite, si es interno (municipio) o externo (vecino)
- **Usuario caratulador**: Nombre y apellido del usuario que inicia el expediente con formato: "Nombre Apellido REPARTICIÓN#SECTOR"
- **Área iniciadora**: Repartición caratuladora
- **Tipo de expediente**: La opción seleccionada al crear el expediente
- **Motivo del expediente**: Texto libre ingresado por el usuario al crear el expediente
- **Número de expediente**: El identificador automático con formato estándar

## 8. Estados y Gestión

### 8.1 Estados de Tipos de Expediente

#### Activo
- **Descripción**: El tipo está disponible para crear expedientes
- **Visible en**: Dropdown de "Crear Expediente" para usuarios autorizados
- **Acciones permitidas**: Editar parámetros modificables, desactivar

#### Inactivo
- **Descripción**: El tipo existe pero no está disponible para crear nuevos expedientes
- **Visible en**: Solo en el Backoffice, no aparece en el sistema operativo
- **Acciones permitidas**: Reactivar, editar, eliminar (si no tiene expedientes asociados)

#### Borrador
- **Descripción**: Configuración en proceso, no finalizada
- **Visible en**: Solo en Backoffice como borrador
- **Acciones permitidas**: Completar configuración, activar, descartar

### 8.2 Transiciones de Estado

```
Borrador → [Completar configuración] → Activo
Activo ↔ [Activar/Desactivar] ↔ Inactivo
Inactivo → [Eliminar] → ❌ (solo si no tiene expedientes)
```

## 9. Validaciones y Restricciones

### 9.1 Validaciones del Sistema

#### Campos Obligatorios
- Tipo de expediente
- Acrónimo (único, 3-10 caracteres)
- Tipo de inicio (Interno o Externo)
- Reparticiones habilitadas para caratular
- Repartición caratuladora

#### Reglas de Unicidad
- **Acrónimo**: Debe ser único en toda la instalación de GDI
- **Tipo + Acrónimo**: La combinación debe ser única para evitar confusiones

#### Validaciones Condicionales
- **Selección Múltiple**: Obligatorio si "Habilitadas" = "Selección Múltiple"
- **Repartición Específica**: Obligatorio solo si Caratuladora = "Específica"
- **Consistencia lógica**: Las reparticiones habilitadas deben existir y estar activas

### 9.2 Restricciones de Modificación

#### Campos Inmutables (una vez creado)
- **Tipo de expediente**: Mantiene consistencia conceptual
- **Acrónimo**: Impacta la numeración oficial existente

#### Campos Modificables
- **Motivo del expediente**: Puede actualizarse para mayor claridad
- **Tipo de inicio**: Ajuste de políticas de acceso (Interno/Externo)
- **Reparticiones habilitadas**: Cambio inmediato en disponibilidad
- **Repartición caratuladora**: Afecta solo expedientes futuros

## 10. Impacto en el Sistema Operativo

### 10.1 Efecto Inmediato en Módulos

#### Módulo Expedientes
- **Dropdown "Crear Expediente"**: Muestra tipos activos filtrados por repartición del usuario según configuración "Habilitadas"
- **Asignación automática**: Aplica lógica de repartición caratuladora configurada
- **Validación de inicio**: Verifica tipo de inicio (interno/externo) según configuración y tipo de usuario
- **Numeración**: Usa acrónimo + **sigla de repartición administradora** en la numeración oficial
- **Carátula automática**: Genera PDF con firma del creador pero asigna responsabilidad según configuración
- **Reparticiones actuantes**: Asigna automáticamente a la repartición creadora como actuante

#### Módulo Documentos
- **Vinculación**: Los documentos pueden vincularse a expedientes según tipos configurados
- **Referencias cruzadas**: Respeta las reglas de responsabilidad administrativa

#### Módulo Organigrama
- **Permisos de creación**: Filtra tipos de expediente según repartición del usuario y configuración "Habilitadas"
- **Responsabilidades**: Aplica automáticamente la repartición caratuladora configurada
- **Validación de usuarios**: Previene acceso no autorizado según configuración

### 10.2 Ejemplo de Flujo Completo

**Configuración: HABCOM (Habilitación Comercial)**
```
├── Habilitadas: Todas
├── Caratuladora: Específica → Dirección de Comercio (DICO)
└── Tipo: Externo
```

**Flujo:**
1. Ciudadano inicia trámite → Sistema crea expediente "borrador"
2. Marta López (Mesa de Entrada) toma el trámite
3. **Sistema genera: EX-2025-001234-TN-DICO**

**Roles asignados:**
- Administradora: Dirección de Comercio
- Actuante: Mesa de Entrada
- Creadora: Mesa de Entrada (para auditoría)

**Carátula**: Firmada por Marta López, administrada por DICO