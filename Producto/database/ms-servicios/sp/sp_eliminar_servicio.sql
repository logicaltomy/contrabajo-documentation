CREATE OR ALTER PROCEDURE dbo.sp_eliminar_servicio
(
    @id_servicio INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM dbo.servicio WHERE id_servicio = @id_servicio)
            THROW 60030, 'Servicio no existe.', 1;

        UPDATE dbo.servicio
        SET id_estado = 0
        WHERE id_servicio = @id_servicio;

        SELECT 'Servicio desactivado correctamente' AS mensaje;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO