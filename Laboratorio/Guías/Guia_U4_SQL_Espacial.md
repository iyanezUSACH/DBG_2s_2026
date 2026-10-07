# Guía U4 · Consultas espaciales aplicadas

**Semanas 14 y 16 (21–24 dic y 4–8 ene).** Base: scripts `i01`–`i03` de `sql/02_caso_incendios`. Criterio común: usar el perímetro más reciente de cada evento (vista `v_area_vigente`). Cada respuesta incluye la pregunta en lenguaje del cliente, la consulta, una interpretación de 2–3 líneas y **el geoproceso equivalente del Módulo G con el que se contrasta**. ★ = nivel prueba.

```sql
CREATE OR REPLACE VIEW riesgo.v_area_vigente AS
SELECT DISTINCT ON (id_evento) id_area, id_evento, fecha_corte, geom
FROM riesgo.area_quemada
ORDER BY id_evento, fecha_corte DESC;
```

## A. Predicados espaciales

**4.1** ¿Qué establecimientos quedaron dentro de un área quemada? Distinga críticos de no críticos.

**4.2** ★ ¿Qué establecimientos críticos están a menos de 2 km de un área quemada sin estar dentro? ¿Por qué `ST_DWithin` y no `ST_Distance < 2000`?

**4.3** Asigne a cada foco la comuna que lo contiene y compare con la declarada.

**4.4** ¿Qué incendios afectaron a más de una comuna? ¿Por qué excluir los que solo se tocan?

**4.5** Comunas vecinas de Viña del Mar y tipo de contacto (borde o vértice).

## B. Combinaciones y agregación espacial

**4.6** ★ ¿Qué vías quedaron cortadas y en cuántos metros? Exprese el porcentaje de cada vía afectado.

**4.7** Críticos y camas por comuna usando la geometría en lugar de la FK. Compare con el conteo por clave foránea y explique la diferencia.

**4.8** ★ Superficie quemada por comuna (ha y %), sin contar dos veces las superposiciones. Compare con el resultado del Lab B.

**4.9** Para cada foco, el cuartel de bomberos más cercano con `<->` y `LATERAL`.

**4.10** Los tres establecimientos críticos más cercanos a cada foco activo.

**4.11** Población expuesta por ponderación areal. Discuta dos limitaciones del supuesto de distribución homogénea.

## C. Operaciones geométricas y desempeño

**4.12** Zona de amenaza con buffer de 500 m, disuelta, y establecimientos que contiene.

**4.13** Kilómetros de red vial por comuna y categoría (recorte línea-polígono).

**4.14** Contorno del área de estudio, envolvente convexa y centroide de los focos.

**4.15** ★ Compare con `EXPLAIN ANALYZE` `ST_Distance(...) < 1000` y `ST_DWithin`. ¿Dónde se usa el índice?

**4.16** Cree la vista `v_exposicion_critica` con geometría, agréguela en ArcGIS Pro como capa de consulta con simbología por nivel, expórtela a GeoPackage con `ogr2ogr` y respalde el esquema con `pg_dump`.

## Respuestas

Soluciones ejecutables de 4.1–4.16 en [i05_consultas_espaciales_soluciones.sql](../sql/02_caso_incendios/i05_consultas_espaciales_soluciones.sql) (requiere `i01`, `i02` e `i03`; para 4.15, también `i04_espacial_soluciones.sql`).
