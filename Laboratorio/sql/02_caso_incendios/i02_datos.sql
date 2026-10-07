-- =====================================================================
-- Diseño de Bases de Geodatos (14504) · USACH
-- Caso territorial · Script i02: datos
-- Datos SINTÉTICOS con fines docentes. Población: aprox. Censo 2017.
-- Coordenadas aproximadas en EPSG:32719 (WGS 84 / UTM 19S).
-- Requiere haber ejecutado i01_esquema_relacional.sql
-- =====================================================================

SET search_path TO riesgo, public;

BEGIN;

INSERT INTO region (cod_region, nombre) VALUES
    (5,  'Valparaíso'),
    (13, 'Metropolitana de Santiago');

INSERT INTO comuna (cod_comuna, nombre, cod_region, poblacion) VALUES
    ('05101', 'Valparaíso',    5, 296655),
    ('05102', 'Casablanca',    5,  26867),
    ('05103', 'Concón',        5,  42152),
    ('05109', 'Viña del Mar',  5, 334248),
    ('05801', 'Quilpué',       5, 151708),
    ('05804', 'Villa Alemana', 5, 126548);

INSERT INTO tipo_infraestructura (id_tipo, nombre, critica) VALUES
    (1, 'Hospital',               true),
    (2, 'CESFAM',                 true),
    (3, 'Establecimiento educacional', true),
    (4, 'Cuartel de bomberos',    true),
    (5, 'Planta de agua potable', true),
    (6, 'Centro comercial',       false),
    (7, 'Sede vecinal',           false);
SELECT setval('tipo_infraestructura_id_tipo_seq', 7);

INSERT INTO infraestructura
    (id_infra, nombre, id_tipo, cod_comuna, capacidad, x_utm, y_utm, fecha_registro) VALUES
    ( 1, 'Hospital Dr. Gustavo Fricke',          1, '05109', 600, 263500, 6344500, '2023-03-01'),
    ( 2, 'Hospital Carlos van Buren',            1, '05101', 500, 254000, 6337000, '2023-03-01'),
    ( 3, 'Hospital de Quilpué',                  1, '05801', 250, 273500, 6341500, '2023-03-01'),
    ( 4, 'CESFAM Belloto Sur',                   2, '05801', NULL, 276500, 6339500, '2023-04-10'),
    ( 5, 'CESFAM Reñaca Alto',                   2, '05109', NULL, 261000, 6348500, '2023-04-10'),
    ( 6, 'CESFAM Villa Alemana',                 2, '05804', NULL, 281500, 6340500, '2023-04-10'),
    ( 7, 'Escuela Villa Independencia',          3, '05109', 420, 267500, 6346800, '2023-05-02'),
    ( 8, 'Escuela El Retiro',                    3, '05801', 380, 272500, 6346000, '2023-05-02'),
    ( 9, 'Liceo Concón',                         3, '05103', 650, 262000, 6353000, '2023-05-02'),
    (10, 'Escuela Cerro Alegre',                 3, '05101', 300, 252500, 6336500, '2023-05-02'),
    (11, 'Cuartel Bomberos Viña del Mar',        4, '05109',   3, 262800, 6343800, '2023-06-15'),
    (12, 'Cuartel Bomberos Quilpué',             4, '05801',   4, 274200, 6342300, '2023-06-15'),
    (13, 'Cuartel Bomberos Concón',              4, '05103',   2, 264000, 6354500, '2023-06-15'),
    (14, 'Planta de agua potable Concón',        5, '05103', NULL, 266500, 6352000, '2023-07-20'),
    (15, 'Centro comercial Marina',              6, '05109', NULL, 262500, 6346000, '2023-08-01'),
    (16, 'Sede vecinal El Olivar',               7, '05109', NULL, 268500, 6347500, '2023-08-01'),
    (17, 'Sede vecinal Achupallas',              7, '05109', NULL, 266000, 6345000, '2023-08-01'),
    (18, 'Escuela Villa Alemana Norte',          3, '05804', 510, 280500, 6344500, '2023-05-02'),
    (19, 'CESFAM Miraflores',                    2, '05101', NULL, 264500, 6342000, '2024-01-12');
SELECT setval('infraestructura_id_infra_seq', 19);

INSERT INTO cobertura_bomberos (id_infra, cod_comuna, fecha_convenio) VALUES
    (11, '05109', '2015-01-01'),
    (11, '05103', '2019-07-01'),
    (12, '05801', '2015-01-01'),
    (12, '05804', '2021-03-15'),
    (13, '05103', '2015-01-01');

INSERT INTO evento_incendio
    (id_evento, codigo, fecha_inicio, fecha_control, causa, sup_afectada_ha, cod_comuna, x_utm, y_utm) VALUES
    (1, 'VAL-2024-001', '2024-02-02 14:50', '2024-02-06 18:00', 'Intencional', 8500.00, '05801', 271500, 6347500),
    (2, 'VAL-2024-002', '2024-02-02 16:10', '2024-02-05 12:00', 'Intencional', 1200.00, '05804', 283500, 6344800),
    (3, 'VAL-2024-003', '2024-02-03 11:30', '2024-02-03 20:00', 'Accidental',    45.50, '05109', 259000, 6349000),
    (4, 'VAL-2023-014', '2023-12-22 17:00', '2023-12-23 09:30', 'Accidental',   310.00, '05101', 257000, 6331000),
    (5, 'VAL-2025-002', '2025-01-15 13:20', '2025-01-15 22:00', 'Desconocida',   12.00, '05103', 268500, 6356500),
    (6, 'VAL-2025-011', '2025-02-20 15:40', NULL,               'Desconocida',   60.00, '05101', 250000, 6329000),
    (7, 'VAL-2025-015', '2025-03-01 12:00', '2025-03-01 19:30', 'Accidental',     3.20, '05804', 285000, 6337500),
    (8, 'VAL-2024-020', '2024-11-30 16:00', '2024-12-01 08:00', 'Intencional',  150.00, '05102', 275000, 6315000);
SELECT setval('evento_incendio_id_evento_seq', 8);

INSERT INTO evento_afecta (id_evento, id_infra, nivel_dano) VALUES
    (1,  7, 'Grave'),
    (1, 16, 'Total'),
    (1,  8, 'Moderado'),
    (1, 17, 'Leve'),
    (2, 18, 'Leve'),
    (3,  5, 'Leve');

COMMIT;

-- Verificación rápida
SELECT 'comuna' AS tabla, count(*) FROM comuna
UNION ALL SELECT 'infraestructura', count(*) FROM infraestructura
UNION ALL SELECT 'evento_incendio', count(*) FROM evento_incendio
UNION ALL SELECT 'evento_afecta',  count(*) FROM evento_afecta;
