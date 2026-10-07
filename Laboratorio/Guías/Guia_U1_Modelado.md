# Guía U1 · Diseño conceptual y lógico de bases de datos

**Semanas 1–5 (21 sep – 23 oct; la semana 2 es de presentaciones).** Caso clásico: **registro académico universitario**. Resolver en equipo salvo indicación. ★ = nivel control. Semana 3: 1.5–1.8, 1.19 y 1.20; el miércoles 7 de octubre, modelo lógico (cardinalidad, tipos de campos y claves) con 1.11 y 1.21 como preparación del Lab C. El ejercicio 1.14 conecta con el proyecto territorial.

> **Relato del cliente (Registro Curricular):** *“La universidad tiene departamentos que dictan asignaturas y administran carreras. Cada estudiante pertenece a una carrera. Una asignatura puede exigir otras como prerrequisito. Cada período se abren secciones de una asignatura, cada una con un profesor, un cupo y una sala. El estudiante se inscribe en una sección por asignatura y período y, al terminar, obtiene una nota entre 1,0 y 7,0; aprueba con 4,0. Algunos estudiantes de magíster también hacen clases por horas.”*

## A. Sistemas gestores y niveles de abstracción

**1.1** Explique con el caso la diferencia entre *esquema* e *instancia*. ¿Qué cambia cuando un estudiante se inscribe en una sección?

**1.2** Hoy cada secretaría de carrera lleva sus inscripciones en planillas Excel separadas. Enumere cuatro problemas concretos (redundancia, inconsistencia, acceso concurrente, seguridad) que resolvería un SGBD.

**1.3** Clasifique como independencia *física* o *lógica*: (a) se crea un índice sobre `inscripcion`; (b) se divide `persona` en dos tablas; (c) se migra la base a otro servidor; (d) se agrega la columna `telefono`.

**1.4** Dibuje la arquitectura ANSI/SPARC indicando qué vista externa usarían: un estudiante, la secretaría docente, la jefatura de carrera y el administrador de la base.

## B. Requerimientos y reglas de negocio

**1.5** A partir del relato, redacte al menos 10 reglas de negocio numeradas (RN-01…), verificables y atómicas.

**1.6** Construya el diccionario de datos (nombre, descripción, tipo, dominio, obligatoriedad, fuente, ejemplo) para `seccion` e `inscripcion`.

**1.7** Identifique usuarios y roles y construya una matriz rol × entidad con permisos C/R/U/D. ¿Quién puede modificar una nota?

### Modelar el espacio geográfico (semana 3)

> Un objeto geográfico (*feature*) es una abstracción de un fenómeno del mundo real con **identidad, atributos, geometría y relaciones**. ISO 19109 fija las reglas para escribir el esquema de aplicación que los describe; ISO 19110 fija cómo documentarlos en un **catálogo de entidades**, que es el diccionario de datos llevado al territorio.

**1.19** ★ **Catálogo de entidades (ISO 19110).** Para `campus`, `edificio` y `domicilio`, construya una ficha por tipo de entidad con: nombre, definición, código, atributos (nombre, definición, tipo de valor, dominio o lista de valores), **tipo de geometría** (punto, línea o polígono) y **relaciones** con otros tipos de entidad. Compare con el diccionario de 1.6: ¿qué columnas de la ficha no existían allí?

**1.20** **Esquema de aplicación (ISO 19109).** Decida y justifique el tipo de geometría de cada entidad según la escala de uso: ¿un campus es punto o polígono?, ¿una comuna?, ¿un río en el manejo de una cuenca? Después, lea el paquete *Spatial Unit* de LADM (ISO 19152-1) y explique en tres líneas por qué un estándar modela por separado el *objeto* (el predio) y su *representación espacial* (el polígono).

## C. Modelo ER y EER

**1.8** ★ Construya el modelo ER del relato con identificadores, cardinalidades (mín..máx) y participación total/parcial. Identifique la entidad débil y la relación N:M con atributos.

**1.9** Modele con EER la especialización de `persona` en `estudiante` y `profesor`. ¿Disjunta o solapada? ¿Total o parcial? Justifique con el relato.

