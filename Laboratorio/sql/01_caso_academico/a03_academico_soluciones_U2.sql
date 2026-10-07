-- =====================================================================
-- Diseño de Bases de Geodatos (14504) · USACH · 2º semestre 2026
-- Caso clásico · Script a03: soluciones de la Guía U2
-- Requiere a01_esquema.sql y a02_datos.sql. Re-ejecutable.
-- =====================================================================

SET search_path TO academico, public;

-- 2.1 Explorar el esquema desde el catálogo ---------------------------
SELECT table_name, column_name, data_type, domain_name, is_nullable
FROM information_schema.columns
WHERE table_schema = 'academico'
ORDER BY table_name, ordinal_position;

-- 2.2 ALTER TABLE con restricción, dentro de una transacción -----------
BEGIN;
ALTER TABLE persona ADD COLUMN telefono varchar(12)
    CHECK (telefono ~ '^\+56[0-9]{9}$');
UPDATE persona SET telefono = '+56912345678' WHERE rut = '20111222-4';
SELECT rut, nombres, telefono FROM persona WHERE rut = '20111222-4';
ALTER TABLE persona DROP COLUMN telefono;
ROLLBACK;

-- 2.3 Nueva tabla con dos FK a la misma tabla y un CHECK ----------------
BEGIN;
CREATE TABLE tutoria (
    id_tutoria   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rut_estudiante d_rut NOT NULL REFERENCES estudiante (rut) ON DELETE CASCADE,
    rut_profesor   d_rut NOT NULL REFERENCES profesor (rut)  ON DELETE RESTRICT,
    fecha        date    NOT NULL DEFAULT current_date,
    tema         varchar(80) NOT NULL,
    CONSTRAINT ck_tutoria_distinta CHECK (rut_estudiante <> rut_profesor)
);
INSERT INTO tutoria (rut_estudiante, rut_profesor, tema)
VALUES ('20444555-6', '12345678-5', 'Prerrequisitos pendientes');
SELECT * FROM tutoria;
ROLLBACK;

-- 2.4 Cuatro INSERT que deben fallar ------------------------------------
DO $$ BEGIN
  INSERT INTO academico.inscripcion (rut_estudiante, cod_asig, periodo, num_seccion, nota, estado)
  VALUES ('21222333-0', '14504', '2026-2', 1, 7.5, 'Aprobada');
EXCEPTION WHEN check_violation THEN RAISE NOTICE '(a) nota fuera de dominio: %', SQLERRM; END $$;
DO $$ BEGIN
  INSERT INTO academico.persona (rut, nombres, apellidos, email, fecha_nac)
  VALUES ('21222333-A', 'X', 'Y', 'x@y.cl', '2006-01-01');
EXCEPTION WHEN check_violation THEN RAISE NOTICE '(b) RUT mal formado: %', SQLERRM; END $$;
DO $$ BEGIN
  INSERT INTO academico.inscripcion (rut_estudiante, cod_asig, periodo, num_seccion)
  VALUES ('21222333-0', '14504', '2026-2', 9);
EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE '(c) sección inexistente: %', SQLERRM; END $$;
DO $$ BEGIN
  INSERT INTO academico.inscripcion (rut_estudiante, cod_asig, periodo, num_seccion)
  VALUES ('20111222-4', '14504', '2026-2', 2);
EXCEPTION WHEN unique_violation THEN RAISE NOTICE '(d) PK duplicada: %', SQLERRM; END $$;

-- 2.5 RESTRICT vs CASCADE ----------------------------------------------
BEGIN;
DO $$ BEGIN
  DELETE FROM academico.departamento WHERE cod_depto = 'DIGEA';
EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'RESTRICT: %', SQLERRM; END $$;
-- Florencia no tiene inscripciones: borrar la persona arrastra su fila de estudiante
DELETE FROM persona WHERE rut = '21222333-0';
SELECT count(*) AS queda_estudiante FROM estudiante WHERE rut = '21222333-0';
ROLLBACK;

-- 2.6 Filtro y orden ----------------------------------------------------
SELECT p.apellidos, p.nombres, e.anio_ingreso
FROM estudiante e JOIN persona p USING (rut)
WHERE e.cod_carrera = 'ICTM'
ORDER BY p.apellidos, p.nombres;

-- 2.7 Funciones de fecha ------------------------------------------------
SELECT p.nombres || ' ' || p.apellidos AS estudiante,
       date_part('year', age(DATE '2026-09-21', p.fecha_nac)) AS edad,
       2026 - e.anio_ingreso AS anios_en_la_carrera
FROM estudiante e JOIN persona p USING (rut)
ORDER BY edad DESC;

-- 2.8 NULL: estado de las inscripciones del período en curso ------------
SELECT rut_estudiante, cod_asig,
       COALESCE(nota::text, 'En curso') AS nota,
       CASE WHEN nota IS NULL THEN 'Sin calificar' ELSE 'Calificada' END AS situacion
FROM inscripcion
WHERE periodo = '2026-2'
ORDER BY cod_asig, rut_estudiante;

-- 2.9 Agregación por asignatura (período cerrado) ----------------------
SELECT a.nombre, count(i.nota) AS n_notas,
       round(avg(i.nota), 2) AS promedio, min(i.nota), max(i.nota)
FROM inscripcion i JOIN asignatura a USING (cod_asig)
WHERE i.periodo = '2026-1'
GROUP BY a.nombre
ORDER BY promedio DESC;

-- 2.10 HAVING -----------------------------------------------------------
SELECT cod_asig, count(*) AS inscritos
FROM inscripcion
WHERE periodo = '2026-2'
GROUP BY cod_asig
HAVING count(*) > 2
ORDER BY inscritos DESC;

-- 2.11 count(*) vs count(columna) por sección -----------------------------
SELECT cod_asig, periodo, num_seccion,
       count(*)              AS inscritos,
       count(nota)           AS con_nota,
       count(*) - count(nota) AS sin_nota,
       round(avg(nota), 2)   AS promedio
FROM inscripcion
GROUP BY cod_asig, periodo, num_seccion
ORDER BY periodo, cod_asig, num_seccion;

-- 2.12 Operaciones de conjuntos -------------------------------------------
-- (a) personas que son estudiante o profesor
SELECT rut FROM estudiante UNION SELECT rut FROM profesor ORDER BY 1;
-- (b) personas que son estudiante y profesor (especialización solapada)
SELECT rut FROM estudiante INTERSECT SELECT rut FROM profesor;
-- (c) estudiantes que cursaron en 2026-1 y no se inscribieron en 2026-2
SELECT rut_estudiante FROM inscripcion WHERE periodo = '2026-1'
EXCEPT
SELECT rut_estudiante FROM inscripcion WHERE periodo = '2026-2'
ORDER BY 1;

-- 2.13 JOIN de cinco tablas -----------------------------------------------
SELECT pe.apellidos AS estudiante, a.nombre AS asignatura, i.num_seccion,
       pp.apellidos AS profesor, h.dia, b.hora_inicio, h.cod_sala
FROM inscripcion i
JOIN persona    pe ON pe.rut = i.rut_estudiante
JOIN asignatura a  ON a.cod_asig = i.cod_asig
JOIN seccion    s  ON (s.cod_asig, s.periodo, s.num_seccion) = (i.cod_asig, i.periodo, i.num_seccion)
JOIN persona    pp ON pp.rut = s.rut_profesor
JOIN seccion_horario h ON (h.cod_asig, h.periodo, h.num_seccion) = (s.cod_asig, s.periodo, s.num_seccion)
JOIN bloque_horario b  ON b.num_bloque = h.num_bloque
WHERE i.periodo = '2026-2'
ORDER BY a.nombre, pe.apellidos, h.dia;

-- 2.14 LEFT JOIN: todas las secciones, aunque estén vacías ----------------
SELECT s.cod_asig, s.num_seccion, s.cupo,
       count(i.rut_estudiante) AS inscritos,
       s.cupo - count(i.rut_estudiante) AS vacantes
FROM seccion s
LEFT JOIN inscripcion i
       ON (i.cod_asig, i.periodo, i.num_seccion) = (s.cod_asig, s.periodo, s.num_seccion)
WHERE s.periodo = '2026-2'
GROUP BY s.cod_asig, s.num_seccion, s.cupo
ORDER BY inscritos, s.cod_asig;
-- estudiantes sin ninguna inscripción
SELECT p.nombres, p.apellidos
FROM estudiante e JOIN persona p USING (rut)
LEFT JOIN inscripcion i ON i.rut_estudiante = e.rut
WHERE i.rut_estudiante IS NULL;

-- 2.15 Subconsulta correlacionada -----------------------------------------
SELECT i.rut_estudiante, i.cod_asig, i.nota
FROM inscripcion i
WHERE i.nota > (SELECT avg(i2.nota) FROM inscripcion i2
                WHERE i2.cod_asig = i.cod_asig AND i2.periodo = i.periodo)
ORDER BY i.cod_asig, i.nota DESC;

-- 2.16 CTE + ventana: promedio ponderado por créditos y ranking en la carrera
WITH ppa AS (
    SELECT i.rut_estudiante,
           round(sum(i.nota * a.creditos) / sum(a.creditos), 2) AS ppa,
           sum(a.creditos) FILTER (WHERE i.estado = 'Aprobada') AS creditos_aprobados
    FROM inscripcion i JOIN asignatura a USING (cod_asig)
    WHERE i.nota IS NOT NULL
    GROUP BY i.rut_estudiante
)
SELECT e.cod_carrera, p.apellidos, ppa.ppa, ppa.creditos_aprobados,
       rank() OVER (PARTITION BY e.cod_carrera ORDER BY ppa.ppa DESC) AS ranking
FROM ppa
JOIN estudiante e ON e.rut = ppa.rut_estudiante
JOIN persona p    ON p.rut = e.rut
ORDER BY e.cod_carrera, ranking;

-- 2.17 Vista: acta de notas ---------------------------------------------
CREATE OR REPLACE VIEW v_acta AS
SELECT i.periodo, a.cod_asig, a.nombre AS asignatura, i.num_seccion,
       p.rut, p.apellidos || ', ' || p.nombres AS estudiante,
       i.nota, i.estado
FROM inscripcion i
JOIN asignatura a ON a.cod_asig = i.cod_asig
JOIN persona p    ON p.rut = i.rut_estudiante;

SELECT * FROM v_acta WHERE periodo = '2026-1' ORDER BY asignatura, estudiante;

-- 2.18 Roles y privilegios ------------------------------------------------
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_consulta_14504') THEN
    CREATE ROLE rol_consulta_14504 NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_secretaria_14504') THEN
    CREATE ROLE rol_secretaria_14504 NOLOGIN; END IF;
END $$;
GRANT USAGE ON SCHEMA academico TO rol_consulta_14504, rol_secretaria_14504;
GRANT SELECT ON v_acta TO rol_consulta_14504;
GRANT SELECT ON ALL TABLES IN SCHEMA academico TO rol_secretaria_14504;
GRANT INSERT, UPDATE ON inscripcion TO rol_secretaria_14504;

BEGIN;
SET LOCAL ROLE rol_consulta_14504;
SELECT count(*) AS filas_acta FROM v_acta;
DO $$ BEGIN
  PERFORM * FROM academico.inscripcion;
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'consulta no ve la tabla base: %', SQLERRM; END $$;
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_secretaria_14504;
INSERT INTO inscripcion (rut_estudiante, cod_asig, periodo, num_seccion)
VALUES ('21222333-0', '10102', '2026-2', 1);
SELECT count(*) AS inscritos_algebra FROM inscripcion WHERE cod_asig = '10102' AND periodo = '2026-2';
ROLLBACK;

-- 2.19 Intercambio de datos (desde psql) ----------------------------------
--   \copy (SELECT * FROM academico.v_acta) TO 'acta.csv' CSV HEADER
--   CREATE TABLE academico.stg_persona (LIKE academico.persona);  -- sin dominios: usar text
--   ...validar: SELECT * FROM stg WHERE rut !~ '^[0-9]{7,8}-[0-9K]$';

-- 2.20 Desafío: consultas de negocio que cruzan reglas ---------------------
-- (a) inscripciones 2026-2 que no cumplen prerrequisitos aprobados
SELECT i.rut_estudiante, i.cod_asig, pr.cod_prereq AS prerrequisito_faltante
FROM inscripcion i
JOIN prerrequisito pr ON pr.cod_asig = i.cod_asig
WHERE i.periodo = '2026-2'
  AND NOT EXISTS (SELECT 1 FROM inscripcion ap
                  WHERE ap.rut_estudiante = i.rut_estudiante
                    AND ap.cod_asig = pr.cod_prereq
                    AND ap.estado = 'Aprobada')
ORDER BY 1, 2;

-- (b) cadena completa de prerrequisitos de Inteligencia Territorial (CTE recursiva)
WITH RECURSIVE cadena AS (
    SELECT cod_asig, cod_prereq, 1 AS nivel
    FROM prerrequisito WHERE cod_asig = '14520'
    UNION ALL
    SELECT p.cod_asig, p.cod_prereq, c.nivel + 1
    FROM prerrequisito p JOIN cadena c ON p.cod_asig = c.cod_prereq
)
SELECT c.nivel, a.cod_asig, a.nombre
FROM cadena c JOIN asignatura a ON a.cod_asig = c.cod_prereq
ORDER BY c.nivel, a.cod_asig;

-- =====================================================================
-- E. La ubicación como atributo (puente hacia la Unidad 3)
-- =====================================================================

-- 2.21 Distancia domicilio -> campus con la fórmula de haversine en SQL puro.
--      En la U3 esto será ST_Distance sobre una columna geometry.
CREATE OR REPLACE FUNCTION km_haversine(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric)
RETURNS numeric AS $$
  SELECT round((6371 * 2 * asin(sqrt(
           power(sin(radians(lat2 - lat1) / 2), 2) +
           cos(radians(lat1)) * cos(radians(lat2)) *
           power(sin(radians(lon2 - lon1) / 2), 2))))::numeric, 2);
