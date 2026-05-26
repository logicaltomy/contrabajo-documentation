CREATE OR ALTER PROCEDURE dbo.sp_listar_servicios
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SELECT 
            s.id_servicio,
            s.titulo,
            s.descripcion,
            s.precio,
            s.fecha_creacion,
            s.id_estado
        FROM dbo.servicio s
        WHERE s.id_estado = 1
        ORDER BY s.fecha_creacion DESC;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO