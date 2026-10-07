# Insumo para cátedra U1 · Sistema gestor de bases de datos (SGBD)

**Origen:** adaptado de `DAG_1S2023_GEODATABASE_CLASE1.pptx` (curso DyDAT, 1S 2023, slide 12), quitando todo lo específico de geodatabase/Esri para dejar solo la definición genérica de SGBD. Pensado como apoyo puntual para la semana 1 (Cátedra U1, bloque "propósito y componentes de un sistema gestor de bases de datos"), antes de introducir niveles de abstracción con el caso académico.

## ¿Qué es un sistema gestor de bases de datos (SGBD)?

Un SGBD es el software que controla la organización, el almacenamiento, la recuperación, la seguridad y la integridad de los datos en una base de datos. Acepta solicitudes de las aplicaciones y coordina con el sistema operativo la transferencia de los datos correspondientes.

> Definición operativa: una **colección de datos interrelacionados** junto con un **conjunto de programas para acceder a esos datos**.

## Por qué importa distinguirlo de "guardar datos en archivos"

Conecta directamente con el ejercicio 1.2 de la Guía U1 (planillas Excel separadas por secretaría de carrera): un SGBD resuelve justamente los problemas que esa situación expone —

* redundancia e inconsistencia entre copias de los mismos datos;
* acceso concurrente de múltiples usuarios sin corromper la información;
* control de seguridad y de quién puede leer o modificar qué;
* independencia entre cómo se guardan los datos y cómo los usa cada aplicación.

Esta última idea es el puente natural hacia niveles de abstracción y la arquitectura ANSI/SPARC (ejercicios 1.3–1.4), que ya están cubiertos en la guía y no requieren este insumo.
