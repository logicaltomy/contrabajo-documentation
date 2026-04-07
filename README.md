# Documentación y Auditoría de Base de Datos - Contrabajo

Este repositorio contiene los scripts de las bases de datos de los microservicios del proyecto, junto con el control de cambios derivados de la auditoría de coherencia y normalización técnica.

## Últimos cambios
**Versión: 0.1.0-Pre-Alpha**

**Cambios implementados:**
* Integración inicial de los scripts SQL para las bases de datos independientes: `MS_Usuarios`, `MS_Comunicaciones` y `MS_Servicios`.
* Inicio del proceso de auditoría informal de coherencia sobre el sistema transaccional (ACID).
* Validación inicial (✔) de columnas en `MS_Usuarios`: `tipo_perfil`, `region`, `coordenadas`, `calle` y `tipo_evento`.

**Pendientes (Cambios a efectuar ⚠️ en revisión):**
* ->>> `MS_Usuarios` - Tabla `usuario`: Eliminar columna `run` y `fecha_nacimiento`. Estos datos ya están presentes en la tabla `cedula_identidad`; se debe usar un JOIN para cumplir con la Tercera Forma Normal (3FN).
* ->>> `MS_Usuarios` - Tabla `usuario`: Eliminar la columna `dv` por ser innecesaria.
* ->>> `MS_Usuarios` - Tabla `usuario`: Desarrollar una función para automatizar la creación del `username` (ej. tomando fragmentos del nombre) para evitar nombres de usuario inapropiados.
* ->>> `MS_Usuarios` - Tabla `historial_usuario`: Evaluar la necesidad y viabilidad técnica de las columnas `promedio_tiempo_sesion`, `nivel_actividad` y `ultimo_dispositivo`.
* ->>> `MS_Usuarios` - Tabla `sesion_usuario`: Auditar el manejo de valores NULL en las columnas `ip_creacion` y `dispositivo`.
