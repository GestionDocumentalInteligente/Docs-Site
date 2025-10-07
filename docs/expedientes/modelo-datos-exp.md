## 3.3 Modelo de Datos del Flujo de Creación

### Conceptos Fundamentales

El flujo de creación de expedientes involucra múltiples entidades que trabajan de forma coordinada para garantizar la integridad, trazabilidad y validez legal del proceso. Cada expediente creado genera automáticamente:

- **Un registro principal** que contiene todos los metadatos del expediente
- **Una carátula oficial** como documento independiente con numeración propia
- **Relaciones organizacionales** que determinan permisos y responsabilidades
- **Un historial de auditoría** que registra cada paso del proceso

### Flujo de Datos durante la Creación

## Flujo de Datos durante la Creación

## Flujo de Datos durante la Creación

[Usuario] → [Validación] → [Expediente] → [Numeración] → [Carátula] → [Vinculación]  
    ↓                ↓                ↓               ↓              ↓              ↓  
[Permisos]      [Tipos]         [Repartición]    [Secuencial]    [Documento]    [Bidireccional]

### Estructura de Datos Implementada

#### Tabla Principal: `expedients`

**Propósito**: Registro central de cada expediente con sus metadatos fundamentales.

```sql
CREATE TABLE expedients (
    -- Identificación única
    expedient_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    expedient_number VARCHAR UNIQUE NOT NULL, -- EE-AAAA-NNNNNN-SIGLA_ECO-SIGLA_DEPT
    
    -- Configuración del expediente
    expedient_type_id UUID NOT NULL,
    motive TEXT NOT NULL CHECK (length(trim(motive)) > 0),
    
    -- Datos del iniciador
    initiator_type initiator_type_enum NOT NULL,
    initiator_details JSONB, -- CUIT, nombre, email para externos
    
    -- Estructura organizacional
    admin_department_id UUID NOT NULL, -- Repartición administradora
    created_by_user_id UUID NOT NULL,  -- Usuario creador
    assigned_user_id UUID,             -- Usuario asignado (opcional)
    
    -- Vinculación con carátula
    caratula_document_id UUID,         -- Documento carátula generado
    
    -- Control de estado
    status expedient_status DEFAULT 'active',
    
    -- Auditoría temporal
    created_at TIMESTAMP DEFAULT NOW(),
    last_activity_at TIMESTAMP DEFAULT NOW(),
    
    -- Metadatos adicionales
    audit_data JSONB,
    is_deleted BOOLEAN DEFAULT false,
    
    -- Constraints
    CONSTRAINT fk_expedient_type FOREIGN KEY (expedient_type_id) 
        REFERENCES expedient_types(expedient_type_id),
    CONSTRAINT fk_admin_department FOREIGN KEY (admin_department_id) 
        REFERENCES departments(department_id),
    CONSTRAINT fk_creator FOREIGN KEY (created_by_user_id) 
        REFERENCES users(user_id),
    CONSTRAINT fk_caratula FOREIGN KEY (caratula_document_id) 
        REFERENCES document_draft(document_id)
);

-- Tipos de datos personalizados
CREATE TYPE initiator_type_enum AS ENUM ('INTERNO', 'EXTERNO');
CREATE TYPE expedient_status AS ENUM ('active', 'transferred', 'archived', 'cancelled');
```

#### Sistema de Numeración: `expedient_numeration_requests`

**Propósito**: Garantizar numeración secuencial única y trazable.

```sql
CREATE TABLE expedient_numeration_requests (
    numeration_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Identificación del tipo y contexto
    expedient_type_id UUID NOT NULL,
    department_id UUID NOT NULL,    -- Repartición numeradora
    year SMALLINT NOT NULL,         -- Año de numeración
    
    -- Control de secuencia
    reserved_number VARCHAR UNIQUE NOT NULL, -- Número reservado (ej: "000123")
    reserved_at TIMESTAMP DEFAULT NOW(),
    is_confirmed BOOLEAN DEFAULT false,
    
    -- Vinculación final
    expedient_id UUID,             -- Se completa al confirmar
    
    CONSTRAINT fk_numeration_type FOREIGN KEY (expedient_type_id) 
        REFERENCES expedient_types(expedient_type_id),
    CONSTRAINT fk_numeration_dept FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    CONSTRAINT unique_number_per_type_year UNIQUE (expedient_type_id, year, reserved_number)
);
```

