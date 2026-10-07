# Guía U2 · Implementación relacional y lenguaje SQL

**Semanas 6–9 (26 oct – 20 nov; la semana 6 se trabaja con el Lab autónomo A).** Caso clásico: **registro académico**. Base: `sql/01_caso_academico/a01_esquema.sql` y `a02_datos.sql`. Entregar un `.sql` comentado por ejercicio con la salida relevante. ★ = nivel control.

## A. Definición de datos y restricciones

**2.1** Liste tablas y columnas del esquema `academico` con `information_schema.columns`. ¿Qué columnas usan dominios propios (`domain_name`)?

**2.2** Agregue a `persona` una columna `telefono` que solo acepte `+56` y 9 dígitos. Pruébela y elimínela, todo dentro de una transacción.

**2.3** Cree la tabla `tutoria(id, rut_estudiante, rut_profesor, fecha, tema)` con dos claves foráneas y un CHECK que impida que una persona se tutoree a sí misma. Inserte una tutoría.

**2.4** ★ Escriba cuatro `INSERT` que fallen por: nota fuera de dominio, RUT mal formado, sección inexistente e inscripción duplicada. Copie cada error e identifique la restricción.

**2.5** Intente borrar el departamento DIGEA y luego la persona de Florencia Jiménez (sin inscripciones). ¿Por qué uno falla y el otro borra también una fila de `estudiante`? Use `ROLLBACK`.

## B. Consultas, funciones y agregación

**2.6** Estudiantes de ICTM ordenados por apellido.

**2.7** Edad de cada estudiante al 21 de septiembre de 2026 y años en la carrera.

**2.8** Inscripciones del período 2026-2 mostrando “En curso” cuando no hay nota (`COALESCE`, `CASE`).

**2.9** Promedio, mínimo y máximo por asignatura en 2026-1.

**2.10** Asignaturas con más de dos inscritos en 2026-2 (`HAVING`).

**2.11** ★ Por sección: inscritos, con nota, sin nota y promedio. ¿Por qué difieren `count(*)` y `count(nota)`?

**2.12** Con `UNION`, `INTERSECT` y `EXCEPT`: (a) personas que son estudiante o profesor; (b) las que son ambas cosas; (c) estudiantes que cursaron en 2026-1 y no se inscribieron en 2026-2.

## C. Combinaciones, subconsultas, CTE y vistas

**2.13** Inscripciones 2026-2 con nombre del estudiante, asignatura, sección, profesor, día, hora y sala (siete tablas).

**2.14** ★ Todas las secciones de 2026-2 con inscritos y vacantes, incluidas las vacías. Luego, los estudiantes sin ninguna inscripción.

**2.15** Inscripciones cuya nota supera el promedio de su asignatura en ese período (subconsulta correlacionada).

**2.16** ★ Con una CTE, promedio ponderado por créditos (PPA) y créditos aprobados por estudiante; ranking dentro de cada carrera con `rank() OVER (PARTITION BY …)`.

**2.17** Cree la vista `v_acta` (período, asignatura, sección, estudiante, nota, estado).

## D. Transacciones, roles e intercambio

**2.18** Cree `rol_consulta_14504` (solo lee `v_acta`) y `rol_secretaria_14504` (inscribe). Demuestre con `SET LOCAL ROLE` qué puede hacer cada uno.

**2.19** Exporte `v_acta` a CSV con `\copy`. Importe un CSV de nuevas personas a una tabla de paso con columnas `text` y escriba la consulta que detecta RUT mal formados antes de insertarlos.

**2.20** **Desafío.** (a) Detecte las inscripciones de 2026-2 que no cumplen sus prerrequisitos aprobados (`NOT EXISTS`). (b) Obtenga la cadena completa de prerrequisitos de Inteligencia Territorial con `WITH RECURSIVE`.

## E. La ubicación como atributo (puente a la Unidad 3)

**2.21** ★ Escriba la función `km_haversine(lat1, lon1, lat2, lon2)` y calcule la distancia en línea recta entre el domicilio de cada estudiante y el campus. Ordene de mayor a menor. Control: Matías González (Puente Alto) 20,5 km; Catalina Reyes (Estación Central) 3,0 km.

**2.22** Distancia promedio y máxima al campus por carrera, y número de estudiantes por comuna de residencia.

**2.23** ★ ¿Quién está hoy, martes en el bloque 5, en qué sala y en qué edificio? Una sola consulta que una inscripción, estudiante, persona, carrera, sección, asignatura, horario, bloque, sala y edificio.

**2.24** Ocupación de las salas del martes en el bloque 5 (inscritos sobre capacidad) y computadores operativos disponibles. Después, las salas libres en ese bloque (`NOT EXISTS`).

**2.25** Escriba, sin ejecutarla, cómo cambiaría cada consulta de 2.21–2.24 si la latitud y la longitud fueran una sola columna `geometry`. Compare su respuesta con la tabla de equivalencias del Módulo G.

## Lab 8 · Banco de 15 consultas del proyecto

Cada equipo aplica lo aprendido a **su caso territorial**: redacta 15 preguntas de negocio (al menos 3 con JOIN múltiple, 2 con subconsulta, 2 con CTE, 2 con agregación y HAVING, 1 con operación de conjuntos y 1 vista) y las resuelve en SQL, con pregunta, consulta y resultado esperado. Es parte del Hito P2.

## Respuestas

Soluciones ejecutables de 2.1–2.25 en [a03_academico_soluciones_U2.sql](../sql/01_caso_academico/a03_academico_soluciones_U2.sql) (requiere `a01_esquema.sql` y `a02_datos.sql`; es re-ejecutable). El Lab 8 es abierto y no tiene solución única.
