<div align="center">

<img src="estilo/banner.png" alt="Laboratorio de R para Ciencia Política — ITAM" width="100%">

<br>

### [**→ Entra al sitio del curso ←**](https://emirandago.github.io/r-para-politologos/)

**Ahí está todo, ordenado y fácil de leer.**
Esta página que estás viendo es el almacén; el sitio es la puerta.

<br>

</div>

---

## ¿Qué es esto?

Un curso de **once sesiones de una hora** para aprender R sin haber programado
nunca. Se da a la hora de la comida, en el ITAM, y va dirigido a estudiantes de
Ciencia Política y Relaciones Internacionales de los primeros semestres.

No necesitas saber estadística. No necesitas que se te den las matemáticas. No
necesitas haber tocado una línea de código en tu vida. Lo único que hace falta
es traer curiosidad por la política mexicana, que es de lo que van todos los
ejemplos.

## ¿Qué vas a poder hacer?

Al final de las once horas vas a poder contestar esta pregunta tú, con datos
oficiales del INE:

> **¿Los municipios donde Morena arrasó en 2024 son los mismos donde ganaron
> las candidaturas morenistas a ministra en la elección judicial de 2025?**

Dos mapas de México, una regresión, y una respuesta que puedes defender frente
a alguien que opine distinto. En la sesión 1 vas a hacer tu primera gráfica de
barras sin entender todavía cómo funciona, y va a salir bien. Esa es la idea.

## Empieza en tres pasos

