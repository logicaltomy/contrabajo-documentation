# Documentación y Auditoría de Base de Datos - Contrabajo

Este repositorio contiene los scripts SQL de los microservicios del proyecto Contrabajo, junto con el control de cambios derivados de la auditoría de coherencia, normalización técnica y adaptación para Azure SQL Database.

## Historial reciente

### 1.8.1-Pre-Alpha
- Se incorpora limpieza explícita de `dbo.usuario_baneo` en el bloque de eliminación de tablas.
- Se crea la tabla `dbo.usuario_baneo` para registrar sanciones de moderación sobre usuarios.
- Campos incluidos: usuario sancionado, moderador, motivo, fechas de inicio/fin, marca de baneo permanente y estado activo de la sanción.
