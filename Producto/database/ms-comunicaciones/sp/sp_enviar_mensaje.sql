CREATE OR ALTER PROCEDURE sp_enviar_mensaje
    @id_emisor INT,
    @id_receptor INT,
    @id_chat_oferta BIGINT,
    @contenido NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.mensaje_chat (
        id_emisor,
        id_receptor,
        id_chat_oferta,
        contenido
    )
    VALUES (
        @id_emisor,
        @id_receptor,
        @id_chat_oferta,
        @contenido
    );

    SELECT SCOPE_IDENTITY() AS id_mensaje_chat;
END;
GO