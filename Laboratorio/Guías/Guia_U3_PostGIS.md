# Guía U3 · Modelado y gestión de datos espaciales en PostGIS

**Semana 13 (14–18 dic), después del Módulo G.** Base: ejecutar en orden `sql/02_caso_incendios/i01_esquema_relacional.sql`, `i02_datos.sql` e `i03_espacial.sql`. El caso de incendios se entrega ya modelado: revisen su esquema como repaso de U1–U2 antes de espacializarlo. Incluir consulta, resultado y captura de ArcGIS Pro (capa de consulta) cuando se pida inspección visual. ★ = nivel control.

## A. Tipos de geometría y representaciones

**3.1** Para los hospitales, obtenga la geometría en WKT, EWKT, WKB (hex) y GeoJSON en WGS 84. ¿Qué información tiene EWKT que WKT no tiene?

**3.2** Inventaríe las capas espaciales con `geometry_columns`. ¿Por qué `stg_area_quemada` aparece con SRID 0 y tipo GEOMETRY, y qué riesgo implica?

**3.3** ★ Para `comuna`, `via` e `infraestructura` informe tipo, dimensión topológica, número de coordenadas y SRID. Diferencie `ST_Dimension` de `ST_NDims`.

**3.4** Área de cada comuna (km²) y densidad. Compare el área quemada calculada con la declarada y discuta las diferencias.

## B. Sistemas de referencia y unidades

**3.5** Longitud y latitud de los hospitales. Distancia Hospital Fricke–Hospital de Quilpué con `geometry` en UTM y con `geography`. ¿Cuándo dejarían de ser casi iguales?

**3.6** Reproduzca el error clásico: la misma distancia en EPSG:4326 con `geometry`. ¿Qué unidad devuelve?

## C. Validez, calidad y reglas espaciales

**3.7** ★ Diagnostique la tabla de paso con `ST_IsValid`, `ST_IsValidReason`, `ST_SRID` y la extensión. Corrija el SRID mal declarado (`ST_SetSRID` + `ST_Transform`) y los inválidos (`ST_MakeValid` + `ST_CollectionExtract`) y promuévalos a `area_quemada`. Compare con Check Geometry del Lab B.

**3.8** ★ Encuentre establecimientos cuya geometría no cae en la comuna declarada. Implemente un trigger que impida nuevos casos (equivalente a una attribute rule) y demuéstrelo.

**3.9** Matriz de relaciones entre comunas (`ST_Touches`, `ST_Overlaps`, `ST_Relate`) y largo del límite común. ¿Qué par se toca solo en un vértice?

## D. Eficiencia, metadatos y tiempo

**3.10** Genere 200.000 puntos sintéticos y compare con `EXPLAIN ANALYZE` una consulta punto-en-polígono antes y después de crear un índice GiST.

**3.11** Con `fecha_corte`, obtenga el perímetro vigente de cada evento y el crecimiento de VAL-2024-001 entre cortes. Una `catalogo_capa` con `geometry_columns` para una ficha de metadatos por capa.
