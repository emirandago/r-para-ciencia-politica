# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 10 · Que otro pueda repetirlo
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Envolver un cálculo que ya escribiste dos veces en una función propia,
#   preparar una carpeta que se pueda convertir en su propio repositorio,
#   y traducir ese código a un documento Quarto que vas a publicar en
#   GitHub Pages antes de que se acabe la hora.
#
# Qué necesitas antes de empezar:
#   Haber corrido la sesión 1 (.Rproj, here()) y sentirte cómodo con
#   read_csv(), el pipe |> y ggplot(). Y una cuenta ya creada en
#   github.com.
#
# Datos: INE, cómputos distritales 2024, agregados por entidad — la misma
#        base que abriste en la sesión 1. Ver datos/README.md.
# Autor: Emiliano Miranda González
# ==============================================================

# ESTA ES LA VERSIÓN RESUELTA. Se publica después de la sesión.
# Si estás en clase, usa 10_script.R.
#
# Recuerda: este archivo es el andamiaje, no el entregable. El entregable
# de hoy es el documento Quarto que armas con la sección 5, y la página
# publicada que resulta de la sección 7.


# ---- 0. Los paquetes ----

# ESTA LÍNEA NO SE CORRE DESDE EL SCRIPT. Está comentada a propósito.
# Cópiala a la consola, córrela una vez en tu vida, y olvídate:
#
#   install.packages(c("tidyverse", "here"))
#
# Quarto no se instala aparte: viene incluido en RStudio desde hace varias
# versiones.

library(tidyverse)
library(here)


# ---- 1. Dónde está parado R, otra vez ----

here()

# Debe terminar en /r-para-politologos.


# ---- 2. Los datos que ya conoces ----

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

glimpse(resultados)


# ---- 3. Una función propia, en tres líneas ----

# En la sesión 1 calculaste esto:
#
#   sum(resultados$votos_shh) / sum(resultados$total_votos) * 100
#
# En la sesión 4 volviste a escribir prácticamente la misma cuenta, con
# otra variable. Esa fórmula, repetida, se convierte en función:

pct_ponderado <- function(parte, total) {
  sum(parte) / sum(total) * 100
}

# La misma cifra de la sesión 1, ahora con una función:
pct_ponderado(resultados$votos_shh, resultados$total_votos)

# Y la MISMA función, sin volver a escribir la fórmula, con otra coalición:
pct_ponderado(resultados$votos_fcm, resultados$total_votos)

# Eso es lo que gana una función: la fórmula se escribe una sola vez y se
# llama cuantas veces haga falta. Si algún día encuentras un error en la
# cuenta, lo arreglas en un solo lugar, no en cada copia que hiciste de ella.
#
# Esto es apenas la entrada al tema. Argumentos con valor por default,
# return() explícito cuando el cuerpo tiene más de un camino posible, y
# qué significa el alcance (scope) de una variable dentro de una función:
# todo eso vive, con el mismo cuidado que el resto del curso, en
# extras/01-funciones-e-iteracion.


# ---- 4. Prepara la carpeta de tu reporte ----

ruta_reporte <- here("..", "mi-primer-reporte")
dir.create(ruta_reporte, showWarnings = FALSE)

file.copy(
  here("datos", "limpios", "presidencial_2024_entidad.csv"),
  file.path(ruta_reporte, "presidencial_2024_entidad.csv"),
  overwrite = TRUE
)

list.files(ruta_reporte)

# Ahora ve al panel de Files de RStudio, entra a esa carpeta, y ahí es
# donde vas a crear tu documento Quarto.


# ---- 5. El documento Quarto: esto NO es código de R ----

# File > New File > Quarto Document..., formato HTML, y guárdalo como
# "index.qmd" DENTRO de mi-primer-reporte. El nombre importa: GitHub Pages
# busca automáticamente un archivo llamado index.html para mostrarlo como
# la página principal, y al renderizar index.qmd obtienes index.html sin
# renombrar nada.
#
# Copia el bloque de abajo dentro de ese archivo nuevo, quitando el "# "
# del principio de cada línea.

# ---
# title: "Participacion en la eleccion de 2024"
# author: "Tu nombre"
# format:
#   html:
#     embed-resources: true
# ---
#
# ## Cuanta gente salio a votar en 2024
#
# Este reporte responde una pregunta que ya viste en la sesion 1: la
# participacion nacional no es el promedio simple de 32 porcentajes
# estatales, es un promedio ponderado por el tamano de cada entidad.
#
# ```{r}
# #| message: false
# library(tidyverse)
# library(here)
#
# resultados <- read_csv("presidencial_2024_entidad.csv")
#
# pct_ponderado <- function(parte, total) {
#   sum(parte) / sum(total) * 100
# }
# ```
#
# La participacion nacional ponderada de 2024 fue de
# `r round(pct_ponderado(resultados$total_votos, resultados$lista_nominal), 1)`
# por ciento.
#
# (Esa línea con una comilla invertida, la letra "r", un espacio y una
# expresión de R, cerrada con otra comilla invertida, es "código en línea":
# el número no lo escribiste tú, lo calculó Quarto al renderizar. Aquí, en
# este script de R, no se ejecuta nada: es texto de referencia para copiar.)
#
# Nota: a diferencia de un script .R, un documento Quarto corre parado en
# la carpeta donde vive el propio archivo .qmd. Como el .csv está en la
# misma carpeta que index.qmd, ni siquiera hace falta here() aquí.


# ---- 6. Renderiza ----

# Botón "Render", arriba del editor, con index.qmd abierto. Al terminar
# queda un archivo nuevo, index.html, en la misma carpeta.


# ---- 7. Sube tu carpeta a GitHub, con el navegador ----

#   1. github.com, con sesión iniciada: crea un repositorio nuevo, público,
#      vacío, llamado por ejemplo mi-primer-reporte.
#   2. Arrastra a la ventana del repositorio los tres archivos: index.html,
#      index.qmd y presidencial_2024_entidad.csv. Confirma la subida.
#   3. Settings > Pages: publica desde la rama principal, carpeta raíz.
#   4. Espera un minuto, refresca, copia la URL que aparece:
#      https://tu-usuario.github.io/mi-primer-reporte/


# ==============================================================
# Antes de mandar el link, ábrelo tú primero en una pestaña nueva y
# revísalo como si no supieras qué esperar.
#
# ¿El número de participación que aparece en el texto es el mismo que
# calculaste en la consola? ¿Qué pasaría con ese número, sin que tú
# tuvieras que tocar una sola letra, si mañana cambiaran los datos de
# origen?
# ==============================================================
