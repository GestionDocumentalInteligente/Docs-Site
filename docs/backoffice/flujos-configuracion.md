# Flujos de Configuracion

## 1. Configuracion Inicial del Sistema

El proceso de configuracion inicial establece las bases para que el sistema GDI funcione correctamente. Debe realizarse en un orden especifico, ya que cada paso depende del anterior.

### Flujo Completo de Setup

```
Paso 1: Informacion General
    │  └─ Nombre, acronimo, identidad visual
    ▼
Paso 2: Organigrama - Reparticiones
    │  └─ Crear secretarias, direcciones, subsecretarias
    ▼
Paso 3: Organigrama - Sectores
    │  └─ Crear sectores dentro de cada reparticion
    ▼
Paso 4: Organigrama - Usuarios y Titulares
    │  └─ Asignar titulares, cargar usuarios (individual o masiva)
    ▼
Paso 5: Accesos y Control
    │  └─ Invitar administradores adicionales
    ▼
Paso 6: Tipos de Documentos
    │  └─ Configurar desde plantillas o crear desde cero
    ▼
Paso 7: Tipos de Expedientes
    │  └─ Configurar tipos de tramites disponibles
    ▼
Paso 8: Integraciones y API Keys
    │  └─ Conectar servicios externos (IA, firma digital, etc.)
    ▼
Sistema Operativo
```

## 2. Flujo de Configuracion de Informacion General

### Proceso

1. **Completar datos institucionales**: Nombre oficial, acronimo, tipo de entidad, domicilio fiscal, identificacion tributaria
2. **Configurar identidad visual**: Subir logo, isologo, imagen de portada. Seleccionar color institucional
3. **Frase anual (opcional)**: Ingresar lema del periodo en curso
4. **Guardar cambios**: Validacion automatica y aplicacion inmediata

### Impacto

- La identidad visual se aplica en toda la interfaz del sistema principal
- Los datos institucionales aparecen en encabezados de documentos y caratulas de expedientes
- Los documentos ya existentes no se modifican para preservar integridad historica

## 3. Flujo de Configuracion del Organigrama

### 3.1 Crear Reparticiones

1. Acceder a seccion Organigrama
2. Seleccionar "Nueva Reparticion"
3. Completar campos obligatorios:
   - **Nombre**: Denominacion oficial (ej: "Secretaria de Gobierno")
   - **Acronimo**: Codigo unico global (ej: "SEGOB"), formato `[A-Z]{3,8}`
4. Completar campos opcionales: descripcion, tipo de reparticion
5. Guardar y verificar unicidad del acronimo

### 3.2 Crear Sectores

1. Seleccionar la reparticion padre
2. Agregar nuevo sector
3. Completar campos:
   - **Nombre**: Denominacion del sector (ej: "Departamento de Tesoreria")
   - **Acronimo**: Codigo unico global (ej: "TESO"), formato `[A-Z]{3,4}[0-9]{0,2}`
4. Opcionalmente asignar responsable de sector

### 3.3 Asignar Titulares

1. Seleccionar reparticion
2. Buscar usuario existente en el sistema
3. Asignar como titular (responsable principal)
4. Opcionalmente asignar delegados de gestion

### 3.4 Carga de Usuarios

**Individual**: Desde la interfaz del Backoffice, completando formulario por cada usuario.

**Masiva (CSV/Excel)**: Para incorporaciones a gran escala:

1. Descargar template predefinido
2. Completar datos: CUIL, Email, Nombre, Reparticion, Sector, Cargo
3. Subir archivo al sistema
4. Validacion automatica (CUIL unico, email unico, reparticion/sector existente)
5. Procesamiento en lotes de 50 usuarios
6. Envio automatico de invitaciones por email
7. Usuarios completan datos personales y activan cuenta

## 4. Flujo de Configuracion de Documentos

### Desde Plantilla (Recomendado)

1. Seleccionar "Usar Plantilla" del catalogo
2. Elegir plantilla (ej: Decreto, Resolucion, Nota)
3. Los campos inmutables vienen predefinidos (acronimo, nombre)
4. Ajustar parametros modificables:
   - `habilitado_en`: Todas las reparticiones o reparticiones especificas
   - `tipo_firma`: Digital todos, digital solo numerador, o electronica todos
5. Activar el tipo de documento

### Desde Cero

1. Seleccionar "Crear desde Cero"
2. Definir parametros de identificacion:
   - `tipo_documento`: Acto administrativo, documento general, comunicacion, o importado
   - `acronimo`: Codigo unico de 2-5 caracteres
   - `nombre_documento`: Nombre descriptivo (max. 40 caracteres)
   - `ultimo_numero_papel`: Solo para actos administrativos
3. Configurar comportamiento y permisos
4. Validar y guardar

## 5. Flujo de Configuracion de Expedientes

### Desde Plantilla (Recomendado)

1. Seleccionar plantilla del catalogo (ej: Licitacion Publica, Habilitacion Comercial)
2. Los campos inmutables vienen predefinidos
3. Ajustar parametros de negocio:
   - `tipo_de_inicio`: Interno o externo
   - `reparticiones_habilitadas`: Quienes pueden crear
   - `reparticion_caratuladora`: Quien administra y numera
4. Activar tipo de expediente

### Desde Cero

1. Definir tipo de expediente y acronimo (trata)
2. Configurar tipo de inicio
3. Definir reparticiones habilitadas para crear
4. Configurar reparticion caratuladora (dinamica o fija)
5. Validar y activar

## 6. Flujo de Mantenimiento

### Operaciones Recurrentes

| Operacion | Seccion | Frecuencia Tipica |
|-----------|---------|-------------------|
| Rotacion de titulares | Organigrama | Segun cambios de gestion |
| Alta/baja de usuarios | Organigrama | Continua |
| Nuevo tipo de documento | Documentos | Segun necesidad normativa |
| Nuevo tipo de expediente | Expedientes | Segun nuevos tramites |
| Rotacion de API Keys | API Keys | Cada 90 dias recomendado |
| Verificar integraciones | Integraciones | Semanal |
| Revisar auditoria | Accesos y Control | Diaria |

### Reestructuracion Organizacional

Para cambios mayores en la estructura del municipio:

1. Planificar cambios en reparticiones y sectores
2. Crear nuevas estructuras antes de migrar usuarios
3. Transferir usuarios a nuevos sectores/reparticiones
4. Reasignar titulares
5. Desactivar estructuras obsoletas (no eliminar si tienen historial)
6. Verificar que permisos y tipos de documento reflejen la nueva estructura
