-- =========================================================
-- ELIMINACIÓN DE TABLAS EN ORDEN CORRECTO (HIJOS → PADRES)
-- =========================================================
IF OBJECT_ID(N'dbo.recuperacion_cuenta', N'U') IS NOT NULL DROP TABLE dbo.recuperacion_cuenta;
IF OBJECT_ID(N'dbo.pregunta_seguridad_usuario', N'U') IS NOT NULL DROP TABLE dbo.pregunta_seguridad_usuario;
IF OBJECT_ID(N'dbo.sesion_usuario', N'U') IS NOT NULL DROP TABLE dbo.sesion_usuario;
IF OBJECT_ID(N'dbo.historial_usuario', N'U') IS NOT NULL DROP TABLE dbo.historial_usuario;
IF OBJECT_ID(N'dbo.cedula_identidad', N'U') IS NOT NULL DROP TABLE dbo.cedula_identidad;
IF OBJECT_ID(N'dbo.foto', N'U') IS NOT NULL DROP TABLE dbo.foto;
IF OBJECT_ID(N'dbo.usuario', N'U') IS NOT NULL DROP TABLE dbo.usuario;
IF OBJECT_ID(N'dbo.direccion', N'U') IS NOT NULL DROP TABLE dbo.direccion;
IF OBJECT_ID(N'dbo.comuna', N'U') IS NOT NULL DROP TABLE dbo.comuna;
IF OBJECT_ID(N'dbo.coordenadas', N'U') IS NOT NULL DROP TABLE dbo.coordenadas;
IF OBJECT_ID(N'dbo.region', N'U') IS NOT NULL DROP TABLE dbo.region;
IF OBJECT_ID(N'dbo.tipo_perfil', N'U') IS NOT NULL DROP TABLE dbo.tipo_perfil;

-- =========================================================
-- TABLA: TIPO PERFIL
-- Almacena los distintos tipos de perfil del sistema.
-- Ejemplo:
-- - Cliente
-- - Trabajador
--
-- SMALLINT es suficiente porque la cantidad de perfiles
-- posibles será reducida.
-- =========================================================
CREATE TABLE dbo.tipo_perfil (
    id_tipo_perfil SMALLINT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(25) NOT NULL UNIQUE
);

-- =========================================================
-- TABLA: REGIÓN
-- Almacena las regiones disponibles dentro de la aplicación.
-- =========================================================
CREATE TABLE dbo.region (
    id_region INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- =========================================================
-- TABLA: COORDENADAS
-- Permite guardar latitud y longitud de usuarios,
-- direcciones o servicios.
--
-- Será útil para:
-- - Buscar trabajadores cercanos
-- - Filtrar por ubicación
-- - Ordenar por distancia
-- =========================================================
CREATE TABLE dbo.coordenadas (
    id_coordenadas INT IDENTITY(1,1) PRIMARY KEY,
    latitud DECIMAL(10,8) NOT NULL,
    longitud DECIMAL(11,8) NOT NULL,
    detalle VARCHAR(120) NULL
);

-- =========================================================
-- TABLA: COMUNA
-- Representa las comunas asociadas a cada región.
-- =========================================================
CREATE TABLE dbo.comuna (
    id_comuna INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL,
    id_region INT NOT NULL,
    CONSTRAINT UQ_comuna_region_nombre UNIQUE (id_region, nombre),
    FOREIGN KEY (id_region) REFERENCES dbo.region(id_region)
);

-- =========================================================
-- TABLA: DIRECCIÓN
-- Almacena la dirección de un usuario.
--
-- Incluye calle, número, comuna y coordenadas opcionales.
-- =========================================================
CREATE TABLE dbo.direccion (
    id_direccion INT IDENTITY(1,1) PRIMARY KEY,
    calle VARCHAR(80) NOT NULL,
    numero VARCHAR(10) NULL,
    id_comuna INT NOT NULL,
    id_coordenadas INT NULL,
    FOREIGN KEY (id_comuna) REFERENCES dbo.comuna(id_comuna),
    FOREIGN KEY (id_coordenadas) REFERENCES dbo.coordenadas(id_coordenadas)
);

-- =========================================================
-- TABLA: USUARIO
-- Tabla principal del microservicio.
--
-- telefono:
-- Se utiliza VARCHAR(9) porque el teléfono es texto,
-- no un valor matemático.
--
-- verificado:
-- BIT permite representar:
-- 0 = No verificado
-- 1 = Verificado
--
-- id_estado:
-- Referencia lógica hacia MS_Servicios.estado(id_estado)
-- pero no se implementa FK real para evitar acoplamiento
-- entre microservicios.
-- =========================================================
CREATE TABLE dbo.usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    run INT NOT NULL UNIQUE,
    dv VARCHAR(1) NOT NULL,
    username VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    a_paterno VARCHAR(60) NOT NULL,
    a_materno VARCHAR(60) NULL,
    telefono VARCHAR(9) NULL,
    correo VARCHAR(60) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    fecha_nacimiento DATE NOT NULL,
    verificado BIT NOT NULL DEFAULT 0,
    id_tipo_perfil SMALLINT NOT NULL,
    id_direccion INT NULL,
    id_estado INT NOT NULL,

    FOREIGN KEY (id_tipo_perfil) REFERENCES dbo.tipo_perfil(id_tipo_perfil),
    FOREIGN KEY (id_direccion) REFERENCES dbo.direccion(id_direccion)
);

-- =========================================================
-- TABLA: FOTO
-- Almacena imágenes asociadas al usuario.
--
-- Puede contener:
-- - Foto de perfil
-- - Evidencia de trabajos realizados
-- - Imágenes asociadas a servicios
-- =========================================================
CREATE TABLE dbo.foto (
    id_foto INT IDENTITY(1,1) PRIMARY KEY,
    fecha_subida DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    enlace VARCHAR(300) NOT NULL,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

-- =========================================================
-- TABLA: CÉDULA IDENTIDAD
-- Permite almacenar información extraída desde OCR
-- para validación de identidad.
--
-- Los campos del documento pueden quedar NULL
-- hasta que el OCR procese completamente la imagen.
-- =========================================================
CREATE TABLE dbo.cedula_identidad (
    id_documento INT IDENTITY(1,1) PRIMARY KEY,
    nro_documento VARCHAR(20) NOT NULL UNIQUE,
    run_documento INT NULL,
    dv_documento VARCHAR(1) NULL,
    fecha_nacimiento_documento DATE NULL,
    id_usuario INT NOT NULL UNIQUE,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

-- =========================================================
-- TABLA: HISTORIAL USUARIO
-- Permite almacenar trazabilidad simple del usuario.
-- =========================================================
CREATE TABLE dbo.historial_usuario (
    id_historial_usuario BIGINT IDENTITY(1,1) PRIMARY KEY,
    fecha_ultima_conexion DATETIME2(0) NULL,
    cantidad_conexiones INT NOT NULL DEFAULT 0,
    total_vistas_perfil INT NOT NULL DEFAULT 0,
    ultimo_dispositivo VARCHAR(100) NULL,
    id_usuario INT NOT NULL UNIQUE,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

-- =========================================================
-- TABLA: SESIÓN USUARIO
-- Permite controlar sesiones activas, expiración
-- y último acceso.
-- =========================================================
CREATE TABLE dbo.sesion_usuario (
    id_sesion_usuario BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    fecha_inicio DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    fecha_expiracion DATETIME2(0) NOT NULL,
    fecha_ultimo_acceso DATETIME2(0) NULL,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

-- =========================================================
-- TABLA: PREGUNTA SEGURIDAD USUARIO
-- Almacena preguntas y respuestas de seguridad
-- permanentes del usuario.
--
-- Cada usuario solo puede tener un único conjunto
-- de preguntas de seguridad.
-- =========================================================
CREATE TABLE dbo.pregunta_seguridad_usuario (
    id_pregunta_seguridad INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    pregunta_seguridad1 VARCHAR(150) NOT NULL,
    respuesta_seguridad1_hash VARCHAR(255) NOT NULL,
    pregunta_seguridad2 VARCHAR(150) NOT NULL,
    respuesta_seguridad2_hash VARCHAR(255) NOT NULL,
    fecha_actualizacion DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_pregunta_seguridad_usuario_usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

-- =========================================================
-- TABLA: RECUPERACION CUENTA
-- Registra solicitudes de recuperación de cuenta.
--
-- Puede almacenar códigos temporales enviados
-- por correo, SMS o futuras validaciones.
-- =========================================================
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

-- =========================================================
-- ÍNDICES
-- Mejoran búsquedas y joins frecuentes.
-- =========================================================
CREATE INDEX IX_usuario_tipo_perfil ON dbo.usuario(id_tipo_perfil);
CREATE INDEX IX_usuario_direccion ON dbo.usuario(id_direccion);
CREATE INDEX IX_foto_usuario ON dbo.foto(id_usuario);
CREATE INDEX IX_pregunta_seguridad_usuario ON dbo.pregunta_seguridad_usuario(id_usuario);
CREATE INDEX IX_recuperacion_cuenta_usuario ON dbo.recuperacion_cuenta(id_usuario, usada);