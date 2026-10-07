-- =====================================================================
-- Diseño de Bases de Geodatos (14504) · USACH
-- Caso territorial · Script i03: extensión espacial (U3)
-- Requiere i01_esquema_relacional.sql y i02_datos.sql
-- Motor: PostgreSQL 16 + PostGIS 3.4
-- Geometrías SINTÉTICAS simplificadas (no usar para análisis real).
-- SRID de trabajo: 32719 (WGS 84 / UTM 19S), unidades en metros.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS postgis;
SET search_path TO riesgo, public;

BEGIN;

-- ---------------------------------------------------------------------
-- 1. Comunas: polígonos simplificados (MultiPolygon)
-- ---------------------------------------------------------------------
ALTER TABLE comuna ADD COLUMN IF NOT EXISTS geom geometry(MultiPolygon, 32719);

UPDATE comuna SET geom = ST_Multi(ST_GeomFromText(w, 32719))
FROM (VALUES
  ('05101', 'POLYGON((248000 6326000, 270000 6326000, 270000 6340000, 256000 6340000, 248000 6340000, 248000 6326000))'),
  ('05102', 'POLYGON((262000 6300000, 290000 6300000, 290000 6326000, 270000 6326000, 262000 6326000, 262000 6300000))'),
  ('05103', 'POLYGON((258000 6350000, 270000 6350000, 270000 6358000, 258000 6358000, 258000 6350000))'),
  ('05109', 'POLYGON((256000 6340000, 270000 6340000, 270000 6350000, 258000 6350000, 256000 6350000, 256000 6340000))'),
  ('05801', 'POLYGON((270000 6336000, 278000 6336000, 278000 6350000, 270000 6350000, 270000 6340000, 270000 6336000))'),
  ('05804', 'POLYGON((278000 6336000, 286000 6336000, 286000 6346000, 278000 6346000, 278000 6336000))')
) AS v(cut, w)
WHERE comuna.cod_comuna = v.cut;

ALTER TABLE comuna ALTER COLUMN geom SET NOT NULL;

-- ---------------------------------------------------------------------
-- 2. Puntos: de columnas x/y a geometría
-- ---------------------------------------------------------------------
ALTER TABLE infraestructura ADD COLUMN IF NOT EXISTS geom geometry(Point, 32719);
UPDATE infraestructura SET geom = ST_SetSRID(ST_MakePoint(x_utm, y_utm), 32719);
ALTER TABLE infraestructura ALTER COLUMN geom SET NOT NULL;

ALTER TABLE evento_incendio ADD COLUMN IF NOT EXISTS geom geometry(Point, 32719);
UPDATE evento_incendio SET geom = ST_SetSRID(ST_MakePoint(x_utm, y_utm), 32719);
ALTER TABLE evento_incendio ALTER COLUMN geom SET NOT NULL;

-- ---------------------------------------------------------------------
-- 3. Áreas quemadas (perímetros con fecha de corte = atributo temporal)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS area_quemada;
CREATE TABLE area_quemada (
    id_area      serial PRIMARY KEY,
    id_evento    integer NOT NULL REFERENCES evento_incendio (id_evento) ON DELETE CASCADE,
    fecha_corte  date    NOT NULL,
    fuente       varchar(60) NOT NULL DEFAULT 'Sintético curso 14504',
    geom         geometry(MultiPolygon, 32719) NOT NULL,
    CONSTRAINT ck_area_valida CHECK (ST_IsValid(geom)),
    CONSTRAINT ck_area_no_vacia CHECK (NOT ST_IsEmpty(geom)),
    UNIQUE (id_evento, fecha_corte)
);

INSERT INTO area_quemada (id_evento, fecha_corte, geom) VALUES
  (1, '2024-02-03', ST_Multi(ST_GeomFromText('POLYGON((268500 6345500, 271000 6345000, 273000 6346000, 272800 6348500, 270000 6349000, 268500 6347800, 268500 6345500))', 32719))),
  (1, '2024-02-06', ST_Multi(ST_GeomFromText('POLYGON((266200 6345500, 268000 6344200, 271000 6344000, 274000 6345500, 274500 6348500, 272000 6350000, 268500 6349800, 266200 6347800, 266200 6345500))', 32719))),
  (2, '2024-02-05', ST_Multi(ST_GeomFromText('POLYGON((281800 6343200, 285600 6343400, 285900 6345800, 283000 6345900, 281800 6345000, 281800 6343200))', 32719))),
  (3, '2024-02-03', ST_Multi(ST_GeomFromText('POLYGON((258700 6348700, 259400 6348700, 259400 6349300, 258700 6349300, 258700 6348700))', 32719))),
  (4, '2023-12-23', ST_Multi(ST_GeomFromText('POLYGON((255500 6330000, 258800 6330200, 258500 6332000, 256000 6332100, 255500 6330000))', 32719)));

-- ---------------------------------------------------------------------
-- 4. Red vial (MultiLineString)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS via;
CREATE TABLE via (
    id_via     serial PRIMARY KEY,
    nombre     varchar(80) NOT NULL,
    categoria  varchar(20) NOT NULL
               CHECK (categoria IN ('Autopista','Ruta nacional','Ruta regional','Urbana')),
    geom       geometry(MultiLineString, 32719) NOT NULL
);

INSERT INTO via (nombre, categoria, geom) VALUES
  ('Ruta 68',              'Ruta nacional', ST_Multi(ST_GeomFromText('LINESTRING(256000 6336000, 266000 6328000, 278000 6322000, 290000 6318000)', 32719))),
  ('Troncal Sur',          'Autopista',     ST_Multi(ST_GeomFromText('LINESTRING(264000 6343000, 272000 6341000, 286000 6339000)', 32719))),
  ('Camino Internacional', 'Ruta nacional', ST_Multi(ST_GeomFromText('LINESTRING(263000 6351000, 275000 6350500, 286000 6347000)', 32719))),
  ('Avenida España',       'Urbana',        ST_Multi(ST_GeomFromText('LINESTRING(256000 6337500, 262000 6343000)', 32719))),
  ('Avenida Borgoño',      'Urbana',        ST_Multi(ST_GeomFromText('LINESTRING(259000 6346000, 262000 6356000)', 32719))),
  ('Camino El Olivar',     'Urbana',        ST_Multi(ST_GeomFromText('LINESTRING(265000 6344000, 269000 6347000, 273500 6349500)', 32719)));

-- ---------------------------------------------------------------------
-- 5. Tabla de paso con errores intencionales (para ejercicios de calidad)
--    Sin CHECK de validez ni tipo fijo: así llegan los datos "del mundo"
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS stg_area_quemada;
CREATE TABLE stg_area_quemada (
    id_stg     serial PRIMARY KEY,
    id_evento  integer,
    origen     varchar(40),
    geom       geometry
);

INSERT INTO stg_area_quemada (id_evento, origen, geom) VALUES
  (5, 'Brigada terreno (moño)',           ST_GeomFromText('POLYGON((268000 6356000, 269000 6357000, 269000 6356000, 268000 6357000, 268000 6356000))', 32719)),
  (6, 'Planilla GPS en grados',            ST_GeomFromText('POLYGON((-71.66 -33.07, -71.64 -33.07, -71.64 -33.05, -71.66 -33.05, -71.66 -33.07))', 32719)),
  (7, 'Digitalización correcta',          ST_GeomFromText('POLYGON((284800 6337300, 285300 6337300, 285300 6337700, 284800 6337700, 284800 6337300))', 32719)),
  (8, 'Anillo sin cerrar corregido a mano', ST_GeomFromText('POLYGON((274000 6314000, 276000 6314000, 276000 6316000, 275000 6315000, 276000 6316000, 274000 6316000, 274000 6314000))', 32719));

-- ---------------------------------------------------------------------
-- 6. Metadatos y procedencia por capa
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS catalogo_capa;
CREATE TABLE catalogo_capa (
    tabla          varchar(63) PRIMARY KEY,
    descripcion    text        NOT NULL,
    fuente         varchar(120) NOT NULL,
    fecha_fuente   date,
    licencia       varchar(60),
    escala_ref     varchar(20),
    srid           integer     NOT NULL,
    responsable    varchar(60) NOT NULL,
    actualizado    timestamptz NOT NULL DEFAULT now()
);

INSERT INTO catalogo_capa (tabla, descripcion, fuente, fecha_fuente, licencia, escala_ref, srid, responsable) VALUES
  ('comuna',          'Límites comunales simplificados',        'Sintético curso 14504 (ref. BCN/INE)', '2024-01-01', 'Uso docente', '1:250.000', 32719, 'Equipo docente'),
  ('infraestructura', 'Establecimientos críticos y servicios',  'Sintético curso 14504 (ref. MINSAL/MINEDUC)', '2024-01-12', 'Uso docente', '1:25.000', 32719, 'Equipo docente'),
  ('evento_incendio', 'Focos de incendio forestal',             'Sintético curso 14504 (ref. CONAF)', '2025-03-01', 'Uso docente', '1:50.000', 32719, 'Equipo docente'),
  ('area_quemada',    'Perímetros de área afectada por fecha',  'Sintético curso 14504 (ref. CONAF)', '2024-02-06', 'Uso docente', '1:50.000', 32719, 'Equipo docente'),
  ('via',             'Red vial principal simplificada',        'Sintético curso 14504 (ref. MOP)', '2024-01-01', 'Uso docente', '1:250.000', 32719, 'Equipo docente');

-- ---------------------------------------------------------------------
-- 7. Índices espaciales GiST y estadísticas
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS gix_comuna_geom   ON comuna          USING gist (geom);
CREATE INDEX IF NOT EXISTS gix_infra_geom    ON infraestructura USING gist (geom);
CREATE INDEX IF NOT EXISTS gix_evento_geom   ON evento_incendio USING gist (geom);
CREATE INDEX IF NOT EXISTS gix_area_geom     ON area_quemada    USING gist (geom);
CREATE INDEX IF NOT EXISTS gix_via_geom      ON via             USING gist (geom);

COMMIT;

ANALYZE comuna; ANALYZE infraestructura; ANALYZE evento_incendio;
ANALYZE area_quemada; ANALYZE via;

-- Verificación: inventario de columnas geométricas registradas
SELECT f_table_name AS tabla, f_geometry_column AS columna, type AS tipo, srid
FROM geometry_columns
WHERE f_table_schema = 'riesgo'
ORDER BY 1;
