CREATE OR ALTER PROCEDURE dbo.sp_actualizar_usuario
(
    @id_usuario INT,
    @username VARCHAR(30),
    @telefono VARCHAR(20),
    @rango_disponibilidad_m INT = NULL,
    @rango_busqueda_m INT = NULL,
    @id_direccion INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM dbo.usuario WHERE id_usuario = @id_usuario)
        BEGIN
            THROW 50030, 'Usuario no existe.', 1;
        END

        IF EXISTS (
            SELECT 1 FROM dbo.usuario 
            WHERE username = @username AND id_usuario <> @id_usuario
        )
        BEGIN
            THROW 50031, 'Username ya en uso.', 1;
        END

        UPDATE dbo.usuario
        SET 
            username = @username,
            telefono = @telefono,
            rango_disponibilidad_m = COALESCE(@rango_disponibilidad_m, rango_disponibilidad_m),
            rango_busqueda_m = COALESCE(@rango_busqueda_m, rango_busqueda_m),
            id_direccion = @id_direccion
        WHERE id_usuario = @id_usuario;

        SELECT 'Usuario actualizado correctamente' AS mensaje;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO
