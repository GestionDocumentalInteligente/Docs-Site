# 🔖 Sistema de Sellos GDI

## Índice
1. ¿Qué es el Sistema de Sellos?
2. Arquitectura del Sistema
3. Tablas Implementadas
4. Flujo de Asignación de Sellos
5. Relación con Ranks y Permisos
6. Casos de Uso
7. Diferencias con Sistema de Firmas
8. Modelo de Datos Completo

---

## 1. ¿Qué es el Sistema de Sellos?

El **Sistema de Sellos** en GDI es un mecanismo de **identificación visual y funcional** que se aplica a los documentos oficiales para indicar la **autoridad, rango o función específica** del firmante, más allá de su identidad personal.

### Concepto Fundamental
Un **sello** representa:
- ✅ **Cargo o función institucional** (no la persona)
- ✅ **Nivel de autoridad** dentro de la jerarquía
- ✅ **Identificación visual** en documentos oficiales
- ✅ **Validación de competencia** para ciertos tipos de documentos

**Ejemplo**: Un Intendente puede tener asignado el sello "INTENDENTE MUNICIPAL" que aparecerá en todos los documentos que firme con esa investidura.

---

## 2. Arquitectura del Sistema

### Estructura Jerárquica de 4 Niveles

```
🌐 global_seals (Catálogo Universal)
    ↓
🏛️ city_seals (Sellos Municipales)  
    ↓
👤 user_seals (Asignación a Usuarios)
    ↑
⭐ rank_allowed_seals (Control por Jerarquía)
```

### Flujo de Herencia y Control

1. **`global_seals`**: Define sellos estándar reutilizables
2. **`city_seals`**: Adapta sellos globales a cada municipio
3. **`rank_allowed_seals`**: Controla qué ranks pueden usar cada sello
4. **`user_seals`**: Asigna sellos específicos a usuarios autorizados

---

## 3. Tablas Implementadas

### 3.1 `global_seals` - Catálogo Universal

**Propósito**: Catálogo estándar de sellos reutilizable entre municipios

```sql
CREATE TABLE global_seals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    acronym TEXT NOT NULL UNIQUE,         -- Ej: "INTEN", "SECGOB" 
    name TEXT NOT NULL,                    -- Ej: "Intendente Municipal"
    description TEXT,                      -- Descripción funcional
    created_at TIMESTAMP DEFAULT now()
);
```

**Ejemplos de Sellos Globales**:
- `INTEN` → "Intendente Municipal" 
- `SECGOB` → "Secretario de Gobierno"
- `DIROBR` → "Director de Obras Públicas"
- `JEFGAB` → "Jefe de Gabinete"

### 3.2 `city_seals` - Implementación Municipal

**Propósito**: Versión municipal específica de cada sello global

```sql
CREATE TABLE city_seals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    global_seal_id UUID,                  -- Referencia a global_seals (opcional)
    acronym TEXT NOT NULL UNIQUE,         -- Acrónimo específico del municipio
    name TEXT NOT NULL,                    -- Nombre personalizado
    description TEXT,                      -- Descripción local
    created_at TIMESTAMP DEFAULT now(),
    
    FOREIGN KEY (global_seal_id) REFERENCES global_seals(id)
);
```

**Funcionalidad**:
- **Hereda** de `global_seals` pero permite **personalización local**
- **`global_seal_id` NULL**: Sello específico del municipio
- **`global_seal_id` NOT NULL**: Adaptación local de sello estándar

### 3.3 `rank_allowed_seals` - Control de Autorización

**Propósito**: Define qué ranks pueden usar cada sello

```sql
CREATE TABLE rank_allowed_seals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rank_id UUID NOT NULL,                -- Referencia a ranks
    city_seal_id UUID NOT NULL,           -- Referencia a city_seals  
    created_at TIMESTAMP DEFAULT now(),
    
    FOREIGN KEY (rank_id) REFERENCES ranks(rank_id),
    FOREIGN KEY (city_seal_id) REFERENCES city_seals(id)
);
```

**Lógica de Control**:
- Solo usuarios con `rank_id` autorizado pueden usar el sello
- Un sello puede estar disponible para múltiples ranks
- Un rank puede tener acceso a múltiples sellos

### 3.4 `user_seals` - Asignación Individual

**Propósito**: Asigna sellos específicos a usuarios individuales

