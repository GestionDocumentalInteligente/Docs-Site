# 🔢 Sistema de Numeración y Nomenclatura Oficial - Implementación 

El sistema de numeración de GDI garantiza la asignación única y secuencial de números oficiales a documentos con validez legal.

## 🎯 Objetivo del Sistema

Asegurar que cada documento oficial tenga un **identificador único, secuencial y trazable** que cumpla con normativas municipales y permita búsqueda, auditoría y validación legal.

---

## 📋 Formato de Numeración Oficial

### Estructura Estándar

```
<TIPO>-<AAAA>-<NNNNNN>-<SIGLA_ECO>-<SIGLA_DEPARTMENT>
```

### Componentes del Formato

| Componente | Descripción | Fuente en BD | Ejemplo |
|------------|-------------|--------------|---------|
| **TIPO** | Acrónimo del tipo de documento | `document_types.acronym` | DECRE |
| **AAAA** | Año de la fecha oficial | `EXTRACT(YEAR FROM NOW())` | 2025 |
| **NNNNNN** | Número correlativo (6 dígitos) | `numeration_requests.reserved_number` | 000123 |
| **SIGLA_ECO** | Sigla del ecosistema/municipio | `municipalities.acronym` | TN |
| **SIGLA_DEPARTMENT** | Sigla del department numerador | `departments.acronym` | INTEN |

### Ejemplos Reales

```
DECRE-2025-000123-TN-INTEN    (Decreto de Intendencia)
RESOL-2025-000045-TN-SECGOB   (Resolución de Secretaría de Gobierno)
DISP-2025-000067-TN-DIROBR    (Disposición de Dirección de Obras)
IF-2025-001234-TN-SECGOB      (Informe de Secretaría de Gobierno)
```

---

## 🏗️ Arquitectura del Sistema de Numeración

### Tablas Involucradas

#### 1. `numeration_requests` (Reserva de Números)

```sql
CREATE TABLE numeration_requests (
    numeration_requests_id UUID PRIMARY KEY,
    document_type_id UUID NOT NULL,
    user_id UUID NOT NULL,              -- Usuario que solicita
    department_id UUID NOT NULL,        -- Department numerador
    year SMALLINT NOT NULL,             -- Año del documento
    reserved_number VARCHAR UNIQUE NOT NULL, -- Número reservado
    reserved_at TIMESTAMP NOT NULL,     -- Momento de reserva
    is_confirmed BOOLEAN DEFAULT false, -- Si fue confirmado
    confirmed_at TIMESTAMP,             -- Momento de confirmación
    validation_status validation_status_enum NOT NULL
);
```

#### 2. `official_documents` (Documentos Oficiales)

```sql
CREATE TABLE official_documents (
    document_id UUID PRIMARY KEY,
    numeration_requests_id UUID NOT NULL,
    official_number VARCHAR UNIQUE NOT NULL, -- Número final formateado
    year SMALLINT NOT NULL,
    numerator_id UUID NOT NULL,         -- Usuario numerador
    signed_at TIMESTAMP NOT NULL,       -- Fecha oficial
    signed_pdf_url VARCHAR NOT NULL     -- PDF firmado
);
```

### Estados de Numeración

```sql
CREATE TYPE validation_status_enum AS ENUM (
    'pending',    -- Número reservado, esperando confirmación
    'valid',      -- Número confirmado y válido
    'invalid'     -- Número invalidado por error
);
```

---

## 🔄 Proceso de Numeración Completo

### FASE 1: Reserva de Número

**Trigger**: Numerador inicia proceso de firma final

```sql
-- 1. Calcular siguiente número correlativo
WITH next_number AS (
    SELECT COALESCE(MAX(CAST(reserved_number AS INTEGER)), 0) + 1 as next_num
    FROM numeration_requests nr
    JOIN document_types dt ON nr.document_type_id = dt.document_type_id
    WHERE dt.document_type_id = ?
      AND nr.year = EXTRACT(YEAR FROM NOW())
)
-- 2. Reservar número
INSERT INTO numeration_requests (
    document_type_id,
    user_id,
    department_id,
    year,
    reserved_number,
    reserved_at,
    validation_status
) 
SELECT 
    ?,                              -- document_type_id
    ?,                              -- numerator user_id
    ?,                              -- department_id del numerador
    EXTRACT(YEAR FROM NOW()),
    LPAD(next_num::TEXT, 6, '0'),  -- Número con ceros a la izquierda
    NOW(),
    'pending'
FROM next_number;
```

