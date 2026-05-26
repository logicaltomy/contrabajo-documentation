CREATE OR ALTER PROCEDURE sp_crear_chat_oferta
    @id_trabajador INT,
    @id_cliente INT,
    @id_oferta_servicio INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.chat_oferta (
        id_trabajador,
        id_cliente,
        id_oferta_servicio
    )
    VALUES (
        @id_trabajador,
        @id_cliente,
        @id_oferta_servicio
    );

    SELECT SCOPE_IDENTITY() AS id_chat_oferta;
END;
GO