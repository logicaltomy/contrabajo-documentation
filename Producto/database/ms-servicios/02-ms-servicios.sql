-- =========================================================
-- BASE DE DATOS
-- =========================================================
USE master;
GO
IF DB_ID(N'MS_Servicios') IS NOT NULL
BEGIN
    ALTER DATABASE MS_Servicios SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MS_Servicios;
END
GO
CREATE DATABASE MS_Servicios;
GO
USE MS_Servicios;
GO

-- DROP en orden correcto (hijos → padres)
IF OBJECT_ID(N'dbo.foto', N'U') IS NOT NULL DROP TABLE dbo.foto;
IF OBJECT_ID(N'dbo.valoracion', N'U') IS NOT NULL DROP TABLE dbo.valoracion;
IF OBJECT_ID(N'dbo.cita_servicio', N'U') IS NOT NULL DROP TABLE dbo.cita_servicio;
IF OBJECT_ID(N'dbo.oferta_servicio', N'U') IS NOT NULL DROP TABLE dbo.oferta_servicio;
IF OBJECT_ID(N'dbo.tipo_precio', N'U') IS NOT NULL DROP TABLE dbo.tipo_precio;
IF OBJECT_ID(N'dbo.categoria_servicio', N'U') IS NOT NULL DROP TABLE dbo.categoria_servicio;
IF OBJECT_ID(N'dbo.estado', N'U') IS NOT NULL DROP TABLE dbo.estado;

-- TABLAS BASE
CREATE TABLE dbo.estado (
    id_estado SMALLINT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(100) NULL
);

