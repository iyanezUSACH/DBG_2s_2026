# Respuestas · Guía U1 · Diseño conceptual y lógico

Respuestas de referencia para [Guia_U1_Modelado.md](../Guías/Guia_U1_Modelado.md). En los ejercicios de modelado hay más de una solución correcta: lo que se evalúa es que cada decisión esté justificada por el relato, por una regla de negocio o por una definición. Intente resolver cada ejercicio antes de leer su respuesta.

> **Ejercicios 1.11, 1.12, 1.13 y 1.21:** forman parte del Lab autónomo C (entrega domingo 18 de octubre, 23:59). Sus respuestas se publican el **lunes 19 de octubre**.

Referencias: Elmasri y Navathe (2016), caps. 1–5 y 9; ISO 19109:2025; ISO 19110:2016; ISO 19152-1:2024. El esquema completo del caso está en [a01_esquema.sql](../sql/01_caso_academico/a01_esquema.sql).

---

## A. Sistemas gestores y niveles de abstracción

**1.1** El **esquema** es la descripción de la estructura de la base (tablas, columnas, tipos, restricciones) y cambia muy poco. La **instancia** (o estado) es el conjunto de datos almacenados en un momento dado y cambia con cada operación. Cuando un estudiante se inscribe en una sección cambia **solo la instancia**: se agrega una fila a `inscripcion`. El esquema sigue igual, y la nueva fila debe cumplirlo (RUT válido, sección existente, una sección por asignatura y período).

**1.2** Cuatro problemas que resuelve un SGBD frente a planillas separadas:

| Problema | En el caso | Respuesta del SGBD |
|---|---|---|
| Redundancia | El nombre y la carrera de un estudiante se repiten en la planilla de cada secretaría | Cada dato se guarda una vez y se referencia por su clave |
| Inconsistencia | Una secretaría corrige el correo y otra no; quedan dos versiones | Una sola fuente; claves foráneas y catálogos |
| Acceso concurrente | Dos secretarías inscriben a la vez en la última vacante | Transacciones con aislamiento y bloqueo |
| Seguridad | Cualquiera con la planilla puede cambiar una nota | Roles y privilegios por tabla, vista o columna |

También son válidos: integridad (notas fuera de 1,0–7,0), respaldo y recuperación ante fallas, y consultas que cruzan secretarías.

**1.3** (a) **física**: el índice cambia el nivel interno, no el esquema conceptual. (b) **lógica**: cambia el esquema conceptual; las vistas externas deben seguir funcionando. (c) **física**: cambia el almacenamiento, no el esquema. (d) **lógica**: se modifica el esquema conceptual.

**1.4** Arquitectura ANSI/SPARC de tres niveles: externo, conceptual e interno, con correspondencias entre ellos.

| Usuario | Vista externa |
|---|---|
| Estudiante | Su avance: asignaturas inscritas, notas, horario y sala. Sin datos de otros estudiantes |
| Secretaría docente | Secciones, cupos, horarios, salas e inscritos por sección; puede inscribir y retirar |
| Jefatura de carrera | Indicadores agregados: tasas de aprobación, promedios y estudiantes en riesgo |
| Administrador de la base | El esquema conceptual completo y el nivel interno: índices, archivos, respaldos y roles |

---

## B. Requerimientos y reglas de negocio

**1.5** Reglas verificables y atómicas (una idea por regla), redactadas de modo que se pueda comprobar si se cumplen:

- **RN-01** Todo estudiante pertenece a exactamente una carrera.
- **RN-02** Toda carrera es administrada por exactamente un departamento.
- **RN-03** Un estudiante se inscribe en a lo más una sección de una misma asignatura en un mismo período.
- **RN-04** La nota es un valor entre 1,0 y 7,0 con un decimal; se aprueba con 4,0 o más.
- **RN-05** Una sección se identifica por la asignatura, el período y su número.
- **RN-06** El número de inscritos en una sección no supera su cupo.
- **RN-07** Toda sección tiene exactamente un profesor responsable.
- **RN-08** Una asignatura no puede ser prerrequisito de sí misma.
- **RN-09** Para inscribir una asignatura, el estudiante debe haber aprobado todos sus prerrequisitos.
- **RN-10** Una sala no puede asignarse a dos secciones en el mismo período, día y bloque.
- **RN-11** Una persona puede ser a la vez estudiante y profesor.
- **RN-12** Toda asignatura es dictada por exactamente un departamento.

