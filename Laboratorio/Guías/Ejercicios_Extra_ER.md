# Ejercicios extra · Modelado E-R (banco optativo)

**No forman parte de la evaluación del curso.** Son ocho enunciados independientes de modelado conceptual, útiles para practicar entidad-relación, entidad débil, especialización y relaciones N:M antes del Control 1, más allá del caso del registro académico de `Guia_U1_Modelado.md`. Adaptados de material de bases de datos de nivel de máster (Marín Díaz, *Bases de Datos*, temas 2 y 3). Para cada uno: construya el modelo ER/EER con identificadores, cardinalidades y participación, y transfórmelo a esquema relacional marcando PK, FK y `ON DELETE`.

**E.1 · Matrícula escolar**

`ALUMNO(num_matricula, nombre, fecha_nacimiento, telefono)` · `ASIGNATURA(cod_asignatura, nombre)` · `PROFESOR(id_p, nif_p, nombre, especialidad, telefono)`.

- Un alumno puede estar matriculado en una o varias asignaturas, y en la misma asignatura más de un curso escolar si repite; se debe registrar en qué curso escolar quedó matriculado de cada una.
- Una asignatura tiene entre 10 y 20 alumnos como mínimo y máximo.
- Una asignatura es impartida por un único profesor; un profesor puede impartir varias asignaturas.

**E.2 · Origen de los empleados**

`REGION(nombre_region)` · `PROVINCIA(cod_provincia, nombre)` · `LOCALIDAD(cod_localidad, nombre)` · `EMPLEADO(id_e, dni_e, nombre, telefono, salario)`.

- Cada empleado nació en una sola localidad; cada localidad pertenece a una única provincia; cada provincia pertenece a una única región.

**E.3 · Montaje de dormitorios**

- Cada modelo de dormitorio lo monta al menos dos montadores; un montador puede montar varios modelos, y el mismo modelo en distintas fechas (se registra la fecha de cada montaje).
- De un montador interesa NIF, nombre, dirección, teléfono y cuántos dormitorios de cada modelo ha montado.
- Un modelo puede ser comprado por uno o varios clientes, y un cliente puede comprar uno o varios modelos; de un cliente interesa NIF, nombre, dirección, teléfono y fecha de compra de cada modelo.

**E.4 · Editorial con sucursales**

- La editorial tiene varias sucursales (domicilio, teléfono, código). Cada sucursal tiene varios empleados (datos personales, DNI, teléfono); un empleado trabaja en una única sucursal.
- Cada sucursal publica varias revistas (título, número de registro, periodicidad, tipo).
- Hay periodistas que no trabajan en sucursales y escriben para varias revistas (mismos datos que empleado, más especialidad).
- De cada número de revista se guarda fecha, número de páginas y ejemplares vendidos.

**E.5 · Videoclub**

- Una película tiene título, nacionalidad, productora y fecha; puede haber varias películas con el mismo título en fechas distintas.
- En una película participan varios actores (nombre, nacionalidad, sexo), algunos como principales. Una película tiene un director (nombre, nacionalidad).
- De cada película hay uno o varios ejemplares, diferenciados por número de ejemplar y estado de conservación. Un ejemplar puede estar alquilado a un socio (DNI, nombre, dirección, teléfono), con fecha de inicio y de devolución del alquiler.
- Un socio debe ser avalado por otro socio. *Pista:* esta última relación es recursiva, igual que `prerrequisito` en el caso académico del curso.

**E.6 · Entidad bancaria**

- Cliente: DNI, nombre, dirección, localidad, fecha de nacimiento, sexo.
- Sucursal: código, nombre, dirección, localidad.
- Transacción: número (único por cuenta), fecha, cantidad.
- Un cliente puede tener muchas cuentas y una cuenta puede ser de muchos clientes (N:M); una cuenta pertenece a una sola sucursal.

**E.7 · Municipios y viviendas**

- Municipio: identificador único, nombre, código postal, provincia.
- Vivienda: tipo de vía, nombre de vía, número.
- Persona: DNI, nombre, sexo, fecha de nacimiento.
- Una persona habita una sola vivienda, pero puede ser propietaria de varias. *Pista:* la relación de una persona con su cabeza de familia es recursiva.

**E.8 · Nóminas de una empresa**

- Empleado: número interno (asignado al ingresar), NIF, nombre, número de hijos, porcentaje de retención, cuenta corriente (banco, sucursal, número), departamentos en los que trabaja (con función distinta en cada uno).
- Departamento: nombre y sus sedes.
- Nómina: identificada por empleado + ejercicio fiscal + mes + número de orden (por si hay varias en el mismo mes); guarda ingreso total y descuento total.
- Cada nómina tiene varias líneas (al menos una de ingreso), identificadas por número de línea dentro de la nómina; una línea es de ingreso o de descuento, con su cantidad (positiva o negativa) y, si es descuento, la base y el porcentaje aplicado.
- Toda línea de ingreso responde a un único concepto retributivo (código y descripción); varias líneas pueden compartir el mismo concepto.

## Respuestas

[Respuestas de los ejercicios extra](../Soluciones/Respuestas_Ejercicios_Extra_ER.md).
