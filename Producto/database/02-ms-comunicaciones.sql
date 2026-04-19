-- =========================================================
-- ELIMINACIÓN DE TABLAS EN ORDEN CORRECTO (HIJOS → PADRES)
-- =========================================================
IF OBJECT_ID(N'dbo.mensaje_chat', N'U') IS NOT NULL DROP TABLE dbo.mensaje_chat;
IF OBJECT_ID(N'dbo.reporte', N'U') IS NOT NULL DROP TABLE dbo.reporte;
IF OBJECT_ID(N'dbo.notificacion', N'U') IS NOT NULL DROP TABLE dbo.notificacion;
IF OBJECT_ID(N'dbo.mensaje_soporte', N'U') IS NOT NULL DROP TABLE dbo.mensaje_soporte;
IF OBJECT_ID(N'dbo.chat_cita', N'U') IS NOT NULL DROP TABLE dbo.chat_cita;
IF OBJECT_ID(N'dbo.tipo_reporte', N'U') IS NOT NULL DROP TABLE dbo.tipo_reporte;
GO

-- =========================================================
-- TABLA: TIPO_REPORTE
-- Almacena los distintos tipos de reportes que pueden
-- existir dentro de la plataforma.
--
-- Ejemplos:
-- - Usuario ofensivo
-- - Incumplimiento de servicio
-- - Estafa
-- - Contenido inapropiado
-- =========================================================
CREATE TABLE dbo.tipo_reporte (
    id_tipo_reporte INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT PK_tipo_reporte PRIMARY KEY (id_tipo_reporte),
    CONSTRAINT UQ_tipo_reporte_nombre UNIQUE (nombre)
);
GO

-- =========================================================
-- TABLA: CHAT_CITA
-- Representa una conversación asociada a una cita o servicio.
--
-- Este chat se genera entre:
-- - Trabajador
-- - Cliente
-- activo:
-- Permite cerrar el chat sin eliminarlo físicamente.
-- =========================================================
CREATE TABLE dbo.chat_cita (
    id_chat_cita BIGINT IDENTITY(1,1) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_chat_cita_fecha_creacion DEFAULT SYSUTCDATETIME(),

    id_trabajador INT NOT NULL,
    id_cliente INT NOT NULL,
    id_cita INT NULL,

    activo BIT NOT NULL
        CONSTRAINT DF_chat_cita_activo DEFAULT 1,

    CONSTRAINT PK_chat_cita PRIMARY KEY (id_chat_cita)
);
GO

-- =========================================================
-- TABLA: MENSAJE_SOPORTE
-- Almacena mensajes enviados por usuarios hacia soporte.
--
-- Se utiliza para:
-- - Problemas técnicos
-- - Reclamos
-- - Dudas
-- - Problemas con pagos o citas
--
-- resuelto:
-- 0 = Pendiente
-- 1 = Resuelto
-- =========================================================
CREATE TABLE dbo.mensaje_soporte (
    id_mensaje_soporte INT IDENTITY(1,1) NOT NULL,
    asunto VARCHAR(80) NOT NULL,
    detalle NVARCHAR(500) NOT NULL,

    fecha_envio DATETIME2(0) NOT NULL
        CONSTRAINT DF_mensaje_soporte_fecha_envio DEFAULT SYSUTCDATETIME(),

    fecha_resolucion DATETIME2(0) NULL,

    id_emisor INT NOT NULL,

    resuelto BIT NOT NULL
        CONSTRAINT DF_mensaje_soporte_resuelto DEFAULT 0,

    CONSTRAINT PK_mensaje_soporte PRIMARY KEY (id_mensaje_soporte)
);
GO

-- =========================================================
-- TABLA: NOTIFICACION
-- Almacena notificaciones visibles para el usuario.
--
-- Ejemplos:
-- - Nuevo mensaje
-- - Cambio de estado de cita
-- - Respuesta de soporte
-- - Reporte recibido
--
-- tipo:
-- Permite categorizar la notificación.
--
-- leida:
-- 0 = No leída
-- 1 = Leída
-- =========================================================
CREATE TABLE dbo.notificacion (
id_notificacion BIGINT IDENTITY(1,1) NOT NULL,
fecha_creacion DATETIME2(0) NOT NULL,
detalle NVARCHAR(200) NOT NULL,
id_usuario_receptor INT NOT NULL,
leida BIT NOT NULL DEFAULT 0,
url_destino VARCHAR(300) NULL,
    CONSTRAINT PK_notificacion PRIMARY KEY (id_notificacion)
);
GO

-- =========================================================
-- TABLA: REPORTE
-- Permite a un usuario reportar una situación, usuario
-- o funcionalidad de la aplicación.
--
-- entidad_reportada:
-- Permite saber qué fue reportado.
--
-- entidad_id:
-- Guarda el identificador interno de dicha entidad.
--
-- funcion_asociada:
-- Puede almacenar valores como:
-- - chat
-- - perfil
-- - cita
-- - servicio
-- - comentario
-- =========================================================
CREATE TABLE dbo.reporte (
    id_reporte BIGINT IDENTITY(1,1) NOT NULL,

    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_reporte_fecha_creacion DEFAULT SYSUTCDATETIME(),

    descripcion_reporte NVARCHAR(500) NOT NULL,

    id_usuario_emisor INT NOT NULL,

    id_tipo_reporte INT NOT NULL,

    entidad_id BIGINT NULL,

    CONSTRAINT PK_reporte PRIMARY KEY (id_reporte),

    CONSTRAINT FK_reporte_tipo_reporte
        FOREIGN KEY (id_tipo_reporte)
        REFERENCES dbo.tipo_reporte(id_tipo_reporte)
);
GO

-- =========================================================
-- TABLA: MENSAJE_CHAT
-- Almacena los mensajes enviados dentro de un chat.
--
-- Se registran:
-- - Fecha de envío
-- - Fecha de recepción
-- - Fecha de lectura
-- - Emisor y receptor
-- - Contenido del mensaje
--
-- url_adjunto:
-- Permite guardar imágenes, archivos o evidencia
-- asociada al mensaje.
-- =========================================================
CREATE TABLE dbo.mensaje_chat (
    id_mensaje_chat BIGINT IDENTITY(1,1) NOT NULL,

    fecha_envio DATETIME2(0) NOT NULL
        CONSTRAINT DF_mensaje_chat_fecha_envio DEFAULT SYSUTCDATETIME(),

    fecha_recibido DATETIME2(0) NULL,
    fecha_leido DATETIME2(0) NULL,

    contenido NVARCHAR(1000) NOT NULL,

    url_adjunto VARCHAR(300) NULL,

    id_emisor INT NOT NULL,
    id_receptor INT NOT NULL,

    id_chat_cita BIGINT NOT NULL,

    CONSTRAINT PK_mensaje_chat PRIMARY KEY (id_mensaje_chat),

    CONSTRAINT FK_mensaje_chat_chat_cita
        FOREIGN KEY (id_chat_cita)
        REFERENCES dbo.chat_cita(id_chat_cita)
);
GO

-- =========================================================
-- ÍNDICES
-- Se crean para optimizar consultas frecuentes y joins.
-- =========================================================
CREATE INDEX IX_chat_cita_trabajador_cliente
ON dbo.chat_cita(id_trabajador, id_cliente);
GO

CREATE INDEX IX_chat_cita_id_cita
ON dbo.chat_cita(id_cita);
GO

CREATE INDEX IX_chat_cita_activo
ON dbo.chat_cita(activo);
GO

CREATE INDEX IX_mensaje_chat_chat_fecha
ON dbo.mensaje_chat(id_chat_cita, fecha_envio);
GO

CREATE INDEX IX_mensaje_chat_emisor
ON dbo.mensaje_chat(id_emisor, fecha_envio DESC);
GO

CREATE INDEX IX_notificacion_usuario_leida
ON dbo.notificacion(id_usuario_receptor, leida, fecha_creacion DESC);
GO

CREATE INDEX IX_reporte_usuario_tipo
ON dbo.reporte(id_usuario_emisor, id_tipo_reporte, fecha_creacion DESC);
GO

CREATE INDEX IX_mensaje_soporte_emisor_resuelto
ON dbo.mensaje_soporte(id_emisor, resuelto, fecha_envio DESC);
GO

-- =========================================================
-- REFERENCIAS LÓGICAS ENTRE MICROSERVICIOS
--
-- Estas relaciones no se implementan como FOREIGN KEY
-- porque pertenecen a otros microservicios y se busca
-- mantener desacoplamiento.
--
-- Referencias lógicas:
--
-- chat_cita.id_trabajador
-- chat_cita.id_cliente
-- mensaje_chat.id_emisor
-- mensaje_chat.id_receptor
-- notificacion.id_usuario_receptor
-- mensaje_soporte.id_emisor
-- reporte.id_usuario_emisor
--
-- Todos apuntan lógicamente a:
-- MS_Usuarios.dbo.usuario.id_usuario
--
-- chat_cita.id_cita apunta lógicamente a:
-- MS_Servicios.dbo.cita_servicio.id_cita
-- =========================================================
GO