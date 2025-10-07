# Configuración de Documentos

## 1. Propósito y Objetivos Clave

La Configuración de Documentos permite a los Administradores definir y personalizar los parámetros fundamentales para la creación, gestión y formalización de documentos electrónicos dentro del sistema GDI. El objetivo es asegurar que cada documento cumpla con las normativas y requisitos específicos definidos por la municipalidad.

### Objetivos principales:

- **Definir tipos oficiales**: Establecer qué tipos de documentos pueden crear los usuarios del sistema
- **Configurar firma**: Determinar quién o quienes (según organigrama)y que tipo de firmas debe solicitar.

- **Asegurar cumplimiento normativo**: Garantizar que los documentos cumplan con las regulaciones locales
- **Facilitar la gestión**: Proveer plantillas listas para usar y configuraciones personalizadas

## 2. El Objeto DocumentTypeDefinition: Parámetros de Configuración

Cada tipo de documento se define mediante un único objeto de configuración. A continuación se detallan todos sus parámetros, su propósito y sus reglas.

### 2.1 Parámetros de Identificación (Inmutables una vez creados)

Estos campos definen la identidad única del tipo de documento y no pueden ser modificados tras su creación para mantener la integridad referencial y la consistencia histórica.

| **Parámetro** | **Descripción y Uso** | **Validaciones / Opciones** |
|---------------|----------------------|------------------------------|
| **tipo_documento** | Categoría principal del documento según su naturaleza jurídica. Afecta la lógica de negocio subyacente. | Opciones: Acto administrativo, Documento general, Comunicación, Documento importado. |
| **acronimo** | Código corto y único (ej. "DECRE", "IF") que se usa en la nomenclatura oficial del ID del documento. | Formato: 2-5 caracteres mayúsculas. Validación: Único globalmente en el sistema. |
| **nombre_documento** | Nombre completo y descriptivo del tipo de documento que verán los usuarios. | Formato: Texto libre (máx. 40 caracteres). |
| **ultimo_numero_papel** | Para tipos de "Acto Administrativo", permite inicializar la secuencia numérica para mantener la correlación con sistemas previos. | Formato: Numérico (3 dígitos). Condicional: Solo visible y obligatorio para "Acto Administrativo". |

### 2.2 Parámetros de Comportamiento y Permisos (Modificables)

Estos campos definen cómo se comporta el tipo de documento y quién puede interactuar con él. Pueden ser modificados por un Administrador en cualquier momento, aunque algunos cambios solo afectarán a documentos futuros.

| **Parámetro** | **Descripción y Uso** | **Validaciones / Opciones** |
|---------------|----------------------|------------------------------|
| **descripcion** | Texto breve opcional que explica el propósito del tipo de documento a los usuarios. | Texto libre. |
| **habilitado_en** | Define QUIÉN PUEDE FIRMAR. Es la regla de negocio más importante para la firma. La creación del documento es libre para todos, pero la firma se restringe aquí. | Opciones: • Todas las reparticiones: Cualquier titular puede firmar. • Reparticiones específicas: Solo los titulares de las reparticiones seleccionadas pueden firmar. |
| **reparticiones_especificas** | Lista de reparticiones autorizadas para firmar este tipo de documento. | Condicional: Visible y obligatorio si habilitado_en es "Reparticiones específicas". |
| **tipo_firma** | Define el método de firma requerido para garantizar la validez legal del documento. | Opciones: • Digital todos los firmantes (Máxima seguridad) • Digital solo numerador (Seguridad selectiva) • Electrónica todos los firmantes (Simplicidad operativa) |

## 3. Flujo de Configuración: Creando un Nuevo Tipo de Documento

Existen dos vías principales para configurar un nuevo tipo de documento en GDI:

### 3.1 Vía 1: Creación desde Cero

**Propósito**: Permite personalizar completamente un nuevo tipo de documento, adaptándolo a necesidades muy específicas de la municipalidad (ej. documentos  particulares, requerimientos normativos únicos).


- **Proceso**:

  1. **Selección de Vía**: El administrador elige "Crear desde Cero".

  2. **Definición de Parámetros**: Se completan todos los campos del objeto DocumentTypeDefinition (identificación, comportamiento, permisos y firma).

  3. **Validación**: El sistema valida que el acrónimo no exista en ese ecosistema ni en la tabla global.

  4. **Guardado y Activación**: Se guarda el nuevo tipo, que puede quedar en estado "Borrador" para revisión o "Activo" para uso inmediato.

