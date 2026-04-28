CREATE OR ALTER PROCEDURE dbo.sp_login_usuario
(
    @correo VARCHAR(120),
    @contrasena_hash VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF @correo IS NULL OR @contrasena_hash IS NULL
        BEGIN
            THROW 50050, 'Credenciales incompletas.', 1;
        END

        DECLARE @id_usuario INT;

        SELECT @id_usuario = id_usuario
        FROM dbo.usuario
        WHERE correo = @correo
          AND contrasena_hash = @contrasena_hash
          AND id_estado = 1;

        IF @id_usuario IS NULL
        BEGIN
            THROW 50051, 'Credenciales inválidas.', 1;
        END

        -- Actualizar última conexión
        UPDATE dbo.historial_usuario
        SET 
            fecha_ultima_conexion = SYSUTCDATETIME(),
            cantidad_conexiones = cantidad_conexiones + 1
        WHERE id_usuario = @id_usuario;

        SELECT 
            id_usuario,
            username,
            correo
        FROM dbo.usuario
        WHERE id_usuario = @id_usuario;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO