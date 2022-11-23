CREATE DATABASE cwiczenia_5;
CREATE extension postgis;


--Zadanie1
CREATE TABLE objects(
    id INT NOT NULL PRIMARY KEY,
    NAME VARCHAR(50) NOT NULL,
    geom GEOMETRY NOT NULL
);


INSERT INTO objects values (1, 'object_1', ST_Collect( ARRAY [ST_GeomFROMText('linestring(0 1, 1 1)'),
                                                              ST_GeomFROMText('circularstring(1 1, 2 0, 3 1)'),
                                                              ST_GeomFROMText('circularstring(3 1, 4 2, 5 1)'),
                                                              ST_GeomFROMText('linestring(5 1, 6 1)')]));

INSERT INTO objects values (2, 'object_2', ST_Collect( ARRAY [ST_GeomFROMText('linestring(10 6, 14 6)'),
                                                              ST_GeomFROMText('circularstring(14 6, 16 4, 14 2)'),
                                                              ST_GeomFROMText('circularstring(14 2, 12 0, 10 2)'),
                                                              ST_GeomFROMText('linestring(10 2, 10 6)'),
                                                              ST_GeomFROMText('circularstring(11 1, 12 3, 13 2)'),
                                                              ST_GeomFROMText('circularstring(13 2, 12 1, 11 2)')]));

INSERT INTO objects values (3, 'object_3', ST_GeomFROMText('polygon((7 15, 10 17, 12 13, 7 15))'));

INSERT INTO objects values (4, 'object_4', ST_Collect( ARRAY [ST_GeomFROMText('linestring(20 20, 25 25)'),
                                                              ST_GeomFROMText('linestring(25 25, 27 24)'),
                                                              ST_GeomFROMText('linestring(27 24, 25 22)'),
                                                              ST_GeomFROMText('linestring(25 22, 26 21)'),
                                                              ST_GeomFROMText('linestring(26 21, 22 19)'),
                                                              ST_GeomFROMText('linestring(22 19, 20.5 19.5)')]));

INSERT INTO objects values (5, 'object_5', ST_Collect( ARRAY [ST_GeomFROMText('poINT(30 30 59)'),
                                                              ST_GeomFROMText('poINT(38 32 234)')]));

INSERT INTO objects values (6, 'object_6', ST_Collect( ARRAY [ST_GeomFROMText('linestring(1 1, 3 2)'),
                                                              ST_GeomFROMText('poINT(4 2)')]));


--Zadanie2
WITH object_3 AS (SELECT geom FROM objects o WHERE name = 'object_3'),
	 object_4 AS (SELECT geom FROM objects o WHERE name = 'object_4')
SELECT ST_Area(ST_Buffer( ST_ShortestLine(object_3.geom,object_4.geom), 5 )) FROM object_3, object_4;


--Zadanie3
UPDATE objects 
SET geom = ST_MakePolygon( ST_MakeLine(ST_LineMerge(geom), ST_PointN(ST_LineMerge(geom), 1 )))
WHERE NAME='object_4';

SELECT * FROM objects o WHERE NAME='obiekt4';


--Zadanie4
INSERT INTO objects VALUES (7, 'object_7', (SELECT ST_Collect( ARRAY [o3.geom, o4.geom] ) FROM
                                           (SELECT * FROM objects WHERE id = 3) AS o3,
                                           (SELECT * FROM objects WHERE id = 4) AS o4));


--Zadanie5
SELECT ST_Area(ST_Buffer(geom, 5)) 
FROM objects o
WHERE ST_HasArc(ST_LineToCurve(geom))=false;