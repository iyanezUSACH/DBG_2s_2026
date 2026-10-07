# Respuestas · Ejercicios extra de modelado E-R

Respuestas de referencia para [Ejercicios_Extra_ER.md](../Guías/Ejercicios_Extra_ER.md). Para cada caso se resumen las decisiones de modelado y el esquema relacional resultante. Notación: `PK` clave primaria, `FK →` clave foránea con su acción `ON DELETE`, `U` clave alternativa (UNIQUE). Los pasos citados son los del algoritmo de transformación de Elmasri y Navathe (2016, cap. 9).

Hay más de una solución correcta. Compare su modelo con el criterio de cada decisión, no solo con los nombres de las tablas.

---

## E.1 · Matrícula escolar

**Decisiones**

- MATRICULA es una relación **M:N** entre ALUMNO y ASIGNATURA con el atributo `curso_escolar`. Como un alumno puede repetir la asignatura, el curso escolar debe **formar parte de la PK**; si no, la segunda matrícula violaría la clave.
- IMPARTE es **1:N** de PROFESOR a ASIGNATURA: la FK va en `asignatura` (paso 4), con `NOT NULL` porque toda asignatura tiene profesor.
- PROFESOR tiene dos claves candidatas: `id_p` (PK) y `nif_p` (alternativa).

**Esquema**

- `alumno(num_matricula PK, nombre, fecha_nacimiento, telefono)`
- `profesor(id_p PK, nif_p U, nombre, especialidad, telefono)`
- `asignatura(cod_asignatura PK, nombre, id_p FK → profesor RESTRICT NOT NULL)`
- `matricula(num_matricula FK → alumno RESTRICT, cod_asignatura FK → asignatura RESTRICT, curso_escolar)`, PK `(num_matricula, cod_asignatura, curso_escolar)`

**Restricción que no captura el esquema:** "entre 10 y 20 alumnos por asignatura" es una cardinalidad (10, 20). Una FK no puede imponer mínimos ni máximos de filas hijas: se controla con un disparador o en la aplicación, y se documenta como regla de negocio.

## E.2 · Origen de los empleados

**Decisiones**

- Cadena de relaciones **1:N**: REGION → PROVINCIA → LOCALIDAD → EMPLEADO. Cada FK va en el lado N y es `NOT NULL` (participación total).
- **No** se guardan la provincia ni la región en `empleado`: se obtienen por la cadena de FK. Guardarlas crearía dependencias transitivas (`localidad → provincia → region`) y violaría la 3FN.

**Esquema**

- `region(nombre_region PK)`
- `provincia(cod_provincia PK, nombre, nombre_region FK → region RESTRICT NOT NULL)`
- `localidad(cod_localidad PK, nombre, cod_provincia FK → provincia RESTRICT NOT NULL)`
- `empleado(id_e PK, dni_e U, nombre, telefono, salario, cod_localidad FK → localidad RESTRICT NOT NULL)`

Usar el nombre como PK de `region` es aceptable si es estable; un código (como el CUT regional en Chile) es preferible.

## E.3 · Montaje de dormitorios

**Decisiones**

- MONTA es **M:N** entre MONTADOR y MODELO, con `fecha`. Como el mismo montador puede montar el mismo modelo en fechas distintas, `fecha` integra la PK.
- "Cuántos dormitorios de cada modelo ha montado" es un **atributo derivado**: se calcula con `count(*)` sobre `montaje`. No se almacena, salvo que se justifique por rendimiento.
- COMPRA es **M:N** entre CLIENTE y MODELO con `fecha_compra`, que también entra en la PK si un cliente puede comprar el mismo modelo más de una vez.

**Esquema**

- `modelo(cod_modelo PK, nombre)`
- `montador(nif PK, nombre, direccion, telefono)`
- `montaje(nif FK → montador RESTRICT, cod_modelo FK → modelo RESTRICT, fecha)`, PK `(nif, cod_modelo, fecha)`
- `cliente(nif PK, nombre, direccion, telefono)`
- `compra(nif_cliente FK → cliente RESTRICT, cod_modelo FK → modelo RESTRICT, fecha_compra)`, PK `(nif_cliente, cod_modelo, fecha_compra)`

**No captura:** "cada modelo lo montan al menos dos montadores" (mínimo 2): disparador o control de aplicación.

## E.4 · Editorial con sucursales

**Decisiones**

- EMPLEADO y PERIODISTA comparten datos personales: se puede modelar una **especialización** de PERSONA, **disjunta** (el relato dice que los periodistas no trabajan en sucursales) y **parcial** o total según si se registran otras personas. Alternativa válida: dos tablas independientes con columnas repetidas.
- NUMERO_REVISTA es una **entidad débil** de REVISTA: el número solo es único dentro de su revista. Su PK incluye la de la revista (paso 2) y su FK usa `CASCADE`.
- ESCRIBE es **M:N** entre PERIODISTA y REVISTA.