```sql
CREATE TABLE user_seals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,                -- Usuario asignado
    city_seal_id UUID NOT NULL,           -- Sello asignado
    created_at TIMESTAMP DEFAULT now(),
    
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (city_seal_id) REFERENCES city_seals(id)
);
```

**Características**:
- **Relación many-to-many**: Un usuario puede tener múltiples sellos
- **Un sello puede ser usado por múltiples usuarios**
- **Control previo**: Debe cumplir `rank_allowed_seals`

### 3.5 Campo `default_seal_id` en Users

**Ubicación**: `users.default_seal_id BIGINT`

**Propósito**: 
- Sello **por defecto** que se aplica automáticamente al firmar
- **Tipo BIGINT**: Posible referencia a sistema externo o secuencial
- **Nullable**: Usuario puede no tener sello por defecto

---

## 4. Flujo de Asignación de Sellos

### Proceso Completo

#### Paso 1: Configuración Global
```sql
-- Crear sello estándar
INSERT INTO global_seals (acronym, name, description) 
VALUES ('INTEN', 'Intendente Municipal', 'Máxima autoridad ejecutiva municipal');
```

#### Paso 2: Adaptación Municipal  
```sql
-- Crear versión municipal
INSERT INTO city_seals (global_seal_id, acronym, name, description)
VALUES (
    '[global_seal_uuid]',
    'INTEN-TN', 
    'Intendente Municipal de Terranova',
    'Intendente del Municipio de Terranova'
);
```

#### Paso 3: Autorización por Rank
```sql
-- Autorizar rank "Intendente" para usar este sello
INSERT INTO rank_allowed_seals (rank_id, city_seal_id)
VALUES ('[intendente_rank_id]', '[city_seal_id]');
```

#### Paso 4: Asignación a Usuario
```sql
-- Asignar sello al usuario con cargo de Intendente
INSERT INTO user_seals (user_id, city_seal_id)
VALUES ('[intendente_user_id]', '[city_seal_id]');

-- Configurar como sello por defecto  
UPDATE users 
SET default_seal_id = [user_seal_id]
WHERE user_id = '[intendente_user_id]';
```

### Validación Automática

```sql
-- Query de validación: ¿Puede el usuario usar este sello?
SELECT EXISTS (
    SELECT 1
    FROM users u
    JOIN departments d ON u.sector_id IN (
        SELECT sector_id FROM sectors WHERE department_id = d.department_id
    )
    JOIN rank_allowed_seals ras ON d.rank_id = ras.rank_id
    JOIN user_seals us ON u.user_id = us.user_id
    WHERE u.user_id = ? 
      AND ras.city_seal_id = us.city_seal_id
      AND us.city_seal_id = ?
) as can_use_seal;
```

---

## 5. Relación con Ranks y Permisos

### Integración con Jerarquías

El sistema de sellos se **integra directamente** con:
- **`ranks`**: Define niveles jerárquicos
- **`departments`**: Estructura organizacional  
- **`document_types_allowed_by_rank`**: Permisos de firma

### Matriz de Control

| Usuario | Department | Rank | Sello Permitido | Puede Firmar |
|---------|------------|------|----------------|--------------|
| Juan Pérez | Intendencia | Intendente | INTEN-TN | Decretos ✅ |
| María García | Sec. Gobierno | Secretario | SECGOB-TN | Resoluciones ✅ |
| Carlos López | Dir. Obras | Director | DIROBR-TN | Disposiciones ✅ |

### Query de Permisos Completos

```sql
-- Obtener sellos disponibles para un usuario
SELECT 
    cs.acronym,
    cs.name,
    cs.description,
    CASE WHEN us.user_id IS NOT NULL THEN 'ASIGNADO' ELSE 'DISPONIBLE' END as status
FROM city_seals cs
JOIN rank_allowed_seals ras ON cs.id = ras.city_seal_id
JOIN departments d ON ras.rank_id = d.rank_id
JOIN sectors s ON d.department_id = s.department_id
JOIN users u ON s.sector_id = u.sector_id
LEFT JOIN user_seals us ON cs.id = us.city_seal_id AND u.user_id = us.user_id
WHERE u.user_id = ?
ORDER BY cs.name;
```

---

## 6. Casos de Uso

### Caso 1: Usuario con Múltiples Funciones

**Situación**: El Intendente también es Director de Seguridad

