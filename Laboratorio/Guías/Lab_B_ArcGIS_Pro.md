# 🧭 Lab autónomo B · Geoprocesos del caso en ArcGIS Pro

**Semana 12 (7–11 de diciembre; lunes 7 interferiado y martes 8 feriado) · sin clase presencial.** Tiempo estimado: 4 h + 2 h. **Entrega: viernes 11 de diciembre, 23:59.** Requisito: labs 10 y 11 realizados. Datos: carpeta `Laboratorio/datos`.

| Paso | Qué hacer | Valor de control |
|---|---|---|
| B1 | *New* → *Map* `labB_<apellido>`; *Catalog* → *Add Folder Connection* a `datos` | Carpeta visible |
| B2 | Usar o crear `caso_14504.gdb` con feature dataset `riesgo` en EPSG:32719 | Feature dataset creado |
| B3 | *Feature Class To Geodatabase*: `comuna`, `area_vigente` y `via` desde `caso_14504.gpkg` | 6 comunas · 4 áreas · 6 vías |
| B4 | *XY Table To Point* con `infraestructura.csv` y `evento_incendio.csv` (X = `x_utm`, Y = `y_utm`, EPSG:32719) | 19 y 8 puntos · equivale a `ST_SetSRID(ST_MakePoint(x, y), 32719)` |
| B5 | *Check Geometry* sobre `area_vigente` y `comuna` | Tabla de salida vacía · equivale a `ST_IsValid` |
| B6 | *Select Layer By Location*: `infraestructura` *Within* `area_vigente`; exportar `infra_dentro` | 3: Escuela El Retiro, Escuela Villa Independencia, Sede vecinal El Olivar |
| B7 | *Pairwise Buffer* 500 m y 2.000 m con *Dissolve all*; *Spatial Join* con `buffer_2000` | Establecimientos a menos de 2 km |
| B8 | *Pairwise Intersect* `area_vigente` × `comuna` → *Calculate Geometry Attributes* (ha) → *Summary Statistics* por `nombre` | Quilpué ≈ 2.123 ha · Viña del Mar ≈ 1.843 ha · Villa Alemana ≈ 959 ha · Valparaíso ≈ 565 ha |
| B9 | *Definition Query* `id_tipo = 4` sobre `infraestructura`; *Near* desde `evento_incendio` | VAL-2024-001 ≈ 5.859 m del Cuartel Bomberos Quilpué · VAL-2025-002 ≈ 4.924 m del Cuartel Bomberos Concón |
| B10 | *ModelBuilder*: encadenar B6–B9, parametrizar distancia y expresión, ejecutar y exportar el diagrama | Modelo ejecutable |
| B11 | Escribir la función SQL equivalente de cada paso B4–B9 (tabla G3 del Módulo G) | Se implementa en PostGIS en las semanas 13 y 14 |

## Entrega

* `caso_14504.gdb.zip` o paquete de proyecto `.ppkx`.
* Imagen del modelo de ModelBuilder.
* Bitácora PDF con los resultados B3–B9 comparados con los valores de control y la tabla B11.

## Problemas frecuentes

* **Puntos en el océano o en otro continente:** se eligió un sistema distinto a EPSG:32719 en XY Table To Point.
* **Buffers en grados:** la capa quedó en WGS 84 geográfico.
* **No encuentro una herramienta:** búsquela por nombre en el panel *Geoprocessing*.
