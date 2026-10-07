-- =====================================================================
-- Diseño de Bases de Geodatos (14504) · USACH
-- Unidad 3 · Script i04: soluciones de la Guía U3
-- Requiere i01_esquema_relacional.sql, i02_datos.sql e i03_espacial.sql
-- =====================================================================

SET search_path TO riesgo, public;

-- ---------------------------------------------------------------------
-- 3.1 Representaciones OGC: WKT, EWKT, WKB y GeoJSON
-- ---------------------------------------------------------------------
SELECT nombre,
       ST_AsText(geom)                     AS wkt,
       ST_AsEWKT(geom)                     AS ewkt,
       encode(ST_AsBinary(geom), 'hex')    AS wkb_hex,
       ST_AsGeoJSON(ST_Transform(geom, 4326), 6) AS geojson_wgs84
FROM infraestructura
WHERE id_tipo = 1
ORDER BY nombre;

-- ---------------------------------------------------------------------
-- 3.2 Inventario de capas espaciales (catálogo geometry_columns)
-- ---------------------------------------------------------------------
SELECT f_table_name, f_geometry_column, coord_dimension, srid, type
FROM geometry_columns
WHERE f_table_schema = 'riesgo'
ORDER BY f_table_name;

-- ---------------------------------------------------------------------
-- 3.3 Tipo, dimensión y SRID de cada geometría (por tabla)
-- ---------------------------------------------------------------------
SELECT 'comuna' AS tabla, ST_GeometryType(geom) AS tipo, ST_Dimension(geom) AS dim_topologica,
       ST_NDims(geom) AS n_coords, ST_SRID(geom) AS srid, count(*)
FROM comuna GROUP BY 1,2,3,4,5
UNION ALL
SELECT 'via', ST_GeometryType(geom), ST_Dimension(geom), ST_NDims(geom), ST_SRID(geom), count(*)
FROM via GROUP BY 1,2,3,4,5
UNION ALL
SELECT 'infraestructura', ST_GeometryType(geom), ST_Dimension(geom), ST_NDims(geom), ST_SRID(geom), count(*)
FROM infraestructura GROUP BY 1,2,3,4,5;

-- ---------------------------------------------------------------------
-- 3.4 Magnitudes: superficie comunal (km²) y área quemada calculada vs declarada
-- ---------------------------------------------------------------------
SELECT nombre, round((ST_Area(geom) / 1e6)::numeric, 1) AS area_km2,
       round((poblacion / (ST_Area(geom) / 1e6))::numeric, 0) AS densidad_hab_km2
FROM comuna
ORDER BY densidad_hab_km2 DESC;

SELECT e.codigo, a.fecha_corte, e.sup_afectada_ha AS declarada_ha,
       round((ST_Area(a.geom) / 1e4)::numeric, 1) AS calculada_ha,
       round((100 * (ST_Area(a.geom) / 1e4 - e.sup_afectada_ha) / e.sup_afectada_ha)::numeric, 1) AS dif_pct
FROM area_quemada a
JOIN evento_incendio e USING (id_evento)
ORDER BY e.codigo, a.fecha_corte;
-- Discusión: diferencias grandes = geometría simplificada, perímetro no final
-- o cifra oficial que incluye áreas no digitalizadas. Documentar en metadatos.

-- ---------------------------------------------------------------------
-- 3.5 SRC: coordenadas geográficas y distancias geometry vs geography
-- ---------------------------------------------------------------------
SELECT nombre,
       round(ST_X(ST_Transform(geom, 4326))::numeric, 5) AS lon,
       round(ST_Y(ST_Transform(geom, 4326))::numeric, 5) AS lat
FROM infraestructura WHERE id_tipo = 1;

SELECT round(ST_Distance(a.geom, b.geom)::numeric, 1)                         AS dist_utm_m,
       round(ST_Distance(ST_Transform(a.geom,4326)::geography,
                         ST_Transform(b.geom,4326)::geography)::numeric, 1)   AS dist_geography_m
