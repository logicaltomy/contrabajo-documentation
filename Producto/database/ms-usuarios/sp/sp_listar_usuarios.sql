CREATE OR ALTER PROCEDURE dbo.sp_listar_usuarios
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SELECT 
            u.id_usuario,
            u.username,
            u.nombre,
            u.a_paterno,
            u.correo,
            u.verificado,
            tp.nombre AS tipo_perfil
        FROM dbo.usuario u
        INNER JOIN dbo.tipo_perfil tp ON u.id_tipo_perfil = tp.id_tipo_perfil
        ORDER BY u.id_usuario DESC;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO