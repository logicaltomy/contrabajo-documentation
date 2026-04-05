IF DB_ID(N'MS_Comunicaciones') IS NULL
BEGIN
    CREATE DATABASE [MS_Comunicaciones];
END;
GO

USE [MS_Comunicaciones];
GO

IF OBJECT_ID(N'dbo.mensaje_chat', N'U') IS NOT NULL DROP TABLE dbo.mensaje_chat;
IF OBJECT_ID(N'dbo.reporte', N'U') IS NOT NULL DROP TABLE dbo.reporte;
IF OBJECT_ID(N'dbo.notificacion', N'U') IS NOT NULL DROP TABLE dbo.notificacion;
IF OBJECT_ID(N'dbo.mensaje_soporte', N'U') IS NOT NULL DROP TABLE dbo.mensaje_soporte;
IF OBJECT_ID(N'dbo.chat_cita', N'U') IS NOT NULL DROP TABLE dbo.chat_cita;
IF OBJECT_ID(N'dbo.tipo_reporte', N'U') IS NOT NULL DROP TABLE dbo.tipo_reporte;
GO

CREATE TABLE dbo.tipo_reporte (
    id_tipo_reporte INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    detalle VARCHAR(200) NULL,
    CONSTRAINT PK_tipo_reporte PRIMARY KEY (id_tipo_reporte),
    CONSTRAINT UQ_tipo_reporte_nombre UNIQUE (nombre)
);
GO

CREATE TABLE dbo.chat_cita (
    id_chat_cita BIGINT IDENTITY(1,1) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL CONSTRAINT DF_chat_cita_fecha_creacion DEFAULT SYSUTCDATETIME(),
    id_trabajador INT NOT NULL,
    id_cliente INT NOT NULL,
    id_cita INT NULL,
    CONSTRAINT PK_chat_cita PRIMARY KEY (id_chat_cita)
);
GO

CREATE TABLE dbo.mensaje_soporte (
    id_mensaje_soporte INT IDENTITY(1,1) NOT NULL,
    asunto VARCHAR(80) NOT NULL,
    detalle NVARCHAR(500) NOT NULL,
    fecha_envio DATETIME2(0) NOT NULL CONSTRAINT DF_mensaje_soporte_fecha_envio DEFAULT SYSUTCDATETIME(),
    fecha_resolucion DATETIME2(0) NULL,
    id_emisor INT NOT NULL,
    id_estado SMALLINT NOT NULL,
    CONSTRAINT PK_mensaje_soporte PRIMARY KEY (id_mensaje_soporte)
);
GO

CREATE TABLE dbo.notificacion (
    id_notificacion BIGINT IDENTITY(1,1) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL CONSTRAINT DF_notificacion_fecha_creacion DEFAULT SYSUTCDATETIME(),
    detalle NVARCHAR(200) NOT NULL,
    id_usuario_receptor INT NOT NULL,
    leida BIT NOT NULL CONSTRAINT DF_notificacion_leida DEFAULT 0,
    url_destino VARCHAR(300) NULL,
    CONSTRAINT PK_notificacion PRIMARY KEY (id_notificacion)
);
GO

CREATE TABLE dbo.reporte (
    id_reporte BIGINT IDENTITY(1,1) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL CONSTRAINT DF_reporte_fecha_creacion DEFAULT SYSUTCDATETIME(),
    descripcion_reporte NVARCHAR(500) NOT NULL,
    funcion_asociada VARCHAR(50) NULL,
    id_usuario_emisor INT NOT NULL,
    id_tipo_reporte INT NOT NULL,
    entidad_reportada VARCHAR(100) NULL,
    entidad_id BIGINT NULL,
    CONSTRAINT PK_reporte PRIMARY KEY (id_reporte),
    CONSTRAINT FK_reporte_tipo_reporte FOREIGN KEY (id_tipo_reporte) REFERENCES dbo.tipo_reporte(id_tipo_reporte)
);
GO

CREATE TABLE dbo.mensaje_chat (
    id_mensaje_chat BIGINT IDENTITY(1,1) NOT NULL,
    fecha_envio DATETIME2(0) NOT NULL CONSTRAINT DF_mensaje_chat_fecha_envio DEFAULT SYSUTCDATETIME(),
    fecha_recibido DATETIME2(0) NULL,
    fecha_leido DATETIME2(0) NULL,
    contenido NVARCHAR(1000) NOT NULL,
    id_emisor INT NOT NULL,
    id_receptor INT NOT NULL,
    id_chat_cita BIGINT NOT NULL,
    id_estado SMALLINT NOT NULL,
    CONSTRAINT PK_mensaje_chat PRIMARY KEY (id_mensaje_chat),
    CONSTRAINT FK_mensaje_chat_chat_cita FOREIGN KEY (id_chat_cita) REFERENCES dbo.chat_cita(id_chat_cita)
);
GO

CREATE INDEX IX_chat_cita_trabajador_cliente ON dbo.chat_cita(id_trabajador, id_cliente);
CREATE INDEX IX_chat_cita_id_cita ON dbo.chat_cita(id_cita);
CREATE INDEX IX_mensaje_chat_chat_fecha ON dbo.mensaje_chat(id_chat_cita, fecha_envio);
CREATE INDEX IX_mensaje_chat_emisor ON dbo.mensaje_chat(id_emisor, fecha_envio DESC);
CREATE INDEX IX_notificacion_usuario_leida ON dbo.notificacion(id_usuario_receptor, leida, fecha_creacion DESC);
CREATE INDEX IX_reporte_usuario_tipo ON dbo.reporte(id_usuario_emisor, id_tipo_reporte, fecha_creacion DESC);
CREATE INDEX IX_mensaje_soporte_emisor_estado ON dbo.mensaje_soporte(id_emisor, id_estado, fecha_envio DESC);
GO

/*
Referencias logicas cruzadas:
- chat_cita.id_trabajador, id_cliente, mensaje_chat.id_emisor, id_receptor,
  notificacion.id_usuario_receptor, mensaje_soporte.id_emisor y reporte.id_usuario_emisor
  apuntan logicamente a MS_Usuarios.dbo.usuario.id_usuario.
- chat_cita.id_cita apunta logicamente a MS_Servicios.dbo.cita_servicio.id_cita.
- mensaje_chat.id_estado y mensaje_soporte.id_estado apuntan logicamente a MS_Servicios.dbo.estado.id_estado.
*/
GO