**Esquema** (con especialización, opción 8A)

- `sucursal(codigo PK, domicilio, telefono)`
- `persona(dni PK, nombre, direccion, telefono)`
- `empleado(dni PK FK → persona CASCADE, cod_sucursal FK → sucursal RESTRICT NOT NULL)`
- `periodista(dni PK FK → persona CASCADE, especialidad)`
- `revista(num_registro PK, titulo, periodicidad, tipo, cod_sucursal FK → sucursal RESTRICT NOT NULL)`
- `escribe(dni FK → periodista CASCADE, num_registro FK → revista CASCADE)`, PK `(dni, num_registro)`
- `numero_revista(num_registro FK → revista CASCADE, numero, fecha, num_paginas, ejemplares_vendidos)`, PK `(num_registro, numero)`

La disjunción (un DNI no puede estar a la vez en `empleado` y `periodista`) no la impone el esquema: requiere un disparador o una columna discriminadora en `persona`.

## E.5 · Videoclub

**Decisiones**

- PELÍCULA no se identifica por el título (se repite). Clave candidata natural: `(titulo, fecha)`; se recomienda una **clave sustituta** `id_pelicula` y declarar `(titulo, fecha)` como UNIQUE.
- ACTÚA es **M:N** con el atributo `es_principal`.
- DIRIGE es **1:N** de DIRECTOR a PELÍCULA.
- EJEMPLAR es **débil** de PELÍCULA: `num_ejemplar` solo distingue copias de una misma película.
- ALQUILER es **M:N** entre EJEMPLAR y SOCIO a lo largo del tiempo: la fecha de inicio entra en la PK para conservar el historial.
- AVALA es **recursiva 1:N** sobre SOCIO: cada socio tiene un avalista y un socio puede avalar a varios.

**Esquema**

- `director(id_director PK, nombre, nacionalidad)`
- `pelicula(id_pelicula PK, titulo, fecha, nacionalidad, productora, id_director FK → director RESTRICT NOT NULL)`, U `(titulo, fecha)`
- `actor(id_actor PK, nombre, nacionalidad, sexo)`
- `actua(id_pelicula FK → pelicula CASCADE, id_actor FK → actor RESTRICT, es_principal boolean NOT NULL)`, PK `(id_pelicula, id_actor)`
- `ejemplar(id_pelicula FK → pelicula CASCADE, num_ejemplar, estado)`, PK `(id_pelicula, num_ejemplar)`
- `socio(dni PK, nombre, direccion, telefono, dni_aval FK → socio RESTRICT)`, `CHECK (dni_aval <> dni)`
- `alquiler(id_pelicula, num_ejemplar, fecha_inicio, dni_socio FK → socio RESTRICT NOT NULL, fecha_devolucion)`, PK `(id_pelicula, num_ejemplar, fecha_inicio)`, FK `(id_pelicula, num_ejemplar) → ejemplar RESTRICT`, `CHECK (fecha_devolucion IS NULL OR fecha_devolucion >= fecha_inicio)`

**Sobre el aval:** el relato dice que todo socio *debe* ser avalado, lo que pediría `dni_aval NOT NULL`. Pero entonces el primer socio no se podría registrar. Se deja `NULL` solo para el socio fundador, o se usa una restricción diferida (`DEFERRABLE INITIALLY DEFERRED`). Es un ejemplo de por qué la participación total en una relación recursiva requiere cuidado.

## E.6 · Entidad bancaria

**Decisiones**

- TITULARIDAD es **M:N** entre CLIENTE y CUENTA.
- CUENTA pertenece a una sola SUCURSAL: **1:N**, FK en `cuenta`.
- TRANSACCIÓN es **débil** de CUENTA: su número es único solo dentro de la cuenta.
- La `localidad` de cliente y sucursal puede normalizarse en una tabla propia (como en E.2).

**Esquema**

- `cliente(dni PK, nombre, direccion, localidad, fecha_nacimiento, sexo)`
- `sucursal(codigo PK, nombre, direccion, localidad)`
- `cuenta(num_cuenta PK, cod_sucursal FK → sucursal RESTRICT NOT NULL)`
- `titularidad(dni FK → cliente RESTRICT, num_cuenta FK → cuenta RESTRICT)`, PK `(dni, num_cuenta)`
- `transaccion(num_cuenta FK → cuenta RESTRICT, num_transaccion, fecha, cantidad)`, PK `(num_cuenta, num_transaccion)`

