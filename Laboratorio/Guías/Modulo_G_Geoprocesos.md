# Módulo G · Geoprocesos básicos y paralelo geodatabase ↔ PostGIS

**Semanas 10–12 (23 nov – 11 dic), dentro de la Unidad 3.** Herramienta: ArcGIS Pro. Propósito: generar información geográfica propia y dominar las operaciones vectoriales básicas antes de reescribirlas en SQL espacial.

## G1. Del dato al mapa

1. **Generar** (S10): tablas del caso incendios a feature classes (XY Table To Point) y digitalización de lo que falta.
2. **Estructurar** (S10): feature dataset con un solo sistema de referencia, dominios, subtipos y relationship classes.
3. **Procesar** (S11–S12): selección, proximidad, superposición y agregación, encadenados en ModelBuilder.
4. **Trasladar** (S13): la misma estructura y validación en PostGIS.
5. **Mapear** (S16): capas de consulta desde PostgreSQL y mapa final del proyecto.

## G2. Paralelo de conceptos

| Geodatabase (Esri) | PostgreSQL / PostGIS | En el caso |
|---|---|---|
| File o enterprise geodatabase | Base de datos | `geodatos` |
| Feature dataset (SRC común) | Esquema + un solo SRID | `riesgo`, EPSG:32719 |
| Feature class | Tabla con `geometry(tipo, SRID)` | `infraestructura`, `area_quemada` |
| Tabla | Tabla sin geometría | `tipo_infraestructura` |
| ObjectID | `serial` / `IDENTITY` como PK | `id_infra` |
| Dominio codificado / de rango | `DOMAIN`, `CHECK` o FK a catálogo | `d_causa` |
| Subtipo | Columna discriminadora + restricciones | `id_tipo` |
| Relationship class (simple / compuesta) | FK con `RESTRICT` / `CASCADE` | evento → área quemada |
| Topología | `ST_IsValid`, `ST_Overlaps`, triggers | Comunas sin solape |
| Attribute rules | Triggers y `CHECK` | Punto dentro de su comuna |
| Índice espacial | Índice GiST | `gix_infra_geom` |
| Shape_Area / Shape_Length | `ST_Area` / `ST_Length` | Superficie quemada |
| Metadatos | `COMMENT ON` + `catalogo_capa` | Fuente, fecha, escala |

## G3. Equivalencias herramienta ↔ SQL

| Herramienta ArcGIS Pro | Pregunta territorial | PostGIS |
|---|---|---|
| Select Layer By Attribute | ¿Qué establecimientos son hospitales? | `WHERE id_tipo = 1` |
| Select Layer By Location | ¿Qué escuelas están en el área quemada? | `ST_Within`, `ST_Intersects` |
| XY Table To Point | Coordenadas a puntos | `ST_SetSRID(ST_MakePoint(x, y), 32719)` |
| Define Projection | Declarar el SRC | `ST_SetSRID` |
| Project | Cambiar de SRC | `ST_Transform` |
| Calculate Geometry Attributes | Área y longitud | `ST_Area`, `ST_Length` |
| Pairwise Buffer | Zona de 500 m | `ST_Buffer(geom, 500)` |
| Pairwise Clip | Vías dentro de una comuna | `ST_Intersection` con el polígono |
| Pairwise Intersect | Superficie quemada por comuna | `ST_Intersection` + `ST_Intersects` |
| Pairwise Erase | Comuna sin área quemada | `ST_Difference` |
| Union (overlay) | Combinar dos coberturas | `ST_Intersection` + `ST_Difference` |
| Pairwise Dissolve | Zona continua | `ST_Union` + `GROUP BY` |
| Merge | Juntar capas del mismo tipo | `UNION ALL` |
| Spatial Join | Establecimientos por comuna | `JOIN ON ST_Intersects` + `count(*)` |
| Near | Cuartel más cercano | `ORDER BY geom <-> geom LIMIT 1` |
| Summary Statistics | Totales por categoría | `GROUP BY` |
| Feature To Point | Punto representativo | `ST_PointOnSurface`, `ST_Centroid` |
| Minimum Bounding Geometry | Envolvente | `ST_ConvexHull(ST_Collect(geom))` |
| Check / Repair Geometry | Geometrías inválidas | `ST_IsValid`, `ST_MakeValid` |

## G4. Ejercicios

**G.1** Cree `caso_14504.gdb` con el feature dataset `riesgo` en WGS 84 / UTM 19S (EPSG:32719). Justifique por qué no usar coordenadas geográficas para medir.

**G.2** Cree los dominios `causa` (codificado) y `capacidad` (rango 1–2000) y el subtipo de infraestructura por tipo. Compare con los `DOMAIN` y `CHECK` del script `i01_esquema_relacional.sql` y con los del registro académico.

**G.3** Importe `infraestructura` y `evento_incendio` desde CSV con XY Table To Point y cree la relationship class evento → área quemada. ¿Simple o compuesta? Relacione con `ON DELETE CASCADE`.

**G.4** Seleccione por localización los establecimientos críticos dentro de las áreas quemadas.

**G.5** Genere buffers de 500 m y 2 km alrededor de las áreas quemadas, disuélvalos y cuente los establecimientos en cada anillo (Spatial Join).

**G.6** Calcule la superficie quemada por comuna con Intersect + Summary Statistics y compárela con la declarada.

**G.7** Con Near, determine el cuartel de bomberos más cercano a cada foco.

**G.8** Encadene G.4–G.7 en ModelBuilder con parámetros (distancia del buffer, tipo de establecimiento) y exporte el diagrama: será la especificación que traducirán a SQL en la U4.

## Respuestas

[Respuestas del Módulo G](../Soluciones/Respuestas_Modulo_G.md), con el SQL equivalente y los valores de control de cada ejercicio.
