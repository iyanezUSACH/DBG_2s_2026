-- =====================================================================
-- Diseño de Bases de Geodatos (14504) · USACH · 2º semestre 2026
-- Caso clásico · Script a01: esquema "Registro Académico Universitario"
-- Unidades 1 y 2: aprender bases de datos relacionales sin geometría.
-- Motor: PostgreSQL 16.  Uso:
--   createdb academico
--   psql -d academico -f a01_esquema.sql
-- =====================================================================

DROP SCHEMA IF EXISTS academico CASCADE;
CREATE SCHEMA academico;
SET search_path TO academico, public;

-- ---------------------------------------------------------------------
-- Dominios
-- ---------------------------------------------------------------------
CREATE DOMAIN d_rut AS varchar(10)
    CHECK (VALUE ~ '^[0-9]{7,8}-[0-9K]$');

CREATE DOMAIN d_nota AS numeric(2,1)
    CHECK (VALUE BETWEEN 1.0 AND 7.0);

CREATE DOMAIN d_periodo AS char(6)
    CHECK (VALUE ~ '^[0-9]{4}-[12]$');

CREATE DOMAIN d_email AS varchar(80)
    CHECK (VALUE ~ '^[^@\s]+@[^@\s]+\.[a-z]{2,}$');

-- La ubicación entra como ATRIBUTO, todavía sin geometría:
-- latitud y longitud en grados decimales (EPSG:4326). En la semana 7
-- estas dos columnas se convierten en una sola columna geometry (ejercicio 2.25).
CREATE DOMAIN d_lat AS numeric(9,6)
    CHECK (VALUE BETWEEN -56.0 AND -17.0);      -- Chile continental

CREATE DOMAIN d_lon AS numeric(9,6)
    CHECK (VALUE BETWEEN -76.0 AND -66.0);

CREATE DOMAIN d_cut_comuna AS char(5)
    CHECK (VALUE ~ '^[0-9]{5}$');

-- ---------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------
CREATE TABLE departamento (
    cod_depto   varchar(6)   PRIMARY KEY,
    nombre      varchar(80)  NOT NULL UNIQUE
);

CREATE TABLE carrera (
    cod_carrera        varchar(6)  PRIMARY KEY,
    nombre             varchar(80) NOT NULL UNIQUE,
    cod_depto          varchar(6)  NOT NULL
                       REFERENCES departamento (cod_depto) ON DELETE RESTRICT,
    duracion_semestres smallint    NOT NULL CHECK (duracion_semestres BETWEEN 8 AND 14)
);

-- Superclase de la especialización PERSONA -> ESTUDIANTE / PROFESOR (solapada)
CREATE TABLE persona (
    rut         d_rut        PRIMARY KEY,
    nombres     varchar(60)  NOT NULL,
    apellidos   varchar(60)  NOT NULL,
    email       d_email      NOT NULL UNIQUE,
    fecha_nac   date         NOT NULL CHECK (fecha_nac > '1940-01-01')
);

CREATE TABLE estudiante (
    rut          d_rut       PRIMARY KEY
                 REFERENCES persona (rut) ON DELETE CASCADE,
    cod_carrera  varchar(6)  NOT NULL
                 REFERENCES carrera (cod_carrera) ON DELETE RESTRICT,
    anio_ingreso smallint    NOT NULL CHECK (anio_ingreso BETWEEN 2000 AND 2030)
);

CREATE TABLE profesor (
    rut         d_rut        PRIMARY KEY
                REFERENCES persona (rut) ON DELETE CASCADE,
    cod_depto   varchar(6)   NOT NULL
                REFERENCES departamento (cod_depto) ON DELETE RESTRICT,
    jerarquia   varchar(12)  NOT NULL
                CHECK (jerarquia IN ('Instructor','Asistente','Asociado','Titular','Por horas'))
);

-- ---------------------------------------------------------------------
-- Dónde ocurren las cosas: comuna, campus, edificio, sala y mobiliario
-- ---------------------------------------------------------------------
CREATE TABLE comuna (
    cod_comuna  d_cut_comuna PRIMARY KEY,        -- código único territorial (CUT)
    nombre      varchar(60)  NOT NULL UNIQUE,
    provincia   varchar(60)  NOT NULL,
    region      varchar(60)  NOT NULL
);

CREATE TABLE campus (
    cod_campus  varchar(6)   PRIMARY KEY,
    nombre      varchar(60)  NOT NULL UNIQUE,
    direccion   varchar(120) NOT NULL,
    cod_comuna  d_cut_comuna NOT NULL
                REFERENCES comuna (cod_comuna) ON DELETE RESTRICT,
    latitud     d_lat        NOT NULL,
    longitud    d_lon        NOT NULL
);

CREATE TABLE edificio (
    cod_edificio varchar(8)   PRIMARY KEY,
    nombre       varchar(60)  NOT NULL,
    cod_campus   varchar(6)   NOT NULL
                 REFERENCES campus (cod_campus) ON DELETE RESTRICT,
    latitud      d_lat        NOT NULL,
    longitud     d_lon        NOT NULL
);

CREATE TABLE sala (
    cod_sala     varchar(10) PRIMARY KEY,
    cod_edificio varchar(8)  NOT NULL
                 REFERENCES edificio (cod_edificio) ON DELETE RESTRICT,
    piso         smallint    NOT NULL CHECK (piso BETWEEN -2 AND 20),
    capacidad    smallint    NOT NULL CHECK (capacidad BETWEEN 1 AND 300),
    tipo         varchar(20) NOT NULL DEFAULT 'Aula'
                 CHECK (tipo IN ('Aula','Laboratorio','Taller','Auditorio'))
);

-- Relación 1:N con la sala: si el inventario fuera una columna de sala
-- ("20 PC, 1 proyector...") se violaría la 1FN.
CREATE TABLE mobiliario (
    id_item     serial      PRIMARY KEY,
    cod_sala    varchar(10) NOT NULL
                REFERENCES sala (cod_sala) ON DELETE CASCADE,
    tipo        varchar(30) NOT NULL,
    cantidad    smallint    NOT NULL CHECK (cantidad > 0),
    estado      varchar(14) NOT NULL DEFAULT 'Operativo'
                CHECK (estado IN ('Operativo','En reparación','De baja'))
);

-- Dónde vive cada persona: relación 1:1 con persona (domicilio principal)
CREATE TABLE domicilio (
    rut         d_rut        PRIMARY KEY
                REFERENCES persona (rut) ON DELETE CASCADE,
    calle       varchar(80)  NOT NULL,
    numero      varchar(10),
    cod_comuna  d_cut_comuna NOT NULL
                REFERENCES comuna (cod_comuna) ON DELETE RESTRICT,
    latitud     d_lat        NOT NULL,
    longitud    d_lon        NOT NULL,
    fuente      varchar(40)  NOT NULL DEFAULT 'Declarado por el estudiante'
);

CREATE TABLE asignatura (
    cod_asig    varchar(6)   PRIMARY KEY,
    nombre      varchar(80)  NOT NULL,
    creditos    smallint     NOT NULL CHECK (creditos BETWEEN 1 AND 10),
    cod_depto   varchar(6)   NOT NULL
                REFERENCES departamento (cod_depto) ON DELETE RESTRICT
);

-- Relación recursiva N:M: una asignatura exige otras
CREATE TABLE prerrequisito (
    cod_asig    varchar(6)  NOT NULL REFERENCES asignatura (cod_asig) ON DELETE CASCADE,
    cod_prereq  varchar(6)  NOT NULL REFERENCES asignatura (cod_asig) ON DELETE RESTRICT,
    PRIMARY KEY (cod_asig, cod_prereq),
    CONSTRAINT ck_no_autorreferencia CHECK (cod_asig <> cod_prereq)
);

-- Entidad débil: se identifica por la asignatura + período + número
CREATE TABLE seccion (
    cod_asig      varchar(6)  NOT NULL REFERENCES asignatura (cod_asig) ON DELETE CASCADE,
    periodo       d_periodo   NOT NULL,
    num_seccion   smallint    NOT NULL CHECK (num_seccion > 0),
    rut_profesor  d_rut       NOT NULL REFERENCES profesor (rut) ON DELETE RESTRICT,
    cupo          smallint    NOT NULL CHECK (cupo BETWEEN 1 AND 120),
    PRIMARY KEY (cod_asig, periodo, num_seccion)
);

-- Cuándo: bloques horarios institucionales
CREATE TABLE bloque_horario (
    num_bloque  smallint   PRIMARY KEY CHECK (num_bloque BETWEEN 1 AND 8),
    hora_inicio time       NOT NULL,
    hora_fin    time       NOT NULL,
    CONSTRAINT ck_bloque_horas CHECK (hora_fin > hora_inicio)
);

