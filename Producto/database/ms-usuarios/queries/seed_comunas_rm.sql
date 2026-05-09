/*
Seed inicial de comunas para Azure SQL Server.

Uso recomendado:
- Ejecutar sobre una base nueva o vacia del microservicio MS_Usuarios.
- Deja `Sin comuna` como id 1.
- Crea primero la region base `Region Metropolitana` si no existe.

Este script no modifica el esquema, solo inserta datos de referencia.
*/

SET NOCOUNT ON;

DECLARE @idRegionMetropolitana INT;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.region
    WHERE nombre = 'Region Metropolitana'
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM sys.identity_columns
        WHERE OBJECT_NAME(object_id) = 'region'
    )
    BEGIN
        INSERT INTO dbo.region (nombre)
        VALUES ('Region Metropolitana');
    END
    ELSE
    BEGIN
        SET IDENTITY_INSERT dbo.region ON;
        INSERT INTO dbo.region (id_region, nombre)
        VALUES (1, 'Region Metropolitana');
        SET IDENTITY_INSERT dbo.region OFF;
    END
END

SELECT TOP 1 @idRegionMetropolitana = id_region
FROM dbo.region
WHERE nombre = 'Region Metropolitana'
ORDER BY id_region;

IF @idRegionMetropolitana IS NULL
BEGIN
    THROW 50001, 'No se pudo resolver la region base Region Metropolitana.', 1;
END

SET IDENTITY_INSERT dbo.comuna ON;

MERGE dbo.comuna AS target
USING (
    VALUES
        (1, 'Sin comuna'),
        (2, 'Alhue'),
        (3, 'Batuco'),
        (4, 'Buin'),
        (5, 'Calera de Tango'),
        (6, 'Cerrillos'),
        (7, 'Cerro Navia'),
        (8, 'Colina'),
        (9, 'Conchali'),
        (10, 'Curacavi'),
        (11, 'El Bosque'),
        (12, 'El Monte'),
        (13, 'Estacion Central'),
        (14, 'Huechuraba'),
        (15, 'Independencia'),
        (16, 'Isla de Maipo'),
        (17, 'La Cisterna'),
        (18, 'La Florida'),
        (19, 'La Granja'),
        (20, 'La Pintana'),
        (21, 'La Reina'),
        (22, 'Lampa'),
        (23, 'Las Condes'),
        (24, 'Lo Barnechea'),
        (25, 'Lo Espejo'),
        (26, 'Lo Prado'),
        (27, 'Macul'),
        (28, 'Maipu'),
        (29, 'Maria Pinto'),
        (30, 'Melipilla'),
        (31, 'Nunoa'),
        (32, 'Padre Hurtado'),
        (33, 'Paine'),
        (34, 'Pedro Aguirre Cerda'),
        (35, 'Penaflor'),
        (36, 'Penalolen'),
        (37, 'Pirque'),
        (38, 'Providencia'),
        (39, 'Pudahuel'),
        (40, 'Puente Alto'),
        (41, 'Quilicura'),
        (42, 'Quinta Normal'),
        (43, 'Recoleta'),
        (44, 'Renca'),
        (45, 'San Bernardo'),
        (46, 'San Joaquin'),
        (47, 'San Jose de Maipo'),
        (48, 'San Miguel'),
        (49, 'San Pedro'),
        (50, 'San Ramon'),
        (51, 'Santiago'),
        (52, 'Talagante'),
        (53, 'Tiltil'),
        (54, 'Vitacura')
) AS source (id_comuna, nombre)
ON target.id_comuna = source.id_comuna
WHEN NOT MATCHED BY TARGET THEN
    INSERT (id_comuna, nombre, id_region)
    VALUES (source.id_comuna, source.nombre, @idRegionMetropolitana);

SET IDENTITY_INSERT dbo.comuna OFF;

/*
Notas:
- La lista replica el catalogo local usado por la app.
- `Sin comuna` queda como primer id para integraciones donde el front aun no envie comuna.
*/
