# Documentación y Auditoría de Base de Datos - Contrabajo

Este repositorio contiene los scripts SQL de los microservicios del proyecto Contrabajo, junto con el control de cambios derivados de la auditoría de coherencia, normalización técnica y adaptación para Azure SQL Database.

## Últimos cambios
Versión: 1.1.1.b-Pre-Alpha

Cambios implementados:
* Adaptación de scripts SQL para compatibilidad con Azure SQL Database.
* Eliminación de instrucciones CREATE DATABASE, USE y GO en los scripts preparados para Azure.
* Ajuste de relaciones lógicas entre microservicios sin uso de claves foráneas cruzadas.
* Actualización de MS_Usuarios para documentar referencias lógicas hacia MS_Servicios.
* Modificación de MS_Servicios:
  * Eliminación de la columna detalle en dbo.oferta_servicio.
  * Eliminación de la columna moneda en dbo.oferta_servicio.
  * Eliminación completa de la tabla dbo.historial_servicios.
* Reordenamiento de DROP TABLE para evitar errores por dependencias.
* Ajuste de índices y comentarios de referencias lógicas entre microservicios.