CREATE TABLE dbo.categoria_servicio (
    id_cat_servicio INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE dbo.tipo_precio (
    id_tipo_precio INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

-- TABLA PRINCIPAL
CREATE TABLE dbo.oferta_servicio (
    id_oferta_servicio INT IDENTITY(1,1) PRIMARY KEY,
    titulo VARCHAR(80) NOT NULL,
    descripcion VARCHAR(300) NOT NULL,
    precio DECIMAL(12,2) NULL,
    disponible BIT NOT NULL DEFAULT 1,
    borrado BIT NOT NULL DEFAULT 0,
    fecha_publicacion DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    id_cat_servicio INT NOT NULL,
    id_tipo_precio INT NULL,

    -- Referencia lógica a MS_Usuarios.dbo.usuario.id_usuario
    id_trabajador INT NOT NULL,

    -- Referencia lógica a MS_Usuarios.dbo.usuario.id_usuario
    id_cliente INT NULL,

    FOREIGN KEY (id_cat_servicio) REFERENCES dbo.categoria_servicio(id_cat_servicio),
    FOREIGN KEY (id_tipo_precio) REFERENCES dbo.tipo_precio(id_tipo_precio),
    CONSTRAINT CK_oferta_servicio_precio CHECK (precio IS NULL OR precio >= 0)
);

CREATE TABLE dbo.cita_servicio (
    id_cita INT IDENTITY(1,1) PRIMARY KEY,
    comentario VARCHAR(200) NULL,
    precio_acordado DECIMAL(12,2) NULL,
    fecha_solicitud DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    fecha_inicio_trabajo DATETIME2(0) NULL,
    fecha_fin_trabajo DATETIME2(0) NULL,
    cod_inicio INT NULL,
    cod_final INT NULL,

    id_oferta_servicio INT NOT NULL,

    -- Referencia lógica a MS_Usuarios.dbo.coordenadas.id_coordenadas
    id_coordenadas INT NULL,

    id_cat_servicio INT NOT NULL,

    -- Referencia lógica a MS_Usuarios.dbo.usuario.id_usuario
    id_trabajador INT NOT NULL,

    -- Referencia lógica a MS_Usuarios.dbo.usuario.id_usuario
    id_cliente INT NOT NULL,

    id_estado SMALLINT NOT NULL,

    FOREIGN KEY (id_oferta_servicio) REFERENCES dbo.oferta_servicio(id_oferta_servicio),
    FOREIGN KEY (id_cat_servicio) REFERENCES dbo.categoria_servicio(id_cat_servicio),
    FOREIGN KEY (id_estado) REFERENCES dbo.estado(id_estado),
    CONSTRAINT CK_cita_servicio_precio CHECK (precio_acordado IS NULL OR precio_acordado >= 0)
);

CREATE TABLE dbo.valoracion (
    id_valoracion BIGINT IDENTITY(1,1) PRIMARY KEY,
    voto TINYINT NOT NULL,
    fecha_voto DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    comentario VARCHAR(300) NULL,

    -- Referencia lógica a MS_Usuarios.dbo.usuario.id_usuario
    id_trabajador INT NOT NULL,

    -- Referencia lógica a MS_Usuarios.dbo.usuario.id_usuario
    id_cliente INT NOT NULL,

    id_cita INT NULL,

    FOREIGN KEY (id_cita) REFERENCES dbo.cita_servicio(id_cita),
    CONSTRAINT CK_valoracion_voto CHECK (voto BETWEEN 1 AND 5)
);

-- =========================================================
-- TABLA: FOTO
-- Almacena metadatos de imágenes asociadas a una oferta.
--
-- El archivo físico se guarda en el sistema de ficheros local
-- del microservicio (a futuro en un contenedor/bucket aparte).
--
-- nombre_original : nombre del fichero tal como lo envió el cliente.
-- nombre_archivo  : nombre único en disco (UUID + extensión).
-- enlace          : ruta relativa pública para servir la imagen,
--                   p.ej.  /fotos/a1b2c3d4-....jpg
-- tipo_mime       : MIME del fichero (image/jpeg, image/png, …).
-- tamano_bytes    : peso del fichero en bytes.
-- ancho_px / alto_px : dimensiones opcionales en píxeles.
--
-- id_usuario es referencia lógica a MS_Usuarios.dbo.usuario
-- (no se puede declarar FK física entre bases de datos distintas).
-- =========================================================
CREATE TABLE dbo.foto (
    id_foto            INT IDENTITY(1,1) PRIMARY KEY,
    fecha_subida       DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),

    -- Metadatos del fichero
    nombre_original    VARCHAR(255)  NOT NULL,
    nombre_archivo     VARCHAR(100)  NOT NULL UNIQUE,
    enlace             VARCHAR(300)  NOT NULL,
    tipo_mime          VARCHAR(50)   NOT NULL,
    tamano_bytes       BIGINT        NOT NULL,
    ancho_px           INT           NULL,
    alto_px            INT           NULL,

    id_oferta_servicio INT           NOT NULL,

    -- Referencia lógica a MS_Usuarios.dbo.usuario.id_usuario
    id_usuario         INT           NOT NULL,

    FOREIGN KEY (id_oferta_servicio) REFERENCES dbo.oferta_servicio(id_oferta_servicio),
    CONSTRAINT CK_foto_tamano CHECK (tamano_bytes > 0),
    CONSTRAINT CK_foto_mime   CHECK (tipo_mime LIKE 'image/%')
);

-- ÍNDICES
CREATE INDEX IX_oferta_servicio_categoria ON dbo.oferta_servicio(id_cat_servicio);
CREATE INDEX IX_oferta_servicio_tipo_precio ON dbo.oferta_servicio(id_tipo_precio);
CREATE INDEX IX_oferta_servicio_trabajador ON dbo.oferta_servicio(id_trabajador, fecha_publicacion DESC);

CREATE INDEX IX_cita_servicio_oferta ON dbo.cita_servicio(id_oferta_servicio);
CREATE INDEX IX_cita_servicio_estado ON dbo.cita_servicio(id_estado, fecha_solicitud DESC);
CREATE INDEX IX_cita_servicio_cliente ON dbo.cita_servicio(id_cliente, fecha_solicitud DESC);

CREATE INDEX IX_valoracion_trabajador ON dbo.valoracion(id_trabajador, fecha_voto DESC);

CREATE INDEX IX_foto_oferta ON dbo.foto(id_oferta_servicio);
CREATE INDEX IX_foto_usuario ON dbo.foto(id_usuario);

-- Referencias lógicas cruzadas entre microservicios
-- oferta_servicio.id_trabajador e id_cliente → MS_Usuarios.dbo.usuario.id_usuario
-- cita_servicio.id_trabajador e id_cliente → MS_Usuarios.dbo.usuario.id_usuario
-- cita_servicio.id_coordenadas → MS_Usuarios.dbo.coordenadas.id_coordenadas
-- valoracion.id_trabajador e id_cliente → MS_Usuarios.dbo.usuario.id_usuario
-- foto.id_usuario → MS_Usuarios.dbo.usuario.id_usuario

-- =========================================================
-- ACCESO DE APLICACIÓN
-- Mapea el login de servidor 'admincontrabajo' como usuario
-- dentro de esta base de datos.
-- Debe ejecutarse cada vez que se recrea la BD desde cero.
-- =========================================================
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'admincontrabajo')
    CREATE USER admincontrabajo FOR LOGIN admincontrabajo;
ALTER ROLE db_owner ADD MEMBER admincontrabajo;