FROM infraestructura a, infraestructura b
WHERE a.id_infra = 1 AND b.id_infra = 3;

-- ---------------------------------------------------------------------
-- 3.6 Error típico de unidades: distancia en grados
-- ---------------------------------------------------------------------
SELECT ST_Distance(ST_Transform(a.geom,4326), ST_Transform(b.geom,4326)) AS dist_en_grados_MAL,
       ST_Distance(a.geom, b.geom)                                     AS dist_en_metros_BIEN
FROM infraestructura a, infraestructura b
WHERE a.id_infra = 1 AND b.id_infra = 3;
-- En EPSG:4326 la unidad es el grado: "0,09" no significa 90 m.

-- ---------------------------------------------------------------------
-- 3.7 Validez geométrica en la tabla de paso
-- ---------------------------------------------------------------------
SELECT id_stg, origen, ST_SRID(geom) AS srid, ST_IsValid(geom) AS valida,
       ST_IsValidReason(geom) AS motivo,
       ST_XMin(geom) < 1000 AS parece_grados
FROM stg_area_quemada
ORDER BY id_stg;

-- Corrección y promoción a la tabla definitiva
BEGIN;
-- (a) SRID mal declarado: la geometría está en grados, reasignar 4326 y transformar
UPDATE stg_area_quemada
SET geom = ST_Transform(ST_SetSRID(geom, 4326), 32719)
WHERE ST_XMin(geom) < 1000;

-- (b) geometrías inválidas: reparar y quedarse solo con la parte poligonal
UPDATE stg_area_quemada
SET geom = ST_CollectionExtract(ST_MakeValid(geom), 3)
WHERE NOT ST_IsValid(geom);

SELECT id_stg, ST_GeometryType(geom), ST_IsValid(geom), round((ST_Area(geom)/1e4)::numeric,1) AS ha
FROM stg_area_quemada ORDER BY id_stg;

INSERT INTO area_quemada (id_evento, fecha_corte, fuente, geom)
SELECT s.id_evento, e.fecha_inicio::date, s.origen, ST_Multi(s.geom)
FROM stg_area_quemada s
JOIN evento_incendio e USING (id_evento);

SELECT id_evento, fecha_corte, fuente FROM area_quemada ORDER BY id_evento, fecha_corte;
ROLLBACK;  -- cambiar a COMMIT para dejar los datos corregidos

-- ---------------------------------------------------------------------
-- 3.8 Consistencia atributo-geometría: ¿el punto está en la comuna declarada?
-- ---------------------------------------------------------------------
SELECT i.id_infra, i.nombre, i.cod_comuna AS declarada, c.cod_comuna AS segun_geometria, c.nombre
FROM infraestructura i
JOIN comuna c ON ST_Within(i.geom, c.geom)
WHERE c.cod_comuna <> i.cod_comuna;
-- Esperado: CESFAM Miraflores declarado en Valparaíso, ubicado en Viña del Mar.

-- Regla de integridad espacial como trigger (evita nuevos casos)
CREATE OR REPLACE FUNCTION fn_chk_punto_en_comuna() RETURNS trigger AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM riesgo.comuna c
                   WHERE c.cod_comuna = NEW.cod_comuna
                     AND ST_Intersects(c.geom, NEW.geom)) THEN
        RAISE EXCEPTION 'La geometría de % no está en la comuna %', NEW.nombre, NEW.cod_comuna;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_infra_en_comuna ON infraestructura;
CREATE TRIGGER tg_infra_en_comuna
BEFORE INSERT OR UPDATE OF geom, cod_comuna ON infraestructura
FOR EACH ROW EXECUTE FUNCTION fn_chk_punto_en_comuna();

BEGIN;
UPDATE infraestructura SET cod_comuna = '05109' WHERE id_infra = 19;   -- corrección: pasa
DO $$ BEGIN
  INSERT INTO riesgo.infraestructura (nombre, id_tipo, cod_comuna, x_utm, y_utm, geom)
  VALUES ('Prueba fuera', 2, '05103', 250000, 6330000,
          ST_SetSRID(ST_MakePoint(250000, 6330000), 32719));
EXCEPTION WHEN raise_exception THEN RAISE NOTICE 'Trigger: %', SQLERRM; END $$;
ROLLBACK;

-- ---------------------------------------------------------------------
-- 3.9 Relaciones topológicas entre comunas (matriz de vecindad)
-- ---------------------------------------------------------------------
SELECT a.nombre AS comuna_a, b.nombre AS comuna_b,
       ST_Touches(a.geom, b.geom)   AS se_tocan,
       ST_Overlaps(a.geom, b.geom)  AS se_solapan,
       ST_Relate(a.geom, b.geom)    AS de9im,
       round(ST_Length(ST_Intersection(a.geom, b.geom))::numeric) AS limite_comun_m
FROM comuna a
JOIN comuna b ON a.cod_comuna < b.cod_comuna AND ST_Intersects(a.geom, b.geom)
ORDER BY a.nombre, b.nombre;
-- Esperado: ninguna comuna se solapa (partición correcta del territorio).

-- ---------------------------------------------------------------------
-- 3.10 Índices espaciales: efecto medible con 200.000 puntos sintéticos
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS pto_muestreo;
CREATE TABLE pto_muestreo AS
SELECT g AS id,
       ST_SetSRID(ST_MakePoint(248000 + random() * 38000,
                               6300000 + random() * 58000), 32719)::geometry(Point, 32719) AS geom
FROM generate_series(1, 200000) AS g;
ALTER TABLE pto_muestreo ADD PRIMARY KEY (id);
ANALYZE pto_muestreo;

-- Sin índice: Seq Scan
EXPLAIN (ANALYZE, COSTS OFF, TIMING ON)
SELECT count(*) FROM pto_muestreo p
JOIN area_quemada a ON ST_Intersects(p.geom, a.geom)
WHERE a.id_evento = 1;

CREATE INDEX gix_pto_muestreo ON pto_muestreo USING gist (geom);
ANALYZE pto_muestreo;

-- Con índice: Index Scan / Bitmap sobre gix_pto_muestreo
EXPLAIN (ANALYZE, COSTS OFF, TIMING ON)
SELECT count(*) FROM pto_muestreo p
JOIN area_quemada a ON ST_Intersects(p.geom, a.geom)
WHERE a.id_evento = 1;

-- ---------------------------------------------------------------------
-- 3.11 Metadatos, procedencia y atributo temporal
-- ---------------------------------------------------------------------
-- Perímetro más reciente de cada evento (DISTINCT ON)
SELECT DISTINCT ON (id_evento)
       id_evento, fecha_corte, round((ST_Area(geom)/1e4)::numeric, 1) AS ha
FROM area_quemada
ORDER BY id_evento, fecha_corte DESC;

-- Crecimiento del incendio VAL-2024-001 entre cortes
SELECT fecha_corte,
       round((ST_Area(geom)/1e4)::numeric, 1) AS ha,
       round((ST_Area(geom)/1e4 - lag(ST_Area(geom)/1e4) OVER (ORDER BY fecha_corte))::numeric, 1) AS crecimiento_ha
FROM area_quemada WHERE id_evento = 1
ORDER BY fecha_corte;

-- Ficha de metadatos unida al inventario de geometrías
SELECT c.tabla, c.fuente, c.fecha_fuente, c.escala_ref, g.type, g.srid
FROM catalogo_capa c
JOIN geometry_columns g ON g.f_table_schema = 'riesgo' AND g.f_table_name = c.tabla
ORDER BY c.tabla;

COMMENT ON COLUMN area_quemada.fecha_corte IS 'Fecha del perímetro; un evento puede tener varios cortes';