#### Configuración de Tipos: `expedient_types`

**Propósito**: Definir reglas de negocio y permisos por tipo de expediente.

```sql
CREATE TABLE expedient_types (
    expedient_type_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Identificación
    name VARCHAR NOT NULL,          -- "Licitación Pública"
    acronym VARCHAR UNIQUE NOT NULL, -- "LICPUB"
    description TEXT,
    
    -- Reglas de creación
    enabled_departments UUID[],     -- Reparticiones que pueden crear
    admin_department_type department_assignment_enum NOT NULL,
    specific_admin_department UUID, -- Si es asignación específica
    
    -- Control
    is_active BOOLEAN DEFAULT true,
    audit_data JSONB,
    
    CONSTRAINT fk_specific_dept FOREIGN KEY (specific_admin_department) 
        REFERENCES departments(department_id)
);

CREATE TYPE department_assignment_enum AS ENUM ('CREATOR', 'SPECIFIC');
```

### Funciones de Proceso Automatizado

#### Generación de Número Oficial

```sql
CREATE OR REPLACE FUNCTION generate_expedient_number(
    p_expedient_type_id UUID,
    p_admin_department_id UUID
) RETURNS VARCHAR AS $$
DECLARE
    v_year INTEGER := EXTRACT(YEAR FROM NOW());
    v_next_number INTEGER;
    v_type_acronym VARCHAR;
    v_dept_acronym VARCHAR;
    v_municipality_acronym VARCHAR;
    v_final_number VARCHAR;
BEGIN
    -- Obtener siguiente número secuencial
    SELECT COALESCE(MAX(CAST(reserved_number AS INTEGER)), 0) + 1
    INTO v_next_number
    FROM expedient_numeration_requests
    WHERE expedient_type_id = p_expedient_type_id 
      AND year = v_year;
    
    -- Obtener componentes del número
    SELECT et.acronym, d.acronym, m.acronym
    INTO v_type_acronym, v_dept_acronym, v_municipality_acronym
    FROM expedient_types et
    JOIN departments d ON d.department_id = p_admin_department_id
    JOIN municipalities m ON d.municipality_id = m.id_municipality
    WHERE et.expedient_type_id = p_expedient_type_id;
    
    -- Construir número final: EX-AAAA-NNNNNN-SIGLA_ECO-SIGLA_DEPT
    v_final_number := 'EX-' || v_year || '-' || 
                      LPAD(v_next_number::TEXT, 6, '0') || '-' ||
                      v_municipality_acronym || '-' || v_dept_acronym;
    
    -- Reservar número
    INSERT INTO expedient_numeration_requests (
        expedient_type_id, department_id, year, 
        reserved_number, reserved_at
    ) VALUES (
        p_expedient_type_id, p_admin_department_id, 
        v_year, LPAD(v_next_number::TEXT, 6, '0'), NOW()
    );
    
    RETURN v_final_number;
END;
$$ LANGUAGE plpgsql;
```

#### Validación de Permisos de Creación

```sql
CREATE OR REPLACE FUNCTION user_can_create_expedient_type(
    p_user_id UUID,
    p_expedient_type_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_department_id UUID;
    v_enabled_departments UUID[];
BEGIN
    -- Obtener department del usuario
    SELECT d.department_id
    INTO v_user_department_id
    FROM users u
    JOIN sectors s ON u.sector_id = s.sector_id
    JOIN departments d ON s.department_id = d.department_id
    WHERE u.user_id = p_user_id;
    
    -- Obtener departments habilitados para este tipo
    SELECT enabled_departments
    INTO v_enabled_departments
    FROM expedient_types
    WHERE expedient_type_id = p_expedient_type_id
      AND is_active = true;
    
    -- Verificar si el department del usuario está habilitado
    RETURN v_user_department_id = ANY(v_enabled_departments);
END;
$$ LANGUAGE plpgsql;
```

