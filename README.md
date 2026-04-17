# Documentación y Auditoría de Base de Datos - Contrabajo

Este repositorio contiene los scripts SQL de los microservicios del proyecto Contrabajo, junto con el control de cambios derivados de la auditoría de coherencia, normalización técnica y adaptación para Azure SQL Database.

## Últimos cambios
feat: 1.2

Cambios implementados en MS_Usuarios
Se reorganizó el orden de eliminación de tablas para evitar errores por restricciones de claves foráneas.
Se mantuvo el desacoplamiento entre microservicios evitando claves foráneas directas hacia MS_Servicios.
Se dejó id_estado como referencia lógica hacia MS_Servicios.estado(id_estado).
Se cambió telefono desde BIGINT a VARCHAR(9) debido a que el número telefónico es un dato textual y no numérico.
Se mantuvo a_materno como nullable debido a que no todos los usuarios poseen apellido materno.
Se mantuvo dv como VARCHAR(1) para permitir el uso de números o la letra K.
Se agregaron comentarios explicativos detallados para cada tabla y decisión de modelado.
Se creó la tabla pregunta_seguridad_usuario para almacenar preguntas y respuestas de seguridad de manera separada de la tabla principal usuario.
Se mantuvo recuperacion_cuenta como tabla independiente para registrar solicitudes temporales de recuperación.
Se agregaron índices para optimizar búsquedas frecuentes y relaciones entre tablas.
Arquitectura