-- Una sección puede reunirse varios días: cada reunión tiene día, bloque y sala
CREATE TABLE seccion_horario (
    cod_asig     varchar(6)  NOT NULL,
    periodo      d_periodo   NOT NULL,
    num_seccion  smallint    NOT NULL,
    dia          varchar(9)  NOT NULL
                 CHECK (dia IN ('Lunes','Martes','Miércoles','Jueves','Viernes','Sábado')),
    num_bloque   smallint    NOT NULL REFERENCES bloque_horario (num_bloque) ON DELETE RESTRICT,
    cod_sala     varchar(10) NOT NULL REFERENCES sala (cod_sala) ON DELETE RESTRICT,
    PRIMARY KEY (cod_asig, periodo, num_seccion, dia, num_bloque),
    FOREIGN KEY (cod_asig, periodo, num_seccion)
        REFERENCES seccion (cod_asig, periodo, num_seccion) ON DELETE CASCADE,
    CONSTRAINT uq_sala_ocupada UNIQUE (cod_sala, periodo, dia, num_bloque)  -- una sala, un bloque, una sección
);

-- Relación N:M con atributos entre ESTUDIANTE y SECCION
CREATE TABLE inscripcion (
    rut_estudiante    d_rut       NOT NULL REFERENCES estudiante (rut) ON DELETE RESTRICT,
    cod_asig          varchar(6)  NOT NULL,
    periodo           d_periodo   NOT NULL,
    num_seccion       smallint    NOT NULL,
    fecha_inscripcion date        NOT NULL DEFAULT current_date,
    nota              d_nota,
    estado            varchar(10) NOT NULL DEFAULT 'Inscrita'
                      CHECK (estado IN ('Inscrita','Aprobada','Reprobada','Retirada')),
    PRIMARY KEY (rut_estudiante, cod_asig, periodo),          -- una sección por asignatura y período
    FOREIGN KEY (cod_asig, periodo, num_seccion)
        REFERENCES seccion (cod_asig, periodo, num_seccion) ON DELETE RESTRICT,
    CONSTRAINT ck_estado_nota CHECK (
        (estado = 'Aprobada'  AND nota >= 4.0) OR
        (estado = 'Reprobada' AND nota <  4.0) OR
        (estado IN ('Inscrita','Retirada') AND nota IS NULL))
);

-- Índices de apoyo a claves foráneas
CREATE INDEX ix_carrera_depto     ON carrera (cod_depto);
CREATE INDEX ix_estudiante_carr   ON estudiante (cod_carrera);
CREATE INDEX ix_profesor_depto    ON profesor (cod_depto);
CREATE INDEX ix_asignatura_depto  ON asignatura (cod_depto);
CREATE INDEX ix_seccion_profesor  ON seccion (rut_profesor);
CREATE INDEX ix_inscripcion_secc  ON inscripcion (cod_asig, periodo, num_seccion);
CREATE INDEX ix_domicilio_comuna  ON domicilio (cod_comuna);
CREATE INDEX ix_sala_edificio     ON sala (cod_edificio);
CREATE INDEX ix_horario_sala      ON seccion_horario (cod_sala, dia, num_bloque);

-- Diccionario de datos en el catálogo
COMMENT ON SCHEMA academico IS 'Caso clásico 14504: registro académico universitario (datos ficticios)';
COMMENT ON TABLE  seccion IS 'Entidad débil: asignatura + período + número de sección';
COMMENT ON TABLE  inscripcion IS 'Relación N:M estudiante-sección con nota y estado';
COMMENT ON COLUMN inscripcion.nota IS 'Escala chilena 1,0 a 7,0; NULL mientras la asignatura está en curso';
COMMENT ON TABLE  prerrequisito IS 'Relación recursiva N:M entre asignaturas';
COMMENT ON TABLE  domicilio IS 'Domicilio principal declarado; latitud y longitud en EPSG:4326 (grados)';
COMMENT ON COLUMN domicilio.latitud IS 'En la semana 7 estas dos columnas se convierten en una columna geometry(Point); en la Unidad 3 se proyecta a EPSG:32719';
COMMENT ON TABLE  seccion_horario IS 'Día, bloque y sala de cada reunión de una sección';
