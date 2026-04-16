-- DROP en orden correcto (hijos → padres)
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

-- TABLAS BASE
CREATE TABLE dbo.tipo_perfil (
    id_tipo_perfil SMALLINT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(25) NOT NULL UNIQUE
);

CREATE TABLE dbo.region (
    id_region INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dbo.coordenadas (
    id_coordenadas INT IDENTITY(1,1) PRIMARY KEY,
    latitud DECIMAL(10,8) NOT NULL,
    longitud DECIMAL(11,8) NOT NULL,
    detalle VARCHAR(120) NULL
);

CREATE TABLE dbo.tipo_evento (
    id_tipo_evento SMALLINT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(25) NOT NULL UNIQUE
);

-- DEPENDENCIAS INTERMEDIAS
CREATE TABLE dbo.comuna (
    id_comuna INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL,
    id_region INT NOT NULL,
    CONSTRAINT UQ_comuna_region_nombre UNIQUE (id_region, nombre),
    FOREIGN KEY (id_region) REFERENCES dbo.region(id_region)
);

CREATE TABLE dbo.direccion (
    id_direccion INT IDENTITY(1,1) PRIMARY KEY,
    calle VARCHAR(80) NOT NULL,
    numero VARCHAR(10) NULL,
    id_comuna INT NOT NULL,
    id_coordenadas INT NULL,
    FOREIGN KEY (id_comuna) REFERENCES dbo.comuna(id_comuna),
    FOREIGN KEY (id_coordenadas) REFERENCES dbo.coordenadas(id_coordenadas)
);

-- TABLA PRINCIPAL
CREATE TABLE dbo.usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    run INT NOT NULL UNIQUE,
    dv VARCHAR(1) NOT NULL,
    username VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(70) NOT NULL,
    a_paterno VARCHAR(70) NOT NULL,
    a_materno VARCHAR(70) NOT NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(120) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    fecha_nacimiento DATE NOT NULL,
    verificado BIT NOT NULL DEFAULT 0,
    id_tipo_perfil SMALLINT NOT NULL,
    id_direccion INT NULL,

    -- ARQUITECTURA MICROSERVICIOS
    -- id_estado referencia lógica a MS_Servicios.estado(id_estado)
    -- No se implementa FK para mantener desacoplamiento entre microservicios
    id_estado INT NOT NULL,

    FOREIGN KEY (id_tipo_perfil) REFERENCES dbo.tipo_perfil(id_tipo_perfil),
    FOREIGN KEY (id_direccion) REFERENCES dbo.direccion(id_direccion)
);

-- TABLAS DEPENDIENTES
CREATE TABLE dbo.foto (
    id_foto INT IDENTITY(1,1) PRIMARY KEY,
    fecha_subida DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    enlace VARCHAR(300) NOT NULL,
    detalle VARCHAR(100) NULL,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

CREATE TABLE dbo.cedula_identidad (
    id_documento INT IDENTITY(1,1) PRIMARY KEY,
    nro_documento VARCHAR(20) NOT NULL UNIQUE,
    run_documento INT NULL,
    dv_documento VARCHAR(1) NULL,
    fecha_nacimiento_documento DATE NULL,
    id_usuario INT NOT NULL UNIQUE,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

CREATE TABLE dbo.historial_usuario (
    id_historial_usuario BIGINT IDENTITY(1,1) PRIMARY KEY,
    fecha_ultima_conexion DATETIME2(0) NULL,
    cantidad_conexiones INT NOT NULL DEFAULT 0,
    total_vistas_perfil INT NOT NULL DEFAULT 0,
    ultimo_dispositivo VARCHAR(100) NULL,
    id_usuario INT NOT NULL UNIQUE,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

CREATE TABLE dbo.log_actividad (
    id_log BIGINT IDENTITY(1,1) PRIMARY KEY,
    fecha_evento DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    entidad_afectada VARCHAR(100) NOT NULL,
    entidad_id BIGINT NULL,
    ip_direccion VARCHAR(45) NULL,
    dispositivo VARCHAR(120) NULL,
    url_pantalla VARCHAR(300) NULL,
    duracion_segundos INT NULL CHECK (duracion_segundos >= 0),
    id_usuario INT NULL,
    id_tipo_evento SMALLINT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario),
    FOREIGN KEY (id_tipo_evento) REFERENCES dbo.tipo_evento(id_tipo_evento)
);

CREATE TABLE dbo.sesion_usuario (
    id_sesion_usuario BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    fecha_inicio DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    fecha_expiracion DATETIME2(0) NOT NULL,
    fecha_ultimo_acceso DATETIME2(0) NULL,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

CREATE TABLE dbo.verificacion_cuenta (
    id_verificacion BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    codigo_hash VARCHAR(255) NOT NULL,
    canal VARCHAR(20) NOT NULL CHECK (canal IN ('correo', 'sms')),
    fecha_creacion DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    fecha_expiracion DATETIME2(0) NOT NULL,
    fecha_verificacion DATETIME2(0) NULL,
    usada BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

CREATE TABLE dbo.recuperacion_cuenta (
    id_recuperacion BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    codigo_hash VARCHAR(255) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    fecha_expiracion DATETIME2(0) NOT NULL,
    fecha_uso DATETIME2(0) NULL,
    usada BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

-- ÍNDICES
CREATE INDEX IX_usuario_tipo_perfil ON dbo.usuario(id_tipo_perfil);
CREATE INDEX IX_usuario_direccion ON dbo.usuario(id_direccion);
CREATE INDEX IX_foto_usuario ON dbo.foto(id_usuario);
CREATE INDEX IX_log_actividad_usuario_fecha ON dbo.log_actividad(id_usuario, fecha_evento DESC);
CREATE INDEX IX_log_actividad_tipo_evento_fecha ON dbo.log_actividad(id_tipo_evento, fecha_evento DESC);
CREATE INDEX IX_verificacion_cuenta_usuario ON dbo.verificacion_cuenta(id_usuario, usada);
CREATE INDEX IX_recuperacion_cuenta_usuario ON dbo.recuperacion_cuenta(id_usuario, usada);