#### Determinación de Repartición Administradora

```sql
CREATE OR REPLACE FUNCTION assign_admin_department(
    p_expedient_type_id UUID,
    p_creator_department_id UUID
) RETURNS UUID AS $$
DECLARE
    v_assignment_type department_assignment_enum;
    v_specific_department UUID;
BEGIN
    SELECT admin_department_type, specific_admin_department
    INTO v_assignment_type, v_specific_department
    FROM expedient_types
    WHERE expedient_type_id = p_expedient_type_id;
    
    CASE v_assignment_type
        WHEN 'CREATOR' THEN
            RETURN p_creator_department_id;
        WHEN 'SPECIFIC' THEN
            RETURN v_specific_department;
        ELSE
            RAISE EXCEPTION 'Tipo de asignación inválido para expedient_type_id: %', p_expedient_type_id;
    END CASE;
END;
$$ LANGUAGE plpgsql;
```

### Triggers y Validaciones Automáticas

```sql
-- Trigger de validación pre-inserción
CREATE OR REPLACE FUNCTION validate_expedient_creation()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar permisos de usuario
    IF NOT user_can_create_expedient_type(NEW.created_by_user_id, NEW.expedient_type_id) THEN
        RAISE EXCEPTION 'Usuario no autorizado para crear este tipo de expediente';
    END IF;
    
    -- Validar datos de iniciador externo
    IF NEW.initiator_type = 'EXTERNO' THEN
        IF NEW.initiator_details IS NULL OR 
           NOT (NEW.initiator_details ? 'cuit') OR
           NOT (NEW.initiator_details ? 'name') THEN
            RAISE EXCEPTION 'Datos de iniciador externo incompletos (CUIT y nombre requeridos)';
        END IF;
    END IF;
    
    -- Validar motivo
    IF NEW.motive IS NULL OR trim(NEW.motive) = '' THEN
        RAISE EXCEPTION 'Motivo del expediente es obligatorio';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_expedient_creation
    BEFORE INSERT ON expedients
    FOR EACH ROW
    EXECUTE FUNCTION validate_expedient_creation();

-- Trigger post-creación para generar carátula
CREATE OR REPLACE FUNCTION post_expedient_creation()
RETURNS TRIGGER AS $$
DECLARE
    v_caratula_id UUID;
BEGIN
    -- Generar carátula automática
    SELECT generate_expedient_caratula(NEW.expedient_id) INTO v_caratula_id;
    
    -- Actualizar expediente con referencia a carátula
    UPDATE expedients 
    SET caratula_document_id = v_caratula_id
    WHERE expedient_id = NEW.expedient_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_post_expedient_creation
    AFTER INSERT ON expedients
    FOR EACH ROW
    EXECUTE FUNCTION post_expedient_creation();
```

### Índices para Optimización de Performance

```sql
-- Índices principales para búsquedas frecuentes
CREATE INDEX idx_expedients_number ON expedients(expedient_number);
CREATE INDEX idx_expedients_type ON expedients(expedient_type_id);
CREATE INDEX idx_expedients_admin_dept ON expedients(admin_department_id);
CREATE INDEX idx_expedients_creator ON expedients(created_by_user_id);
CREATE INDEX idx_expedients_status ON expedients(status) WHERE status != 'archived';
CREATE INDEX idx_expedients_created_date ON expedients(created_at);

-- Índices para numeración
CREATE INDEX idx_numeration_type_year ON expedient_numeration_requests(expedient_type_id, year);
CREATE INDEX idx_numeration_confirmed ON expedient_numeration_requests(is_confirmed);

-- Índices para tipos activos
CREATE INDEX idx_expedient_types_active ON expedient_types(is_active) WHERE is_active = true;
```