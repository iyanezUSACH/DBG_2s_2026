-- =====================================================================
-- Diseño de Bases de Geodatos (14504) · USACH
-- Unidad 4 · Script i05: soluciones de la Guía U4
-- Requiere i01, i02 e i03 (y i04_espacial_soluciones.sql para 4.15)
-- Criterio general: usar el perímetro MÁS RECIENTE de cada evento.
-- =====================================================================

SET search_path TO riesgo, public;

-- Vista auxiliar: último perímetro por evento
CREATE OR REPLACE VIEW v_area_vigente AS
SELECT DISTINCT ON (id_evento) id_area, id_evento, fecha_corte, geom
FROM area_quemada
ORDER BY id_evento, fecha_corte DESC;

-- ---------------------------------------------------------------------
-- 4.1 Contención: establecimientos DENTRO de un área quemada
-- ---------------------------------------------------------------------
SELECT e.codigo, i.nombre, t.nombre AS tipo, t.critica
FROM v_area_vigente a
JOIN evento_incendio e      USING (id_evento)
JOIN infraestructura i      ON ST_Within(i.geom, a.geom)
JOIN tipo_infraestructura t ON t.id_tipo = i.id_tipo
ORDER BY e.codigo, i.nombre;

-- ---------------------------------------------------------------------
-- 4.2 Proximidad: establecimientos críticos a menos de 2.000 m de un área
--     (fuera de ella), con su distancia. ST_DWithin usa el índice GiST.
-- ---------------------------------------------------------------------
SELECT e.codigo, i.nombre, round(ST_Distance(i.geom, a.geom)) AS dist_m
FROM v_area_vigente a
JOIN evento_incendio e      USING (id_evento)
JOIN infraestructura i      ON ST_DWithin(i.geom, a.geom, 2000)
JOIN tipo_infraestructura t ON t.id_tipo = i.id_tipo AND t.critica
WHERE NOT ST_Intersects(i.geom, a.geom)
ORDER BY dist_m;

-- ---------------------------------------------------------------------
-- 4.3 Join espacial punto-en-polígono: comuna real de cada foco
-- ---------------------------------------------------------------------
SELECT e.codigo, e.cod_comuna AS declarada, c.cod_comuna AS geometrica, c.nombre,
       (e.cod_comuna = c.cod_comuna) AS consistente
FROM evento_incendio e
LEFT JOIN comuna c ON ST_Intersects(e.geom, c.geom)
ORDER BY e.codigo;

-- ---------------------------------------------------------------------
-- 4.4 Áreas quemadas que afectan a más de una comuna
-- ---------------------------------------------------------------------
SELECT e.codigo, count(*) AS n_comunas, string_agg(c.nombre, ', ' ORDER BY c.nombre) AS comunas
FROM v_area_vigente a
JOIN evento_incendio e USING (id_evento)
JOIN comuna c ON ST_Intersects(a.geom, c.geom)
            AND NOT ST_Touches(a.geom, c.geom)
GROUP BY e.codigo
HAVING count(*) > 1;

-- ---------------------------------------------------------------------
-- 4.5 Vecindad topológica: comunas que limitan con Viña del Mar
-- ---------------------------------------------------------------------
SELECT v.nombre AS vecina,
       CASE WHEN ST_Dimension(ST_Intersection(b.geom, v.geom)) = 1
            THEN 'Comparten borde' ELSE 'Solo un vértice' END AS tipo_contacto
FROM comuna b
JOIN comuna v ON ST_Touches(b.geom, v.geom)
WHERE b.nombre = 'Viña del Mar'
ORDER BY v.nombre;

-- ---------------------------------------------------------------------
-- 4.6 Vías cortadas: longitud de cada vía dentro de áreas quemadas
-- ---------------------------------------------------------------------
SELECT v.nombre, v.categoria, e.codigo,
       round(ST_Length(ST_Intersection(v.geom, a.geom))) AS largo_afectado_m,
       round((100 * ST_Length(ST_Intersection(v.geom, a.geom)) / ST_Length(v.geom))::numeric, 1) AS pct_via
FROM via v
JOIN v_area_vigente a  ON ST_Intersects(v.geom, a.geom)
JOIN evento_incendio e USING (id_evento)
ORDER BY largo_afectado_m DESC;

-- ---------------------------------------------------------------------
-- 4.7 Agregación espacial: críticos por comuna usando la GEOMETRÍA (no la FK)
-- ---------------------------------------------------------------------
SELECT c.nombre,
       count(i.id_infra) AS n_criticos_geom,
       sum(CASE WHEN i.id_tipo = 1 THEN i.capacidad ELSE 0 END) AS camas
FROM comuna c
LEFT JOIN (infraestructura i
           JOIN tipo_infraestructura t ON t.id_tipo = i.id_tipo AND t.critica)
       ON ST_Intersects(c.geom, i.geom)
GROUP BY c.nombre
ORDER BY n_criticos_geom DESC, c.nombre;

-- ---------------------------------------------------------------------
-- 4.8 Superficie quemada por comuna (intersección polígono-polígono)
-- ---------------------------------------------------------------------
WITH quemado AS (
    SELECT c.cod_comuna, ST_Union(ST_Intersection(c.geom, a.geom)) AS geom
    FROM comuna c
    JOIN v_area_vigente a ON ST_Intersects(c.geom, a.geom)
    GROUP BY c.cod_comuna
)
SELECT c.nombre,
       round((ST_Area(q.geom) / 1e4)::numeric, 1)                  AS quemado_ha,
       round((100 * ST_Area(q.geom) / ST_Area(c.geom))::numeric, 2) AS pct_comuna
FROM quemado q
JOIN comuna c USING (cod_comuna)
ORDER BY quemado_ha DESC;

-- ---------------------------------------------------------------------
-- 4.9 KNN: cuartel de bomberos más cercano a cada foco (operador <->)
-- ---------------------------------------------------------------------
SELECT e.codigo, b.nombre AS cuartel_mas_cercano, round(b.dist) AS dist_m
FROM evento_incendio e
CROSS JOIN LATERAL (
    SELECT i.nombre, ST_Distance(i.geom, e.geom) AS dist
    FROM infraestructura i
    WHERE i.id_tipo = 4
    ORDER BY i.geom <-> e.geom
    LIMIT 1
) AS b
ORDER BY dist_m DESC;

-- ---------------------------------------------------------------------
-- 4.10 Los 3 establecimientos críticos más cercanos a cada foco ACTIVO
-- ---------------------------------------------------------------------
SELECT e.codigo, k.rk, k.nombre, round(k.dist) AS dist_m
FROM evento_incendio e
CROSS JOIN LATERAL (
    SELECT i.nombre, ST_Distance(i.geom, e.geom) AS dist,
           row_number() OVER (ORDER BY i.geom <-> e.geom) AS rk
    FROM infraestructura i
    JOIN tipo_infraestructura t ON t.id_tipo = i.id_tipo AND t.critica
    ORDER BY i.geom <-> e.geom
    LIMIT 3
) AS k
WHERE e.fecha_control IS NULL
ORDER BY e.codigo, k.rk;

-- ---------------------------------------------------------------------
-- 4.11 Población expuesta aproximada (ponderación areal, supuesto de
--      distribución homogénea; discutir sus límites)
-- ---------------------------------------------------------------------
SELECT e.codigo, c.nombre,
       round((100 * ST_Area(ST_Intersection(c.geom, a.geom)) / ST_Area(c.geom))::numeric, 2) AS pct_area,
       round(c.poblacion * ST_Area(ST_Intersection(c.geom, a.geom)) / ST_Area(c.geom)) AS pob_expuesta_aprox
FROM v_area_vigente a
JOIN evento_incendio e USING (id_evento)
JOIN comuna c ON ST_Intersects(c.geom, a.geom)
ORDER BY pob_expuesta_aprox DESC;

-- ---------------------------------------------------------------------
-- 4.12 Área de influencia: buffer de 500 m + disolución (ST_Union)
-- ---------------------------------------------------------------------
WITH amenaza AS (
    SELECT ST_Union(ST_Buffer(geom, 500)) AS geom FROM v_area_vigente
)
SELECT round((ST_Area(geom) / 1e4)::numeric, 1) AS zona_amenaza_ha,
       ST_NumGeometries(geom) AS n_parches
