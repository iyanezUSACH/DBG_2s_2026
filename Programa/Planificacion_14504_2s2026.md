Calendario "DISEÑO DE BASES DE GEODATOS" (14504)
                               2° Semestre 2026

HORARIO ASIGNATURA: [completar con el horario real de la sección]

Versión replanificada el 30/09/2026 (semana 2 de 17), alineada con el
Programa v2026-09-30, que incorpora las sugerencias de Daniel Flores:
PostgreSQL y PostGIS antes, caso territorial propio de la carrera (manejo
de cuencas, zonas de sacrificio) y estándares geoespaciales ISO/OGC.

Caso clásico (U1–U2): registro académico universitario; sus coordenadas
pasan a geometría en la semana 7.
Caso territorial (desde la semana 8): exposición de infraestructura crítica
a incendios forestales en la Región de Valparaíso, cliente ficticio
SENAPRED. Proyecto de los equipos: problema territorial de la carrera
(manejo de cuencas, zonas de sacrificio u otro), definido en el Hito P0.

Ausencias del docente ya incorporadas a este calendario: 13–16 de octubre,
17 de noviembre y 9 de diciembre de 2026.

---

1° Semana: 21/09 (Presencial) — REALIZADA
    o Presentación del curso, calendario, evaluación y bibliografía.
    o SGBD, niveles de abstracción, esquemas e independencia de datos ·
      caso clásico (Guía U1, 1.1–1.4).
    * Evaluación diagnóstica: programación, modelos de datos y nociones de SIG.

2° Semana: 28/09 (Presencial) — Sin materia nueva
    o Presentaciones de los estudiantes.
    o El contenido previsto para esta semana (requerimientos, reglas de
      negocio, diccionario de datos) pasa a la semana 3.
    * Hito P0 (2 oct): ficha del caso territorial del proyecto — problema,
      cliente, preguntas y fuentes candidatas. Temas sugeridos: manejo de
      una cuenca, zona de sacrificio (p. ej., Quintero-Puchuncaví) u otro
      problema territorial de la carrera.

3° Semana: 05/10 (Presencial) — Modelar el espacio geográfico
    o Requerimientos, reglas de negocio, diccionario de datos, usuarios y
      roles (Guía U1, 1.5–1.7).
    o Modelado del espacio geográfico: el objeto geográfico como entidad
      con atributos, geometría y relaciones (ISO 19109); el diccionario de
      datos como catálogo de entidades (ISO 19110); LADM (ISO 19152) como
      ejemplo de modelo de dominio territorial ya estandarizado.
    o Modelo entidad-relación: identificadores, cardinalidad, participación
      (Guía U1, 1.8–1.9).
    o Miércoles 07/10 — Modelo lógico: traducción de cardinalidades a
      tablas (1:N, 1:1, N:M, entidad débil, multivaluados), tipos de
      campos y dominios, claves (candidata, primaria, alternativa,
      foránea, compuesta, natural/sustituta) e integridad referencial
      Cátedra y taller en la misma sesión (presentación U1, diapositivas
      11–21; Guía U1, 1.11 y 1.21). Prepara el Lab autónomo C de la semana 4.
    * Aplicación inmediata al caso de cada equipo: catálogo de entidades del
      proyecto (insumo del Hito P1).

4° Semana: 12/10 — Lunes 12 feriado. Docente ausente 13 al 16/10: semana
completa sin clase presencial.
    o Lab autónomo C · Modelo relacional y normalización (Guía U1, 1.11–1.13):
      transformar el ER a esquema relacional marcando PK, FK y ON DELETE;
      normalizar hasta 3FN la planilla de ejemplo, documentando las
      dependencias funcionales en cada paso.
    o Valores de control: la planilla de ejemplo se descompone en 4 tablas
      (persona, carrera, asignatura, inscripción con FK a persona y
      asignatura); ninguna dependencia transitiva debe quedar en la tabla de
      inscripción.
    o Entrega: domingo 18/10, 23:59. En la clase de la semana 5 se revisa un
      caso al azar antes del Control 1.

