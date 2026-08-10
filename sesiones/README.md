# Sesiones

Once carpetas, una por sesión de una hora. La forma cómoda de recorrerlas es
el sitio publicado —tiene navegación, botones de descarga y las páginas en
prosa—: [emirandago.github.io/r-para-ciencia-politica](https://emirandago.github.io/r-para-ciencia-politica/).
Esta carpeta es el código fuente que lo produce, y también se puede navegar
directamente: cada sesión trae su propio `README.md` con la liga a su página
del sitio, la pregunta que responde y la sesión anterior y siguiente.

## Anatomía de una sesión

Cada carpeta trae siempre los mismos siete archivos, con el número de la
sesión como prefijo (`01_`, `02_`, …):

| Archivo | Qué es |
|---|---|
| `NN_guion.qmd` | La página de la sesión en el sitio: el gancho, los objetivos, el contenido en prosa y el bloque "si algo falla". |
| `NN_slides.tex` | La fuente Beamer de las láminas que se proyectan en clase. |
| `NN_slides.pdf` | Las láminas ya compiladas, para descargar sin tener LaTeX instalado. |
| `NN_script.R` | El script guía de la hora. Tiene huecos a propósito y **no corre de corrido**: está hecho para llenarse en vivo durante la sesión. |
| `NN_script_completo.R` | La versión resuelta de `NN_script.R`, esta sí corre de principio a fin. Se publica después de la sesión. |
| `NN_ejercicio.R` | El ejercicio para llevar y resolver por cuenta propia. |
| `NN_solucion.R` | La solución comentada del ejercicio, publicada junto con `NN_script_completo.R`. |

## Las once sesiones

| # | Título | Pregunta que responde | Entregable de la hora | Carpeta | Página del sitio |
|---|---|---|---|---|---|
| 1 | Tu primera hora en R | ¿Por qué un politólogo programa? | Un gráfico de barras de la elección 2024, hecho en la sesión | [01-primer-contacto/](01-primer-contacto/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/01-primer-contacto/01_guion.html) |
| 2 | Los datos son tablas | ¿Cómo se ve una base de datos por dentro? | Cargar y describir una base electoral real | [02-los-datos-son-tablas/](02-los-datos-son-tablas/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/02-los-datos-son-tablas/02_guion.html) |
| 3 | Pedirle cosas a los datos | ¿Dónde ganó Morena por más de veinte puntos? | Una tabla filtrada que contesta una pregunta propia | [03-pedirle-cosas-a-los-datos/](03-pedirle-cosas-a-los-datos/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/03-pedirle-cosas-a-los-datos/03_guion.html) |
| 4 | Agrupar, resumir, cruzar | ¿Cómo comparo estados entre sí? | Cruzar dos bases y resumir por entidad | [04-agrupar-resumir-cruzar/](04-agrupar-resumir-cruzar/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/04-agrupar-resumir-cruzar/04_guion.html) |
| 5 | La gramática de los gráficos | ¿Por qué unos gráficos convencen y otros no? | Un gráfico con título, fuente y paleta defendible | [05-gramatica-de-los-graficos/](05-gramatica-de-los-graficos/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/05-gramatica-de-los-graficos/05_guion.html) |
| 6 | Gráficos que se publican | ¿Cómo hago una figura de paper? | Una figura en PDF lista para un trabajo final | [06-graficos-que-se-publican/](06-graficos-que-se-publican/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/06-graficos-que-se-publican/06_guion.html) |
| 7 | El mapa de México | ¿Cómo se ve el voto en el territorio? | Un mapa coroplético de resultados 2024 | [07-el-mapa-de-mexico/](07-el-mapa-de-mexico/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/07-el-mapa-de-mexico/07_guion.html) |
| 8 | Describir sin mentir | ¿Qué significa que dos cosas «van juntas»? | Un scatter con línea de tendencia e interpretación escrita | [08-describir-sin-mentir/](08-describir-sin-mentir/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/08-describir-sin-mentir/08_guion.html) |
| 9 | La regresión como instrumento politológico | ¿Cuánto explica X a Y? | Una tabla de regresión con lectura en prosa | [09-la-regresion/](09-la-regresion/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/09-la-regresion/09_guion.html) |
| 10 | Que otro pueda repetirlo | ¿Cómo entrego trabajo serio? | Un reporte reproducible propio, publicado | [10-que-otro-pueda-repetirlo/](10-que-otro-pueda-repetirlo/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/10-que-otro-pueda-repetirlo/10_guion.html) |
| 11 | La IA como copiloto, no como piloto | ¿Cómo uso la IA sin dejar de aprender? | El proyecto Morena × ministras, hecho en pareja con la IA | [11-la-ia-como-copiloto/](11-la-ia-como-copiloto/) | [sitio](https://emirandago.github.io/r-para-ciencia-politica/sesiones/11-la-ia-como-copiloto/11_guion.html) |

Once horas no alcanzan para todo lo que enseñaron los tres cursos que este
laboratorio hereda. Lo que no cupo aquí vive en [`extras/`](../extras/),
con el mismo estándar de calidad.
