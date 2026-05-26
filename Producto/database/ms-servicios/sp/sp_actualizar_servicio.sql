CREATE OR ALTER PROCEDURE dbo.sp_actualizar_servicio
(
    @id_servicio INT,
    @titulo VARCHAR(100),
    @descripcion NVARCHAR(500),
    @precio DECIMAL(10,2)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM dbo.servicio WHERE id_servicio = @id_servicio)
            THROW 60010, 'Servicio no existe.', 1;

        UPDATE dbo.servicio
        SET 
            titulo = @titulo,
            descripcion = @descripcion,
            precio = @precio
        WHERE id_servicio = @id_servicio;

        SELECT 'Servicio actualizado correctamente' AS mensaje;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO