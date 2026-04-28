CREATE OR ALTER PROCEDURE dbo.sp_buscar_usuario_por_correo
(
    @correo VARCHAR(120)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF @correo IS NULL OR CHARINDEX('@', @correo) = 0
        BEGIN
            THROW 50020, 'Correo inválido.', 1;
        END

        SELECT 
            id_usuario,
            username,
            correo,
            contrasena_hash,
            verificado,
            id_estado
        FROM dbo.usuario
        WHERE correo = @correo;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO