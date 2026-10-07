# Insumo para cátedra U3 · Arquitectura de la geodatabase (Esri)

**Origen:** adaptado de `DAG_1S2023_GEODATABASE_CLASE1.pptx` (curso DyDAT, 1S 2023, slides 8–19). Pensado como apoyo de cátedra para la semana 10 ("Entra el territorio · ArcGIS Pro I"), justo antes o junto con el Módulo G (`Modulo_G_Geoprocesos.md`), para fundamentar la tabla de paralelos G2 con algo más que la enumeración de equivalencias.

## De SGBD genérico a geodatabase

En la semana 1 (Cátedra U1) se definió el SGBD como una colección de datos interrelacionados más un conjunto de programas para acceder a ellos. La **geodatabase** es la estructura de datos nativa de ArcGIS: el formato principal para editar y administrar información geográfica, construido sobre esa misma idea de SGBD, pero especializado en datos espaciales.

Es el almacenamiento físico de la información geográfica y se apoya, según el caso, en un sistema de archivos o en un DBMS relacional al que se accede con SQL — el mismo PostgreSQL que el curso usa desde la Unidad 2.

## Tipos de geodatabase

| Tipo | Descripción | Relación con el curso |
|---|---|---|
| File GDB | Contenida en una carpeta del sistema de archivos | La que se usa en los labs (`caso_14504.gdb`) |
| Personal GDB | Base de datos de Microsoft Access | Deprecada en ArcGIS Pro; no se usa en el curso |
| Enterprise / multiusuario | DBMS relacional multiusuario (Oracle, SQL Server, **PostgreSQL**, SAP HANA) | Es la vía que conecta ArcGIS Pro directamente con PostgreSQL/PostGIS (requiere licencia para habilitar una geodatabase enterprise) |
| XML | Formato de intercambio basado en XML | No se usa en el curso; mencionar solo como referencia |

## Arquitectura interna: tablas de sistema vs. tablas de usuario

Dentro de una geodatabase hay dos conjuntos de tablas:

* **Tablas definidas por el usuario:** cada dataset (feature class, tabla) se guarda en una o más de estas tablas.
* **Tablas del sistema:** llevan el registro del esquema completo — definiciones, reglas y relaciones entre datasets. Cuatro tablas concentran esta información:
  * `GDB_Items`: lista de todos los elementos de la geodatabase (clases de entidad, topologías, dominios).
  * `GDB_ItemTypes`: catálogo predefinido de tipos de elemento reconocidos.
  * `GDB_ItemRelationships`: asociaciones de esquema entre elementos (por ejemplo, qué feature classes pertenecen a qué feature dataset).
  * `GDB_ItemRelationshipTypes`: catálogo predefinido de tipos de relación reconocidos.

**Paralelo directo con PostGIS** (para sumar a la tabla G2 del Módulo G): así como la geodatabase mantiene su propio catálogo de metadatos en `GDB_Items`/`GDB_ItemTypes`, PostgreSQL/PostGIS expone el suyo en `information_schema` (columnas, tablas, dominios) y en `geometry_columns` (qué tabla tiene qué columna geométrica, con qué tipo y SRID) — exactamente lo que se inspecciona en el ejercicio 3.2 de la Guía U3.

## Diseño de una geodatabase

El diseño de una geodatabase sigue los mismos pasos fundamentales del diseño SIG en general: organizar la información geográfica en temas de datos (capas) que se integran por su ubicación geográfica. Esto es exactamente lo que hace G1 paso 2 del Módulo G — estructurar el feature dataset `riesgo` con un solo sistema de referencia, dominios, subtipos y relationship classes — antes de cargar ningún dato.

## Referencias (de la presentación original)

* Documentación oficial Esri, *What is a geodatabase*: <https://pro.arcgis.com/es/pro-app/latest/help/data/geodatabases/overview/what-is-a-geodatabase-.htm>
* Modelos de datos de referencia: <https://support.esri.com/en/technical-article/000011644>
