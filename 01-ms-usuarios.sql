IF DB_ID(N'MS_Usuarios') IS NULL
BEGIN
    CREATE DATABASE [MS_Usuarios];
END;
GO

USE [MS_Usuarios];
GO

IF OBJECT_ID(N'dbo.recuperacion_cuenta', N'U') IS NOT NULL DROP TABLE dbo.recuperacion_cuenta;
IF OBJECT_ID(N'dbo.verificacion_cuenta', N'U') IS NOT NULL DROP TABLE dbo.verificacion_cuenta;
IF OBJECT_ID(N'dbo.sesion_usuario', N'U') IS NOT NULL DROP TABLE dbo.sesion_usuario;
IF OBJECT_ID(N'dbo.log_actividad', N'U') IS NOT NULL DROP TABLE dbo.log_actividad;
IF OBJECT_ID(N'dbo.historial_usuario', N'U') IS NOT NULL DROP TABLE dbo.historial_usuario;
IF OBJECT_ID(N'dbo.cedula_identidad', N'U') IS NOT NULL DROP TABLE dbo.cedula_identidad;
IF OBJECT_ID(N'dbo.foto', N'U') IS NOT NULL DROP TABLE dbo.foto;
IF OBJECT_ID(N'dbo.usuario', N'U') IS NOT NULL DROP TABLE dbo.usuario;
IF OBJECT_ID(N'dbo.direccion', N'U') IS NOT NULL DROP TABLE dbo.direccion;
IF OBJECT_ID(N'dbo.comuna', N'U') IS NOT NULL DROP TABLE dbo.comuna;
IF OBJECT_ID(N'dbo.region', N'U') IS NOT NULL DROP TABLE dbo.region;
IF OBJECT_ID(N'dbo.coordenadas', N'U') IS NOT NULL DROP TABLE dbo.coordenadas;
IF OBJECT_ID(N'dbo.tipo_evento', N'U') IS NOT NULL DROP TABLE dbo.tipo_evento;
IF OBJECT_ID(N'dbo.tipo_perfil', N'U') IS NOT NULL DROP TABLE dbo.tipo_perfil;
GO

CREATE TABLE dbo.tipo_perfil (
    id_tipo_perfil SMALLINT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(25) NOT NULL,
    CONSTRAINT PK_tipo_perfil PRIMARY KEY (id_tipo_perfil),
    CONSTRAINT UQ_tipo_perfil_nombre UNIQUE (nombre)
);
GO

CREATE TABLE dbo.region (
    id_region INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    CONSTRAINT PK_region PRIMARY KEY (id_region),
    CONSTRAINT UQ_region_nombre UNIQUE (nombre)
);
GO

CREATE TABLE dbo.comuna (
    id_comuna INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    id_region INT NOT NULL,
    CONSTRAINT PK_comuna PRIMARY KEY (id_comuna),
    CONSTRAINT UQ_comuna_region_nombre UNIQUE (id_region, nombre),
    CONSTRAINT FK_comuna_region FOREIGN KEY (id_region) REFERENCES dbo.region(id_region)
);
GO

CREATE TABLE dbo.coordenadas (
    id_coordenadas INT IDENTITY(1,1) NOT NULL,
    latitud DECIMAL(10,8) NOT NULL,
    longitud DECIMAL(11,8) NOT NULL,
    detalle VARCHAR(120) NULL,
    CONSTRAINT PK_coordenadas PRIMARY KEY (id_coordenadas)
);
GO

CREATE TABLE dbo.direccion (
    id_direccion INT IDENTITY(1,1) NOT NULL,
    calle VARCHAR(80) NOT NULL,
    numero VARCHAR(10) NULL,
    villa VARCHAR(80) NULL,
    id_comuna INT NOT NULL,
    id_coordenadas INT NULL,
    CONSTRAINT PK_direccion PRIMARY KEY (id_direccion),
    CONSTRAINT FK_direccion_comuna FOREIGN KEY (id_comuna) REFERENCES dbo.comuna(id_comuna),
    CONSTRAINT FK_direccion_coordenadas FOREIGN KEY (id_coordenadas) REFERENCES dbo.coordenadas(id_coordenadas)
);
GO

CREATE TABLE dbo.tipo_evento (
    id_tipo_evento SMALLINT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(25) NOT NULL,
    CONSTRAINT PK_tipo_evento PRIMARY KEY (id_tipo_evento),
    CONSTRAINT UQ_tipo_evento_nombre UNIQUE (nombre)
);
GO

CREATE TABLE dbo.usuario (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    run VARCHAR(12) NOT NULL,
    dv VARCHAR(2) NOT NULL,
    username VARCHAR(30) NOT NULL,
    nombre VARCHAR(70) NOT NULL,
    a_paterno VARCHAR(70) NOT NULL,
    a_materno VARCHAR(70) NOT NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(120) NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    fecha_registro DATETIME2(0) NOT NULL CONSTRAINT DF_usuario_fecha_registro DEFAULT SYSUTCDATETIME(),
    fecha_nacimiento DATE NOT NULL,
    verificado BIT NOT NULL CONSTRAINT DF_usuario_verificado DEFAULT 0,
    id_tipo_perfil SMALLINT NOT NULL,
    id_direccion INT NULL,
    CONSTRAINT PK_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT UQ_usuario_run UNIQUE (run),
    CONSTRAINT UQ_usuario_username UNIQUE (username),
    CONSTRAINT UQ_usuario_correo UNIQUE (correo),
    CONSTRAINT FK_usuario_tipo_perfil FOREIGN KEY (id_tipo_perfil) REFERENCES dbo.tipo_perfil(id_tipo_perfil),
    CONSTRAINT FK_usuario_direccion FOREIGN KEY (id_direccion) REFERENCES dbo.direccion(id_direccion)
);
GO

CREATE TABLE dbo.foto (
    id_foto INT IDENTITY(1,1) NOT NULL,
    fecha_subida DATETIME2(0) NOT NULL CONSTRAINT DF_foto_fecha_subida DEFAULT SYSUTCDATETIME(),
    enlace VARCHAR(300) NOT NULL,
    detalle VARCHAR(100) NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT PK_foto PRIMARY KEY (id_foto),
    CONSTRAINT FK_foto_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);
GO

CREATE TABLE dbo.cedula_identidad (
    id_documento INT IDENTITY(1,1) NOT NULL,
    nro_documento VARCHAR(20) NOT NULL,
    run VARCHAR(12) NULL,
    fecha_nacimiento DATE NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT PK_cedula_identidad PRIMARY KEY (id_documento),
    CONSTRAINT UQ_cedula_identidad_usuario UNIQUE (id_usuario),
    CONSTRAINT UQ_cedula_identidad_numero UNIQUE (nro_documento),
    CONSTRAINT FK_cedula_identidad_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);
GO

CREATE TABLE dbo.historial_usuario (
    id_historial_usuario BIGINT IDENTITY(1,1) NOT NULL,
    fecha_historial_usuario DATETIME2(0) NOT NULL CONSTRAINT DF_historial_usuario_fecha DEFAULT SYSUTCDATETIME(),
    fecha_ultima_conexion DATETIME2(0) NULL,
    cantidad_conexiones INT NOT NULL CONSTRAINT DF_historial_usuario_conexiones DEFAULT 0,
    total_vistas_perfil INT NOT NULL CONSTRAINT DF_historial_usuario_vistas DEFAULT 0,
    promedio_tiempo_sesion INT NOT NULL CONSTRAINT DF_historial_usuario_tiempo DEFAULT 0,
    nivel_actividad VARCHAR(20) NULL,
    ultimo_dispositivo VARCHAR(100) NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT PK_historial_usuario PRIMARY KEY (id_historial_usuario),
    CONSTRAINT UQ_historial_usuario_usuario UNIQUE (id_usuario),
    CONSTRAINT FK_historial_usuario_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);
GO

CREATE TABLE dbo.log_actividad (
    id_log BIGINT IDENTITY(1,1) NOT NULL,
    fecha_evento DATETIME2(0) NOT NULL CONSTRAINT DF_log_actividad_fecha DEFAULT SYSUTCDATETIME(),
    entidad_afectada VARCHAR(100) NOT NULL,
    entidad_id BIGINT NULL,
    ip_direccion VARCHAR(45) NULL,
    dispositivo VARCHAR(120) NULL,
    url_pantalla VARCHAR(300) NULL,
    duracion_segundos INT NULL,
    id_usuario INT NULL,
    id_tipo_evento SMALLINT NOT NULL,
    CONSTRAINT PK_log_actividad PRIMARY KEY (id_log),
    CONSTRAINT FK_log_actividad_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario),
    CONSTRAINT FK_log_actividad_tipo_evento FOREIGN KEY (id_tipo_evento) REFERENCES dbo.tipo_evento(id_tipo_evento),
    CONSTRAINT CK_log_actividad_duracion CHECK (duracion_segundos IS NULL OR duracion_segundos >= 0)
);
GO

CREATE TABLE dbo.sesion_usuario (
    id_sesion_usuario BIGINT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    fecha_inicio DATETIME2(0) NOT NULL CONSTRAINT DF_sesion_usuario_inicio DEFAULT SYSUTCDATETIME(),
    fecha_expiracion DATETIME2(0) NOT NULL,
    fecha_ultimo_acceso DATETIME2(0) NULL,
    ip_creacion VARCHAR(45) NULL,
    dispositivo VARCHAR(120) NULL,
    activa BIT NOT NULL CONSTRAINT DF_sesion_usuario_activa DEFAULT 1,
    CONSTRAINT PK_sesion_usuario PRIMARY KEY (id_sesion_usuario),
    CONSTRAINT UQ_sesion_usuario_token_hash UNIQUE (token_hash),
    CONSTRAINT FK_sesion_usuario_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);
GO

CREATE TABLE dbo.verificacion_cuenta (
    id_verificacion BIGINT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    codigo_hash VARCHAR(255) NOT NULL,
    canal VARCHAR(20) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL CONSTRAINT DF_verificacion_cuenta_creacion DEFAULT SYSUTCDATETIME(),
    fecha_expiracion DATETIME2(0) NOT NULL,
    fecha_verificacion DATETIME2(0) NULL,
    usada BIT NOT NULL CONSTRAINT DF_verificacion_cuenta_usada DEFAULT 0,
    CONSTRAINT PK_verificacion_cuenta PRIMARY KEY (id_verificacion),
    CONSTRAINT FK_verificacion_cuenta_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario),
    CONSTRAINT CK_verificacion_cuenta_canal CHECK (canal IN ('correo', 'sms'))
);
GO

CREATE TABLE dbo.recuperacion_cuenta (
    id_recuperacion BIGINT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    codigo_hash VARCHAR(255) NOT NULL,
    canal VARCHAR(20) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL CONSTRAINT DF_recuperacion_cuenta_creacion DEFAULT SYSUTCDATETIME(),
    fecha_expiracion DATETIME2(0) NOT NULL,
    fecha_uso DATETIME2(0) NULL,
    usada BIT NOT NULL CONSTRAINT DF_recuperacion_cuenta_usada DEFAULT 0,
    CONSTRAINT PK_recuperacion_cuenta PRIMARY KEY (id_recuperacion),
    CONSTRAINT FK_recuperacion_cuenta_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario),
    CONSTRAINT CK_recuperacion_cuenta_canal CHECK (canal IN ('correo', 'sms'))
);
GO

CREATE INDEX IX_usuario_tipo_perfil ON dbo.usuario(id_tipo_perfil);
CREATE INDEX IX_usuario_direccion ON dbo.usuario(id_direccion);
CREATE INDEX IX_foto_usuario ON dbo.foto(id_usuario);
CREATE INDEX IX_log_actividad_usuario_fecha ON dbo.log_actividad(id_usuario, fecha_evento DESC);
CREATE INDEX IX_log_actividad_tipo_evento_fecha ON dbo.log_actividad(id_tipo_evento, fecha_evento DESC);
CREATE INDEX IX_sesion_usuario_usuario_activa ON dbo.sesion_usuario(id_usuario, activa);
CREATE INDEX IX_verificacion_cuenta_usuario ON dbo.verificacion_cuenta(id_usuario, usada);
CREATE INDEX IX_recuperacion_cuenta_usuario ON dbo.recuperacion_cuenta(id_usuario, usada);
GO

/*
Referencias logicas cruzadas:
- log_actividad.entidad_afectada + entidad_id puede apuntar a ofertas, citas o chats de otros microservicios.
- No se crean FKs entre bases para mantener autonomia por microservicio.
*/
GO
