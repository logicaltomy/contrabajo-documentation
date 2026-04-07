IF DB_ID(N'MS_Servicios') IS NULL
BEGIN
    CREATE DATABASE [MS_Servicios];
END;
GO

USE [MS_Servicios];
GO

IF OBJECT_ID(N'dbo.valoracion', N'U') IS NOT NULL DROP TABLE dbo.valoracion;
IF OBJECT_ID(N'dbo.historial_servicios', N'U') IS NOT NULL DROP TABLE dbo.historial_servicios;
IF OBJECT_ID(N'dbo.cita_servicio', N'U') IS NOT NULL DROP TABLE dbo.cita_servicio;
IF OBJECT_ID(N'dbo.oferta_servicio', N'U') IS NOT NULL DROP TABLE dbo.oferta_servicio;
IF OBJECT_ID(N'dbo.tipo_precio', N'U') IS NOT NULL DROP TABLE dbo.tipo_precio;
IF OBJECT_ID(N'dbo.categoria_servicio', N'U') IS NOT NULL DROP TABLE dbo.categoria_servicio;
IF OBJECT_ID(N'dbo.estado', N'U') IS NOT NULL DROP TABLE dbo.estado;
GO

CREATE TABLE dbo.estado (
    id_estado SMALLINT IDENTITY(1,1) NOT NULL,
    codigo VARCHAR(30) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100) NULL,
    CONSTRAINT PK_estado PRIMARY KEY (id_estado),
    CONSTRAINT UQ_estado_codigo UNIQUE (codigo),
    CONSTRAINT UQ_estado_nombre UNIQUE (nombre)
);
GO

CREATE TABLE dbo.categoria_servicio (
    id_cat_servicio INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    CONSTRAINT PK_categoria_servicio PRIMARY KEY (id_cat_servicio),
    CONSTRAINT UQ_categoria_servicio_nombre UNIQUE (nombre)
);
GO

CREATE TABLE dbo.tipo_precio (
    id_tipo_precio INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(20) NOT NULL,
    CONSTRAINT PK_tipo_precio PRIMARY KEY (id_tipo_precio),
    CONSTRAINT UQ_tipo_precio_nombre UNIQUE (nombre)
);
GO

CREATE TABLE dbo.oferta_servicio (
    id_oferta_servicio INT IDENTITY(1,1) NOT NULL,
    titulo VARCHAR(80) NOT NULL,
    descripcion VARCHAR(300) NOT NULL,
    detalle NVARCHAR(500) NULL,
    precio DECIMAL(12,2) NULL,
    disponible BIT NOT NULL CONSTRAINT DF_oferta_servicio_disponible DEFAULT 1,
    fecha_publicacion DATETIME2(0) NOT NULL CONSTRAINT DF_oferta_servicio_fecha_publicacion DEFAULT SYSUTCDATETIME(),
    id_cat_servicio INT NOT NULL,
    id_tipo_precio INT NULL,
    id_trabajador INT NOT NULL,
    id_cliente INT NULL,
    moneda CHAR(3) NOT NULL CONSTRAINT DF_oferta_servicio_moneda DEFAULT 'CLP',
    CONSTRAINT PK_oferta_servicio PRIMARY KEY (id_oferta_servicio),
    CONSTRAINT FK_oferta_servicio_categoria FOREIGN KEY (id_cat_servicio) REFERENCES dbo.categoria_servicio(id_cat_servicio),
    CONSTRAINT FK_oferta_servicio_tipo_precio FOREIGN KEY (id_tipo_precio) REFERENCES dbo.tipo_precio(id_tipo_precio),
    CONSTRAINT CK_oferta_servicio_precio CHECK (precio IS NULL OR precio >= 0)
);
GO

CREATE TABLE dbo.cita_servicio (
    id_cita INT IDENTITY(1,1) NOT NULL,
    comentario VARCHAR(200) NULL,
    precio_acordado DECIMAL(12,2) NULL,
    fecha_solicitud DATETIME2(0) NOT NULL CONSTRAINT DF_cita_servicio_fecha_solicitud DEFAULT SYSUTCDATETIME(),
    fecha_inicio_trabajo DATETIME2(0) NULL,
    fecha_fin_trabajo DATETIME2(0) NULL,
    cod_inicio INT NULL,
    cod_final INT NULL,
    id_oferta_servicio INT NOT NULL,
    id_coordenadas INT NULL,
    id_cat_servicio INT NOT NULL,
    id_trabajador INT NOT NULL,
    id_cliente INT NOT NULL,
    id_estado SMALLINT NOT NULL,
    CONSTRAINT PK_cita_servicio PRIMARY KEY (id_cita),
    CONSTRAINT FK_cita_servicio_oferta FOREIGN KEY (id_oferta_servicio) REFERENCES dbo.oferta_servicio(id_oferta_servicio),
    CONSTRAINT FK_cita_servicio_categoria FOREIGN KEY (id_cat_servicio) REFERENCES dbo.categoria_servicio(id_cat_servicio),
    CONSTRAINT FK_cita_servicio_estado FOREIGN KEY (id_estado) REFERENCES dbo.estado(id_estado),
    CONSTRAINT CK_cita_servicio_precio CHECK (precio_acordado IS NULL OR precio_acordado >= 0)
);
GO

