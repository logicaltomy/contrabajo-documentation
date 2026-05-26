CREATE OR ALTER PROCEDURE dbo.sp_eliminar_usuario
(
    @id_usuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM dbo.usuario WHERE id_usuario = @id_usuario)
        BEGIN
            THROW 50040, 'Usuario no existe.', 1;
        END

        -- Soft delete (cambio de estado)
        UPDATE dbo.usuario
        SET id_estado = 0
        WHERE id_usuario = @id_usuario;

        SELECT 'Usuario desactivado correctamente' AS mensaje;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO