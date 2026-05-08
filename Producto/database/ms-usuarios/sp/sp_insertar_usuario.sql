CREATE OR ALTER PROCEDURE dbo.sp_insertar_usuario
(
    @run INT,
    @dv VARCHAR(1),
    @username VARCHAR(30),
    @nombre VARCHAR(70),
    @a_paterno VARCHAR(70),
    @a_materno VARCHAR(70) = NULL,
    @telefono VARCHAR(20) = NULL,
    @correo VARCHAR(120),
    @rango_disponibilidad_m INT = 20000,
    @rango_busqueda_m INT = 20000,
    @contrasena_hash VARCHAR(255),
    @fecha_nacimiento DATE,
    @id_tipo_perfil SMALLINT,
    @id_direccion INT = NULL,
    @id_estado INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- ============================================
        -- VALIDACIONES BÁSICAS
        -- ============================================

        IF @run IS NULL OR @dv IS NULL
        BEGIN
            THROW 50001, 'RUN y DV son obligatorios.', 1;
        END

        IF @username IS NULL OR LEN(@username) < 3
        BEGIN
            THROW 50002, 'Username inválido (mínimo 3 caracteres).', 1;
        END

        IF @correo IS NULL OR CHARINDEX('@', @correo) = 0
        BEGIN
            THROW 50003, 'Correo electrónico inválido.', 1;
        END

        IF @contrasena_hash IS NULL OR LEN(@contrasena_hash) < 10
        BEGIN
            THROW 50004, 'Hash de contraseña inválido.', 1;
        END

        -- ============================================
        -- VALIDACIÓN DE DUPLICADOS
        -- ============================================

        IF EXISTS (SELECT 1 FROM dbo.usuario WHERE run = @run)
        BEGIN
            THROW 50005, 'El RUN ya está registrado.', 1;
        END

        IF EXISTS (SELECT 1 FROM dbo.usuario WHERE username = @username)
        BEGIN
            THROW 50006, 'El username ya está en uso.', 1;
        END

        IF EXISTS (SELECT 1 FROM dbo.usuario WHERE correo = @correo)
        BEGIN
            THROW 50007, 'El correo ya está registrado.', 1;
        END

        -- ============================================
        -- INSERCIÓN
        -- ============================================

        INSERT INTO dbo.usuario
        (
            run,
            dv,
            username,
            nombre,
            a_paterno,
            a_materno,
            telefono,
            correo,
            rango_disponibilidad_m,
            rango_busqueda_m,
            contrasena_hash,
            fecha_registro,
            fecha_nacimiento,
            verificado,
            id_tipo_perfil,
            id_direccion,
            id_estado
        )
        VALUES
        (
            @run,
            @dv,
            @username,
            @nombre,
            @a_paterno,
            @a_materno,
            @telefono,
            @correo,
            @rango_disponibilidad_m,
            @rango_busqueda_m,
            @contrasena_hash,
            SYSUTCDATETIME(),
            @fecha_nacimiento,
            0, -- usuario no verificado por defecto
            @id_tipo_perfil,
            @id_direccion,
            @id_estado
        );

        -- ============================================
        -- RETORNO
        -- ============================================

        SELECT 
            'Usuario creado correctamente' AS mensaje,
            SCOPE_IDENTITY() AS id_usuario;

    END TRY
    BEGIN CATCH

        -- ============================================
        -- MANEJO DE ERRORES
        -- ============================================

        SELECT 
            ERROR_NUMBER() AS codigo_error,
            ERROR_MESSAGE() AS mensaje_error;

    END CATCH
END;
GO
