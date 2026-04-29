CREATE OR ALTER PROCEDURE sp_crear_mensaje_soporte
    @asunto VARCHAR(80),
    @detalle NVARCHAR(500),
    @id_emisor INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.mensaje_soporte (
        asunto,
        detalle,
        id_emisor
    )
    VALUES (
        @asunto,
        @detalle,
        @id_emisor
    );

    SELECT SCOPE_IDENTITY() AS id_mensaje_soporte;
END;
GO