```sql
-- Asignar múltiples sellos
INSERT INTO user_seals (user_id, city_seal_id) VALUES
('[intendente_id]', '[sello_intendente_id]'),
('[intendente_id]', '[sello_director_seguridad_id]');

-- Sello por defecto: Intendente
UPDATE users SET default_seal_id = '[sello_intendente_id]' 
WHERE user_id = '[intendente_id]';
```

**Al Firmar**:
- **Decretos**: Usa automáticamente sello "INTENDENTE" 
- **Disposiciones de Seguridad**: Puede cambiar a "DIRECTOR DE SEGURIDAD"

### Caso 2: Interinatos y Reemplazos

**Situación**: Secretario actúa como Intendente interino

```sql
-- Asignar temporalmente sello de Intendente
INSERT INTO user_seals (user_id, city_seal_id) 
VALUES ('[secretario_id]', '[sello_intendente_id]');
```

**Resultado**: El secretario puede firmar con autoridad de Intendente

### Caso 3: Sello Municipal Específico

**Situación**: Crear sello único del municipio

```sql
-- Sello sin referencia global (específico)
INSERT INTO city_seals (global_seal_id, acronym, name) 
VALUES (NULL, 'COORD-EMER', 'Coordinador de Emergencias Terranova');
```

---

## 7. Diferencias con Sistema de Firmas

### Complementariedad de Sistemas

| Aspecto | **Sistema de Firmas** | **Sistema de Sellos** |
|---------|----------------------|----------------------|
| **Propósito** | Autenticar identidad | Indicar autoridad/cargo |
| **Tecnología** | Firma digital/electrónica | Identificación visual |
| **Validez Legal** | Jurídica plena | Administrativa |
| **Personalización** | Por usuario | Por cargo/función |
| **Duración** | Permanente (certificado) | Temporal (cargo) |

### Flujo Integrado

```
Usuario firma documento
     ↓
1. Autenticación: Sistema de Firmas (¿quién es?)
     ↓  
2. Autorización: Sistema de Sellos (¿con qué autoridad?)
     ↓
3. Aplicación: Sello aparece en documento final
```

---

## 8. Modelo de Datos Completo

### Diagrama de Relaciones

```
global_seals
    ↓ (1:N - opcional)
city_seals ←→ rank_allowed_seals ←→ ranks
    ↓ (1:N)           ↑ (N:M)
user_seals ←→ users.default_seal_id
    ↑ (N:M)
users
```

### Constraints y Validaciones

```sql
-- Unicidad de acrónimos por tabla
UNIQUE(global_seals.acronym)
UNIQUE(city_seals.acronym)

-- Un usuario no puede tener el mismo sello duplicado
UNIQUE(user_seals.user_id, user_seals.city_seal_id)

-- Un rank no puede tener autorización duplicada para el mismo sello
UNIQUE(rank_allowed_seals.rank_id, rank_allowed_seals.city_seal_id)
```

### Queries de Administración

```sql
-- Sellos más utilizados
SELECT 
    cs.name,
    COUNT(us.user_id) as usuarios_asignados
FROM city_seals cs
LEFT JOIN user_seals us ON cs.id = us.city_seal_id
GROUP BY cs.id, cs.name
ORDER BY usuarios_asignados DESC;

-- Usuarios sin sellos asignados
SELECT u.full_name, u.email
FROM users u
LEFT JOIN user_seals us ON u.user_id = us.user_id
WHERE us.user_id IS NULL;

-- Sellos disponibles para un rank específico
SELECT cs.acronym, cs.name
FROM city_seals cs
JOIN rank_allowed_seals ras ON cs.id = ras.city_seal_id
WHERE ras.rank_id = ?;
```

---

## Conclusión

El **Sistema de Sellos** proporciona una **capa adicional de identificación institucional** que va más allá de la identidad personal, permitiendo:

- ✅ **Representación visual** del cargo en documentos
- ✅ **Control granular** por jerarquía y función  
- ✅ **Flexibilidad** para múltiples roles por usuario
- ✅ **Estandarización** entre municipios con personalización local
- ✅ **Integración** completa con sistema de permisos y firmas

Este sistema asegura que cada documento oficial refleje **claramente la autoridad** bajo la cual fue emitido, fortaleciendo la **trazabilidad y legitimidad** de los actos administrativos.