**Acción de borrado:** aunque TRANSACCIÓN es débil, aquí conviene `RESTRICT` y no `CASCADE`. En un banco, borrar una cuenta no debe destruir su historial de movimientos; las cuentas se cierran con un estado, no se eliminan.

## E.7 · Municipios y viviendas

**Decisiones**

- VIVIENDA no tiene un identificador propio en el relato: tipo de vía, nombre de vía y número solo son únicos **dentro de un municipio**. Dos opciones: (a) entidad débil de MUNICIPIO con PK compuesta, o (b) clave sustituta `id_vivienda` con la combinación como UNIQUE. La (b) simplifica las FK que llegan a vivienda.
- HABITA es **1:N** (una persona habita una sola vivienda): FK en `persona`.
- PROPIETARIO es **M:N** (una persona puede ser dueña de varias viviendas y una vivienda puede tener varios dueños).
- CABEZA_DE_FAMILIA es **recursiva 1:N** sobre PERSONA.

**Esquema** (opción b)

- `municipio(id_municipio PK, nombre, codigo_postal, provincia)`
- `vivienda(id_vivienda PK, tipo_via, nombre_via, numero, id_municipio FK → municipio RESTRICT NOT NULL)`, U `(id_municipio, tipo_via, nombre_via, numero)`
- `persona(dni PK, nombre, sexo, fecha_nacimiento, id_vivienda FK → vivienda RESTRICT NOT NULL, dni_cabeza_familia FK → persona SET NULL)`
- `propiedad(dni FK → persona RESTRICT, id_vivienda FK → vivienda RESTRICT)`, PK `(dni, id_vivienda)`

El cabeza de familia es nulo para quien es su propio cabeza de familia, o bien se apunta a sí mismo; documente cuál de las dos convenciones usa. La vivienda es el objeto con ubicación del caso: desde la semana 7 tendría una geometría de punto.

## E.8 · Nóminas de una empresa

**Decisiones**

- `cuenta corriente (banco, sucursal, número)` es un **atributo compuesto**: se aplana en tres columnas.
- Las **sedes** del departamento son un **atributo multivaluado**: tabla propia (paso 6).
- TRABAJA_EN es **M:N** con el atributo `funcion` (distinta en cada departamento).
- NÓMINA es **débil** de EMPLEADO, con identificador parcial `(ejercicio, mes, num_orden)`.
- LÍNEA es **débil** de NÓMINA, con identificador parcial `num_linea`. Es una entidad débil de otra entidad débil: su PK tiene cinco columnas.
- LÍNEA se especializa en ingreso y descuento (**disjunta y total**). Se resuelve con una columna discriminadora `tipo` y un `CHECK` que exige los atributos propios de cada subtipo.
- `ingreso_total` y `descuento_total` son **derivados** de las líneas.

**Esquema**

- `empleado(num_interno PK, nif U, nombre, num_hijos, pct_retencion, banco, sucursal_banco, num_cuenta)`
- `departamento(nombre PK)`
- `sede_departamento(nombre_depto FK → departamento CASCADE, sede)`, PK `(nombre_depto, sede)`
- `trabaja_en(num_interno FK → empleado CASCADE, nombre_depto FK → departamento RESTRICT, funcion NOT NULL)`, PK `(num_interno, nombre_depto)`
- `nomina(num_interno FK → empleado RESTRICT, ejercicio, mes, num_orden, ingreso_total, descuento_total)`, PK `(num_interno, ejercicio, mes, num_orden)`, `CHECK (mes BETWEEN 1 AND 12)`
- `concepto(codigo PK, descripcion)`
- `linea_nomina(num_interno, ejercicio, mes, num_orden, num_linea, tipo, cantidad, base, porcentaje, cod_concepto FK → concepto RESTRICT)`, PK `(num_interno, ejercicio, mes, num_orden, num_linea)`, FK `(num_interno, ejercicio, mes, num_orden) → nomina CASCADE`, con:

```sql
CHECK (tipo IN ('Ingreso', 'Descuento')),
CHECK (
  (tipo = 'Ingreso'   AND cod_concepto IS NOT NULL AND base IS NULL AND porcentaje IS NULL) OR
  (tipo = 'Descuento' AND cod_concepto IS NULL     AND base IS NOT NULL AND porcentaje IS NOT NULL)
)
```

**No capturan las claves:** "toda nómina tiene al menos una línea de ingreso" (mínimo 1 del lado hijo) y la coherencia entre `ingreso_total` y la suma de sus líneas. Lo primero requiere un disparador; lo segundo se evita no almacenando los totales y calculándolos en una vista.
