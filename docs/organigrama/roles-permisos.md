# Roles y Permisos

## 5.1 Tipos de Usuario

### Agente (Usuario Estándar)
- **Definición**: Usuario regular del sistema
- **Rol asignado** (en `user_roles`): ["Agente"]
- **En el organigrama**: Acceso de solo lectura a "Mi Equipo" y organigrama general

### Titular de Repartición (Gestor)
- **Definición**: Usuario responsable de una repartición
- **Rol asignado** (en `user_roles`): ["Gestor de Área", "Agente"]
- **En el organigrama**: Todas las funciones de Agente + gestión completa de su repartición

## 5.2 Matriz de Funcionalidades por Rol

| **Funcionalidad** | **Agente** | **Titular** |
|-------------------|------------|-------------|
| Ver Mi Equipo | ✅ Solo lectura | ✅ Lectura y gestión |
| Ver Organigrama General | ✅ Solo lectura | ✅ Solo lectura |
| Crear usuarios (en `users`) | ❌ | ✅ Solo en su repartición |
| Pausar/Reactivar usuarios (en `users`) | ❌ | ✅ Solo en su repartición |
| Dar de baja usuarios (en `users`) | ❌ | ✅ Solo en su repartición |
| Editar datos de usuarios (en `users`) | ❌ | ✅ Solo en su repartición |
| Buscar usuarios | ✅ | ✅ |
| Asignar responsables (en `departments.head_user_id`) | ✅ | ✅ |

## 5.3 Restricciones de Seguridad

### Validaciones del Sistema:
- **Titularidad**: El sistema verifica que el usuario sea titular de la repartición (en `department_heads`) antes de permitir gestión
- **Alcance**: Los titulares solo pueden gestionar usuarios que pertenezcan a sectores de su propia repartición
- **Estados**: Solo se permite gestionar usuarios en estados válidos
- **Auditoría**: Todas las acciones administrativas se registran para trazabilidad (en `audit_data` o `system_audit_log`)