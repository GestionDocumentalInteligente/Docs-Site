# Flujos de Gestión del Organigrama

## 4.1 Sección "Mi Equipo" - Vista para Agentes

<!-- [IMAGEN PANTALLA - Vista Agente Mi Equipo] -->

Cuando un **agente** entra a "Mi Equipo":

### Pestaña "Organización":
- En el panel izquierdo ve su repartición (tabla departments)
- Ve tabs de sectores (tabla sectors) de su repartición
- Por defecto ve su propio sector
- Puede hacer click en otros tabs para ver otros sectores de la misma repartición
- Cada sector muestra los usuarios (tabla users) en formato de cards

### Pestaña "Usuarios":
- Ve una lista completa de TODOS los usuarios (tabla users) de su repartición
- Cada usuario muestra a qué sector (tabla sectors) pertenece (con tags)
- Vista unificada sin importar el sector

## 4.2 Sección "Mi Equipo" - Vista para Titulares

Cuando un **titular** entra a "Mi Equipo":

### Pestaña "Organización":
- Ve exactamente lo mismo que un agente de su repartición
- Tabs de sectores de su repartición
- Puede navegar entre sectores

### Pestaña "Usuarios":
- Ve la lista completa de usuarios de su repartición
- Cada usuario con su tag de sector

### Diferencia clave - Gestión:
- El titular ve botones y opciones de gestión
- Puede dar de **alta** nuevos usuarios (creando un registro en users)
- Puede dar de **baja** usuarios existentes (actualizando users.is_active a false)
- Puede **pausar** usuarios (actualizando users.is_active a false) (ej: por licencia)

## 4.3 Flujo de Alta de Usuario (Solo Titulares)

<!-- [IMAGEN FLUJO - Proceso Alta Usuario] -->

### Proceso de alta de usuario:

**Paso 1:** Titular hace click en botón "Agregar"

**Paso 2:** Se abre formulario con datos mínimos requeridos:
- **CUIL** (users.cuil): Para identificación única del usuario
- **Email** (users.email): Para envío de invitación
- **Sector** (user_sectors.sector_id): Dropdown con sectores de su repartición
- **Cargo**: Descripción del puesto

**Paso 3:** Sistema valida datos y crea usuario en estado "pendiente_activacion" (users.is_active a false)

**Paso 4:** Sistema envía invitación por email con link de activación

**Paso 5:** La persona recibe invitación y accede al sistema (vía ARCA u otro método)

**Paso 6:** La persona completa sus datos personales:
- Nombre y Apellido
- DNI
- Celular
- País
- Otros datos requeridos

**Paso 7:** Sistema valida CUIL con datos ingresados y activa la cuenta

**Paso 8:** Usuario aparece como "activo" (users.is_active a true) en la lista del titular

## 4.4 Gestión de Estados de Usuario (Solo Titulares)

### Pausar Usuario: (users.is_active a false)
- Usuario mantiene acceso limitado
- Útil para licencias temporales
- El usuario puede consultar pero no gestionar

### Dar de Baja Usuario: (users.is_active a false)
- Usuario pierde acceso completo al sistema
- Para desvinculaciones permanentes
- Se mantiene el registro histórico

### Reactivar Usuario: (users.is_active a true)
- Vuelve a estado activo
- Recupera acceso completo
- Se restauran todos los permisos anteriores

### Estados disponibles: (reflejados en users.is_active)
- **Activo**: Acceso completo al sistema
- **Pausado**: Acceso limitado/solo consulta
- **Inactivo**: Sin acceso al sistema
- **Pendiente activación**: Usuario creado pero no activado