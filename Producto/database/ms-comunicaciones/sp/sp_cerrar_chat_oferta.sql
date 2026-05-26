CREATE OR ALTER PROCEDURE sp_cerrar_chat_oferta
    @id_chat_oferta BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.chat_oferta
    SET activo = 0
    WHERE id_chat_oferta = @id_chat_oferta;
END;
GO