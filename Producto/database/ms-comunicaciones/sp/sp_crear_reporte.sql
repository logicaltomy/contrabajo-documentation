CREATE OR ALTER PROCEDURE sp_crear_reporte
    @descripcion NVARCHAR(500),
    @id_usuario_emisor INT,
    @id_tipo_reporte INT,
    @entidad_id BIGINT = NULL,
    @resolucion_reporte VARCHAR(50) = NULL,
    @resuelto BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.reporte (
        descripcion_reporte,
        resolucion_reporte,
        resuelto,
        id_usuario_emisor,
        id_tipo_reporte,
        entidad_id
    )
    VALUES (
        @descripcion,
        @resolucion_reporte,
        @resuelto,
        @id_usuario_emisor,
        @id_tipo_reporte,
        @entidad_id
    );

    SELECT SCOPE_IDENTITY() AS id_reporte;
END;
GO
