# 🔀 Estados y Transiciones de Documentos - Implementación Real

Este documento define los estados oficiales implementados en la base de datos de GDI y las reglas de transición entre ellos.

## 📊 Estados Principales del Documento

### Definición de ENUMs Implementados

```sql
CREATE TYPE document_status AS ENUM (
    'draft',        -- En edición colaborativa
    'sent_to_sign', -- Enviado al circuito de firmas  
    'signed',       -- Firmado y con validez legal oficial
    'rejected',     -- Rechazado por algún firmante
    'cancelled',    -- Cancelado antes de completar proceso
    'archived'      -- Archivado después de finalizado
);
```

### Estados de Firmantes Individuales

```sql
CREATE TYPE document_signer_status AS ENUM (
    'pending',   -- Esperando su turno para firmar
    'signed',    -- Ya completó su firma
    'rejected'   -- Rechazó el documento
);
```

![Estados Principales](../images/estados-principales-documento.png)

---

## 🔄 Diagrama de Estados Completo

### Flujo Principal

```
📝 draft → 📤 sent_to_sign → ✅ signed → 📦 archived
```

### Flujos de Excepción

```
📝 draft
   ↓
   🗑️ deleted (is_deleted=true)

📤 sent_to_sign
   ↓
   ❌ rejected → 🔄 draft (corrección)
   ↓
   🚫 cancelled

✅ signed
   ↓
   📦 archived
```

### Evolución Visual del Encabezado
La siguiente imagen resume cómo cambia la presentación visual del encabezado del documento a medida que avanza por los estados principales.

![Evolución de estados de encabezados](../assets/images/docs/Evolución_estados_encabezados.png)

![Diagrama Estados Completo](../images/diagrama-estados-completo.png)

---

## 📝 ESTADO: `draft`

### Descripción
Documento en proceso de creación y edición colaborativa. El contenido es modificable y los usuarios autorizados pueden colaborar en tiempo real.

### Características
- ✅ **Contenido editable** via editor colaborativo
- ✅ **Configuración de firmantes** permitida
- ✅ **Múltiples editores** simultáneos (pad_id)
- ✅ **Guardado automático** cada 30 segundos
- ❌ **Sin validez legal** hasta firmarse

### Campos Relevantes
```sql
-- Estado del documento
status = 'draft'

-- Metadatos de edición
pad_id VARCHAR NOT NULL,           -- ID del editor colaborativo
created_by UUID NOT NULL,          -- Usuario creador
created_at TIMESTAMP DEFAULT NOW(),
last_modified_at TIMESTAMP DEFAULT NOW(),

-- Contenido
reference TEXT NOT NULL,           -- Referencia/motivo (obligatorio)
content JSONB NOT NULL,           -- Contenido enriquecido (obligatorio)

-- Control
is_deleted BOOLEAN DEFAULT false  -- Eliminación lógica
```

### Validaciones en Estado `draft`
```sql
-- Validaciones obligatorias
CHECK (reference IS NOT NULL AND reference != ''),
CHECK (content IS NOT NULL AND content != '{}'),
CHECK (pad_id IS NOT NULL AND pad_id != '')
```

### Transiciones Permitidas DESDE `draft`

| Transición | Trigger | Validaciones Requeridas |
|------------|---------|------------------------|
| `draft` → `sent_to_sign` | Usuario envía a firmas | • Contenido no vacío<br>• Al menos un firmante<br>• Numerador asignado |
| `draft` → `deleted` | Eliminación lógica | • Solo el creador<br>• Sin firmantes asignados |

![Estado Draft](../images/estado-draft-detalle.png)

---

## 📤 ESTADO: `sent_to_sign`

### Descripción  
Documento enviado al circuito de firmas. El contenido se vuelve **inmutable** y los firmantes asignados deben proceder según el orden establecido.

### Características
- ❌ **Contenido inmutable** (no editable)
- ✅ **Encabezado provisional** visible
- ✅ **Firmantes notificados** según signing_order
- ✅ **Proceso de firma activo**
- ❌ **Sin validez legal** hasta completar todas las firmas

### Campos Relevantes
```sql
-- Estado y timestamps
status = 'sent_to_sign',
sent_to_sign_at TIMESTAMP NOT NULL,  -- Momento de envío
sent_by UUID,                        -- Usuario que envió

-- Inmutabilidad
-- Los campos content y reference se vuelven read-only
```

### Proceso de Orquestación de Firmas

```sql
-- Firmantes ordenados por signing_order
SELECT ds.*, u.full_name, u.email
FROM document_signers ds
JOIN users u ON ds.user_id = u.user_id
WHERE ds.document_id = ?
ORDER BY ds.signing_order ASC;
```

### Estados de Firmantes Individuales

Cada firmante tiene su propio estado independiente:

```sql
-- Estado individual en document_signers
signing_order INTEGER,               -- Orden de firma (1, 2, 3...)
status document_signer_status,       -- pending, signed, rejected
signed_at TIMESTAMP,                 -- Momento de firma
observations TEXT,                   -- Comentarios del firmante
is_numerator BOOLEAN DEFAULT false   -- Si es el numerador final
```

### Lógica de Progresión Secuencial

```sql
-- Siguiente firmante habilitado
SELECT ds.*
FROM document_signers ds
WHERE ds.document_id = ?
  AND ds.status = 'pending'
  AND ds.signing_order = (
    SELECT MIN(signing_order) 
    FROM document_signers 
    WHERE document_id = ? AND status = 'pending'
  );
```

### Transiciones Permitidas DESDE `sent_to_sign`

| Transición | Trigger | Condición |
|------------|---------|-----------|
| `sent_to_sign` → `signed` | Numerador firma | • Todos los firmantes signed<br>• Numerador completa firma<br>• Número oficial asignado |
| `sent_to_sign` → `rejected` | Cualquier firmante rechaza | • Al menos un firmante rejected<br>• Motivo registrado |
| `sent_to_sign` → `cancelled` | Cancelación administrativa | • Autorización especial<br>• Proceso no completado |

![Estado Sent to Sign](../images/estado-sent-to-sign-detalle.png)

---

## ❌ ESTADO: `rejected`

### Descripción
Documento rechazado por uno o más firmantes durante el proceso de firma. Requiere corrección antes de poder reenviar.

### Características
- ❌ **Proceso de firma detenido**
- ✅ **Motivos de rechazo** registrados  
- ✅ **Posibilidad de corrección** habilitada
- ❌ **Sin validez legal**

### Datos de Rechazo
```sql
-- Tabla de rechazos
CREATE TABLE public.document_rejections (
    rejection_id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid NOT NULL,
    rejected_by uuid NOT NULL,
    reason text,
    rejected_at timestamp without time zone DEFAULT now(),
    audit_data jsonb
);
```

### Información del Rechazo

```sql
-- Consulta de rechazos para un documento
SELECT 
    dr.reason,
    dr.rejected_at,
    u.full_name as rejected_by_name,
    ds.signing_order,
    ds.observations
FROM document_rejections dr
JOIN users u ON dr.rejected_by = u.user_id
JOIN document_signers ds ON dr.document_id = ds.document_id 
    AND dr.rejected_by = ds.user_id
WHERE dr.document_id = ?
ORDER BY dr.rejected_at DESC;
```

### Proceso de Corrección

1. **📋 Revisión de Motivos**: Usuario ve todos los rechazos
2. **✏️ Edición Habilitada**: Se reactiva editor colaborativo  
3. **🔄 Corrección**: Se realizan cambios necesarios
4. **📤 Reenvío**: Nuevo ciclo draft → sent_to_sign

### Transiciones Permitidas DESDE `rejected`

