# Respuestas · Módulo G · Geoprocesos y paralelo geodatabase ↔ PostGIS

Respuestas de referencia para [Modulo_G_Geoprocesos.md](../Guías/Modulo_G_Geoprocesos.md). Cada ejercicio indica la herramienta de ArcGIS Pro, los parámetros clave, el SQL equivalente en PostGIS y el valor de control para autoverificarse. Los valores se calcularon con las geometrías de [i03_espacial.sql](../sql/02_caso_incendios/i03_espacial.sql), usando el **perímetro más reciente** de cada evento (la vista `v_area_vigente` de [i05_consultas_espaciales_soluciones.sql](../sql/02_caso_incendios/i05_consultas_espaciales_soluciones.sql)).

Referencias: Esri, *ArcGIS Pro Tool Reference*; PostGIS 3.4 Manual; ISO 19125-2:2004 (Simple Features, opción SQL).

---

**G.1** *Geodatabase y sistema de referencia.*

- **ArcGIS Pro:** Catalog → New File Geodatabase `caso_14504.gdb` → New Feature Dataset `riesgo` con *WGS 1984 UTM Zone 19S* (EPSG:32719). Todas las feature classes del dataset heredan ese sistema.
- **Por qué no medir en coordenadas geográficas:** latitud y longitud son ángulos, no distancias. Un grado de longitud mide unos 111 km en el ecuador y unos 93 km a la latitud de Valparaíso (≈ 33° S), así que `ST_Distance` o `ST_Area` sobre EPSG:4326 devuelven grados o grados cuadrados sin sentido físico. Una proyección UTM trabaja en metros con deformación pequeña dentro de su huso; la zona del caso (≈ 71,5° O) cae en el huso 19.
- **PostGIS:** el equivalente al feature dataset es el esquema `riesgo` con todas las columnas `geometry(tipo, 32719)`.

**G.2** *Dominios y subtipos.*

| Geodatabase | En `i01_esquema_relacional.sql` | En el registro académico |
|---|---|---|
| Dominio codificado `causa`: Intencional, Accidental, Natural, Desconocida | `CREATE DOMAIN d_causa AS varchar(20) CHECK (VALUE IN (...))` | `CHECK (tipo IN ('Aula','Laboratorio','Taller','Auditorio'))` en `sala` |
| Dominio de rango `capacidad`: 1–2000 | `CHECK (capacidad IS NULL OR capacidad > 0)`; el rango se completa con `CHECK (capacidad BETWEEN 1 AND 2000)` | `CREATE DOMAIN d_nota ... CHECK (VALUE BETWEEN 1.0 AND 7.0)` |
| Subtipo de infraestructura por tipo | Columna discriminadora `id_tipo` con FK a `tipo_infraestructura` (7 tipos) | Especialización `persona` → `estudiante` / `profesor` |

Diferencia de fondo: en la geodatabase, el subtipo permite asignar **dominios y valores por defecto distintos por subtipo** (por ejemplo, la capacidad de un hospital en camas y la de un cuartel en carros). En SQL eso se expresa con un `CHECK` condicional sobre `id_tipo` o con tablas por subclase.

**G.3** *Importación y relationship class.*

- **XY Table To Point:** campos `x_utm` y `y_utm`, sistema de coordenadas EPSG:32719. Si se declara EPSG:4326, los puntos quedan fuera de Chile: es el error del registro de `stg_area_quemada` con coordenadas en grados.
- **Relationship class** `evento_incendio` (origen) → `area_quemada` (destino), cardinalidad 1:N por `id_evento`.
- **¿Simple o compuesta?** **Compuesta.** Un área quemada no existe sin su evento: al borrar el evento deben borrarse sus perímetros. Es el mismo comportamiento que `REFERENCES evento_incendio ON DELETE CASCADE` en `area_quemada`. Una relationship class simple equivale a `RESTRICT` o `SET NULL`: los objetos existen por separado.

**G.4** *Selección por localización.*

- **ArcGIS Pro:** Select Layer By Attribute (`tipo` crítico) y luego Select Layer By Location, *Within* el área quemada vigente.
- **SQL:** `JOIN infraestructura i ON ST_Within(i.geom, a.geom)` con `t.critica` (ejercicio 4.1 de la Guía U4).
- **Control:** dentro de las áreas quemadas quedan **3 establecimientos**: Escuela Villa Independencia y Escuela El Retiro, ambas **críticas**, y Sede vecinal El Olivar, que **no es crítica**. Con el filtro de críticos el resultado son **2**. Todos corresponden al evento VAL-2024-001.

**G.5** *Buffers de 500 m y 2 km.*

- **ArcGIS Pro:** Pairwise Buffer de 500 m y de 2000 m con *Dissolve type = All* (o Multiple Ring Buffer con distancias 500 y 2000), luego Spatial Join *one to many* con la infraestructura y Summary Statistics por anillo.
- **SQL:** `ST_Union(ST_Buffer(geom, 500))` y `ST_Union(ST_Buffer(geom, 2000))`; clasificar cada punto con `ST_Intersects` y `ST_DWithin`, excluyendo lo que ya está dentro del área.
- **Control** (anillos exclusivos):

| Anillo | Establecimientos | Cuáles |
|---|---|---|
| Dentro del área quemada | 3 | Escuela Villa Independencia, Escuela El Retiro, Sede vecinal El Olivar |
| 0–500 m | 0 | — |
| 500–2000 m | 3 | Sede vecinal Achupallas (≈ 522 m), Escuela Villa Alemana Norte (≈ 1.300 m), CESFAM Reñaca Alto (≈ 1.612 m) |

Observe que la sede vecinal Achupallas queda a solo 22 m fuera del anillo de 500 m: el resultado es sensible a la distancia elegida, por eso G.8 la deja como parámetro.

**G.6** *Superficie quemada por comuna.*

- **ArcGIS Pro:** Pairwise Intersect (áreas quemadas vigentes × comunas), Calculate Geometry Attributes (área en hectáreas) y Summary Statistics por comuna.
- **SQL:** ejercicio 4.8: `ST_Area(ST_Union(ST_Intersection(c.geom, a.geom))) / 10000` agrupado por comuna.
- **Control:**

| Comuna | Superficie quemada |
|---|---|
| Quilpué | ≈ 2.123 ha |
| Viña del Mar | ≈ 1.843 ha |
| Villa Alemana | ≈ 959 ha |
| Valparaíso | ≈ 565 ha |

- **Comparación con lo declarado** (`sup_afectada_ha` del evento frente al área de su perímetro vigente):

| Evento | Geometría | Declarada | Lectura |
|---|---|---|---|
| VAL-2024-001 | ≈ 3.924 ha | 8.500 ha | La declaración más que duplica el perímetro: estimación inicial no actualizada |
| VAL-2024-002 | ≈ 959 ha | 1.200 ha | Diferencia moderada |
| VAL-2024-003 | ≈ 42 ha | 45,5 ha | Coinciden |
| VAL-2023-014 | ≈ 565 ha | 310 ha | La geometría es mayor que lo declarado |

La discrepancia es un hallazgo de calidad de datos (ISO 19157-1, exactitud temática): la superficie declarada y la medida no provienen del mismo proceso.

**G.7** *Cuartel más cercano a cada foco.*

- **ArcGIS Pro:** Near, con entrada `evento_incendio` y cercanía a `infraestructura` filtrada por tipo *Cuartel de bomberos*; agrega `NEAR_FID` y `NEAR_DIST`.
- **SQL:** ejercicio 4.9: `CROSS JOIN LATERAL (... ORDER BY i.geom <-> e.geom LIMIT 1)`.
- **Control:**

| Foco | Cuartel más cercano | Distancia |
|---|---|---|
| VAL-2024-001 | Cuartel Bomberos Quilpué | ≈ 5.859 m |
| VAL-2024-002 | Cuartel Bomberos Quilpué | ≈ 9.630 m |
| VAL-2024-003 | Cuartel Bomberos Viña del Mar | ≈ 6.440 m |
| VAL-2023-014 | Cuartel Bomberos Viña del Mar | ≈ 14.053 m |
| VAL-2025-002 | Cuartel Bomberos Concón | ≈ 4.924 m |
| VAL-2025-011 | Cuartel Bomberos Viña del Mar | ≈ 19.567 m |
| VAL-2025-015 | Cuartel Bomberos Quilpué | ≈ 11.819 m |
| VAL-2024-020 | Cuartel Bomberos Quilpué | ≈ 27.312 m |

Near mide distancia euclidiana en el plano UTM, igual que `ST_Distance` sobre EPSG:32719. No es tiempo de respuesta por la red vial.

**G.8** *ModelBuilder.*

Estructura mínima esperada:

1. Variables de modelo marcadas como **parámetro**: distancia del buffer (*Linear Unit*, por defecto 500 m) y tipo de establecimiento (*SQL Expression* o *String* con lista de valores).
2. Cadena: Make Feature Layer (filtro por tipo) → Select Layer By Location (Within) → Pairwise Buffer (distancia parametrizada, Dissolve All) → Spatial Join → Pairwise Intersect con comunas → Summary Statistics → Near hacia cuarteles.
3. Salidas intermedias en `memory\` y salidas finales en la geodatabase.
4. Exportación del diagrama (*Export → Export As Python File* o como imagen) como especificación.

Correspondencia con SQL de la Unidad 4: cada parámetro del modelo pasa a ser un parámetro de una función o una constante en una CTE, y cada herramienta pasa a ser una etapa `WITH` de una sola consulta. Criterio de revisión: con distancia 500 m el modelo reproduce los valores de G.4–G.7; con 2000 m, el anillo de G.5.