### 3.2 Vía 2: Uso de Plantillas Pre-configuradas

- **Propósito**: Ofrece tipos de documento estándar listos para usar, acelerando la implementación y aprovechando las mejores prácticas de la administración pública.

- **Proceso**:
  1. **Selección de Vía**: El administrador elige "Usar Plantilla"
  2. **Selección de Plantilla**: Se escoge una plantilla del catálogo (ej. "Decreto", "Informe", "Nota")
  3. **Ajuste de Parámetros**: Los campos inmutables (Acrónimo, Nombre) ya vienen definidos. El administrador solo ajusta los parámetros modificables como habilitado_en y tipo_firma según las políticas locales
  4. **Activación**: Se activa el nuevo tipo de documento

## 4. Gestión de Tipos de Documento Existentes

### 4.1 Estados: Activo, Inactivo, Borrador

- **Activo**: El tipo de documento está disponible en el dropdown de "Crear Documento" para todos los usuarios
- **Inactivo**: El tipo existe en el Backoffice pero no está disponible para crear nuevos documentos. Es útil para tipos obsoletos que aún tienen documentos asociados
- **Borrador**: La configuración está en proceso y no ha sido finalizada. Solo es visible en el Backoffice

### 4.2 Edición, Desactivación y Eliminación

- **Edición**: Se pueden modificar los parámetros de comportamiento (Sección 2.2) de un tipo existente. Los cambios en habilitado_en o tipo_firma solo afectarán a los documentos creados a partir de ese momento
- **Activación/Desactivación**: Se puede cambiar el estado entre "Activo" e "Inactivo" en cualquier momento
- **Eliminación**: Solo se pueden eliminar tipos de documento que no tengan ningún documento asociado en el sistema, para garantizar la integridad de los datos. La alternativa segura es desactivarlos

## 5. Catálogo de Plantillas y Tipos de Firma

### 5.1 Catálogo Detallado de Plantillas por Categoría

GDI incluye un catálogo de plantillas pre-configuradas para los documentos más comunes. Estas plantillas aceleran la implementación y aseguran el cumplimiento de estándares.

#### Normativo (Actos Administrativos)

| **Documento** | **Acrónimo** | **Descripción** | **Habilitado en** | **Reparticiones** | **Último Número** | **Tipo de Firma** |
|---------------|--------------|-----------------|-------------------|-------------------|-------------------|-------------------|
| Decreto | DECRE | Norma de carácter general dictada por el Departamento Ejecutivo | Repartición específica | INTEN | Number Input | Digital todos los firmantes |
| Resolución | RESOL | Decisión administrativa sobre un caso particular | Repartición específica | INTEN | Number Input | Digital todos los firmantes |
| Disposición | DISP | Decisión administrativa de una dirección o área específica | Repartición específica | DIREC, DIC B, etc. | Number Input | Digital solo numerador |
| Registro de Planos | PROAA | Borrador de resolución, disposición u otro acto aún no firmado | Repartición específica | SSPCG | Number Input | Electrónica todos los firmantes |
| Registro de Habilitación | ORDEN | Norma general sancionada por el Concejo Deliberante | Repartición específica | SSAP, GDPE | Number Input | Electrónica todos los firmantes |
| Proyecto de Ordenanza | PROOR | Propuesta de norma enviada al Concejo Deliberante | Repartición específica | Dpto. Ejecutivo | Number Input | Electrónica a todos |

#### Comunicación

| **Documento** | **Acrónimo** | **Descripción** | **Habilitado en** | **Tipo de Firma** |
|---------------|--------------|-----------------|-------------------|-------------------|
| Nota | NO | Comunicación entre áreas o hacia externos | Todas las reparticiones | Electrónica todos los firmantes |
| Nota externa | NOTEX | Nota dirigida a organismos o entidades fuera de la Administración | Todas las reparticiones | Electrónica todos los firmantes |
| Memo | ME | Comunicación interna entre reparticiones del mismo organismo | Todas las reparticiones | Electrónica todos los firmantes |

#### Técnico (Documentos Generales)