| Transición | Trigger | Validaciones |
|------------|---------|-------------|
| `rejected` → `draft` | Iniciar corrección | • Usuario autorizado<br>• Motivos revisados |
| `rejected` → `cancelled` | Cancelar definitivamente | • Autorización especial |

![Estado Rejected](../images/estado-rejected-detalle.png)

---

## ✅ ESTADO: `signed`

### Descripción
Documento completamente firmado con **plena validez legal**. El numerador ha asignado el número oficial y se ha generado el documento en `official_documents`.

### Características
- ✅ **Validez legal plena**
- ✅ **Número oficial asignado**
- ✅ **PDF firmado generado**
- ✅ **Contenido inmutable permanente**
- ✅ **Encabezado oficial definitivo**

### Proceso de Finalización

```sql
-- Transición compleja que involucra múltiples tablas
BEGIN TRANSACTION;

-- 1. Confirmar última firma (numerador)
UPDATE document_signers 
SET status = 'signed', signed_at = NOW()
WHERE document_id = ? AND is_numerator = true;

-- 2. Confirmar reserva de número
UPDATE numeration_requests 
SET is_confirmed = true, confirmed_at = NOW()
WHERE document_id = ?;

-- 3. Crear documento oficial
INSERT INTO official_documents (
    document_id,
    document_type_id,
    numeration_requests_id,
    reference,
    content,
    official_number,
    year,
    department_id,
    numerator_id,
    signed_at,
    signed_pdf_url,
    signers
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?);

-- 4. Finalizar estado draft
UPDATE document_draft 
SET status = 'signed'
WHERE document_id = ?;

COMMIT;
```

### Datos del Documento Oficial

```sql
-- Información completa del documento oficial
SELECT 
    dd.reference,
    dd.content,
    od.official_number,
    od.signed_at as official_date,
    od.signed_pdf_url,
    dt.name as document_type,
    dt.acronym,
    u.full_name as numerator_name
FROM document_draft dd
JOIN official_documents od ON dd.document_id = od.document_id
JOIN document_types dt ON dd.document_type_id = dt.document_type_id
JOIN users u ON od.numerator_id = u.user_id
WHERE dd.document_id = ?;
```

### Funcionalidades Habilitadas

- ✅ **Descarga PDF oficial**
- ✅ **Búsqueda por número oficial**  
- ✅ **Vinculación automática a expediente**
- ✅ **Inclusión en reportes oficiales**
- ✅ **Consulta pública** (según permisos)

### Transiciones Permitidas DESDE `signed`

| Transición | Trigger | Notas |
|------------|---------|-------|
| `signed` → `archived` | Proceso de archivo | • Después de período de vigencia<br>• Mantiene validez legal |

![Estado Signed](../images/estado-signed-detalle.png)

---

## 🚫 ESTADO: `cancelled`

### Descripción
Documento cancelado antes de completar el proceso de firma. No tiene validez legal y se mantiene solo para auditoría.

### Características
- ❌ **Sin validez legal**
- ✅ **Motivo de cancelación** registrado
- ✅ **Historial preservado** para auditoría
- ❌ **No se puede reactivar**

### Casos de Cancelación

1. **👤 Cancelación por Usuario**: Creador cancela antes de enviar a firma
2. **🏛️ Cancelación Administrativa**: Por decisión de department
3. **⚠️ Cancelación por Error**: Problemas técnicos o de configuración
4. **📅 Cancelación por Timeout**: Proceso demorado excesivamente

### Registro de Cancelación

```sql
-- Registro en audit_data
UPDATE document_draft 
SET 
    status = 'cancelled',
    audit_data = jsonb_set(
        COALESCE(audit_data, '{}'),
        '{cancellation}',
        json_build_object(
            'cancelled_by', ?,
            'cancelled_at', NOW(),
            'reason', ?,
            'original_status', 'sent_to_sign'
        )
    )
WHERE document_id = ?;
```

### Transiciones Permitidas DESDE `cancelled`