**1.10** Modele los prerrequisitos. ¿Qué tipo de relación es? ¿Qué restricción evita que una asignatura sea prerrequisito de sí misma?

## D. Modelo relacional y normalización

**1.11** ★ Transforme el modelo de 1.8–1.10 a esquema relacional. Marque PK, FK y escriba la acción ON DELETE de cada clave foránea.

**1.21** ★ **Tipos de campos y claves.** Para cada columna de `persona`, `seccion` e `inscripcion` indique tipo de dato, dominio (rango o lista de valores), si admite `NULL` y si forma parte de la PK, de una clave alternativa (`UNIQUE`) o de una FK. Justifique al menos tres decisiones de tipo (por ejemplo, por qué el RUT es texto y la nota es `numeric(2,1)`). Explique qué regla del relato impone la PK de `inscripcion`.

**1.12** ★ Normalice hasta 3FN la siguiente planilla, escribiendo las dependencias funcionales en cada paso:

| rut | nombre | carrera | depto_carrera | cod_asig | asignatura | créditos | período | sección | profesor | nota |
|---|---|---|---|---|---|---|---|---|---|---|
| 20111222-4 | Valentina Castro | ICTM | DIGEA | 14501 | Geotecnologías | 5 | 2026-1 | 1 | F. Araya | 6,2 |
| 20111222-4 | Valentina Castro | ICTM | DIGEA | 10145 | Fund. Programación | 5 | 2026-1 | 1 | C. Muñoz | 5,5 |
| 20555666-2 | Catalina Reyes | ICG | DIGEA | 14501 | Geotecnologías | 5 | 2026-1 | 1 | F. Araya | 6,7 |

**1.13** Dé un ejemplo de tabla en 3FN que no esté en FNBC dentro del registro académico y explique qué anomalía persiste.

## E. La ubicación como atributo

> **Ampliación del relato:** *“La universidad tiene campus con dirección; cada campus tiene edificios y cada edificio, salas con capacidad, tipo y mobiliario. Cada sección se reúne uno o más días, en un bloque horario y en una sala. Cada estudiante declara un domicilio con calle, número y comuna.”*

**1.15** Amplíe el modelo ER con campus, edificio, sala, mobiliario, bloque horario y domicilio. ¿Qué cardinalidad tiene domicilio respecto de persona? ¿Por qué el mobiliario no puede ser una columna de sala?

**1.16** ★ El horario de una sección no cabe en la tabla `seccion`: una sección puede reunirse martes y jueves. Modele `seccion_horario` y justifique su clave primaria. ¿Qué regla impide que dos secciones usen la misma sala el mismo día y bloque?

**1.17** Hoy la ubicación se guarda como texto (calle, número, comuna) más dos números (latitud y longitud). Escriba tres preguntas que se pueden responder con eso y dos que **no** (por ejemplo, “¿cuántos estudiantes viven a menos de 5 km del campus en línea recta por su comuna real?”). Guarde la lista: la retomaremos en la Unidad 3.

**1.18** Compare dos formas de guardar la comuna de un domicilio: el nombre escrito a mano o el código único territorial con clave foránea a una tabla `comuna`. ¿Qué anomalías evita la segunda?

**1.14** **Transferencia al proyecto.** Tome el problema territorial de su equipo (manejo de una cuenca, zona de sacrificio u otro): identifique cinco entidades, sus relaciones y cuáles tienen ubicación. Escriba el catálogo de entidades del proyecto con el formato de 1.19, incluido el tipo de geometría de cada una. Defina también cómo guardar esa ubicación mientras no haya geometría (código territorial, dirección, latitud y longitud): en la semana 7 esas columnas pasan a `geometry`. Esto alimenta el Hito P1.

## Respuestas

[Respuestas de la Guía U1](../Soluciones/Respuestas_Guia_U1.md). Las de 1.11, 1.12, 1.13 y 1.21 se publican el lunes 19 de octubre, después de la entrega del Lab autónomo C.
