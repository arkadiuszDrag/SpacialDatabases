SELECT * FROM t2019_kar_buildings LIMIT 10;

SELECT tkb19.gid,
	tkb19.polygon_id,
	tkb19.name,
	tkb19.type,
	tkb19.height,
	st_astext(tkb19.geom)
FROM t2019_kar_buildings tkb19
LEFT JOIN t2018_kar_buildings tkb18 ON tkb19.geom = tkb18.geom
WHERE tkb18.gid IS NULL;

WITH cte1 AS(
	SELECT tkb19.gid,
		tkb19.polygon_id,
		tkb19.name,
		tkb19.type,
		tkb19.height,
		st_astext(tkb19.geom)
	FROM t2019_kar_buildings tkb19
	LEFT JOIN t2018_kar_buildings tkb18 ON tkb19.geom = tkb18.geom
	WHERE tkb18.gid IS NULL
),
cte2 AS(
	SELECT *
	FROM t2019_kar_poi_table k19
	LEFT JOIN t2018_kar_poi_table k18 ON k19.geom = k18.geom
	WHERE k18.gid IS NULL
),

cte AS(
	SELECT x.type
	FROM cte2 x 
	JOIN cte1 y ON st_intersects(x.geom, st_buffer(y.geom, 0.005))
)
SELECT count(*) FROM cte
GROUP BY TYPE;

SELECT *  FROM t2019_kar_streets LIMIT 10;

CREATE TABLE streets_reprojected(
	gid INT PRIMARY KEY,
	link_id FLOAT8,
	st_name VARCHAR(254) NULL,
	ref_in_id FLOAT8,
	nref_in_id FLOAT8,
	func_class VARCHAR(1),
	speed_cat VARCHAR(1),
	fr_speed_I FLOAT8,
	to_speed_I FLOAT8,
	dir_travel VARCHAR(1),
	geom GEOMETRY
);

INSERT INTO streets_reprojected
SELECT gid,
	link_id,
	st_name,
	ref_in_id,
	nref_in_id,
	func_class,
	speed_cat,
	fr_speed_l,
	to_speed_l,
	dir_travel,
	ST_Transform(ST_SetSRID(geom,4326), 3068)
FROM t2019_kar_streets;

SELECT * FROM streets_reprojected LIMIT 10;

CREATE TABLE input_points(
	id INT PRIMARY KEY,
	NAME VARCHAR(254),
	geom GEOMETRY
);

INSERT INTO input_points VALUES (1, 'point1', 'POINT(8.36093 49.03174)'),
    (2, 'point2', 'POINT(8.39876 49.00644)');

UPDATE input_points
SET geom = st_transform(st_setsrid(geom,4326), 3068);

SELECT * FROM t2019_kar_street_node LIMIT 10;

UPDATE t2019_kar_street_node
SET geom = st_transform(st_setsrid(geom,4326), 3068);

WITH cte AS(
	SELECT st_makeline(geom) AS LINE
	FROM input_points
)
SELECT * FROM cte x
CROSS JOIN t2019_kar_street_node y
WHERE st_contains(st_buffer(x.line, 0.002), y.geom);

SELECT * FROM t2019_kar_land_use_a
LIMIT 10;

WITH cte AS(
	SELECT st_buffer(geom,0.003) AS BUFFER 
	FROM t2019_kar_land_use_a
	WHERE TYPE='Park (City/County)'
)
SELECT count(*) FROM cte 
CROSS JOIN t2019_kar_poi_table x
WHERE x."type" ='Sporting Goods Store' AND st_contains(cte.buffer, x.geom);

SELECT st_intersection(railways.geom, waterlines.geom) AS INTERSECT
INTO T2019_KAR_BRIDGES
FROM t2019_kar_railways railways
JOIN t2019_kar_water_lines waterlines ON st_intersects(railways.geom, waterlines.geom);

SELECT * FROM t2019_kar_bridges LIMIT 10;