| Transición | Trigger | Notas |
|------------|---------|-------|
| `cancelled` → `archived` | Proceso de archivo | • Solo para limpieza<br>• Mantiene historia |

![Estado Cancelled](../images/estado-cancelled-detalle.png)

---

## 📦 ESTADO: `archived`

### Descripción
Documento archivado después de cumplir su ciclo de vida útil. Mantiene validez legal pero se considera histórico.

### Características
- ✅ **Validez legal preservada** (si venía de signed)
- ✅ **Solo lectura**
- ✅ **Búsqueda limitada**
- ✅ **Auditoría completa**

### Criterios de Archivo

1. **📅 Tiempo**: Documentos con más de X años
2. **📊 Volumen**: Gestión de espacio en BD
3. **📋 Política**: Según normativas municipales
4. **🔄 Migración**: A sistemas de archivo histórico

### Proceso de Archivo

```sql
-- Archivo masivo por criterios
UPDATE document_draft 
SET status = 'archived'
WHERE status = 'signed' 
  AND signed_at < (NOW() - INTERVAL '5 years');
```

### Transiciones Permitidas DESDE `archived`

**Ninguna** - Estado final del documento.

![Estado Archived](../images/estado-archived-detalle.png)

---

## 🗑️ ESTADO ESPECIAL: Eliminación Lógica

### Concepto de `is_deleted`

**No es un estado** del enum `document_status`, sino un **flag transversal**:

```sql
is_deleted BOOLEAN DEFAULT false
```

### Comportamiento

- ✅ **Preserva registro** en base de datos
- ❌ **Oculta de interfaces** de usuario
- ✅ **Mantiene integridad** referencial
- ✅ **Permite auditoría** completa

### Reglas de Eliminación

| Estado Original | Eliminación Permitida | Efecto |
|----------------|----------------------|--------|
| `draft` | ✅ Sí | Oculto, recuperable |
| `sent_to_sign` | ❌ No | Debe cancelarse |
| `signed` | ❌ Nunca | Documento oficial |
| `rejected` | ✅ Sí | Después de revisión |
| `cancelled` | ✅ Sí | Para limpieza |

### Consultas con Eliminación Lógica

```sql
-- Vista solo documentos activos
SELECT * FROM document_draft 
WHERE is_deleted = false;

-- Vista auditoría (incluye eliminados)
SELECT *, 
       CASE WHEN is_deleted THEN '[ELIMINADO]' ELSE '' END as status_flag
FROM document_draft;
```

![Eliminación Lógica](../images/eliminacion-logica-detalle.png)

---

## ⚠️ Validaciones de Transición

### Reglas de Negocio Implementadas

```sql
-- Función de validación de transición
CREATE OR REPLACE FUNCTION validate_document_transition(
    p_document_id UUID,
    p_new_status document_status
) RETURNS BOOLEAN AS $
DECLARE
    current_status document_status;
    signer_count INTEGER;
    pending_signers INTEGER;
BEGIN
    -- Obtener estado actual
    SELECT status INTO current_status 
    FROM document_draft 
    WHERE document_id = p_document_id;
    
    -- Validar transiciones permitidas
    CASE 
        WHEN current_status = 'draft' AND p_new_status = 'sent_to_sign' THEN
            -- Validar contenido y firmantes
            SELECT COUNT(*) INTO signer_count
            FROM document_signers 
            WHERE document_id = p_document_id;
            
            RETURN signer_count > 0;
            
        WHEN current_status = 'sent_to_sign' AND p_new_status = 'signed' THEN
            -- Validar que todas las firmas estén completas
            SELECT COUNT(*) INTO pending_signers
            FROM document_signers 
            WHERE document_id = p_document_id 
              AND status = 'pending';
              
            RETURN pending_signers = 0;
            
        WHEN current_status = 'rejected' AND p_new_status = 'draft' THEN
            -- Permitir corrección
            RETURN true;
            
        ELSE
            -- Transición no permitida
            RETURN false;
    END CASE;
END;
$ LANGUAGE plpgsql;
```

