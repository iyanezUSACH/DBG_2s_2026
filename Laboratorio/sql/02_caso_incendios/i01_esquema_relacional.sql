-- =====================================================================
-- Diseño de Bases de Geodatos (14504) · USACH
-- Caso territorial · Script i01: esquema relacional (se entrega modelado en la semana 8)
-- "Exposición de infraestructura crítica a incendios forestales,
--  Región de Valparaíso" (cliente ficticio: SENAPRED Valparaíso)
-- Motor: PostgreSQL 16. Ejecutar en una base vacía, p. ej.:
--   createdb geodatos
--   psql -d geodatos -f i01_esquema_relacional.sql
-- Nota: en la versión relacional las coordenadas se guardan como columnas numéricas
-- (x_utm, y_utm, EPSG:32719). En U3 se convierten a geometría PostGIS.
-- =====================================================================

DROP SCHEMA IF EXISTS riesgo CASCADE;
CREATE SCHEMA riesgo;
SET search_path TO riesgo, public;

-- ---------------------------------------------------------------------
-- Dominios reutilizables
-- ---------------------------------------------------------------------
CREATE DOMAIN d_cut_comuna AS char(5)
    CHECK (VALUE ~ '^[0-9]{5}$');

CREATE DOMAIN d_utm_este AS numeric(10,2)
    CHECK (VALUE BETWEEN 160000 AND 840000);

CREATE DOMAIN d_utm_norte AS numeric(10,2)
    CHECK (VALUE BETWEEN 5000000 AND 7700000);

CREATE DOMAIN d_causa AS varchar(20)
    CHECK (VALUE IN ('Intencional','Accidental','Natural','Desconocida'));

-- ---------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------
CREATE TABLE region (
    cod_region   smallint     PRIMARY KEY,
    nombre       varchar(60)  NOT NULL UNIQUE
);

CREATE TABLE comuna (
    cod_comuna      d_cut_comuna PRIMARY KEY,
    nombre          varchar(60)  NOT NULL,
    cod_region      smallint     NOT NULL
                    REFERENCES region (cod_region)
                    ON UPDATE CASCADE ON DELETE RESTRICT,
    poblacion       integer      CHECK (poblacion >= 0),
    UNIQUE (nombre, cod_region)
);

CREATE TABLE tipo_infraestructura (
    id_tipo     smallserial  PRIMARY KEY,
    nombre      varchar(40)  NOT NULL UNIQUE,
    critica     boolean      NOT NULL DEFAULT false
);

CREATE TABLE infraestructura (
    id_infra        serial        PRIMARY KEY,
    nombre          varchar(120)  NOT NULL,
    id_tipo         smallint      NOT NULL
                    REFERENCES tipo_infraestructura (id_tipo)
                    ON DELETE RESTRICT,
    cod_comuna      d_cut_comuna  NOT NULL
                    REFERENCES comuna (cod_comuna)
                    ON DELETE RESTRICT,
    capacidad       integer       CHECK (capacidad IS NULL OR capacidad > 0),
    x_utm           d_utm_este    NOT NULL,
    y_utm           d_utm_norte   NOT NULL,
    fuente          varchar(60)   NOT NULL DEFAULT 'Sintético curso 14504',
    fecha_registro  date          NOT NULL DEFAULT current_date
);

-- Relación N:M: cuerpos de bomberos (infraestructura) que atienden comunas
CREATE TABLE cobertura_bomberos (
    id_infra        integer       NOT NULL
                    REFERENCES infraestructura (id_infra) ON DELETE CASCADE,
    cod_comuna      d_cut_comuna  NOT NULL
                    REFERENCES comuna (cod_comuna) ON DELETE CASCADE,
    fecha_convenio  date          NOT NULL,
    PRIMARY KEY (id_infra, cod_comuna)
);

CREATE TABLE evento_incendio (
    id_evento        serial        PRIMARY KEY,
    codigo           varchar(15)   NOT NULL UNIQUE,
    fecha_inicio     timestamp     NOT NULL,
    fecha_control    timestamp,
    causa            d_causa       NOT NULL DEFAULT 'Desconocida',
    sup_afectada_ha  numeric(10,2) CHECK (sup_afectada_ha >= 0),
    cod_comuna       d_cut_comuna  NOT NULL
                     REFERENCES comuna (cod_comuna) ON DELETE RESTRICT,
    x_utm            d_utm_este    NOT NULL,
    y_utm            d_utm_norte   NOT NULL,
    CONSTRAINT ck_fechas CHECK (fecha_control IS NULL OR fecha_control >= fecha_inicio)
);

-- Tabla puente: establecimientos afectados por un evento (resultado de 1.12)
CREATE TABLE evento_afecta (
    id_evento   integer  NOT NULL REFERENCES evento_incendio (id_evento) ON DELETE CASCADE,
    id_infra    integer  NOT NULL REFERENCES infraestructura (id_infra) ON DELETE CASCADE,
    nivel_dano  varchar(10) NOT NULL CHECK (nivel_dano IN ('Leve','Moderado','Grave','Total')),
    PRIMARY KEY (id_evento, id_infra)
);

-- ---------------------------------------------------------------------
-- Índices de apoyo a FK (PostgreSQL no los crea automáticamente)
-- ---------------------------------------------------------------------
CREATE INDEX ix_comuna_region       ON comuna (cod_region);
CREATE INDEX ix_infra_tipo          ON infraestructura (id_tipo);
CREATE INDEX ix_infra_comuna        ON infraestructura (cod_comuna);
CREATE INDEX ix_evento_comuna       ON evento_incendio (cod_comuna);
CREATE INDEX ix_evento_fecha        ON evento_incendio (fecha_inicio);

-- ---------------------------------------------------------------------
-- Documentación en el catálogo (diccionario de datos vivo)
-- ---------------------------------------------------------------------
COMMENT ON SCHEMA riesgo IS 'Caso conductor 14504: exposición de infraestructura crítica a incendios forestales';
COMMENT ON TABLE  comuna IS 'Comunas según código único territorial (CUT) SUBDERE';
COMMENT ON TABLE  infraestructura IS 'Establecimientos y servicios; coordenadas EPSG:32719';
COMMENT ON COLUMN infraestructura.capacidad IS 'Camas (salud), matrícula (educación) o carros (bomberos)';
COMMENT ON TABLE  evento_incendio IS 'Focos de incendio forestal; punto de inicio EPSG:32719';
COMMENT ON COLUMN evento_incendio.fecha_control IS 'NULL mientras el incendio está activo';
