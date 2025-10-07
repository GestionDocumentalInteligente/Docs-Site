# Integración con Módulo Documentos

## Vinculación Bidireccional

El Módulo Expedientes mantiene una integración estrecha con el Módulo Documentos de GDI, estableciendo una relación bidireccional que potencia las capacidades de ambos sistemas:

### Desde Expedientes hacia Documentos:

- **Búsqueda de documentos existentes**: El sistema permite buscar documentos ya creados en GDI por número oficial, tipo, o contenido

- **Vinculación sin duplicación**: Los documentos mantienen su integridad y versionado original.
    *   **Detalle Técnico**: Esta vinculación se registra en el campo `records.linked_documents` (tipo JSONB) del expediente, almacenando el `document_id` del documento oficial (`official_documents.document_id`) junto con metadatos de vinculación.

- **Referencia cruzada**: Los documentos vinculados mantienen referencia al expediente en sus metadatos

### Desde Documentos hacia Expedientes:

- **Campo "Vincular a expediente"**: Durante la creación de documentos oficiales, se puede especificar vinculación automática

- **Vinculación post-firma**: Una vez firmado y numerado el documento, se ejecuta automáticamente la vinculación al expediente especificado

- **Búsqueda de expedientes**: El sistema permite localizar expedientes por número oficial para vinculación

## Flujo de Integración:

```
Documento Oficial (estado: signed) → Vinculación automática → Expediente especificado
                    ↓
Aparece en Sección Documentos del Expediente → Orden cronológico → Trazabilidad completa
```

## Casos de Uso de Integración:

- **Creación reactiva**: Se crea un expediente para agrupar documentos ya existentes relacionados

- **Creación proactiva**: Se crea el expediente primero y luego se van vinculando documentos conforme se generan

- **Documentos transversales**: Un mismo documento puede estar vinculado a múltiples expedientes

- **Subsanación integrada**: Al subsanar un documento en el expediente, se mantiene la referencia al documento original

## Beneficios de la Integración:

- **Trazabilidad completa**: Visión integral del flujo documental y administrativo

- **Eficiencia operativa**: Evita duplicación de esfuerzos y mantiene consistencia

- **Auditoría unificada**: Logs coordinados entre ambos módulos

- **Búsqueda transversal**: Posibilidad de localizar información desde cualquier punto de entrada