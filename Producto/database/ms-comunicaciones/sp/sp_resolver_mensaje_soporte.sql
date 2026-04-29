CREATE OR ALTER PROCEDURE sp_resolver_mensaje_soporte
    @id_mensaje_soporte INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.mensaje_soporte
    SET 
        resuelto = 1,
        fecha_resolucion = SYSUTCDATETIME()
    WHERE id_mensaje_soporte = @id_mensaje_soporte;
END;
GO