# 🧭 Lab autónomo C · Modelo relacional y normalización

**Semana 4 (12–16 de octubre; lunes 12 feriado, docente ausente 13–16) · sin clase presencial.** Tiempo estimado: 3 h + 1 h. **Entrega: domingo 18 de octubre, 23:59.** Requisito: modelo ER/EER de las semanas 2–3 (ejercicios 1.5–1.10 de `Guia_U1_Modelado.md`). Trabajo con lápiz y papel o editor de diagramas; no requiere PostgreSQL todavía. En la clase de la semana 5 se revisa un caso al azar antes del Control 1.

| Paso | Qué hacer | Valor de control |
|---|---|---|
| C1 | Transforme su modelo ER/EER de 1.8–1.10 al esquema relacional completo (ejercicio 1.11): liste cada tabla con PK, FK y la acción `ON DELETE` de cada clave foránea, y el tipo de dato de cada columna (ejercicio 1.21, visto en la clase del 7 de octubre) | El caso completo tiene 17 tablas (`departamento`, `carrera`, `persona`, `estudiante`, `profesor`, `asignatura`, `prerrequisito`, `seccion`, `seccion_horario`, `bloque_horario`, `inscripcion`, `comuna`, `campus`, `edificio`, `sala`, `mobiliario`, `domicilio`); la de `seccion` es una entidad débil con clave primaria de **tres** columnas |
| C2 | Normalice hasta 3FN la planilla del ejercicio 1.12, escribiendo las dependencias funcionales que identifica en cada paso | La planilla se descompone en **5 tablas**: estudiante, carrera, asignatura, sección (identificada por asignatura + período + número) e inscripción (referencia a estudiante y a sección). La dependencia transitiva rut → carrera → depto_carrera se resuelve separando `carrera` en su propia tabla |
| C3 | Busque en su propio esquema de C1 un ejemplo de tabla en 3FN que no esté en FNBC (ejercicio 1.13) | No hay un valor único de control: revise si alguna clave candidata de la tabla queda determinada por un atributo que no es clave. Anote la tabla elegida y la anomalía que persiste; se discute en clase de la semana 5 |
| C4 | Con el modelo de su equipo, identifique cinco entidades del problema territorial del proyecto, sus relaciones y cuáles tienen ubicación (ejercicio 1.14) | Cada entidad con ubicación debe quedar con una forma concreta de guardarla sin geometría: código territorial (comuna), dirección, latitud y longitud |

## Entrega

* `labC_<apellido>.pdf` o `.md` con el esquema relacional de C1 (PK, FK, `ON DELETE`, tipos de dato), las dependencias funcionales y tablas resultantes de C2, la tabla elegida en C3 con su justificación, y el listado de C4.
* En la clase de la semana 5 se pide explicar un paso elegido al azar antes del Control 1.

## Problemas frecuentes

* **Olvidar la acción `ON DELETE`:** toda FK del caso debe declarar `RESTRICT` o `CASCADE`; revise el criterio en el relato del cliente (por ejemplo, borrar una asignatura no debería borrar sus inscripciones históricas).
* **Dejar `seccion` con clave primaria de una sola columna:** es una entidad débil; sin las tres columnas (asignatura, período, número) dos secciones del mismo período no se pueden distinguir.
* **Normalizar solo hasta 2FN:** revise que ningún atributo no clave dependa de otro atributo no clave (dependencia transitiva), no solo de la clave completa.