### FASE 2: Generación del Número Oficial

**Trigger**: Numerador completa firma digital

```sql
-- Construcción del número oficial completo
SELECT 
    CONCAT(
        dt.acronym, '-',                    -- TIPO
        nr.year, '-',                       -- AÑO  
        nr.reserved_number, '-',            -- NÚMERO
        m.acronym, '-',                     -- ECOSISTEMA
        d.acronym                           -- DEPARTMENT
    ) as official_number
FROM numeration_requests nr
JOIN document_types dt ON nr.document_type_id = dt.document_type_id
JOIN departments d ON nr.department_id = d.department_id
JOIN municipalities m ON d.municipality_id = m.id_municipality
WHERE nr.numeration_requests_id = ?;
```

### FASE 3: Confirmación y Oficialización

```sql
BEGIN TRANSACTION;

-- 1. Confirmar reserva
UPDATE numeration_requests 
SET 
    is_confirmed = true,
    confirmed_at = NOW(),
    validation_status = 'valid'
WHERE numeration_requests_id = ?;

-- 2. Crear documento oficial
INSERT INTO official_documents (
    document_id,
    numeration_requests_id,
    official_number,
    year,
    numerator_id,
    signed_at,
    signed_pdf_url
) VALUES (?, ?, ?, ?, ?, NOW(), ?);

-- 3. Finalizar documento draft
UPDATE document_draft 
SET status = 'signed'
WHERE document_id = ?;

COMMIT;
```
---

## 🔐 Control de Concurrencia

### Problema de Concurrencia

Múltiples usuarios intentando numerar documentos simultáneamente del mismo tipo.

### Solución Implementada

#### 1. Lock Optimista en Reserva

```sql
-- Uso de CTE para atomic increment
WITH RECURSIVE next_available AS (
    SELECT 1 as candidate_number
    UNION ALL
    SELECT candidate_number + 1
    FROM next_available
    WHERE candidate_number < (
        SELECT MAX(CAST(reserved_number AS INTEGER)) + 10
        FROM numeration_requests 
        WHERE document_type_id = ? AND year = ?
    )
),
available_number AS (
    SELECT MIN(candidate_number) as next_number
    FROM next_available
    WHERE candidate_number NOT IN (
        SELECT CAST(reserved_number AS INTEGER)
        FROM numeration_requests
        WHERE document_type_id = ? AND year = ?
    )
)
INSERT INTO numeration_requests (...)
SELECT ..., LPAD(next_number::TEXT, 6, '0')
FROM available_number;
```

#### 2. Constraint de Unicidad

```sql
-- Constraint en BD para prevenir duplicados
ALTER TABLE numeration_requests 
ADD CONSTRAINT unique_reserved_number UNIQUE (reserved_number);

-- Constraint en documento oficial
ALTER TABLE official_documents
ADD CONSTRAINT unique_official_number UNIQUE (official_number);
```

#### 3. Timeout de Reserva

```sql
-- Cleanup automático de reservas vencidas (cron job)
UPDATE numeration_requests 
SET validation_status = 'invalid'
WHERE validation_status = 'pending'
  AND reserved_at < (NOW() - INTERVAL '1 hour')
  AND is_confirmed = false;
```

---

## 📊 Tipos de Numeración por Categoría

### Documentos con Carácter de Acto Administrativo

**Características**:
- ✅ Integración con numeración histórica/externa
- ✅ Secuencia estricta sin saltos
- ✅ Validación especial por department autorizado

#### Configuración Inicial

```sql
-- Campo especial en document_types para actos administrativos
ALTER TABLE document_types 
ADD COLUMN last_paper_number INTEGER; -- Último número en papel

-- Inicialización con número histórico
UPDATE document_types 
SET last_paper_number = 150  -- Último decreto en papel
WHERE acronym = 'DECRE';
```

#### Lógica de Continuidad

