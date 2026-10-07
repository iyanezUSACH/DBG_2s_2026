-- =====================================================================
-- Diseño de Bases de Geodatos (14504) · USACH · 2º semestre 2026
-- Caso clásico · Script a02: datos FICTICIOS del registro académico
-- (nombres, RUT y correos inventados). Requiere a01_esquema.sql
-- =====================================================================

SET search_path TO academico, public;

BEGIN;

INSERT INTO departamento (cod_depto, nombre) VALUES
    ('DIGEA',  'Ingeniería Geoespacial y Ambiental'),
    ('DMCC',  'Matemática y Ciencia de la Computación'),
    ('DIINF', 'Ingeniería Informática');

INSERT INTO carrera (cod_carrera, nombre, cod_depto, duracion_semestres) VALUES
    ('ICTM', 'Ingeniería Civil en Territorio y Medioambiente', 'DIGEA', 12),
    ('ICG',  'Ingeniería Civil en Geografía',                  'DIGEA', 12),
    ('ICI',  'Ingeniería Civil Informática',                   'DIINF', 12);

-- Comunas del Gran Santiago (código único territorial)
INSERT INTO comuna (cod_comuna, nombre, provincia, region) VALUES
    ('13101', 'Santiago',        'Santiago', 'Metropolitana de Santiago'),
    ('13106', 'Cerrillos',       'Santiago', 'Metropolitana de Santiago'),
    ('13110', 'Estación Central','Santiago', 'Metropolitana de Santiago'),
    ('13119', 'Maipú',           'Santiago', 'Metropolitana de Santiago'),
    ('13120', 'Ñuñoa',           'Santiago', 'Metropolitana de Santiago'),
    ('13122', 'Pudahuel',        'Santiago', 'Metropolitana de Santiago'),
    ('13125', 'Quilicura',       'Santiago', 'Metropolitana de Santiago'),
    ('13126', 'Recoleta',        'Santiago', 'Metropolitana de Santiago'),
    ('13130', 'San Miguel',      'Santiago', 'Metropolitana de Santiago'),
    ('13201', 'Puente Alto',     'Cordillera','Metropolitana de Santiago'),
    ('13123', 'La Florida',      'Santiago', 'Metropolitana de Santiago'),
    ('13121', 'Macul',           'Santiago', 'Metropolitana de Santiago');

-- La universidad también tiene dirección y ubicación
INSERT INTO campus (cod_campus, nombre, direccion, cod_comuna, latitud, longitud) VALUES
    ('CEC', 'Campus Estación Central', 'Av. Libertador Bernardo O''Higgins 3363', '13110', -33.448900, -70.683000);

INSERT INTO edificio (cod_edificio, nombre, cod_campus, latitud, longitud) VALUES
    ('EDIGEA',  'Ingeniería Geoespacial y Ambiental', 'CEC', -33.447200, -70.681500),
    ('EDMCC',  'Matemática y Ciencia de la Computación', 'CEC', -33.450100, -70.684800),
    ('EDIINF', 'Ingeniería Informática', 'CEC', -33.449500, -70.686200);

INSERT INTO sala (cod_sala, cod_edificio, piso, capacidad, tipo) VALUES
    ('LAB-GEO', 'EDIGEA',  2, 30, 'Laboratorio'),
    ('B-204',   'EDIGEA',  2, 35, 'Aula'),
    ('A-101',   'EDMCC',  1, 60, 'Aula'),
    ('A-102',   'EDMCC',  1, 60, 'Aula'),
    ('LAB-3',   'EDIINF', 3, 45, 'Laboratorio');

INSERT INTO mobiliario (cod_sala, tipo, cantidad, estado) VALUES
    ('LAB-GEO', 'Puesto de trabajo', 30, 'Operativo'),
    ('LAB-GEO', 'Computador',        20, 'Operativo'),
    ('LAB-GEO', 'Computador',         4, 'En reparación'),
    ('LAB-GEO', 'Proyector',          1, 'Operativo'),
    ('LAB-GEO', 'Pizarra',            1, 'Operativo'),
    ('B-204',   'Puesto de trabajo', 35, 'Operativo'),
    ('B-204',   'Proyector',          1, 'De baja'),
    ('A-101',   'Puesto de trabajo', 60, 'Operativo'),
    ('A-101',   'Proyector',          1, 'Operativo'),
    ('A-102',   'Puesto de trabajo', 60, 'Operativo'),
    ('LAB-3',   'Puesto de trabajo', 45, 'Operativo'),
    ('LAB-3',   'Computador',        45, 'Operativo'),
    ('LAB-3',   'Proyector',          1, 'Operativo');

INSERT INTO bloque_horario (num_bloque, hora_inicio, hora_fin) VALUES
    (1, '08:15', '09:45'), (2, '09:50', '11:20'), (3, '11:30', '13:00'),
    (4, '13:10', '14:40'), (5, '14:50', '16:20'), (6, '16:30', '18:00'),
    (7, '18:10', '19:40'), (8, '19:45', '21:15');

INSERT INTO persona (rut, nombres, apellidos, email, fecha_nac) VALUES
    ('12345678-5', 'Marta',     'Soto Rivas',      'marta.soto@universidad.cl',      '1975-04-12'),
    ('13456789-2', 'Rodrigo',   'Pérez Lagos',     'rodrigo.perez@universidad.cl',   '1980-09-30'),
    ('14567890-K', 'Carolina',  'Muñoz Ortega',    'carolina.munoz@universidad.cl',  '1983-01-18'),
    ('15678901-7', 'Felipe',    'Araya Contreras', 'felipe.araya@universidad.cl',    '1978-11-05'),
    ('16789012-3', 'Daniela',   'Rojas Fuentes',   'daniela.rojas@universidad.cl',   '1990-06-22'),
    ('20111222-4', 'Valentina', 'Castro Núñez',    'valentina.castro@alumnos.cl',    '2004-03-14'),
    ('20222333-1', 'Matías',    'González Vera',   'matias.gonzalez@alumnos.cl',     '2004-07-02'),
    ('20333444-9', 'Javiera',   'Díaz Morales',    'javiera.diaz@alumnos.cl',        '2005-01-27'),
    ('20444555-6', 'Benjamín',  'Silva Tapia',     'benjamin.silva@alumnos.cl',      '2003-10-09'),
    ('20555666-2', 'Catalina',  'Reyes Pino',      'catalina.reyes@alumnos.cl',      '2004-12-20'),
    ('20666777-K', 'Tomás',     'Fernández Leiva', 'tomas.fernandez@alumnos.cl',     '2005-05-16'),
    ('20777888-5', 'Isidora',   'Vargas Molina',   'isidora.vargas@alumnos.cl',      '2004-08-08'),
    ('20888999-1', 'Joaquín',   'Herrera Salinas', 'joaquin.herrera@alumnos.cl',     '2003-02-11'),
    ('21000111-8', 'Antonia',   'Carrasco Bravo',  'antonia.carrasco@alumnos.cl',    '2005-09-03'),
    ('21111222-3', 'Diego',     'Espinoza Olivares','diego.espinoza@alumnos.cl',     '2005-11-25'),
    ('21222333-0', 'Florencia', 'Jiménez Campos',  'florencia.jimenez@alumnos.cl',   '2006-04-01'),
    ('19999000-6', 'Sebastián', 'Navarro Quiroz',  'sebastian.navarro@alumnos.cl',   '1998-12-12');

-- Sebastián Navarro es estudiante de magíster y profesor por horas: especialización solapada
INSERT INTO profesor (rut, cod_depto, jerarquia) VALUES
    ('12345678-5', 'DIGEA',  'Asociado'),
    ('13456789-2', 'DMCC',  'Titular'),
    ('14567890-K', 'DIINF', 'Asistente'),
    ('15678901-7', 'DIGEA',  'Titular'),
    ('16789012-3', 'DIGEA',  'Instructor'),
    ('19999000-6', 'DIGEA',  'Por horas');

INSERT INTO estudiante (rut, cod_carrera, anio_ingreso) VALUES
    ('20111222-4', 'ICTM', 2024),
    ('20222333-1', 'ICTM', 2024),
    ('20333444-9', 'ICTM', 2025),
    ('20444555-6', 'ICTM', 2023),
    ('20555666-2', 'ICG',  2024),
    ('20666777-K', 'ICG',  2025),
    ('20777888-5', 'ICTM', 2024),
    ('20888999-1', 'ICI',  2023),
    ('21000111-8', 'ICTM', 2025),
    ('21111222-3', 'ICG',  2025),
    ('21222333-0', 'ICTM', 2026),
    ('19999000-6', 'ICG',  2017);

INSERT INTO asignatura (cod_asig, nombre, creditos, cod_depto) VALUES
    ('10101', 'Cálculo I',                                  6, 'DMCC'),
    ('10102', 'Álgebra I',                                  6, 'DMCC'),
    ('10145', 'Fundamentos de Programación para Ingeniería',5, 'DIINF'),
    ('14501', 'Geotecnologías',                             5, 'DIGEA'),
    ('14502', 'Cartografía',                                5, 'DIGEA'),
    ('14504', 'Diseño de Bases de Geodatos',                5, 'DIGEA'),
    ('14510', 'Análisis Espacial',                          6, 'DIGEA'),
    ('14520', 'Inteligencia Territorial',                   6, 'DIGEA');

INSERT INTO prerrequisito (cod_asig, cod_prereq) VALUES
    ('14501', '10101'),
    ('14504', '14501'),
    ('14504', '10145'),
    ('14510', '14504'),
    ('14510', '14502'),
    ('14520', '14510');

-- Domicilio de cada persona: la ubicación como atributo (todavía sin geometría)
INSERT INTO domicilio (rut, calle, numero, cod_comuna, latitud, longitud) VALUES
    ('12345678-5', 'Av. Irarrázaval',      '2450', '13120', -33.455900, -70.597400),
    ('13456789-2', 'Gran Avenida',         '4820', '13130', -33.496200, -70.651300),
    ('14567890-K', 'Av. Vitacura',          '820', '13101', -33.443100, -70.652700),
    ('15678901-7', 'Camino Lo Boza',       '1450', '13122', -33.440500, -70.759800),
    ('16789012-3', 'Av. Macul',            '3300', '13121', -33.489700, -70.597900),
    ('20111222-4', 'Pasaje Los Aromos',     '145', '13119', -33.511400, -70.757600),
    ('20222333-1', 'Av. Concha y Toro',    '2210', '13201', -33.610800, -70.576200),
    ('20333444-9', 'Av. Matta',             '980', '13101', -33.457200, -70.645100),
    ('20444555-6', 'Los Alerces',           '332', '13123', -33.537100, -70.576800),
    ('20555666-2', 'Av. Las Rejas',        '1180', '13110', -33.459800, -70.712300),
    ('20666777-K', 'Av. Independencia',    '3450', '13126', -33.409700, -70.660200),
    ('20777888-5', 'Camino a Melipilla',   '7720', '13106', -33.494500, -70.719600),
    ('20888999-1', 'Av. Departamental',    '2150', '13123', -33.520300, -70.601400),
    ('21000111-8', 'Av. Manuel Antonio Matta','450','13125', -33.367400, -70.729500),
    ('21111222-3', 'Pasaje El Roble',       '210', '13119', -33.520600, -70.772800),
    ('21222333-0', 'Av. Salvador',         '1120', '13120', -33.443800, -70.615500),
    ('19999000-6', 'Av. Pedro de Valdivia','1560', '13120', -33.451200, -70.606300);

INSERT INTO seccion (cod_asig, periodo, num_seccion, rut_profesor, cupo) VALUES
    ('10101', '2026-1', 1, '13456789-2', 60),
    ('10145', '2026-1', 1, '14567890-K', 45),
    ('14501', '2026-1', 1, '15678901-7', 40),
    ('14502', '2026-1', 1, '16789012-3', 35),
    ('14504', '2026-2', 1, '12345678-5', 40),
    ('14504', '2026-2', 2, '19999000-6', 30),
    ('14502', '2026-2', 1, '16789012-3', 35),
    ('14510', '2026-2', 1, '15678901-7', 30),
    ('10102', '2026-2', 1, '13456789-2', 60),
    ('10145', '2026-2', 1, '14567890-K', 45);

-- Día, bloque y sala de cada sección (la clase de hoy: martes, bloque 5, LAB-GEO)
INSERT INTO seccion_horario (cod_asig, periodo, num_seccion, dia, num_bloque, cod_sala) VALUES
    ('10101', '2026-1', 1, 'Lunes',     2, 'A-101'),
    ('10145', '2026-1', 1, 'Miércoles', 3, 'LAB-3'),
    ('14501', '2026-1', 1, 'Martes',    5, 'LAB-GEO'),
    ('14502', '2026-1', 1, 'Jueves',    4, 'B-204'),
    ('14504', '2026-2', 1, 'Martes',    5, 'LAB-GEO'),
    ('14504', '2026-2', 1, 'Jueves',    5, 'LAB-GEO'),
    ('14504', '2026-2', 2, 'Miércoles', 6, 'LAB-GEO'),
    ('14502', '2026-2', 1, 'Jueves',    4, 'B-204'),
    ('14510', '2026-2', 1, 'Lunes',     6, 'LAB-GEO'),
    ('10102', '2026-2', 1, 'Lunes',     2, 'A-102'),
    ('10145', '2026-2', 1, 'Miércoles', 3, 'LAB-3');

INSERT INTO inscripcion (rut_estudiante, cod_asig, periodo, num_seccion, fecha_inscripcion, nota, estado) VALUES
    -- 2026-1 (cerrado)
    ('20111222-4', '14501', '2026-1', 1, '2026-03-20', 6.2, 'Aprobada'),
    ('20111222-4', '10145', '2026-1', 1, '2026-03-20', 5.5, 'Aprobada'),
    ('20222333-1', '14501', '2026-1', 1, '2026-03-21', 4.8, 'Aprobada'),
    ('20222333-1', '10145', '2026-1', 1, '2026-03-21', 3.6, 'Reprobada'),
    ('20333444-9', '10101', '2026-1', 1, '2026-03-19', 5.1, 'Aprobada'),
    ('20333444-9', '10145', '2026-1', 1, '2026-03-19', 6.0, 'Aprobada'),
    ('20444555-6', '14501', '2026-1', 1, '2026-03-22', 3.2, 'Reprobada'),
    ('20444555-6', '14502', '2026-1', 1, '2026-03-22', 5.9, 'Aprobada'),
    ('20555666-2', '14501', '2026-1', 1, '2026-03-20', 6.7, 'Aprobada'),
    ('20555666-2', '14502', '2026-1', 1, '2026-03-20', 6.4, 'Aprobada'),
    ('20666777-K', '10101', '2026-1', 1, '2026-03-23', 4.1, 'Aprobada'),
    ('20777888-5', '14501', '2026-1', 1, '2026-03-20', 5.6, 'Aprobada'),
    ('20777888-5', '10145', '2026-1', 1, '2026-03-20', NULL, 'Retirada'),
    ('20888999-1', '10145', '2026-1', 1, '2026-03-19', 6.9, 'Aprobada'),
    ('21000111-8', '10101', '2026-1', 1, '2026-03-24', 2.9, 'Reprobada'),
    ('21111222-3', '10101', '2026-1', 1, '2026-03-24', 5.0, 'Aprobada'),
    ('21111222-3', '14502', '2026-1', 1, '2026-03-24', 4.4, 'Aprobada'),
    -- 2026-2 (en curso: sin nota)
    ('20111222-4', '14504', '2026-2', 1, '2026-09-18', NULL, 'Inscrita'),
    ('20111222-4', '14502', '2026-2', 1, '2026-09-18', NULL, 'Inscrita'),
    ('20222333-1', '10145', '2026-2', 1, '2026-09-18', NULL, 'Inscrita'),
    ('20333444-9', '10102', '2026-2', 1, '2026-09-19', NULL, 'Inscrita'),
    ('20222333-1', '14504', '2026-2', 1, '2026-09-19', NULL, 'Inscrita'),
    ('20444555-6', '14504', '2026-2', 1, '2026-09-19', NULL, 'Inscrita'),
    ('20555666-2', '14504', '2026-2', 1, '2026-09-17', NULL, 'Inscrita'),
    ('20555666-2', '14510', '2026-2', 1, '2026-09-17', NULL, 'Inscrita'),
    ('20666777-K', '10102', '2026-2', 1, '2026-09-20', NULL, 'Inscrita'),
    ('20777888-5', '14504', '2026-2', 1, '2026-09-18', NULL, 'Inscrita'),
    ('21000111-8', '10102', '2026-2', 1, '2026-09-20', NULL, 'Inscrita'),
    ('21111222-3', '14502', '2026-2', 1, '2026-09-21', NULL, 'Inscrita');

COMMIT;

-- Verificación rápida
SELECT 'persona' AS tabla, count(*) FROM persona
UNION ALL SELECT 'estudiante',  count(*) FROM estudiante
UNION ALL SELECT 'profesor',    count(*) FROM profesor
UNION ALL SELECT 'asignatura',  count(*) FROM asignatura
UNION ALL SELECT 'seccion',     count(*) FROM seccion
UNION ALL SELECT 'inscripcion', count(*) FROM inscripcion
UNION ALL SELECT 'comuna',      count(*) FROM comuna
UNION ALL SELECT 'sala',        count(*) FROM sala
UNION ALL SELECT 'mobiliario',  count(*) FROM mobiliario
UNION ALL SELECT 'domicilio',   count(*) FROM domicilio
UNION ALL SELECT 'seccion_horario', count(*) FROM seccion_horario;