| **Documento** | **Acrónimo** | **Descripción** | **Habilitado en** | **Tipo de Firma** |
|---------------|--------------|-----------------|-------------------|-------------------|
| Providencia | PV | Constancia administrativa breve con instrucciones | Todas las reparticiones | Electrónica todos los firmantes |
| Informe | IF | Documento con información técnica, administrativa o de gestión | Todas las reparticiones | Electrónica todos los firmantes |
| Anexo | ANEXO | Documento complementario que acompaña a otro principal | Todas las reparticiones | Electrónica todos los firmantes |
| Instrumento legal | INLEG | Documento de naturaleza jurídica o contractual | Todas las reparticiones | Electrónica todos los firmantes |
| Dictamen | DICT | Opinión técnica o jurídica sobre un asunto específico | Todas las reparticiones | Digital solo numerador |
| Acta | ACTA | Documento que registra lo acontecido en una reunión o evento | Todas las reparticiones | Electrónica todos los firmantes |
| Pliego | PLIEG | Documento que establece condiciones y especificaciones | Todas las reparticiones | Digital solo numerador |

#### Otros

| **Documento** | **Acrónimo** | **Descripción** | **Habilitado en** | **Tipo de Firma** |
|---------------|--------------|-----------------|-------------------|-------------------|
| Informe gráfico | IFGRA | Informe que incluye representaciones visuales | Todas las reparticiones | Electrónica todos los firmantes |
| Documento de test | TEST | Documento para pruebas del sistema | Todas las reparticiones | Electrónica todos los firmantes |

### 5.2 Personalización de Plantillas

Al seleccionar una plantilla, el Administrador puede ajustar:

- **Reparticiones habilitadas**: Cambiar qué titulares pueden firmar el documento
- **Tipo de firma**: Modificar el método de firma según políticas locales
- **Descripción**: Añadir contexto específico del municipio
- **Campos no editables**: Acrónimo y nombre permanecen fijos para mantener la compatibilidad

**Nota**: Las plantillas definen quién puede firmar, no quién puede crear el documento.

### 5.3 Tipos de Firma y su Validez Legal

La configuración del tipo de firma es crucial para determinar la validez legal y el flujo de aprobación.

| **Tipo de Firma** | **Validez Legal** | **Complejidad** | **Uso Recomendado** | **Proceso** |
|-------------------|-------------------|-----------------|---------------------|-------------|
| Digital todos | Máxima | Alta | Decretos, Resoluciones (actos de alta importancia) | Cada firmante debe tener y usar un certificado válido |
| Digital solo numerador | Alta | Media | Disposiciones, Dictámenes, Pliegos (responsabilidad legal en una autoridad) | Solo el último firmante (Numerador) usa certificado digital; los demás usan credenciales GDI |
| Electrónica todos | Media | Baja | Comunicaciones, informes, documentos operativos | Firma con credenciales GDI para todos los firmantes |

## 6. Relación con la Base de Datos

Las definiciones de tipos de documento configuradas en el Backoffice se persisten en la base de datos, principalmente en la tabla `Documentos` (o tablas relacionadas como `TiposDocumento` si existe una tabla específica para la definición de tipos). Cada parámetro (`tipo_documento`, `acronimo`, `nombre_documento`, `descripcion`, `habilitado_en`, `reparticiones_especificas`, `tipo_firma`, `ultimo_numero_papel`) corresponde a un campo o conjunto de campos dentro de estas tablas, asegurando la integridad y persistencia de la configuración. Para más detalles sobre la estructura de la base de datos, consulte la documentación en `06-DataBase/Documentos.md`.

## 7. Impacto en el Sistema y Validaciones

### 6.1 Validaciones y Restricciones del Sistema

- **Campos Obligatorios**: El sistema no permite guardar una configuración sin tipo_documento, acronimo, nombre_documento, habilitado_en y tipo_firma
- **Reglas de Unicidad**: El acronimo debe ser único en toda la instalación. La combinación de nombre_documento y tipo_documento también debe ser única para evitar confusiones
- **Validaciones Condicionales**: El campo ultimo_numero_papel es obligatorio solo para "Actos Administrativos". El campo reparticiones_especificas es obligatorio solo si habilitado_en es "Específicas"

### 6.2 Impacto de los Cambios en los Módulos

Las configuraciones realizadas aquí tienen un efecto inmediato y directo en el resto del sistema:

#### Módulo Documentos:
- El dropdown de "Crear Documento" muestra instantáneamente los tipos activos
- La asignación de firmantes y el flujo de firma se rigen automáticamente por lo configurado
- El formato del encabezado y la numeración se aplican según las plantillas

#### Módulo Expedientes:
- La vinculación de documentos respeta los tipos y reglas definidos
- Las carátulas de expedientes pueden hacer referencia a los tipos de documentos que contienen

#### Módulo Organigrama:
- Los permisos de firma se validan contra los titulares de las reparticiones configuradas
- Se previene la asignación de firmantes no autorizados