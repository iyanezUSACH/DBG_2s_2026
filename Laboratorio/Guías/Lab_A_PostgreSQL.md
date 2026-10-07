# 🧭 Lab autónomo A · Implementar el registro académico en PostgreSQL

**Semana 6 (26–30 de octubre) · sin clase presencial.** Tiempo estimado: 4 h + 2 h. **Entrega: viernes 30 de octubre, 23:59.** Requisito: PostgreSQL 16 y pgAdmin 4 instalados en la semana 5. Scripts: `Laboratorio/sql/01_caso_academico/`.

| Paso | Qué hacer | Qué debe verse |
|---|---|---|
| A1 | Abrir pgAdmin 4, expandir *Servers* e ingresar la contraseña de `postgres` | Nodo *PostgreSQL 16* con *Databases* |
| A2 | Clic derecho en *Databases* → *Create* → *Database*: `academico_<apellido>`, UTF8 | **Captura 1:** base creada |
| A3 | *Tools* → *Query Tool* → abrir `a01_esquema.sql` → F5 | **Captura 2:** “Query returned successfully” |
| A4 | Refrescar y abrir *Schemas* → *academico* → *Tables*; revisar *Columns* y *Constraints* de `inscripcion` y `seccion` | Responder: ¿qué dominios usa `inscripcion`?, ¿qué hace `ck_estado_nota`?, ¿por qué la PK de `seccion` tiene tres columnas?, ¿dónde se guarda la sala de una clase y por qué no está en `seccion`? |
| A5 | Ejecutar `a02_datos.sql` | **Captura 3:** persona 17, estudiante 12, profesor 6, asignatura 8, seccion 10, inscripcion 29, comuna 12, sala 5, mobiliario 13, domicilio 17, seccion_horario 11 |
| A6 | Escribir cuatro `INSERT` que fallen: nota 7,5; RUT mal formado; sección inexistente; inscripción duplicada (ejercicio 2.4) | Cuatro errores; `SELECT count(*) FROM academico.inscripcion;` sigue en 29 |
| A7 | Crear la tabla `tutoria` con dos FK a la misma tabla y un CHECK (ejercicio 2.3) | Tabla creada e insertada una fila |
| A8 | Clic derecho en la base → *ERD For Database*; exportar la imagen | Comparar con su ER de la U1: dos diferencias y la decisión detrás de cada una |
| A8b | Consultar la distancia de cada estudiante al campus con `km_haversine` (ejercicio 2.21) | Matías González, Puente Alto: 20,5 km · Catalina Reyes, Estación Central: 3,0 km |
| A9 | Escribir el DDL de al menos tres tablas de **su proyecto territorial**, incluidas las columnas de ubicación (dirección, comuna, latitud y longitud) | Script sin errores |

## Entrega

* `labA_<apellido>.sql` con los pasos A6, A7 y A9 comentados.
* Bitácora en PDF con capturas 1–3, respuestas A4 y diferencias A8.
* En la clase de la semana 7 se pide explicar un paso elegido al azar.

## Problemas frecuentes

* **“connection refused”:** iniciar el servicio `postgresql-x64-16` en *Servicios* de Windows.
* **“permission denied”:** no está conectado como `postgres`.
* **Tildes mal mostradas:** `SET client_encoding TO 'UTF8';`
* **Rutas con espacios o tildes:** usar una carpeta simple como `C:\curso14504`.