5° Semana: 19/10 (Presencial)
    o Revisión breve del Lab autónomo C. Especialización (EER, Guía U1 1.10)
      y noción de FNBC.
    o Instalación de PostgreSQL 16, pgAdmin 4 y PostGIS 3.4 en la misma
      sesión; comprobación con CREATE EXTENSION postgis.
    * Control 1 (24 oct): modelo ER/EER y relacional, normalización.
    * Hito P1 (23 oct): reglas de negocio, catálogo de entidades, ER/EER y
      esquema en 3FN del proyecto.

6° Semana: 26/10 — Sin clase presencial (lab autónomo ya planificado).
    o Lab autónomo A · Implementar el registro académico en PostgreSQL
      (Lab_A_PostgreSQL.md, pasos A1–A9): crear la base, ejecutar
      a01_esquema.sql y a02_datos.sql, revisar restricciones y dominios,
      función km_haversine.
    o Valores de control: persona 17, estudiante 12, profesor 6, asignatura 8,
      sección 10, inscripción 29, comuna 12, sala 5, mobiliario 13,
      domicilio 17, sección_horario 11.
    o Entrega: viernes 30/10, 23:59.

7° Semana: 02/11 (Presencial) — Primera geometría (adelantado desde la sem. 9)
    o DDL, dominios, DML y carga de datos (Guía U2, 2.1–2.5).
    o La ubicación como atributo y como geometría: las columnas lat/lon del
      caso académico pasan a geometry(Point); ST_Distance contrastado con
      km_haversine (Guía U2, 2.21–2.25).
    o Revisión de un paso del Lab autónomo A elegido al azar.

8° Semana: 09/11 (Presencial) — Entra el caso territorial
    o Consultas, funciones, agregación, combinaciones, subconsultas y vistas
      (Guía U2, 2.6–2.17), resueltas sobre el caso académico y sobre la
      parte relacional del caso de incendios (i01_esquema_relacional.sql,
      i02_datos.sql).
    * Lab 8: banco de 15 consultas del proyecto (parte del Hito P2).

9° Semana: 16/11 — Docente ausente el martes 17/11.
    o Lunes 16: transacciones, roles y privilegios (Guía U2, 2.18); CTE
      como noción.
    o Miércoles 18 a viernes 20: PostGIS sobre el caso territorial — carga
      de i03_espacial.sql, tipos de geometría y SRID, validez geométrica
      (Guía U3 ★: 3.3, 3.7, 3.8, adelantados desde la semana 13).
    * Control 2 (19 nov): SQL — consultas, agregación, JOIN, vistas y
      primeras consultas con geometría.
    * Hito P2 (20 nov): script DDL + DML reproducible con al menos una capa
      espacial del proyecto en PostGIS, banco de consultas, roles.

10° Semana: 23/11 (Presencial) — ArcGIS Pro I
    o Módulo G, G1 pasos 1–2 (Modulo_G_Geoprocesos.md): generar información
      geográfica (XY Table To Point, digitalización) y estructurar el
      feature dataset `riesgo` en EPSG:32719, con dominios, subtipos y
      relationship classes.
    o Conexión de ArcGIS Pro a la base PostGIS del curso; paralelo
      geodatabase ↔ PostgreSQL/PostGIS (tabla G2). Metadatos de capa
      (catalogo_capa) leídos desde ISO 19115-1.
    * Lab 10: ejercicios G.1–G.3.

11° Semana: 30/11 (Presencial) — Geoprocesos · ArcGIS Pro II
    o Módulo G, G.4–G.7: selección por atributos y localización, buffer,
      clip, intersect, union, dissolve, spatial join, near; cada herramienta
      se resuelve también en SQL (Guía U4 ★: 4.2 críticos a menos de 2 km,
      4.6 vías cortadas).
    o Introducción a ModelBuilder.
    * Lab 11: ejercicios G.4–G.7 con su SQL equivalente.

12° Semana: 07/12 — Sin clase presencial. Lunes 7 interferiado, martes 8
feriado, docente además ausente el miércoles 9/12: semana completa sin
docente.
    o Lab autónomo B · Geoprocesos del caso en ArcGIS Pro (Lab_B_ArcGIS_Pro.md,
      pasos B1–B11): feature classes desde el GeoPackage, XY Table To Point,
      Check Geometry, selección por localización, buffers, intersect,
      near y ModelBuilder (G.8). El paso B11 pide escribir la función SQL
      equivalente de cada paso.
    o Valores de control: 3 establecimientos dentro de área quemada
      (Escuela El Retiro, Escuela Villa Independencia, Sede vecinal El
      Olivar); Quilpué ≈ 2.123 ha, Viña del Mar ≈ 1.843 ha, Villa Alemana
      ≈ 959 ha, Valparaíso ≈ 565 ha; VAL-2024-001 ≈ 5.859 m del Cuartel
      Bomberos Quilpué.
    o Entrega: viernes 11/12, 23:59.

13° Semana: 14/12 (Presencial) — Última semana con trabajo práctico
(geoprocesos y SQL espacial cierran el 15/12).
    o Lunes 14 y martes 15 — última sesión práctica: Guía U4 ★ (4.8
      superficie quemada por comuna, 4.15 EXPLAIN ANALYZE con índice GiST),
      contrastadas con los pasos B8–B9 del Lab autónomo B; control de
      calidad de datos (ISO 19157-1) sobre stg_area_quemada.
    o Miércoles 17: cátedra de cierre — tabla G3 completa (equivalencias
      herramienta ↔ SQL), dudas de proyecto.
    * Control 3 (17 dic, escrito): PostGIS y SQL espacial sobre lo ya hecho
      en clase.
    * Hito P3 (18 dic): geodatabase con dominios, subtipos y relationship
      classes; geoprocesos en ModelBuilder; datos en PostGIS validados e
      indexados, con metadatos.

14° Semana: 21/12 (Presencial, sin lab nuevo)
    o Cátedra de cierre de las unidades 3 y 4: repaso conceptual, lectura
      de consultas espaciales resueltas en clase, contraste geoproceso ↔
      SQL, estándares vistos en el curso. Asesoría de proyecto antes del
      receso.

15° Semana: 28/12 — Receso de navidad y año nuevo. Sin actividades.

16° Semana: 04/01 (Presencial)
    o Cátedra y asesorías de proyecto: consultas espaciales de mayor
      desempeño y publicación de resultados (Guía U4, sección C, como
      lectura y demostración del docente).
    * Prueba individual integradora (escrita/oral: interpreta consultas y
      resultados ya trabajados en clase, contrasta geoproceso con SQL
      equivalente).
    * Hito P4 (8 ene): borrador con consultas espaciales, contraste con
      geoprocesos y mapa del proyecto.

17° Semana: 11/01 (Presencial)
    * Defensas del proyecto: 15 minutos + demo en vivo + preguntas
      individuales.
    * Informe técnico final y repositorio del equipo.
    o Coevaluación (formulario anónimo).

---

Qué cambia en esta versión (30/09/2026):

- Semana 2 sin materia (presentaciones de los estudiantes); sus contenidos
  pasan a la semana 3 y la especialización EER a la semana 5.
- Se incorpora el modelado del espacio geográfico con ISO 19109/19110
  (semana 3), ISO 19115-1 (semana 10) e ISO 19157-1 (semana 13).
- PostGIS se instala en la semana 5 junto con PostgreSQL (antes: sin fecha
  propia) y se usa desde la semana 7 (antes: solo el 14–15 de diciembre).
- El caso territorial entra en la semana 8 por su parte relacional y en la
  semana 9 con geometría (antes: semana 10).
- Los ejercicios ★ de las Guías U3 y U4 se reparten entre las semanas 9, 11
  y 13, en vez de concentrarse en dos días de la semana 13.
- CTE y operaciones transaccionales quedan como nociones, para bajar la
  densidad de la Unidad 2 (nivel 3 de la carrera).
- Sin cambios en las fechas de controles, hitos, labs autónomos, prueba ni
  defensas.

Material que hay que ajustar para cumplir esta versión: Guía U1 (ejercicio
de catálogo de entidades ISO 19110), Lab A (paso de verificación de
PostGIS), Guía U2 (2.21–2.25 pasan a la semana 7 con geometría real) y
presentaciones de U1 y U2.

Bibliografía: ver Cátedra/Recursos/Bibliografia.md y la sección
Bibliografía del Programa de la asignatura (v2026-09-30).
