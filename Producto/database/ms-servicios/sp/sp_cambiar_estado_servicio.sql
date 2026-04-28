CREATE OR ALTER PROCEDURE dbo.sp_cambiar_estado_servicio
(
    @id_servicio INT,
    @id_estado INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM dbo.servicio WHERE id_servicio = @id_servicio)
            THROW 60020, 'Servicio no existe.', 1;

        UPDATE dbo.servicio
        SET id_estado = @id_estado
        WHERE id_servicio = @id_servicio;

        SELECT 'Estado del servicio actualizado' AS mensaje;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO