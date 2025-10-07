# Validaciones y Gestión de Excepciones - Framework GDI

## Introducción

El módulo de Documentos de GDI implementa un sistema robusto de validaciones y manejo de excepciones para garantizar la integridad de los datos, la consistencia de los procesos y la capacidad de recuperación ante situaciones imprevistas. Este sistema opera en múltiples niveles, desde validaciones de entrada hasta gestión de casos especiales complejos. Se basa en **constraints de base de datos**, **ENUMs tipados** y **funciones de validación** para una implementación robusta.

Este documento detalla las validaciones implementadas y requeridas para una instalación completa del framework, incluyendo constraints de base de datos, funciones de validación de negocio, triggers automáticos y procedimientos de manejo de excepciones.

## Validaciones del Sistema y su Implementación Técnica

### Validaciones de Entrada

Las validaciones de entrada son la primera línea de defensa para garantizar la calidad de los datos. A continuación, se describen las reglas de negocio y su correspondiente implementación técnica en Supabase.

#### Campos Obligatorios

- **Tipo de documento**: Debe existir y estar activo en el sistema.
- **Referencia/Motivo**: Campo obligatorio con límite de caracteres (máximo 254 caracteres). No puede estar vacío o contener solo espacios.
- **Firmantes**: Al menos un firmante debe estar asignado.
- **Numerador**: Debe estar definido antes de iniciar el circuito. Solo puede haber un numerador por documento.
- **Contenido**: Contenido estructurado obligatorio (HTML válido y bien formado). No puede estar vacío.
- **ID Editor Colaborativo (`pad_id`)**: Requerido para la edición colaborativa.

**Implementación Técnica:**

```sql
-- Validaciones críticas implementadas en la tabla `document_draft`
document_id         UUID NOT NULL DEFAULT gen_random_uuid()
document_type_id    UUID NOT NULL  -- Debe referenciar document_types válido
created_by          UUID NOT NULL  -- Usuario debe existir en users
reference           TEXT NOT NULL  -- Nunca vacío (motivo/referencia)
content             JSONB NOT NULL -- Contenido estructurado obligatorio
pad_id              VARCHAR(255) NOT NULL -- ID editor colaborativo
```

#### Formato

- **Longitud de referencia**: Máximo 254 caracteres.
- **Caracteres permitidos**: Validación de caracteres especiales.
- **Estructura de contenido**: HTML válido y bien formado.

#### Negocio

- **Autorización de firmantes**: Verificación de permisos por tipo de documento.
- **Existencia de usuarios**: Confirmación de que los firmantes existen y están activos en el sistema.
- **Estado de usuarios**: Verificación de que están activos en el sistema.

### Validaciones por Estado y Transiciones

El sistema de estados del documento es fundamental para controlar el ciclo de vida de un documento. Cada transición de estado está protegida por validaciones específicas.

**Estados Controlados por ENUM:**

```sql
-- ENUM document_status con valores válidos
'draft'         -- En edición colaborativa
'sent_to_sign'  -- Enviado al circuito de firmas
'signed'        -- Firmado y con validez legal oficial
'rejected'      -- Rechazado por algún firmante
'cancelled'     -- Cancelado antes de completar proceso
'archived'      -- Archivado después de finalizado
```

#### Estado `draft` (En Edición)

- **Contenido mínimo**: El documento debe tener contenido antes de enviar a firma.
- **Firmantes configurados**: Al menos un firmante y un numerador asignados.
- **Permisos de edición**: El usuario debe tener permisos para modificar.

**Implementación Técnica (Validación de contenido mínimo):**

```sql
-- Validación de contenido mínimo
CREATE OR REPLACE FUNCTION validate_draft_content()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar que reference no sea solo espacios
    IF trim(NEW.reference) = '' THEN
        RAISE EXCEPTION 'La referencia no puede estar vacía';
    END IF;
    
    -- Verificar que content tenga estructura mínima
    IF NEW.content = '{}'::jsonb THEN
        RAISE EXCEPTION 'El contenido no puede estar vacío';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### Estado `sent_to_sign` (Esperando Firmas)

- **Inmutabilidad**: El contenido no puede ser modificado una vez enviado a firma.
- **Integridad de firmantes**: Verificación de que los firmantes siguen activos.
- **Secuencia de firmas**: Validación del orden de firmas configurado.

**Implementación Técnica (Inmutabilidad y firmantes activos):**

```sql
-- Trigger de Inmutabilidad de Contenido
CREATE OR REPLACE FUNCTION protect_document_content()
RETURNS TRIGGER AS $$
BEGIN
    -- Proteger contenido en estados no editables
    IF OLD.status IN ('sent_to_sign', 'signed', 'archived') THEN
        IF OLD.content IS DISTINCT FROM NEW.content OR
           OLD.reference IS DISTINCT FROM NEW.reference THEN
            RAISE EXCEPTION 'No se puede modificar contenido en estado %', OLD.status;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Validar que firmantes siguen activos
CREATE OR REPLACE FUNCTION validate_active_signers()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'sent_to_sign' THEN
        -- Verificar usuarios activos
        IF EXISTS (
            SELECT 1 FROM document_signers ds
            JOIN users u ON ds.user_id = u.user_id
            WHERE ds.document_id = NEW.document_id
              AND u.is_active = false
        ) THEN
            RAISE EXCEPTION 'Todos los firmantes deben estar activos';
        END IF;
        
        -- Marcar sent_to_sign_at
        NEW.sent_to_sign_at = NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### Estado `signed` (Firmado)

- **Numeración válida**: Formato correcto del número oficial.
- **Integridad del documento**: Validación de que no ha sido alterado.
- **Firmas válidas**: Verificación de todas las firmas aplicadas.

**Implementación Técnica (Validación de documento oficial):**

```sql
-- Validar numeración oficial completa
CREATE OR REPLACE FUNCTION validate_official_document()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'signed' THEN
        -- Verificar que existe en official_documents
        IF NOT EXISTS (
            SELECT 1 FROM official_documents 
            WHERE document_id = NEW.document_id
        ) THEN
            RAISE EXCEPTION 'Documento firmado debe tener registro oficial';
        END IF;
        
        -- Verificar numeración confirmada
        IF NOT EXISTS (
            SELECT 1 FROM official_documents od
            JOIN numeration_requests nr ON od.numeration_requests_id = nr.numeration_requests_id
            WHERE od.document_id = NEW.document_id
              AND nr.is_confirmed = true
              AND nr.validation_status = 'valid'
        ) THEN
            RAISE EXCEPTION 'Numeración debe estar confirmada y válida';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Validaciones de Numeración

El sistema de numeración es crítico para la validez de los documentos. Se basa en un formato estricto y una secuencialidad garantizada.

#### Formato del Número Oficial

- **Patrón válido**: `<TIPO>-<AAAA>-<NNNNNN>-<SIGLA_ECO>-<SIGLA_REPARTICIÓN>`.
- **Componentes existentes**: Verificación de que cada parte es válida.
- **Unicidad global**: Confirmación de que el número no existe.

**Implementación Técnica (Unicidad):**

```sql
-- Unicidad absoluta del número reservado en la tabla `numeration_requests`
CONSTRAINT numeration_requests_reserved_number_key 
  UNIQUE (reserved_number)
```

#### Secuencialidad

- **Orden cronológico**: Los números deben ser secuenciales por tipo.
- **Sin duplicados**: Prevención de números repetidos.
- **Sin saltos**: Detección de brechas en la secuencia.

**Implementación Técnica (Reserva atómica de número):**

```sql
-- Función atómica para reservar número
CREATE OR REPLACE FUNCTION reserve_next_number(
    p_document_type_id UUID,
    p_user_id UUID,
    p_department_id UUID
) RETURNS VARCHAR AS $$
DECLARE
    v_next_number INTEGER;
    v_reserved_number VARCHAR;
    v_year INTEGER := EXTRACT(YEAR FROM NOW());
BEGIN
    -- Bloqueo para evitar concurrencia
    LOCK TABLE numeration_requests IN SHARE UPDATE EXCLUSIVE MODE;
    
    -- Obtener siguiente número
    SELECT COALESCE(MAX(CAST(reserved_number AS INTEGER)), 0) + 1
    INTO v_next_number
    FROM numeration_requests
    WHERE document_type_id = p_document_type_id
      AND year = v_year;
    
    -- Formatear número
    v_reserved_number := LPAD(v_next_number::TEXT, 6, '0');
    
    -- Insertar reserva
    INSERT INTO numeration_requests (
        document_type_id, user_id, department_id,
        year, reserved_number, reserved_at, validation_status
    ) VALUES (
        p_document_type_id, p_user_id, p_department_id,
        v_year, v_reserved_number, NOW(), 'pending'
    );
    
    RETURN v_reserved_number;
END;
$$ LANGUAGE plpgsql;
```

### Validaciones de Permisos

El acceso a los documentos y las acciones que se pueden realizar sobre ellos están controlados por un sistema de permisos basado en roles (RBAC) y listas de control de acceso (ACL).

#### Validaciones RBAC

- **Pertenencia a repartición**: El usuario debe pertenecer a una repartición autorizada.
- **Rol activo**: Verificación de que el rol sigue vigente.
- **Permisos por tipo**: Validación específica por tipo de documento.

#### Validaciones ACL

- **Permisos explícitos**: Verificación de permisos otorgados directamente.
- **Vigencia temporal**: Validación de fechas de expiración.
- **Jerarquía de permisos**: Resolución de conflictos entre RBAC y ACL.

**Implementación Técnica (Función de validación de acceso):**

```sql
-- IMPLEMENTACIÓN REQUERIDA
CREATE OR REPLACE FUNCTION user_can_access_document(
    p_user_id UUID,
    p_document_id UUID,
    p_action TEXT  -- 'view', 'edit', 'sign'
) RETURNS BOOLEAN AS $$
DECLARE
    v_document_status document_status;
    v_user_department_id UUID;
    v_creator_department_id UUID;
    v_is_signer BOOLEAN := false;
BEGIN
    -- Obtener estado del documento
    SELECT status INTO v_document_status
    FROM document_draft 
    WHERE document_id = p_document_id AND is_deleted = false;
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- Obtener departamento del usuario
    SELECT d.department_id INTO v_user_department_id
    FROM users u
    JOIN sectors s ON u.sector_id = s.sector_id
    JOIN departments d ON s.department_id = d.department_id
    WHERE u.user_id = p_user_id AND u.is_active = true;
    
    -- Obtener departamento del creador
    SELECT d.department_id INTO v_creator_department_id
    FROM document_draft dd
    JOIN users u ON dd.created_by = u.user_id
    JOIN sectors s ON u.sector_id = s.sector_id
    JOIN departments d ON s.department_id = d.department_id
    WHERE dd.document_id = p_document_id;
    
    -- Verificar si es firmante
    SELECT EXISTS (
        SELECT 1 FROM document_signers ds
        WHERE ds.document_id = p_document_id 
          AND ds.user_id = p_user_id
    ) INTO v_is_signer;
    
    -- Lógica de acceso por estado
    CASE v_document_status
        WHEN 'draft' THEN
            -- En draft: mismo departamento o creador
            RETURN (v_user_department_id = v_creator_department_id) 
                OR EXISTS (
                    SELECT 1 FROM document_draft 
                    WHERE document_id = p_document_id 
                      AND created_by = p_user_id
                );
                
        WHEN 'sent_to_sign' THEN
            -- En firma: firmantes pueden ver/firmar, creador puede ver
            IF p_action = 'sign' THEN
                RETURN v_is_signer;
            ELSE
                RETURN v_is_signer OR 
                       (v_user_department_id = v_creator_department_id);
            END IF;
            
        WHEN 'signed' THEN
            -- Firmado: búsqueda por número oficial (implementar lógica)
            RETURN true;  -- Simplificado, requiere lógica más compleja
            
        WHEN 'rejected' THEN
            -- Rechazado: mismo departamento
            RETURN (v_user_department_id = v_creator_department_id);
            
        ELSE
            RETURN false;
    END CASE;
END;
$$ LANGUAGE plpgsql;
```

## Gestión de Excepciones y Casos Especiales

### Casos Resueltos en el Sistema Actual

#### Rechazo de Documentos

**Comportamiento:**

- Cualquier firmante puede rechazar un documento en cualquier momento del proceso.
- El rechazo es inmediato e irreversible para esa instancia del proceso.

**Resultado:**

- El documento regresa automáticamente al estado "En Edición".
- Se mantiene todo el contenido y configuración original.
- Se registra auditoría completa del rechazo.

**Proceso de Recuperación:**

1.  **Notificación automática**: El creador recibe notificación inmediata.
2.  **Acceso restaurado**: Recupera capacidad de edición completa.
3.  **Correcciones**: Puede realizar cambios según el motivo del rechazo.
4.  **Reinicio**: Puede iniciar nuevamente el proceso de firmas.

**Auditoría del Rechazo:**

- Usuario que rechazó el documento.
- Timestamp exacto del rechazo.
- Motivo del rechazo (si se proporciona).
- Estado previo del documento.

**Implementación Técnica (Proceso de rechazo):**

```sql
-- Función para procesar rechazo
CREATE OR REPLACE FUNCTION process_document_rejection(
    p_document_id UUID,
    p_rejected_by UUID,
    p_reason TEXT
) RETURNS BOOLEAN AS $$
BEGIN
    -- Insertar rechazo
    INSERT INTO document_rejections (
        document_id, rejected_by, reason
    ) VALUES (p_document_id, p_rejected_by, p_reason);
    
    -- Cambiar estado del documento
    UPDATE document_draft 
    SET status = 'rejected' 
    WHERE document_id = p_document_id;
    
    -- Reset estados de firmantes
    UPDATE document_signers 
    SET status = 'pending', signed_at = NULL 
    WHERE document_id = p_document_id;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;
```

#### Integridad de Numeración

**Prevención de Problemas:**

- **Servicio NUMERADOR_OFICIAL**: Garantiza secuencialidad atómica.
- **Bloqueos de concurrencia**: Previene asignación simultánea.
- **Validaciones cruzadas**: Verificación múltiple antes de asignar.

**Control de Calidad:**

- **Funciones de base de datos**: Constraints que previenen duplicados.
- **Verificación automática**: Checks periódicos de integridad.
- **Alertas tempranas**: Notificación de inconsistencias.

**Consistencia Garantizada:**

- **No documentos huérfanos**: La numeración solo ocurre al completar exitosamente.
- **Rollback automático**: Reversión en caso de falla durante asignación.
- **Recuperación**: Procedimientos para restaurar secuencias dañadas.

#### Verificación de Autorización en Tiempo Real

**Validación Continua:**

- **Al momento de firma**: Verificación de titularidad actual.
- **Durante el proceso**: Monitoreo de cambios de permisos.
- **Antes de numeración**: Validación final del numerador.

**Cambios Durante el Proceso:**

- **Pérdida de titularidad**: Bloqueo automático del proceso.
- **Cambio de repartición**: Invalidación inmediata de permisos.
- **Desactivación de usuario**: Suspensión del proceso.

**Resolución de Conflictos:**

- **Única opción**: Cancelar proceso y reasignar firmantes.
- **Notificación**: Alerta a todos los participantes.
- **Auditoría**: Registro completo del conflicto y resolución.

### Limitaciones Actuales y Desarrollo Futuro

#### Gestión de Ausencias

- **Limitación**: No existe sistema automatizado de licencias o delegación temporal.
- **Desarrollo Futuro**: Implementar un sistema de delegación temporal de firmas, con límites de tiempo y auditoría completa.

#### Edición Colaborativa

- **Limitación**: No hay sistema de edición simultánea en tiempo real.
- **Desarrollo Futuro**: Implementar edición colaborativa en tiempo real con control de versiones y resolución de conflictos.

#### Timeouts de Proceso

- **Limitación**: No hay límites de tiempo configurables para los procesos de firma.
- **Desarrollo Futuro**: Implementar escalación automática por inactividad y alertas por documentos pendientes.

#### Archivado Automático

- **Limitación**: No hay un sistema de archivado automático de documentos abandonados.
- **Desarrollo Futuro**: Implementar políticas de archivado configurables con notificaciones y capacidad de recuperación.

## Estrategias de Manejo de Errores

### Errores de Validación

- **Validación temprana**: Verificación en el frontend antes de envío.
- **Mensajes claros**: Descripción específica del error y cómo corregirlo.
- **Validación incremental**: Verificación paso a paso durante el proceso.

### Errores de Sistema

- **Rollback automático**: Reversión de cambios parciales.
- **Reintentos inteligentes**: Reintento con backoff exponencial.
- **Degradación controlada**: Funcionalidad reducida pero operativa.

### Errores de Integración

- **Circuit breakers**: Protección contra servicios externos fallidos.
- **Fallback strategies**: Alternativas cuando los servicios no están disponibles.
- **Monitoreo de dependencias**: Verificación continua de servicios críticos.

## Auditoría y Trazabilidad de Excepciones

### Registro de Eventos

- **Timestamp exacto**: Momento del evento o error.
- **Usuario afectado**: Identificación del usuario involucrado.
- **Acción intentada**: Descripción de la operación que falló.
- **Error específico**: Mensaje de error detallado.
- **Contexto del sistema**: Estado del sistema al momento del error.

### Análisis y Métricas

- **Dashboards de Errores**: Frecuencia por tipo, tendencias temporales, afectación por usuario, tiempo de resolución.
- **Mejora Continua**: Análisis de causa raíz, optimización de validaciones, capacitación de usuarios, evolución del sistema.

## Checklist de Implementación

### ✅ **COMPLETADO EN BASE DE DATOS**

- [x] ENUMs de estado definidos
- [x] Constraints de unicidad implementados
- [x] Foreign keys configuradas
- [x] Campos NOT NULL validados
- [x] Valores por defecto establecidos
- [x] Eliminación lógica implementada

### 🔶 **EN DESARROLLO**

- [ ] Funciones de validación de acceso
- [ ] Triggers de transición de estados
- [ ] Validaciones de firmantes activos
- [ ] Control de numeración atómica
- [ ] Sistema ACL en audit_data

### 📋 **PENDIENTE**

- [ ] Funciones de validación de permisos
- [ ] Triggers de inmutabilidad
- [ ] Validaciones de contenido mínimo
- [ ] Sistema de timeouts
- [ ] Alertas automáticas

## 🎯 Próximas actualizaciones

 El siguiente paso crítico es **implementar las funciones de validación de negocio** y los **triggers automáticos** para completar la robustez del sistema.

**Prioridad alta**: Implementar `user_can_access_document()` y `validate_document_state_transition()` para tener un sistema funcional básico.

*Este documento refleja el estado real de la base de datos GDI al 2025 y las implementaciones pendientes identificadas.*

## Enlaces Relacionados

- [Componentes Técnicos y Datos](./06-componentes-datos.md)
- [Seguridad](./08-seguridad.md)
- [Estados y Transiciones](./03-estados-transiciones.md)
- [Acceso y Permisos](./05-acceso-permisos.md)


