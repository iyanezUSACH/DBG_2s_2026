# Insumo para cátedra U3 · Dominios, subtipos, topología y relationship classes

**Origen:** adaptado de `DAG_1S2023_GEODATABASE_CLASE2.pptx` y `DAG_1S2023_GEODATABASE_CLASE3.pptx` (curso DyDAT, 1S 2023). Complementa `Insumo_U3_Geodatabase_Esri.md` con el sustento conceptual de tres filas de la tabla G2 del Módulo G. Pensado para la cátedra de las semanas 10–11, en paralelo con los ejercicios G.2 y G.3 y como anticipo de los ejercicios 3.7–3.9 de la Guía U3.

## Dominios y subtipos (para G.2)

**Dominios de atributo:** reglas que describen los valores legales de un campo. Sirven para forzar integridad de datos limitando los valores permitidos en un atributo de una tabla o feature class — el mismo rol que cumple un `DOMAIN` o un `CHECK` en PostgreSQL.

**Subtipos:** subconjunto de objetos de un feature class o tabla que comparten los mismos atributos; categorizan los datos y permiten fijar un valor por defecto que se aplica automáticamente al crear una entidad. Equivalen a una columna discriminadora con restricciones en el modelo relacional (por ejemplo, `id_tipo` en `infraestructura`).

| Geodatabase | PostgreSQL | Ejercicio |
|---|---|---|
| Dominio codificado (`causa`) | `DOMAIN` o FK a catálogo | G.2 |
| Dominio de rango (`capacidad`, 1–2000) | `CHECK (capacidad BETWEEN 1 AND 2000)` | G.2 |
| Subtipo por tipo de infraestructura | Columna discriminadora + `CHECK` | G.2 |

## Topología (para la fila "Topología" de G2 y los ejercicios 3.7–3.9)

Un modelo de datos topológico administra relaciones espaciales representando los objetos (punto, línea, área) como un grafo de primitivas: nodos, caras y bordes. La topología sirve para:

* restringir cómo las entidades comparten geometría (polígonos adyacentes con bordes compartidos, líneas de eje compartiendo geometría con manzanas censales);
* definir y aplicar reglas de integridad: sin huecos entre polígonos, sin entidades superpuestas;
* soportar consultas de adyacencia y conectividad;
* construir entidades a partir de geometría no estructurada (por ejemplo, polígonos desde líneas).

**Elementos de una topología de geodatabase** que conviene mostrar antes de los ejercicios 3.7–3.9:

* **Cluster tolerance:** tolerancia (x, y) — y opcionalmente z — usada en el procesamiento topológico; coordenadas dentro de esa tolerancia se mueven a la ubicación de mayor precisión.
* **Ranking de precisión relativa** entre feature classes: la de mayor precisión recibe rango 1; se usa para decidir qué coordenadas ceden ante cuáles al validar.
* **Lista de feature classes participantes:** deben compartir sistema de coordenadas y feature dataset — el mismo requisito que motiva un solo SRID por esquema en PostGIS.
* **Reglas topológicas** (sin huecos, sin superposición, cobertura, etc.).

**Paralelo con PostGIS:** donde la geodatabase valida con una topología declarada y su cluster tolerance, PostGIS lo hace con `ST_IsValid`, `ST_IsValidReason` y `ST_MakeValid` sobre cada geometría, y con triggers para reglas entre tablas (como el ejercicio 3.8, que exige un trigger que impida un establecimiento fuera de su comuna — el equivalente a una regla topológica de contención).

## Relationship classes (para G.3)

Al crear una relationship class se elige una entidad **origen** y una **destino**, y los objetos se asocian por coincidencia de valores en campos clave — el mismo mecanismo de una FK relacional. Puede ser:

* **Simple:** los objetos de origen y destino son independientes entre sí.
* **Compuesta:** al eliminar un objeto de origen, se eliminan también los objetos de destino relacionados — el equivalente exacto de `ON DELETE CASCADE`. Una relación simple sin esa propagación equivale a `ON DELETE RESTRICT` o `SET NULL`.

**Cardinalidad:** 1:1, 1:N o N:M, igual que en el modelo relacional. Con subtipos, además se puede restringir qué tipo de objeto de origen se relaciona con qué tipo de objeto de destino (reglas de relación).

**Relación N:M:** exige una tabla intermedia que asigna la PK de origen a la FK de destino; cada fila asocia un objeto de origen con uno de destino. Esa tabla intermedia puede, opcionalmente, almacenar atributos propios de la relación — exactamente el rol de `prerrequisito` en el caso académico (Unidad 1): una relación N:M recursiva entre `asignatura` consigo misma, resuelta con una tabla propia.

**Aplicación directa al ejercicio G.3:** la relación evento → área quemada — ¿es simple o compuesta? Si se decide que borrar un evento de incendio debe borrar sus áreas quemadas asociadas, es compuesta y equivale a `ON DELETE CASCADE`; si las áreas quemadas deben sobrevivir o impedir el borrado, es simple y equivale a `RESTRICT`.

## Referencias (de las presentaciones originales)

Documentación Esri ArcGIS Pro sobre relationship classes (dominios, subtipos, cardinalidad, tabla intermedia) — citada como fuente en `DAG_1S2023_GEODATABASE_CLASE3.pptx`, slides 4–11.
