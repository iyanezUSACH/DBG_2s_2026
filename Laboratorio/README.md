# 👨‍💻 Material de laboratorio

## Estructura

| Carpeta | Contenido | Unidades |
|---|---|---|
| `Guías/` | Guías por unidad, Módulo G y labs autónomos A y B | U1–U4 |
| `sql/01_caso_academico/` | Caso clásico: registro académico universitario (sin geometría) | U1–U2 |
| `sql/02_caso_incendios/` | Caso territorial: infraestructura crítica e incendios forestales | U3–U4 |
| `datos/` | CSV y GeoPackage del caso incendios para ArcGIS Pro | U3 |

## Caso clásico (semanas 1–9)

```bash
createdb academico
psql -d academico -f sql/01_caso_academico/a01_esquema.sql
psql -d academico -f sql/01_caso_academico/a02_datos.sql
```

Departamentos, carreras, personas (estudiantes y profesores), asignaturas con prerrequisitos, secciones por período, horarios, salas y sus mobiliarios, domicilios e inscripciones con nota.

Incluye a propósito una especialización solapada, una entidad débil, una relación recursiva, una relación 1:1 (domicilio), algunas inscripciones que no cumplen prerrequisitos y **la ubicación como atributo**: comuna con código único territorial, dirección y coordenadas en grados (EPSG:4326) para el campus, los edificios y los domicilios. En la Unidad 3 esas columnas se reemplazan por una columna `geometry` y las consultas de distancia pasan de una fórmula de haversine a `ST_Distance` y `ST_DWithin`.

## Caso territorial (semanas 10–17)

```bash
createdb geodatos
psql -d geodatos -f sql/02_caso_incendios/i01_esquema_relacional.sql
psql -d geodatos -f sql/02_caso_incendios/i02_datos.sql
psql -d geodatos -f sql/02_caso_incendios/i03_espacial.sql   # requiere PostGIS
```

También pueden ejecutarse desde pgAdmin 4: *Query Tool* → abrir el archivo → F5.

## Datos para ArcGIS Pro

| Archivo | Contenido |
|---|---|
| `infraestructura.csv` | 19 establecimientos con `x_utm`, `y_utm` (EPSG:32719) |
| `evento_incendio.csv` | 8 focos de incendio (EPSG:32719) |
| `tipo_infraestructura.csv` | Catálogo de tipos y criticidad |
| `caso_14504.gpkg` | `comuna`, `area_quemada`, `area_vigente` y `via` (EPSG:32719) |

> ⚠️ Todos los datos son **ficticios o sintéticos** y las geometrías están simplificadas. Para el proyecto usen fuentes oficiales (IDE Chile, CONAF, MINSAL, MINEDUC, INE, MOP).