Observe que RN-06 y RN-09 no se pueden imponer con claves: requieren un disparador o control de la aplicación.

**1.6** Diccionario de datos (extracto):

| Entidad | Atributo | Descripción | Tipo | Dominio | Oblig. | Fuente | Ejemplo |
|---|---|---|---|---|---|---|---|
| seccion | cod_asig | Asignatura de la sección | varchar(6) | Código existente en `asignatura` | Sí | Programación docente | 14504 |
| seccion | periodo | Semestre académico | char(6) | AAAA-S, S ∈ {1, 2} | Sí | Programación docente | 2026-2 |
| seccion | num_seccion | Número dentro de asignatura y período | smallint | > 0 | Sí | Programación docente | 1 |
| seccion | rut_profesor | Profesor responsable | varchar(10) | RUT de un profesor existente | Sí | Programación docente | 12345678-9 |
| seccion | cupo | Vacantes ofrecidas | smallint | 1–120 | Sí | Programación docente | 30 |
| inscripcion | rut_estudiante | Estudiante inscrito | varchar(10) | RUT de un estudiante existente | Sí | Registro Curricular | 20111222-4 |
| inscripcion | cod_asig, periodo, num_seccion | Sección inscrita | varchar(6), char(6), smallint | Sección existente | Sí | Registro Curricular | 14504 · 2026-2 · 1 |
| inscripcion | fecha_inscripcion | Fecha de la inscripción | date | ≤ fecha actual | Sí | Sistema | 2026-08-10 |
| inscripcion | nota | Calificación final | numeric(2,1) | 1,0–7,0 o vacío si está en curso | No | Acta del profesor | 6,2 |
| inscripcion | estado | Situación de la inscripción | varchar(10) | Inscrita, Aprobada, Reprobada, Retirada | Sí | Registro Curricular | Aprobada |

**1.7** Roles y permisos (C = crear, R = leer, U = modificar, D = borrar):

| Rol | persona | estudiante | asignatura | seccion | inscripcion |
|---|---|---|---|---|---|
| Estudiante | R (propia) | R (propia) | R | R | R (propias) |
| Secretaría docente | R | R | R | CRU | CRU (sin nota) |
| Profesor | R | R | R | R (propias) | R; U de `nota` solo en sus secciones |
| Registro Curricular | CRU | CRU | CRU | R | RU |
| Administrador | CRUD | CRUD | CRUD | CRUD | CRUD |

**¿Quién puede modificar una nota?** Solo el profesor de la sección y solo en sus propias secciones; Registro Curricular puede corregirla con un procedimiento formal. En SQL esto se expresa con privilegios por columna (`GRANT UPDATE (nota) ON inscripcion`) y una vista o política que filtre las secciones del profesor.

### Modelar el espacio geográfico

**1.19** Catálogo de entidades según ISO 19110 (extracto):

| Campo | campus | edificio | domicilio |
|---|---|---|---|
| Nombre | Campus | Edificio | Domicilio |
| Definición | Recinto universitario con dirección propia | Construcción dentro de un campus que contiene salas | Lugar de residencia principal declarado por una persona |
| Código | CMP | EDF | DOM |
| Atributos (nombre · tipo · dominio) | cod_campus · texto · código único; nombre · texto · único; direccion · texto; cod_comuna · texto(5) · CUT vigente | cod_edificio · texto · código único; nombre · texto | calle · texto; numero · texto; cod_comuna · texto(5) · CUT vigente; fuente · texto |
| Tipo de geometría | Polígono a escala de barrio; punto a escala comunal o regional | Polígono (huella) | Punto |
| Relaciones | Campus **contiene** edificios (1:N); campus **está en** una comuna (N:1) | Edificio **pertenece a** un campus (N:1); edificio **contiene** salas (1:N) | Domicilio **es de** una persona (1:1); domicilio **está en** una comuna (N:1) |