**1. Instala R y luego RStudio.** Son dos programas distintos y hacen falta los
dos, en ese orden. Toma diez minutos y se hace una sola vez en la vida. El paso
a paso, con capturas y separado para Windows y para Mac, está en
[**Empieza aquí**](https://emirandago.github.io/r-para-politologos/empieza-aqui.html).

**2. Descarga el material.** Botón verde **Code** aquí arriba →
**Download ZIP**. Descomprime la carpeta y abre el archivo
`r-para-politologos.Rproj` haciendo doble clic: eso abre RStudio ya acomodado
en el lugar correcto.

**3. Instala los paquetes del curso.** Copia esta línea, pégala en la consola
de RStudio y aprieta Enter. Tarda unos minutos y también se hace una sola vez:

```r
install.packages(c("tidyverse", "here", "janitor", "sf", "viridis", "modelsummary", "fixest"))
```

Si algo de esto falla, la página [Empieza aquí](https://emirandago.github.io/r-para-politologos/empieza-aqui.html)
tiene los cinco problemas más comunes con su solución.

## Las once sesiones

Cada título lleva a su página en el sitio, donde está el contenido explicado y
los archivos para descargar.

| | Sesión | La pregunta de esa hora | Lo que te llevas |
|---|---|---|---|
| 1 | [Tu primera hora en R](https://emirandago.github.io/r-para-politologos/sesiones/01-primer-contacto/01_guion.html) | ¿Por qué un politólogo programa? | Tu primera gráfica de la elección de 2024 |
| 2 | [Los datos son tablas](https://emirandago.github.io/r-para-politologos/sesiones/02-los-datos-son-tablas/02_guion.html) | ¿Cómo se ve una base de datos por dentro? | Saber qué es, exactamente, una fila |
| 3 | [Pedirle cosas a los datos](https://emirandago.github.io/r-para-politologos/sesiones/03-pedirle-cosas-a-los-datos/03_guion.html) | ¿Dónde ganó Morena por más de veinte puntos? | Una tabla que contesta una pregunta tuya |
| 4 | [Agrupar, resumir, cruzar](https://emirandago.github.io/r-para-politologos/sesiones/04-agrupar-resumir-cruzar/04_guion.html) | ¿Cómo comparo estados entre sí? | Unir dos bases que no quieren unirse |
| 5 | [La gramática de los gráficos](https://emirandago.github.io/r-para-politologos/sesiones/05-gramatica-de-los-graficos/05_guion.html) | ¿Por qué unos gráficos convencen y otros no? | Un gráfico con paleta defendible |
| 6 | [Gráficos que se publican](https://emirandago.github.io/r-para-politologos/sesiones/06-graficos-que-se-publican/06_guion.html) | ¿Cómo hago una figura de paper? | Una figura lista para un trabajo final |
| 7 | [El mapa de México](https://emirandago.github.io/r-para-politologos/sesiones/07-el-mapa-de-mexico/07_guion.html) | ¿Cómo se ve el voto en el territorio? | Un mapa de los 2,475 municipios |
| 8 | [Describir sin mentir](https://emirandago.github.io/r-para-politologos/sesiones/08-describir-sin-mentir/08_guion.html) | ¿Qué significa que dos cosas «van juntas»? | Saber cuándo un promedio engaña |
| 9 | [La regresión](https://emirandago.github.io/r-para-politologos/sesiones/09-la-regresion/09_guion.html) | ¿Cuánto explica X a Y? | Leer un coeficiente en voz alta |
| 10 | [Que otro pueda repetirlo](https://emirandago.github.io/r-para-politologos/sesiones/10-que-otro-pueda-repetirlo/10_guion.html) | ¿Cómo entrego trabajo serio? | Tu propio reporte, publicado en internet |
| 11 | [La IA como copiloto](https://emirandago.github.io/r-para-politologos/sesiones/11-la-ia-como-copiloto/11_guion.html) | ¿Cómo uso la IA sin dejar de aprender? | El proyecto final, y criterio para verificar |

## Qué hay en cada carpeta

Todas las carpetas tienen adentro su propia explicación: entra a cualquiera y
vas a encontrar una nota que dice qué es cada archivo.

| Carpeta | Qué guarda y para qué te sirve |
|---|---|
| [**sesiones/**](sesiones/) | Las once sesiones. Cada una trae siempre los mismos siete archivos: las diapositivas en PDF, el guion de la clase, el script para llenar en vivo, el mismo script ya resuelto, el ejercicio para llevar y su solución |
| [**datos/**](datos/) | Las bases con las que vas a trabajar, todas de fuente oficial. Aquí también está escrito de dónde salió cada una, qué significa cada columna y con qué código se construyeron |
| [**extras/**](extras/) | Seis módulos para estudiar por tu cuenta si te quedaste con ganas: funciones, simulación, modelos logit, datos de panel, inferencia causal y una guía para quien viene de Stata |
| [**recursos/**](recursos/) | El acordeón de una página, el glosario de las palabras en inglés y —el más útil de todos— el catálogo de errores comunes, con lo que significa cada uno y cómo se arregla |
| [**ia/**](ia/) | Cómo usar la inteligencia artificial en trabajo cuantitativo sin dejar de aprender, que es de lo que trata la última sesión |
| [**estilo/**](estilo/) | Los colores y las tipografías del curso. Esto es para quien quiera reusar el material, no para tomar la clase |

## Sobre los archivos de cada sesión

Dos cosas que confunden al principio y conviene saber de entrada.

El archivo que dice `script.R` **tiene huecos y no corre de corrido**. No está
roto: está hecho así a propósito, para llenarse durante la clase. El que dice
`script_completo.R` es ese mismo con todo resuelto, y se publica al terminar la
sesión.

El `ejercicio.R` tiene tres niveles: uno de calentamiento que sale rápido, uno
de verdad donde se aprende, y uno para si te sobra tiempo. Nadie los revisa y
no valen puntos. Su solución también se publica después.

## Si nunca has usado GitHub

No hace falta. En serio: puedes tomar el curso completo sin entender nada de
esta página. Lo único que necesitas es el botón verde **Code → Download ZIP**
de aquí arriba, o mejor todavía, los botones de descarga que están en cada
sesión del [sitio del curso](https://emirandago.github.io/r-para-politologos/),
que bajan un archivo a la vez sin complicaciones.

GitHub es simplemente el lugar donde vive el material para que esté disponible
para cualquiera. En la sesión 10 vas a aprender a usarlo, si te interesa, y va
a tener mucho más sentido entonces.

## Para quien quiera reusar este material

El curso es público y se puede adoptar, adaptar y dar en otra parte. Todo el
material está bajo licencia [CC BY 4.0](LICENSE): se puede copiar, modificar y
usar con cualquier fin, incluso comercial, con la única condición de dar
crédito. Los datos de terceros conservan sus propias condiciones, detalladas en
[`datos/README.md`](datos/README.md).

El sitio se construye con [Quarto](https://quarto.org) y se publica solo con
GitHub Actions. Las láminas son Beamer; el preámbulo, la paleta y el tema de
ggplot2 están en [`estilo/`](estilo/), documentados. La cita sugerida está en
[`CITATION.cff`](CITATION.cff), y GitHub la formatea con el botón «Cite this
repository» de la barra lateral.

## Agradecimientos

Este curso no parte de cero. Reúne y actualiza al R de 2026 el contenido de
tres cursos que se dieron antes en el ITAM: el de **Paula Cortina**, el de
**Aldo Gómez** y el de **Álvaro Pérez**
([Introduccion_a_R](https://github.com/AlvaroPLZ/Introduccion_a_R)). Nada de lo
que enseñaron desaparece: está repartido entre `sesiones/` y `extras/`.

Como referencia general en español, el curso reconoce a *AnalizaR Datos
Políticos*, de **Andrés Cruz** y **Francisco Urdinez**
([arcruz0.github.io/libroadp](https://arcruz0.github.io/libroadp/)), el libro
más completo que existe de R aplicado a ciencia política en nuestro idioma.

<div align="center">

---

**[Laboratorio de R para Ciencia Política](https://emirandago.github.io/r-para-politologos/)**
Emiliano Miranda González · ITAM · Departamento Académico de Ciencia Política

</div>
