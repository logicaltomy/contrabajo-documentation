-- =========================================================
-- ELIMINACIÓN DE TABLAS EN ORDEN CORRECTO (HIJOS → PADRES)
-- =========================================================
IF OBJECT_ID(N'dbo.mensaje_chat', N'U') IS NOT NULL DROP TABLE dbo.mensaje_chat;
IF OBJECT_ID(N'dbo.reporte', N'U') IS NOT NULL DROP TABLE dbo.reporte;
IF OBJECT_ID(N'dbo.notificacion', N'U') IS NOT NULL DROP TABLE dbo.notificacion;
IF OBJECT_ID(N'dbo.mensaje_soporte', N'U') IS NOT NULL DROP TABLE dbo.mensaje_soporte;
IF OBJECT_ID(N'dbo.chat_oferta', N'U') IS NOT NULL DROP TABLE dbo.chat_oferta;
IF OBJECT_ID(N'dbo.tipo_reporte', N'U') IS NOT NULL DROP TABLE dbo.tipo_reporte;

-- =========================================================
-- TABLA: TIPO_REPORTE
-- =========================================================
CREATE TABLE dbo.tipo_reporte (
    id_tipo_reporte INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,

    CONSTRAINT PK_tipo_reporte PRIMARY KEY (id_tipo_reporte),
    CONSTRAINT UQ_tipo_reporte_nombre UNIQUE (nombre)
);

-- =========================================================
-- TABLA: CHAT_OFERTA
-- =========================================================
CREATE TABLE dbo.chat_oferta (
    id_chat_oferta BIGINT IDENTITY(1,1) NOT NULL,

    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_chat_oferta_fecha_creacion DEFAULT SYSUTCDATETIME(),

    id_trabajador INT NOT NULL,
    id_cliente INT NOT NULL,

    -- Referencia lógica a MS_Servicios.dbo.oferta_servicio.id_oferta_servicio
    id_oferta_servicio INT NOT NULL,

    -- NUEVO: referencia opcional a cita
    -- Puede ser NULL porque no todo chat genera una cita
    -- Referencia lógica a MS_Servicios.dbo.cita_servicio.id_cita
    id_cita INT NULL,

    activo BIT NOT NULL
        CONSTRAINT DF_chat_oferta_activo DEFAULT 1,

    CONSTRAINT PK_chat_oferta PRIMARY KEY (id_chat_oferta)
);

-- =========================================================
-- TABLA: MENSAJE_SOPORTE
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

-- =========================================================
-- TABLA: NOTIFICACION
-- =========================================================
CREATE TABLE dbo.notificacion (
    id_notificacion BIGINT IDENTITY(1,1) NOT NULL,

    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_notificacion_fecha_creacion DEFAULT SYSUTCDATETIME(),

    detalle NVARCHAR(200) NOT NULL,
    id_usuario_receptor INT NOT NULL,

    leida BIT NOT NULL
        CONSTRAINT DF_notificacion_leida DEFAULT 0,

    url_destino VARCHAR(300) NULL,

    CONSTRAINT PK_notificacion PRIMARY KEY (id_notificacion)
);

-- =========================================================
-- TABLA: REPORTE
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

-- =========================================================
-- TABLA: MENSAJE_CHAT
-- =========================================================
CREATE TABLE dbo.mensaje_chat (
    id_mensaje_chat BIGINT IDENTITY(1,1) NOT NULL,

    fecha_envio DATETIME2(0) NOT NULL
        CONSTRAINT DF_mensaje_chat_fecha_envio DEFAULT SYSUTCDATETIME(),

    fecha_recibido DATETIME2(0) NULL,
    fecha_leido DATETIME2(0) NULL,

    contenido NVARCHAR(1000) NOT NULL,

    id_emisor INT NOT NULL,
    id_receptor INT NOT NULL,

    id_chat_oferta BIGINT NOT NULL,

    CONSTRAINT PK_mensaje_chat PRIMARY KEY (id_mensaje_chat),

    CONSTRAINT FK_mensaje_chat_chat_oferta
        FOREIGN KEY (id_chat_oferta)
        REFERENCES dbo.chat_oferta(id_chat_oferta)
);

-- =========================================================
-- ÍNDICES
-- =========================================================
CREATE INDEX IX_chat_oferta_trabajador_cliente
ON dbo.chat_oferta(id_trabajador, id_cliente);

CREATE INDEX IX_chat_oferta_oferta
ON dbo.chat_oferta(id_oferta_servicio);

-- 🔹 Opcional pero recomendado ahora que existe id_cita
CREATE INDEX IX_chat_oferta_cita
ON dbo.chat_oferta(id_cita);

CREATE INDEX IX_chat_oferta_activo
ON dbo.chat_oferta(activo);

CREATE INDEX IX_mensaje_chat_chat_fecha
ON dbo.mensaje_chat(id_chat_oferta, fecha_envio);

CREATE INDEX IX_mensaje_chat_emisor
ON dbo.mensaje_chat(id_emisor, fecha_envio DESC);

CREATE INDEX IX_notificacion_usuario_leida
ON dbo.notificacion(id_usuario_receptor, leida, fecha_creacion DESC);

CREATE INDEX IX_reporte_usuario_tipo
ON dbo.reporte(id_usuario_emisor, id_tipo_reporte, fecha_creacion DESC);

CREATE INDEX IX_mensaje_soporte_emisor_resuelto
ON dbo.mensaje_soporte(id_emisor, resuelto, fecha_envio DESC);

-- =========================================================
-- REFERENCIAS LÓGICAS ENTRE MICROSERVICIOS
-- =========================================================
-- chat_oferta.id_trabajador
-- chat_oferta.id_cliente
-- mensaje_chat.id_emisor
-- mensaje_chat.id_receptor
-- notificacion.id_usuario_receptor
-- mensaje_soporte.id_emisor
-- reporte.id_usuario_emisor
--
-- → MS_Usuarios.dbo.usuario.id_usuario
--
-- chat_oferta.id_oferta_servicio → MS_Servicios.dbo.oferta_servicio.id_oferta_servicio
-- chat_oferta.id_cita → MS_Servicios.dbo.cita_servicio.id_cita