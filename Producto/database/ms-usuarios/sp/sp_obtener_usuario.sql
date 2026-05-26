CREATE OR ALTER PROCEDURE dbo.sp_obtener_usuario
(
    @id_usuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM dbo.usuario WHERE id_usuario = @id_usuario)
        BEGIN
            THROW 50010, 'Usuario no existe.', 1;
        END

        SELECT 
            u.id_usuario,
            u.run,
            u.dv,
            u.username,
            u.nombre,
            u.a_paterno,
            u.a_materno,
            u.telefono,
            u.correo,
            u.fecha_registro,
            u.fecha_nacimiento,
            u.verificado,
            u.id_estado,
            tp.nombre AS tipo_perfil
        FROM dbo.usuario u
        INNER JOIN dbo.tipo_perfil tp ON u.id_tipo_perfil = tp.id_tipo_perfil
        WHERE u.id_usuario = @id_usuario;

    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS codigo_error, ERROR_MESSAGE() AS mensaje_error;
    END CATCH
END;
GO