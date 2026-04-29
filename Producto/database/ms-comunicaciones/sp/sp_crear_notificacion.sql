CREATE OR ALTER PROCEDURE sp_crear_notificacion
    @id_usuario_receptor INT,
    @detalle NVARCHAR(200),
    @url_destino VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.notificacion (
        id_usuario_receptor,
        detalle,
        url_destino
    )
    VALUES (
        @id_usuario_receptor,
        @detalle,
        @url_destino
    );

    SELECT SCOPE_IDENTITY() AS id_notificacion;
END;
GO