$$ LANGUAGE sql IMMUTABLE;

SELECT p.apellidos || ', ' || p.nombres AS estudiante,
       c.nombre AS comuna,
       km_haversine(d.latitud, d.longitud, ca.latitud, ca.longitud) AS km_al_campus
FROM estudiante e
JOIN persona   p  ON p.rut = e.rut
JOIN domicilio d  ON d.rut = e.rut
JOIN comuna    c  ON c.cod_comuna = d.cod_comuna
CROSS JOIN campus ca
WHERE ca.cod_campus = 'CEC'
ORDER BY km_al_campus DESC;

-- 2.22 Agregación territorial: distancia media por carrera y comunas de origen
SELECT e.cod_carrera,
       count(*) AS estudiantes,
       round(avg(km_haversine(d.latitud, d.longitud, ca.latitud, ca.longitud)), 2) AS km_promedio,
       max(km_haversine(d.latitud, d.longitud, ca.latitud, ca.longitud))           AS km_max
FROM estudiante e
JOIN domicilio d ON d.rut = e.rut
CROSS JOIN campus ca
WHERE ca.cod_campus = 'CEC'
GROUP BY e.cod_carrera
ORDER BY km_promedio DESC;

SELECT c.nombre AS comuna, count(*) AS estudiantes
FROM estudiante e
JOIN domicilio d ON d.rut = e.rut
JOIN comuna c    ON c.cod_comuna = d.cod_comuna
GROUP BY c.nombre
HAVING count(*) >= 1
ORDER BY estudiantes DESC, comuna;

-- 2.23 ¿Quién está hoy, martes en el bloque 5, y en qué sala y edificio?
SELECT p.nombres || ' ' || p.apellidos AS estudiante,
       cr.nombre AS carrera, a.nombre AS asignatura,
       h.cod_sala, ed.nombre AS edificio, b.hora_inicio, b.hora_fin
FROM inscripcion i
JOIN estudiante e      ON e.rut = i.rut_estudiante
JOIN persona    p      ON p.rut = e.rut
JOIN carrera    cr     ON cr.cod_carrera = e.cod_carrera
JOIN seccion    s      ON (s.cod_asig, s.periodo, s.num_seccion) = (i.cod_asig, i.periodo, i.num_seccion)
JOIN asignatura a      ON a.cod_asig = s.cod_asig
JOIN seccion_horario h ON (h.cod_asig, h.periodo, h.num_seccion) = (s.cod_asig, s.periodo, s.num_seccion)
JOIN bloque_horario  b ON b.num_bloque = h.num_bloque
JOIN sala           sa ON sa.cod_sala = h.cod_sala
JOIN edificio       ed ON ed.cod_edificio = sa.cod_edificio
WHERE i.periodo = '2026-2' AND h.dia = 'Martes' AND h.num_bloque = 5
ORDER BY p.apellidos;

-- 2.24 Uso de las salas: ocupación del martes en el bloque 5 y salas libres
SELECT sa.cod_sala, sa.tipo, sa.capacidad,
       count(i.rut_estudiante) AS inscritos,
       round(100.0 * count(i.rut_estudiante) / sa.capacidad, 1) AS pct_ocupacion,
       (SELECT sum(m.cantidad) FROM mobiliario m
        WHERE m.cod_sala = sa.cod_sala AND m.tipo = 'Computador' AND m.estado = 'Operativo') AS pc_operativos
FROM seccion_horario h
JOIN sala sa ON sa.cod_sala = h.cod_sala
LEFT JOIN inscripcion i
       ON (i.cod_asig, i.periodo, i.num_seccion) = (h.cod_asig, h.periodo, h.num_seccion)
WHERE h.periodo = '2026-2' AND h.dia = 'Martes' AND h.num_bloque = 5
GROUP BY sa.cod_sala, sa.tipo, sa.capacidad;

SELECT sa.cod_sala, sa.tipo, sa.capacidad
FROM sala sa
WHERE NOT EXISTS (SELECT 1 FROM seccion_horario h
                  WHERE h.cod_sala = sa.cod_sala AND h.periodo = '2026-2'
                    AND h.dia = 'Martes' AND h.num_bloque = 5)
ORDER BY sa.cod_sala;

-- 2.25 Puente a la Unidad 3: las mismas preguntas con geometría
--   km_haversine(...)                    ->  ST_Distance(geom_domicilio, geom_campus)
--   WHERE km_haversine(...) <= 5         ->  WHERE ST_DWithin(geom_dom, geom_campus, 5000)
--   JOIN comuna c ON c.cod_comuna = ...  ->  JOIN comuna c ON ST_Within(d.geom, c.geom)
-- La consulta cambia de una sola columna: latitud/longitud pasan a ser geometry(Point, 32719).