```sql
-- Continuar numeración desde sistema anterior
WITH historical_base AS (
    SELECT 
        COALESCE(dt.last_paper_number, 0) as base_number,
        COALESCE(MAX(CAST(nr.reserved_number AS INTEGER)), 0) as max_digital
    FROM document_types dt
    LEFT JOIN numeration_requests nr ON dt.document_type_id = nr.document_type_id
        AND nr.year = EXTRACT(YEAR FROM NOW())
    WHERE dt.document_type_id = ?
    GROUP BY dt.last_paper_number
)
SELECT GREATEST(base_number, max_digital) + 1 as next_number
FROM historical_base;
```

### Documentos sin Carácter de Acto Administrativo

**Características**:
- ✅ Numeración secuencial desde 1 cada año
- ✅ Sin restricciones de continuidad histórica
- ✅ Mayor flexibilidad operativa

```sql
-- Reinicio automático cada año
SELECT COALESCE(MAX(CAST(reserved_number AS INTEGER)), 0) + 1 as next_number
FROM numeration_requests nr
JOIN document_types dt ON nr.document_type_id = dt.document_type_id
WHERE dt.document_type_id = ?
  AND nr.year = EXTRACT(YEAR FROM NOW())
  AND dt.last_paper_number IS NULL; -- No es acto administrativo
```

---

## 🏛️ Asignación de Department Numerador

### Lógica de Asignación

La sigla del department que aparece en el número oficial se determina por:

1. **Department del usuario numerador** (quien firma y numera)
2. **NO** el department del creador del documento

### Casos de Uso

#### Caso 1: Numerador = Creador
```
Usuario: Juan Pérez (INTEN)
Crea documento tipo DECRE
Numera él mismo
Resultado: DECRE-2025-000123-TN-INTEN
```

#### Caso 2: Numerador ≠ Creador
```
Usuario Creador: María García (SECGOB)
Crea documento tipo DECRE
Numerador: Intendente (INTEN)
Resultado: DECRE-2025-000123-TN-INTEN
```

### Validación de Autorización

```sql
-- Verificar que usuario puede numerar este tipo
SELECT EXISTS (
    SELECT 1 
    FROM document_types_allowed_by_rank dtar
    JOIN departments d ON d.rank_id = dtar.rank_id
    JOIN users u ON u.sector_id = d.department_id
    WHERE u.user_id = ?                    -- numerador
      AND dtar.document_type_id = ?        -- tipo documento
) as can_numerize;
```
---

## 🔍 Consultas y Búsquedas

### Búsqueda por Número Oficial

```sql
-- Búsqueda exacta por número completo
SELECT 
    dd.reference,
    dd.content,
    od.official_number,
    od.signed_at,
    od.signed_pdf_url,
    dt.name as document_type,
    u.full_name as numerator
FROM official_documents od
JOIN document_draft dd ON od.document_id = dd.document_id
JOIN document_types dt ON dd.document_type_id = dt.document_type_id
JOIN users u ON od.numerator_id = u.user_id
WHERE od.official_number = ?;
```

### Búsqueda por Componentes

```sql
-- Búsqueda por tipo y año
SELECT od.official_number, dd.reference, od.signed_at
FROM official_documents od
JOIN document_draft dd ON od.document_id = dd.document_id
JOIN document_types dt ON dd.document_type_id = dt.document_type_id
WHERE dt.acronym = ?                    -- Ej: 'DECRE'
  AND od.year = ?                       -- Ej: 2025
ORDER BY od.official_number;
```

### Búsqueda por Rango

```sql
-- Documentos entre números
SELECT od.official_number, dd.reference
FROM official_documents od
JOIN document_draft dd ON od.document_id = dd.document_id
JOIN numeration_requests nr ON od.numeration_requests_id = nr.numeration_requests_id
WHERE CAST(nr.reserved_number AS INTEGER) BETWEEN ? AND ?
  AND nr.year = ?
ORDER BY CAST(nr.reserved_number AS INTEGER);
```

---

## 📈 Métricas y Estadísticas

### Secuencias por Tipo y Año

```sql
-- Estado actual de secuencias
SELECT 
    dt.acronym,
    dt.name,
    COUNT(nr.numeration_requests_id) as total_reserved,
    COUNT(CASE WHEN nr.is_confirmed THEN 1 END) as confirmed,
    MAX(CAST(nr.reserved_number AS INTEGER)) as last_number
FROM document_types dt
LEFT JOIN numeration_requests nr ON dt.document_type_id = nr.document_type_id
    AND nr.year = EXTRACT(YEAR FROM NOW())
GROUP BY dt.document_type_id, dt.acronym, dt.name
ORDER BY dt.acronym;
```

### Volumen de Numeración

```sql
-- Documentos numerados por mes
SELECT 
    DATE_TRUNC('month', od.signed_at) as month,
    dt.acronym,
    COUNT(*) as documents_signed
FROM official_documents od
JOIN document_draft dd ON od.document_id = dd.document_id
JOIN document_types dt ON dd.document_type_id = dt.document_type_id
WHERE od.signed_at >= DATE_TRUNC('year', NOW())
GROUP BY DATE_TRUNC('month', od.signed_at), dt.acronym
ORDER BY month, dt.acronym;
```

### Eficiencia del Proceso

```sql
-- Tiempo promedio de numeración
SELECT 
    dt.name,
    AVG(nr.confirmed_at - nr.reserved_at) as avg_numerization_time,
    COUNT(CASE WHEN nr.validation_status = 'invalid' THEN 1 END) as failed_reservations
FROM numeration_requests nr
JOIN document_types dt ON nr.document_type_id = dt.document_type_id
WHERE nr.reserved_at >= (NOW() - INTERVAL '30 days')
GROUP BY dt.document_type_id, dt.name;
```

---

## ⚠️ Gestión de Errores y Excepciones

### Errores Comunes

#### 1. Duplicación de Números

**Causa**: Fallo en control de concurrencia  
**Detección**:
```sql
-- Detectar duplicados
SELECT reserved_number, COUNT(*)
FROM numeration_requests
WHERE year = EXTRACT(YEAR FROM NOW())
GROUP BY reserved_number
HAVING COUNT(*) > 1;
```

**Resolución**:
```sql
-- Invalidar duplicados excepto el primero
UPDATE numeration_requests 
SET validation_status = 'invalid'
WHERE numeration_requests_id IN (
    SELECT numeration_requests_id
    FROM (
        SELECT numeration_requests_id,
               ROW_NUMBER() OVER (PARTITION BY reserved_number ORDER BY reserved_at) as rn
        FROM numeration_requests
        WHERE reserved_number = ?
    ) ranked
    WHERE rn > 1
);
```

#### 2. Reservas Huérfanas

**Causa**: Proceso interrumpido antes de confirmación  
**Detección**:
```sql
-- Reservas pendientes por más de 1 hora
SELECT *
FROM numeration_requests
WHERE validation_status = 'pending'
  AND is_confirmed = false
  AND reserved_at < (NOW() - INTERVAL '1 hour');
```

**Resolución**:
```sql
-- Cleanup automático (cron job diario)
UPDATE numeration_requests 
SET validation_status = 'invalid'
WHERE validation_status = 'pending'
  AND is_confirmed = false
  AND reserved_at < (NOW() - INTERVAL '24 hours');
```

#### 3. Gaps en Secuencia

**Causa**: Números invalidados o reservas fallidas  
**Detección**:
```sql
-- Detectar gaps en secuencia
WITH RECURSIVE number_series AS (
    SELECT 1 as num
    UNION ALL
    SELECT num + 1
    FROM number_series
    WHERE num < (
        SELECT MAX(CAST(reserved_number AS INTEGER))
        FROM numeration_requests
        WHERE document_type_id = ? AND year = ?
    )
)
SELECT ns.num as missing_number
FROM number_series ns
LEFT JOIN numeration_requests nr ON CAST(nr.reserved_number AS INTEGER) = ns.num
    AND nr.document_type_id = ? AND nr.year = ?
WHERE nr.numeration_requests_id IS NULL;
```

### Recovery Procedures

#### Reasignación de Números

```sql
-- Procedimiento para reasignar número específico
CREATE OR REPLACE FUNCTION reassign_document_number(
    p_document_id UUID,
    p_new_number INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
    v_type_id UUID;
    v_current_year INTEGER;
BEGIN
    -- Obtener información del documento
    SELECT document_type_id INTO v_type_id
    FROM document_draft
    WHERE document_id = p_document_id;
    
    v_current_year := EXTRACT(YEAR FROM NOW());
    
    -- Verificar que el nuevo número esté disponible
    IF EXISTS (
        SELECT 1 FROM numeration_requests
        WHERE document_type_id = v_type_id
          AND year = v_current_year
          AND CAST(reserved_number AS INTEGER) = p_new_number
    ) THEN
        RETURN false; -- Número ya ocupado
    END IF;
    
    -- Reasignar número
    UPDATE numeration_requests
    SET reserved_number = LPAD(p_new_number::TEXT, 6, '0'),
        validation_status = 'valid'
    WHERE document_id = p_document_id;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;
```

