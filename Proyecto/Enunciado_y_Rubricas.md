# 🎯 Proyecto integrador

Equipos de 3–4 personas diseñan e implementan una base de geodatos en PostgreSQL/PostGIS y una geodatabase en ArcGIS Pro para un problema territorial o medioambiental real de Chile, con un cliente institucional identificado (SENAPRED, municipio, SEREMI, CONAF, DGA, etc.). El producto debe responder al menos **8 preguntas relacionales y 8 espaciales** relevantes para ese cliente.

## Hitos

| Hito | Semana | Entregable | Peso |
|---|---|---|---|
| P0 | 2 (2 oct) | Ficha del caso: problema, cliente, preguntas y fuentes candidatas | Formativo |
| P1 | 5 (23 oct) | Reglas de negocio, catálogo de entidades (ISO 19110), ER/EER y esquema en 3FN | 8 % |
| P2 | 9 (20 nov) | Script DDL + DML reproducible con al menos una capa espacial en PostGIS, banco de consultas, roles | 8 % |
| P3 | 13 (18 dic) | Geodatabase con dominios, subtipos y relationship classes; geoprocesos en ModelBuilder; datos en PostGIS validados e indexados | 8 % |
| P4 | 16 (8 ene) | Borrador con consultas espaciales, contraste con geoprocesos y mapa | 9 % |
| Informe final | 17 (11 ene) | Informe técnico (máx. 20 páginas) + repositorio | 33 % |
| Defensa | 17 (11–15 ene) | 15 min + demo en vivo + preguntas individuales | 34 % |

## Repositorio mínimo del equipo

`README.md` (cómo reconstruir la base desde cero) · `sql/01_esquema.sql` · `sql/02_datos.sql` · `sql/03_espacial.sql` · `sql/04_consultas.sql` · `docs/modelo_er.png` · `docs/diccionario.md` · `DECISIONES.md` (bitácora fechada) · `gdb/` o paquete de proyecto · respaldo `pg_dump`.

## Rúbrica del informe y la base (33 %)

| Criterio | Logrado (7,0) | Suficiente (4,0–5,5) | Insuficiente (1,0–3,5) | Peso |
|---|---|---|---|---|
| Requerimientos y reglas | Trazables a preguntas del cliente; roles definidos | Presentes sin trazabilidad | Vagas o ausentes | 10 % |
| Modelo conceptual y lógico | ER/EER correcto, 3FN justificada con DF | Errores menores | Errores estructurales | 20 % |
| Implementación e integridad | PK, FK, CHECK, dominios, reglas espaciales; corre desde cero | Ajustes menores | No reproducible | 20 % |
| Geodatos y calidad | SRID homogéneo, 0 inválidas, metadatos completos; geodatabase coherente con PostGIS | Calidad parcial | Sin control | 15 % |
| Consultas | 8 + 8 correctas, relevantes, contrastadas con geoprocesos; índices verificados con EXPLAIN | Correctas pero triviales | Errores o insuficientes | 25 % |
| Documentación | Informe claro, mapas con leyenda y fuente, README reproducible | Incompleta | Desordenada | 10 % |

## Rúbrica de la defensa (34 %)

| Criterio | Descripción | Peso |
|---|---|---|
| Comunicación técnica | Problema y solución en lenguaje del cliente y del especialista | 25 % |
| Demostración | Reconstruye o consulta la base en vivo y muestra el mapa en ArcGIS Pro | 25 % |
| Dominio individual | Cada integrante responde sobre una parte que no presentó | 40 % |
| Tiempo y soporte visual | 15 minutos, diapositivas legibles | 10 % |

## Rúbrica de laboratorios (1–7)

* El script o proyecto corre de principio a fin sin errores (2 pts).
* Cada ejercicio tiene pregunta, resultado e interpretación (2 pts).
* Se usan restricciones, índices, funciones o herramientas pertinentes (1,5 pts).
* Orden y legibilidad (0,5 pts) · Entrega a tiempo (1 pt base).

## Coevaluación

Formulario anónimo en la semana 17: aporte técnico, plazos, colaboración y comunicación (1–5). El promedio define un factor individual entre 0,8 y 1,1 sobre la nota grupal.
