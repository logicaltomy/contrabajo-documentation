# Documentación y Auditoría de Base de Datos - Contrabajo

Este repositorio contiene los scripts SQL de los microservicios del proyecto Contrabajo, junto con el control de cambios derivados de la auditoría de coherencia, normalización técnica y adaptación para Azure SQL Database.

## Últimos cambios
feat: 1.3

Cambios implementados en MS_Comunicaciones
Se adaptó el script para Azure SQL Database eliminando CREATE DATABASE, USE y estructuras innecesarias.
Se agregaron instrucciones DROP TABLE IF EXISTS mediante OBJECT_ID en orden correcto.
Se documentó cada tabla y cada decisión de modelado.
Se mantuvieron referencias lógicas hacia otros microservicios sin implementar claves foráneas cruzadas.
Se simplificó la tabla tipo_reporte eliminando la columna detalle por redundancia con nombre.
Se simplificó la tabla reporte eliminando funcion_asociada y entidad_reportada.
Se dejó únicamente entidad_id para mantener una referencia lógica genérica.
Se simplificó la tabla notificacion eliminando la columna tipo.
Se dejó la clasificación de notificaciones delegada al frontend mediante detalle y url_destino.
Se evaluó eliminar url_adjunto de mensaje_chat para evitar complejidad asociada al manejo de imágenes y archivos.
Se mantuvo activo en chat_cita para permitir cierre lógico de conversaciones.
Se mantuvo fecha_resolucion en mensaje_soporte para futura trazabilidad.
Se corrigieron índices e inconsistencias derivadas de columnas eliminadas.

## Arquitectura

Cada microservicio mantiene su propia base de datos desacoplada.
No se implementan claves foráneas entre bases de datos distintas.
Las relaciones entre microservicios se manejan de forma lógica desde backend.
Todos los scripts fueron preparados para ejecutarse directamente sobre Azure SQL Database.