# Estilo

La identidad visual del laboratorio: una paleta verde institucional que se
repite en las láminas de Beamer, en los gráficos de `ggplot2` y en el sitio
Quarto, para que los tres combinen entre sí.

## Los archivos

| Archivo | Qué es |
|---|---|
| [`paleta-itam.tex`](paleta-itam.tex) | **La única fuente normativa de los colores del curso.** Define los cinco hexes (`verdeITAM #006847`, `verdeProfundo`, `verdeClaro`, `grisTexto`, `guinda`) y sus diluciones. |
| [`preambulo-lab.tex`](preambulo-lab.tex) | El preámbulo de Beamer que se importa en cada `NN_slides.tex` con `\input{../../estilo/preambulo-lab.tex}`. Carga `paleta-itam.tex`, fija la tipografía (sans para cuerpo, serifa TeX Gyre Pagella para lo que "nombra": portada y títulos de lámina), el estilo de bloques de código con `listings`, el encabezado con el logo del ITAM, el pie con folio, y los entornos propios del curso (`\porquenosimporta`, `\yasabemos`, `\lasiguiente`, `errorbox`, `saltobox`). |
| [`tema_lab.R`](tema_lab.R) | `theme_lab()` y las escalas de color de `ggplot2` (`scale_fill_lab_c()`, `scale_fill_lab_d()`, etc.), con los mismos hexes de `paleta-itam.tex` copiados a mano. También trae `theme_lab_mapa()`, la variante sin ejes para la sesión 7. |
| [`estilo.scss`](estilo.scss) | El tema del sitio Quarto (`format: html: theme:` en `_quarto.yml`). Mismos hexes otra vez, más las clases propias del sitio: `.gancho`, `.tarjeta-sesion`, `.descargas`, `.si-algo-falla`, `.ya-sabes`. |
| [`logo_itam.png`](logo_itam.png) | El logo del ITAM que usan tanto el encabezado del deck como la barra de navegación del sitio. |

## La regla de propagación de color

**Si cambia un color, hay que cambiarlo en los tres archivos: `paleta-itam.tex`, `tema_lab.R` y `estilo.scss`.** No hay una sola fuente que los tres lean en tiempo de compilación —LaTeX, R y Sass no comparten un archivo de variables— así que la sincronía es manual. Si se actualiza uno solo, el deck, los gráficos y el sitio dejan de combinar, y se nota: es exactamente el tipo de discrepancia silenciosa contra la que advierte este mismo README (ver más abajo).

`recursos/acordeon-r.tex` también carga `paleta-itam.tex` directamente (`\input{../estilo/paleta-itam.tex}`), así que cualquier cambio de color se propaga también a la hoja de referencia en PDF.

**Nota para quien edite esta carpeta:** existe además un archivo
[`verde-sacramento.tex`](verde-sacramento.tex) con una paleta distinta
(`verdeSacramento #04773B` en vez de `verdeITAM #006847`, y sin el color
`guinda`) que también se autodescribe como "el único lugar normativo".
Verificado con `grep` sobre todo el repositorio: **ningún** `.tex` lo
importa —ni `preambulo-lab.tex` ni `acordeon-r.tex` cargan
`verde-sacramento.tex`—, así que no está en uso. Antes de tocar cualquier
color, confirma con EMG si ese archivo es un remanente de una versión
anterior de la paleta que debe borrarse, o si hay un plan pendiente de
usarlo; mientras tanto, `paleta-itam.tex` es el que gobierna de verdad
láminas, gráficos y sitio.

## Cómo se compila un deck

Cada `NN_slides.tex` se compila desde la carpeta de su propia sesión (las
rutas `\input{../../estilo/...}` y `\includegraphics{../../estilo/...}`
están escritas relativas a ahí):

```
cd sesiones/01-primer-contacto
pdflatex 01_slides.tex
pdflatex 01_slides.tex
```

**Dos veces, siempre.** La primera pasada resuelve el contenido; los nodos
de TikZ con `remember picture` (los que usan `\porquenosimporta` y
`\lasiguiente` para posicionar texto sobre la banda de color) solo se
colocan bien hasta la segunda pasada, cuando LaTeX ya conoce las
coordenadas que calculó la primera vez.
