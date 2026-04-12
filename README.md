# Documentación y Auditoría de Base de Datos - Contrabajo

Este repositorio contiene los scripts de las bases de datos de los microservicios del proyecto, junto con el control de cambios derivados de la auditoría de coherencia y normalización técnica.

## Últimos cambios

**Versión: 0.2-Pre-Alpha**

**Cambios implementados:**

* Refactor de la tabla `usuario`:

  * `run` cambia a tipo `INT`
  * `dv` cambia a `VARCHAR(1)`
  * Se agrega columna `id_estado` como base para control de estado del usuario
* Normalización de la tabla `cedula_identidad`:

  * Se renombran columnas a `run_documento`, `dv_documento` y `fecha_nacimiento_documento` para separar claramente datos del documento vs input manual
* Eliminación de la columna `villa` en `direccion` por falta de contexto funcional
* Simplificación de la tabla `historial_usuario`:

  * Eliminadas columnas `fecha_historial_usuario`, `promedio_tiempo_sesion` y `nivel_actividad`
  * Se prioriza un modelo más liviano y alineado a auditoría real
* Simplificación de la tabla `sesion_usuario`:

  * Eliminadas columnas `ip_creacion`, `dispositivo` y `activa`
  * Reducción de complejidad en gestión de sesiones
* Eliminación de la columna `canal` en `recuperacion_cuenta` por falta de uso dentro de la lógica del sistema

**Pendientes (Cambios a efectuar ⚠️ en revisión):**

* ->>> `MS_Usuarios` - Tabla `usuario`: Definir e integrar correctamente la FK `id_estado` con el microservicio correspondiente (`MS_Comunicaciones`)
* ->>> `MS_Usuarios` - Evaluar centralización del manejo de estados (posible tabla compartida o catálogo común)
* ->>> `MS_Usuarios` - Revisar estrategia de auditoría avanzada para `log_actividad` (posible separación en otro contexto o servicio)
* ->>> `MS_Usuarios` - Definir si `ultimo_dispositivo` en `historial_usuario` se mantiene o se elimina en futuras iteraciones