---

## 🔧 Administración del Sistema

### Comandos de Mantenimiento

#### Reinicio de Secuencias Anuales

```sql
-- Procedimiento de inicio de año
CREATE OR REPLACE FUNCTION reset_annual_sequences()
RETURNS VOID AS $$
DECLARE
    current_year INTEGER := EXTRACT(YEAR FROM NOW());
BEGIN
    -- Log del reset
    INSERT INTO audit_logs (action, details, created_at)
    VALUES ('ANNUAL_SEQUENCE_RESET', 
            json_build_object('year', current_year),
            NOW());
    
    -- Las secuencias se reinician automáticamente
    -- al usar el año como parte de la query
    RAISE NOTICE 'Annual sequences reset for year %', current_year;
END;
$$ LANGUAGE plpgsql;
```

#### Backup de Numeración

```sql
-- Backup de estado de numeración
CREATE TABLE numeration_backup AS
SELECT 
    dt.acronym,
    nr.year,
    MAX(CAST(nr.reserved_number AS INTEGER)) as last_number,
    COUNT(*) as total_documents,
    NOW() as backup_date
FROM numeration_requests nr
JOIN document_types dt ON nr.document_type_id = dt.document_type_id
WHERE nr.is_confirmed = true
GROUP BY dt.document_type_id, dt.acronym, nr.year
ORDER BY dt.acronym, nr.year;
```

#### Validación de Integridad

```sql
-- Función de validación completa
CREATE OR REPLACE FUNCTION validate_numeracion_integrity()
RETURNS TABLE (
    issue_type TEXT,
    description TEXT,
    affected_documents INTEGER
) AS $$
BEGIN
    -- Verificar duplicados
    RETURN QUERY
    SELECT 
        'DUPLICATES'::TEXT,
        'Duplicate reserved numbers found'::TEXT,
        COUNT(*)::INTEGER
    FROM (
        SELECT reserved_number
        FROM numeration_requests
        WHERE year = EXTRACT(YEAR FROM NOW())
        GROUP BY reserved_number
        HAVING COUNT(*) > 1
    ) dups;
    
    -- Verificar huérfanos
    RETURN QUERY
    SELECT 
        'ORPHANS'::TEXT,
        'Pending reservations older than 24h'::TEXT,
        COUNT(*)::INTEGER
    FROM numeration_requests
    WHERE validation_status = 'pending'
      AND reserved_at < (NOW() - INTERVAL '24 hours');
      
    -- Verificar inconsistencias oficial
    RETURN QUERY
    SELECT 
        'INCONSISTENT'::TEXT,
        'Official documents without valid reservation'::TEXT,
        COUNT(*)::INTEGER
    FROM official_documents od
    LEFT JOIN numeration_requests nr ON od.numeration_requests_id = nr.numeration_requests_id
    WHERE nr.validation_status != 'valid' OR nr.is_confirmed = false;
END;
$$ LANGUAGE plpgsql;
```

---

## 📋 Configuración por Municipality

### Personalización de Formato

```sql
-- Configuración específica por municipio
CREATE TABLE municipality_numeration_config (
    municipality_id UUID PRIMARY KEY,
    number_format VARCHAR NOT NULL DEFAULT '{TIPO}-{YEAR}-{NUMBER}-{ECO}-{DEPT}',
    number_padding INTEGER DEFAULT 6,
    year_format VARCHAR DEFAULT 'YYYY',
    separator VARCHAR DEFAULT '-',
    created_at TIMESTAMP DEFAULT NOW()
);
```
### Templates de Numeración

```sql
-- Diferentes formatos según necesidades locales
INSERT INTO municipality_numeration_config VALUES
('municipality-1', '{TIPO}-{YEAR}-{NUMBER}-{ECO}-{DEPT}', 6, 'YYYY', '-'),
('municipality-2', '{TIPO}/{YEAR}/{NUMBER}', 4, 'YY', '/'),
('municipality-3', '{ECO}.{TIPO}.{YEAR}.{NUMBER}', 5, 'YYYY', '.');
```

---