FROM amenaza;

WITH amenaza AS (
    SELECT ST_Union(ST_Buffer(geom, 500)) AS geom FROM v_area_vigente
)
SELECT i.nombre, t.nombre AS tipo
FROM infraestructura i
JOIN tipo_infraestructura t USING (id_tipo)
JOIN amenaza z ON ST_Intersects(i.geom, z.geom)
ORDER BY t.nombre, i.nombre;

-- ---------------------------------------------------------------------
-- 4.13 Recorte: kilómetros de red vial por comuna y categoría
-- ---------------------------------------------------------------------
SELECT c.nombre, v.categoria,
       round((sum(ST_Length(ST_Intersection(v.geom, c.geom))) / 1000)::numeric, 2) AS km
FROM comuna c
JOIN via v ON ST_Intersects(v.geom, c.geom)
GROUP BY c.nombre, v.categoria
ORDER BY c.nombre, km DESC;

-- ---------------------------------------------------------------------
-- 4.14 Unión y envolventes: contorno del área de estudio y de los focos
-- ---------------------------------------------------------------------
SELECT round((ST_Area(ST_Union(geom)) / 1e6)::numeric, 1) AS area_estudio_km2,
       ST_GeometryType(ST_Union(geom))                    AS tipo_resultado
FROM comuna;

SELECT round((ST_Area(ST_ConvexHull(ST_Collect(geom))) / 1e6)::numeric, 1) AS envolvente_focos_km2,
       ST_AsText(ST_Centroid(ST_Collect(geom)))                              AS centroide_focos
FROM evento_incendio;

-- ---------------------------------------------------------------------
-- 4.15 Planes de ejecución: consulta "sargable" vs no sargable
--      (usa pto_muestreo creada en 3.10)
-- ---------------------------------------------------------------------
-- (a) NO usa el índice: la función envuelve la columna
EXPLAIN (ANALYZE, COSTS OFF)
SELECT count(*) FROM pto_muestreo p, evento_incendio e
WHERE e.id_evento = 1 AND ST_Distance(p.geom, e.geom) < 1000;

-- (b) SÍ usa el índice: ST_DWithin agrega un filtro por caja envolvente
EXPLAIN (ANALYZE, COSTS OFF)
SELECT count(*) FROM pto_muestreo p, evento_incendio e
WHERE e.id_evento = 1 AND ST_DWithin(p.geom, e.geom, 1000);

-- ---------------------------------------------------------------------
-- 4.16 Producto para el cliente: vista espacial para QGIS/ArcGIS
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_exposicion_critica AS
SELECT i.id_infra, i.nombre, t.nombre AS tipo, c.nombre AS comuna,
       CASE WHEN ST_Intersects(i.geom, a.geom) THEN 'Dentro'
            WHEN ST_DWithin(i.geom, a.geom, 500)  THEN '< 500 m'
            ELSE '500–2000 m' END AS nivel,
       round(ST_Distance(i.geom, a.geom)) AS dist_m,
       e.codigo AS evento,
       i.geom::geometry(Point, 32719) AS geom
FROM infraestructura i
JOIN tipo_infraestructura t ON t.id_tipo = i.id_tipo AND t.critica
JOIN comuna c ON ST_Intersects(c.geom, i.geom)
JOIN v_area_vigente a ON ST_DWithin(i.geom, a.geom, 2000)
JOIN evento_incendio e ON e.id_evento = a.id_evento;

SELECT nombre, tipo, comuna, nivel, dist_m, evento
FROM v_exposicion_critica ORDER BY dist_m;

-- Exportación y respaldo (desde la terminal):
--   ogr2ogr -f GPKG exposicion.gpkg PG:"dbname=geodatos" riesgo.v_exposicion_critica
--   pg_dump -d geodatos -n riesgo -Fc -f riesgo_$(date +%Y%m%d).dump
--   pg_restore -d geodatos_copia riesgo_YYYYMMDD.dump
