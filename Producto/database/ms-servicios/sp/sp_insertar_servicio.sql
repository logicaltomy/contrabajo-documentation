CREATE OR ALTER PROCEDURE dbo.sp_insertar_servicio
(
    @id_usuario INT,
    @titulo VARCHAR(100),
    @descripcion NVARCHAR(500),
    @precio DECIMAL(10,2),
    @id_estado INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF @titulo IS NULL OR LEN(@titulo) < 5
            THROW 60001, 'Título inválido.', 1;

        IF @precio < 0
            THROW 60002, 'Precio no puede ser negativo.', 1;

        INSERT INTO dbo.servicio
        (
            id_usuario,
            titulo,
            descripcion,
            precio,
            id_estado,
            fecha_creacion
        )
        VALUES
        (
            @id_usuario,
            @titulo,
            @descripcion,
            @precio,
            @id_estado,
            SYSUTCDATETIME()
        );

        SELECT SCOPE_IDENTITY() AS id_servicio;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO