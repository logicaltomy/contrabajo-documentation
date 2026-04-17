-- =========================================================
-- ELIMINACIÓN DE TABLAS EN ORDEN CORRECTO (HIJOS → PADRES)
-- =========================================================
IF OBJECT_ID(N'dbo.recuperacion_cuenta', N'U') IS NOT NULL DROP TABLE dbo.recuperacion_cuenta;
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
-- Esta tabla almacena los tipos de perfil disponibles.
-- Ejemplos:
-- - Cliente / Usuario normal que solicita un servicio
-- - Trabajador / Prestador de servicios
--
-- Se utiliza SMALLINT porque la cantidad de perfiles
-- posibles es reducida y no se espera que crezca demasiado.
-- SMALLINT permite ahorrar espacio respecto a INT.
-- =========================================================
CREATE TABLE dbo.tipo_perfil (
    id_tipo_perfil SMALLINT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(25) NOT NULL UNIQUE
);

-- =========================================================
-- TABLA: REGIÓN
-- Almacena las distintas regiones disponibles dentro
-- del alcance de la aplicación.
--
-- Se utiliza INT porque es un identificador numérico simple
-- y permite crecimiento suficiente a futuro.
-- =========================================================
CREATE TABLE dbo.region (
    id_region INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- =========================================================
-- TABLA: COORDENADAS
-- Permite almacenar coordenadas geográficas asociadas
-- a usuarios, direcciones o servicios.
--
-- Esto será útil para:
-- - Mostrar trabajadores cercanos
-- - Segmentar resultados por ubicación
-- - Ordenar trabajadores según distancia
--
-- Se utiliza DECIMAL porque se requiere precisión
-- en la latitud y longitud.
-- =========================================================
CREATE TABLE dbo.coordenadas (
    id_coordenadas INT IDENTITY(1,1) PRIMARY KEY,
    latitud DECIMAL(10,8) NOT NULL,
    longitud DECIMAL(11,8) NOT NULL,
    detalle VARCHAR(120) NULL
);

-- =========================================================
-- TABLA: COMUNA
-- Representa las comunas disponibles dentro de una región.
--
-- Esto permitirá asociar usuarios y direcciones
-- a una comuna específica, además de facilitar filtros
-- de búsqueda por área de trabajo.
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
-- Almacena la dirección del usuario.
--
-- Incluye:
-- - Calle
-- - Número
-- - Comuna
-- - Coordenadas opcionales
--
-- Las coordenadas son opcionales porque no todos los usuarios
-- querrán compartir ubicación exacta.
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
-- Explicaciones importantes:
--
-- run:
-- Se utiliza INT porque el RUN chileno es un número
-- que no requiere operaciones decimales.
--
-- No se usa INT(8) porque en SQL Server el INT no acepta
-- longitud entre paréntesis. INT ya tiene un tamaño fijo.
--
-- dv:
-- Se utiliza VARCHAR(1) porque el dígito verificador
-- puede ser un número o la letra K.
--
-- username:
-- Nombre visible o identificador del usuario.
--
-- a_materno:
-- Se deja NULL porque algunas personas pueden no tener
-- apellido materno o utilizar solamente uno.
--
-- telefono:
-- Se utiliza VARCHAR(9) porque, aunque almacena números,
-- sigue siendo texto ingresado por el usuario.
-- No se realizan operaciones matemáticas con él.
--
-- correo:
-- Se utiliza VARCHAR(60) para almacenar el email del usuario.
--
-- contrasena_hash:
-- Se utiliza VARCHAR(255) porque los hashes generados
-- por algoritmos modernos suelen ser extensos.
--
-- fecha_registro:
-- Se genera automáticamente al crear el usuario.
--
-- verificado:
-- Se utiliza BIT porque solamente puede tomar dos valores:
-- 0 = Usuario no verificado
-- 1 = Usuario verificado
--
-- id_estado:
-- Referencia lógica hacia MS_Servicios.estado(id_estado)
-- pero no se implementa FOREIGN KEY para mantener
-- desacoplamiento entre microservicios.
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
-- Aquí se podrán guardar:
-- - Foto de perfil
-- - Fotografías de trabajos realizados
-- - Evidencia visual de servicios prestados
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
-- Permite almacenar datos extraídos desde la cédula.
--
-- Esta información se utilizará junto a OCR para validar
-- que los datos ingresados por el usuario coincidan
-- con la información real del documento.
-- En esta tabla la cédula funciona como una validación complementaria,
-- y no necesariamente todos los campos estarán disponibles desde el primer momento.
-- Por eso run_documento, dv_documento y fecha_nacimiento_documento quedaron como NULL, 
-- Para permitir que la fila exista aunque aún no se hayan procesado los datos del documento.
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
-- Tabla de trazabilidad simple.
--
-- Permite almacenar:
-- - Última conexión
-- - Cantidad de conexiones
-- - Total de vistas al perfil
-- - Último dispositivo utilizado
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
-- Permite administrar las sesiones activas.
--
-- Esta tabla servirá para:
-- - Saber si un usuario sigue autenticado
-- - Controlar expiración de sesión
-- - Registrar último acceso
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

-- Tabla de preguntas de seguridad del usuario.
-- Esta tabla se separa de dbo.usuario para evitar sobrecargar la entidad principal
-- con información que solo será utilizada en procesos de recuperación de cuenta.
-- Además, permite mantener una relación 1:1 entre usuario y preguntas de seguridad.
CREATE TABLE dbo.recuperacion_cuenta  (
    -- Identificador único interno de la tabla.
    -- Se utiliza IDENTITY para autoincrementar automáticamente.
    id_pregunta_seguridad INT IDENTITY(1,1) PRIMARY KEY,

    -- Relación directa con el usuario dueño de estas preguntas.
    -- Se marca como UNIQUE para asegurar que cada usuario tenga
    -- un solo conjunto de preguntas de seguridad.
    id_usuario INT NOT NULL UNIQUE,

    -- Primera pregunta de seguridad configurada por el usuario.
    -- Se deja un tamaño amplio para permitir preguntas personalizadas.
    pregunta_seguridad1 VARCHAR(150) NOT NULL,

    -- Respuesta a la primera pregunta de seguridad.
    -- No se almacena en texto plano por motivos de seguridad.
    -- Se almacena un hash, similar a las contraseñas.
    respuesta_seguridad1_hash VARCHAR(255) NOT NULL,

    -- Segunda pregunta de seguridad configurada por el usuario.
    pregunta_seguridad2 VARCHAR(150) NOT NULL,

    -- Respuesta a la segunda pregunta de seguridad.
    -- También se almacena como hash.
    respuesta_seguridad2_hash VARCHAR(255) NOT NULL,

    -- Fecha de la última actualización de las preguntas de seguridad.
    -- Se utiliza para auditoría y control de cambios.
    fecha_actualizacion DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),

    -- Relación con la tabla principal de usuarios.
    CONSTRAINT FK_pregunta_seguridad_usuario_usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.usuario(id_usuario)
);

-- =========================================================
-- ÍNDICES
-- Se crean para optimizar búsquedas frecuentes y joins.
-- =========================================================
CREATE INDEX IX_usuario_tipo_perfil ON dbo.usuario(id_tipo_perfil);
CREATE INDEX IX_usuario_direccion ON dbo.usuario(id_direccion);
CREATE INDEX IX_foto_usuario ON dbo.foto(id_usuario);
CREATE INDEX IX_recuperacion_cuenta_usuario ON dbo.recuperacion_cuenta(id_usuario);