### Triggers de Validación

```sql
-- Trigger que valida transiciones antes de UPDATE
CREATE TRIGGER validate_document_status_change
    BEFORE UPDATE OF status ON document_draft
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION check_valid_transition();
```

![Validaciones Transición](../images/validaciones-transicion.png)

---

## 📊 Métricas por Estado

### Distribución de Estados

```sql
-- Consulta de distribución actual
SELECT 
    status,
    COUNT(*) as total_documents,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM document_draft 
WHERE is_deleted = false
GROUP BY status
ORDER BY total_documents DESC;
```

### Tiempo Promedio por Estado

```sql
-- Análisis de tiempos de permanencia
WITH state_durations AS (
    SELECT 
        document_id,
        status,
        created_at,
        sent_to_sign_at,
        (SELECT signed_at FROM official_documents od WHERE od.document_id = dd.document_id) as signed_at
    FROM document_draft dd
    WHERE status = 'signed'
)
SELECT 
    AVG(sent_to_sign_at - created_at) as avg_draft_duration,
    AVG(signed_at - sent_to_sign_at) as avg_signing_duration
FROM state_durations;
```

### KPIs de Transición

```sql
-- Tasa de éxito por tipo de documento
SELECT 
    dt.name,
    COUNT(CASE WHEN dd.status = 'signed' THEN 1 END) as signed_count,
    COUNT(CASE WHEN dd.status = 'rejected' THEN 1 END) as rejected_count,
    ROUND(
        COUNT(CASE WHEN dd.status = 'signed' THEN 1 END) * 100.0 / 
        COUNT(*), 2
    ) as success_rate
FROM document_draft dd
JOIN document_types dt ON dd.document_type_id = dt.document_type_id
WHERE dd.is_deleted = false
GROUP BY dt.name
ORDER BY success_rate DESC;
```

![Métricas Estados](../images/metricas-estados.png)

---

## 🔄 Diagramas de Flujo Detallados

### Flujo Principal Completo

```
[INICIO] → draft → sent_to_sign → signed → archived → [FIN]
              ↓         ↓           ↓
           deleted   rejected   cancelled
                        ↓
                     draft (corrección)
```

### Flujo de Firmantes

```
Firmante 1: pending → signed
               ↓
Firmante 2: pending → signed  
               ↓
Numerador: pending → signed → [DOCUMENTO OFICIAL]
```

### Flujo de Excepciones

```
sent_to_sign → rejected → draft → sent_to_sign → signed
      ↓            ↓         ↓
   cancelled   cancelled   cancelled
```

![Flujo Completo Estados](../images/flujo-completo-estados.png)

---

## 🛠️ Comandos de Gestión de Estados

### Consultas Útiles para Administración

```sql
-- Documentos "atorados" en sent_to_sign por más de 7 días
SELECT dd.*, dt.name
FROM document_draft dd
JOIN document_types dt ON dd.document_type_id = dt.document_type_id
WHERE dd.status = 'sent_to_sign'
  AND dd.sent_to_sign_at < (NOW() - INTERVAL '7 days');

-- Firmantes pendientes por documento
SELECT 
    dd.document_id,
    dd.reference,
    u.full_name as pending_signer,
    ds.signing_order
FROM document_draft dd
JOIN document_signers ds ON dd.document_id = ds.document_id
JOIN users u ON ds.user_id = u.user_id
WHERE dd.status = 'sent_to_sign'
  AND ds.status = 'pending'
ORDER BY dd.sent_to_sign_at ASC;

-- Documentos rechazados con motivos
SELECT 
    dd.reference,
    dr.reason,
    u.full_name as rejected_by,
    dr.rejected_at
FROM document_draft dd
JOIN document_rejections dr ON dd.document_id = dr.document_id
JOIN users u ON dr.rejected_by = u.user_id
WHERE dd.status = 'rejected'
ORDER BY dr.rejected_at DESC;
```

---

