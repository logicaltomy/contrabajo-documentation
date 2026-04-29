CREATE OR ALTER PROCEDURE sp_listar_notificaciones
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.notificacion
    WHERE id_usuario_receptor = @id_usuario
    ORDER BY fecha_creacion DESC;
END;
GO