CREATE TABLE dbo.historial_servicios (
    id_historial_servicios BIGINT IDENTITY(1,1) NOT NULL,
    fecha_historial_servicios DATETIME2(0) NOT NULL CONSTRAINT DF_historial_servicios_fecha DEFAULT SYSUTCDATETIME(),
    fecha_ultima_actividad DATETIME2(0) NULL,
    veces_disponible INT NOT NULL CONSTRAINT DF_historial_servicios_veces DEFAULT 0,
    promedio_tiempo_activo INT NOT NULL CONSTRAINT DF_historial_servicios_tiempo DEFAULT 0,
    total_vistas_servicio INT NOT NULL CONSTRAINT DF_historial_servicios_vistas DEFAULT 0,
    servicios_concretados INT NOT NULL CONSTRAINT DF_historial_servicios_concretados DEFAULT 0,
    servicios_cancelados INT NOT NULL CONSTRAINT DF_historial_servicios_cancelados DEFAULT 0,
    id_oferta_servicio INT NOT NULL,
    CONSTRAINT PK_historial_servicios PRIMARY KEY (id_historial_servicios),
    CONSTRAINT UQ_historial_servicios_oferta UNIQUE (id_oferta_servicio),
    CONSTRAINT FK_historial_servicios_oferta FOREIGN KEY (id_oferta_servicio) REFERENCES dbo.oferta_servicio(id_oferta_servicio)
);
GO

CREATE TABLE dbo.valoracion (
    id_valoracion BIGINT IDENTITY(1,1) NOT NULL,
    voto TINYINT NOT NULL,
    fecha_voto DATETIME2(0) NOT NULL CONSTRAINT DF_valoracion_fecha_voto DEFAULT SYSUTCDATETIME(),
    comentario VARCHAR(300) NULL,
    id_trabajador INT NOT NULL,
    id_cliente INT NOT NULL,
    id_cita INT NULL,
    CONSTRAINT PK_valoracion PRIMARY KEY (id_valoracion),
    CONSTRAINT FK_valoracion_cita FOREIGN KEY (id_cita) REFERENCES dbo.cita_servicio(id_cita),
    CONSTRAINT CK_valoracion_voto CHECK (voto BETWEEN 1 AND 5)
);
GO

CREATE INDEX IX_oferta_servicio_categoria ON dbo.oferta_servicio(id_cat_servicio);
CREATE INDEX IX_oferta_servicio_tipo_precio ON dbo.oferta_servicio(id_tipo_precio);
CREATE INDEX IX_oferta_servicio_trabajador ON dbo.oferta_servicio(id_trabajador, fecha_publicacion DESC);
CREATE INDEX IX_cita_servicio_oferta ON dbo.cita_servicio(id_oferta_servicio);
CREATE INDEX IX_cita_servicio_estado ON dbo.cita_servicio(id_estado, fecha_solicitud DESC);
CREATE INDEX IX_cita_servicio_cliente ON dbo.cita_servicio(id_cliente, fecha_solicitud DESC);
CREATE INDEX IX_historial_servicios_oferta ON dbo.historial_servicios(id_oferta_servicio);
CREATE INDEX IX_valoracion_trabajador ON dbo.valoracion(id_trabajador, fecha_voto DESC);
GO

/*
Referencias logicas cruzadas:
- oferta_servicio.id_trabajador e id_cliente apuntan logicamente a MS_Usuarios.dbo.usuario.id_usuario.
- cita_servicio.id_trabajador e id_cliente apuntan logicamente a MS_Usuarios.dbo.usuario.id_usuario.
- cita_servicio.id_coordenadas apunta logicamente a MS_Usuarios.dbo.coordenadas.id_coordenadas.
- valoracion.id_trabajador e id_cliente apuntan logicamente a MS_Usuarios.dbo.usuario.id_usuario.
*/
GO