Columnas que no existían en el diccionario de 1.6: **definición** del tipo de entidad, **código** del tipo, **tipo de geometría** y **relaciones con nombre** entre tipos de entidad. El catálogo describe tipos de objetos del mundo real; el diccionario describe columnas de tablas.

**1.20** El tipo de geometría depende de la escala de uso y de la pregunta:

- **Campus:** punto si se pregunta "¿a qué distancia viven los estudiantes?" a escala regional; polígono si se pregunta "¿qué edificios quedan dentro?" o se calcula su superficie.
- **Comuna:** polígono, porque tiene superficie y límites, y se usa para preguntar qué cae dentro. A escala nacional puede representarse por un punto solo para rotular.
- **Río en una cuenca:** línea para red de drenaje, longitudes y conectividad; polígono si interesa el cauce o la planicie de inundación.

LADM (ISO 19152-1) separa el **objeto** (la unidad administrativa básica o el predio, con derechos, restricciones y responsables) de su **representación espacial** (la *spatial unit*, el polígono) porque un mismo objeto puede tener varias representaciones (planos de distintas fechas y precisión, 2D o 3D) y porque los derechos existen aunque la geometría cambie o aún no se haya levantado. Separarlos evita que una corrección geométrica altere la identidad legal del predio.

---

## C. Modelo ER y EER

**1.8** Modelo ER del relato (notación (mín, máx) de Elmasri y Navathe: el par va junto a la entidad que participa):

| Relación | Entidades y (mín, máx) | Razón | Participación |
|---|---|---|---|
| ADMINISTRA | DEPARTAMENTO (0,N) — CARRERA (1,1) | 1:N | Total de carrera |
| DICTA | DEPARTAMENTO (0,N) — ASIGNATURA (1,1) | 1:N | Total de asignatura |
| PERTENECE | CARRERA (0,N) — ESTUDIANTE (1,1) | 1:N | Total de estudiante |
| SE_ABRE | ASIGNATURA (0,N) — SECCIÓN (1,1) | 1:N, **identificadora** | Total de sección |
| RESPONSABLE | PROFESOR (0,N) — SECCIÓN (1,1) | 1:N | Total de sección |
| INSCRIBE | ESTUDIANTE (0,N) — SECCIÓN (0,N) | M:N con atributos `nota`, `estado`, `fecha_inscripcion` | Parcial en ambos lados |
| EXIGE | ASIGNATURA (0,N) — ASIGNATURA (0,N) | M:N recursiva | Parcial |

Identificadores: `cod_depto`, `cod_carrera`, `rut`, `cod_asig`. **Entidad débil:** SECCIÓN, identificada por la asignatura dueña más su identificador parcial (`periodo`, `num_seccion`). **Relación M:N con atributos:** INSCRIBE.

**1.9** Especialización de PERSONA en ESTUDIANTE y PROFESOR:

- **Solapada**, no disjunta: el relato dice que algunos estudiantes de magíster hacen clases por horas, así que una persona puede pertenecer a ambas subclases.
- **Total**, si solo se registran personas que son estudiante, profesor o ambos. Sería parcial si también se registraran, por ejemplo, funcionarios administrativos.
- Atributos comunes en PERSONA (rut, nombres, apellidos, email, fecha de nacimiento); propios en cada subclase (carrera y año de ingreso; departamento y jerarquía).
- En el modelo relacional (opción 8A de Elmasri y Navathe, cap. 9): `persona(rut PK, …)`, `estudiante(rut PK/FK, cod_carrera FK, anio_ingreso)`, `profesor(rut PK/FK, cod_depto FK, jerarquia)`.

**1.10** Es una relación **recursiva M:N** de ASIGNATURA consigo misma, con dos roles: "exige" y "es exigida". Se representa con la tabla `prerrequisito(cod_asig FK, cod_prereq FK)`, ambas columnas hacia `asignatura` y PK compuesta por las dos. La restricción `CHECK (cod_asig <> cod_prereq)` impide que una asignatura sea prerrequisito de sí misma. Ciclos más largos (A exige B y B exige A) no se detectan con un `CHECK`: requieren una consulta recursiva o un disparador.

---

## D. Modelo relacional y normalización

**1.11, 1.12, 1.13:** se publican el lunes 19 de octubre (Lab autónomo C).

---

## E. La ubicación como atributo

**1.15** Ampliación del modelo:

- CAMPUS (1,1) — EN — (0,N) COMUNA; CAMPUS (0,N) — TIENE — (1,1) EDIFICIO; EDIFICIO (0,N) — TIENE — (1,1) SALA; SALA (0,N) — EQUIPADA — (1,1) MOBILIARIO.
- SECCIÓN se reúne en uno o más horarios: SECCIÓN (1,N) — SE_REÚNE — (1,1) SECCIÓN_HORARIO, que referencia BLOQUE_HORARIO y SALA.
- **Domicilio respecto de persona: 1:1.** Cada persona declara a lo más un domicilio principal (0,1) y cada domicilio pertenece a exactamente una persona (1,1). En el esquema, `domicilio.rut` es a la vez PK y FK a `persona`.
- **El mobiliario no puede ser una columna de sala** porque es multivaluado y compuesto: una sala tiene varios tipos de mueble, cada uno con cantidad y estado. Como columna exigiría listas dentro de una celda (viola la 1FN) o un número fijo de columnas (`silla`, `mesa`, `computador`…) que deja nulos y obliga a cambiar el esquema cada vez que aparece un tipo nuevo.

**1.16** `seccion_horario(cod_asig, periodo, num_seccion, dia, num_bloque, cod_sala)`:

- **PK:** `(cod_asig, periodo, num_seccion, dia, num_bloque)`. Una sección puede reunirse varias veces por semana, así que la sección sola no identifica la fila; la sección más el día y el bloque, sí.
- **FK:** `(cod_asig, periodo, num_seccion)` → `seccion` con `ON DELETE CASCADE` (si se elimina la sección, sus horarios no tienen sentido); `num_bloque` → `bloque_horario` y `cod_sala` → `sala` con `RESTRICT`.
- **Regla que impide dos secciones en la misma sala, día y bloque:** la clave alternativa `UNIQUE (cod_sala, periodo, dia, num_bloque)`. Es una segunda clave candidata de la tabla.

**1.17** Con texto (calle, número, comuna) más latitud y longitud **sí** se puede responder:

1. ¿Cuántos estudiantes viven en cada comuna? (agrupando por `cod_comuna`).
2. ¿Qué estudiantes viven en Maipú? (filtro por código de comuna).
3. ¿Cuál es la distancia en línea recta entre el domicilio y el campus? (fórmula de Haversine sobre latitud y longitud).

**No** se puede responder, o no de forma confiable:

1. ¿El punto declarado cae realmente dentro de la comuna declarada? No hay polígono de comuna con el cual comparar.
2. ¿Qué estudiantes viven a menos de 5 km del campus **por la red vial**, o dentro de una zona de riesgo? Requiere geometrías de vías o de zonas y operaciones espaciales.

También son válidas: ¿cuántos viven dentro del radio urbano?, ¿qué domicilios quedan a menos de 500 m de una línea de metro?

**1.18** Guardar el **código único territorial con FK a `comuna`** evita:

- **Anomalías de inserción:** no se puede registrar una comuna inexistente o mal escrita ("Ñuñoa", "Nunoa", "ÑUÑOA").
- **Anomalías de modificación:** si cambia el nombre oficial de una comuna, se actualiza una sola fila de `comuna`, no todos los domicilios.
- **Inconsistencias en consultas:** agrupar por código da conteos correctos; agrupar por texto libre separa la misma comuna en varias.
- Además, el CUT permite cruzar con fuentes oficiales (INE, censo, SINIM), que usan ese mismo código.

---

**1.14** Respuesta abierta (transferencia al proyecto). Criterios de revisión:

- Las cinco entidades son objetos del problema territorial, no columnas ni procesos.
- Cada relación tiene nombre y razón de cardinalidad.
- Al menos una entidad tiene ubicación, con su tipo de geometría justificado por la escala (punto, línea o polígono).
- Para cada entidad con ubicación se define cómo guardarla sin geometría: código territorial (CUT de comuna, código de cuenca), dirección, o coordenadas con su sistema de referencia declarado.
- El catálogo sigue el formato de 1.19.
