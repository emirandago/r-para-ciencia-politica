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
#   github.com — si no la tienes, créala antes de seguir: son cinco
#   minutos y la necesitas en la segunda mitad de la hora.
#
# Datos: INE, cómputos distritales 2024, agregados por entidad — la misma
#        base que abriste en la sesión 1. Ver datos/README.md.
# Autor: Emiliano Miranda González
# ==============================================================

# ─────────────────────────────────────────────────────────────
# ESTE ARCHIVO TIENE HUECOS Y NO CORRE DE CORRIDO. Es a propósito.
# Los huecos están marcados con  ← COMPLETA  y se llenan en clase.
#
# IMPORTANTE, y distinto a las nueve sesiones anteriores: este script NO
# es el entregable de hoy. Es el andamiaje. Aquí preparas y pruebas cada
# pedazo de código en el entorno que ya conoces —consola, script,
# Ctrl+Enter— antes de copiarlo dentro de un documento Quarto nuevo.
# Separamos los dos pasos a propósito: aprender la sintaxis de un archivo
# nuevo (YAML, bloques, texto) y depurar código de R al mismo tiempo es
# demasiada carga junta para una hora. Primero se resuelve el código, en
# el lugar donde ya sabes leer un error; después se traslada, ya probado,
# al formato nuevo. El guion completo de cómo armar el .qmd está en
# 10_guion.qmd, y el desarrollo completo de "escribir funciones propias"
# —argumentos por default, return(), alcance— vive en
# extras/01-funciones-e-iteracion.
#
# La versión resuelta (10_script_completo.R) se publica al terminar la sesión.
# ─────────────────────────────────────────────────────────────


# ---- 0. Los paquetes ----

# ESTA LÍNEA NO SE CORRE DESDE EL SCRIPT. Está comentada a propósito.
# Cópiala a la consola, córrela una vez en tu vida, y olvídate:
#
#   install.packages(c("tidyverse", "here"))
#
# Quarto no se instala aparte: viene incluido en RStudio desde hace varias
# versiones. Si el botón "Render" no aparece cuando abras un archivo .qmd
# más adelante, actualiza RStudio (Help > Check for Updates).

library(tidyverse)
library(here)


# ---- 1. Dónde está parado R, otra vez ----

# Este es el mismo here() de la sesión 1. Ha corrido en nueve sesiones sin
# que lo pensaras demasiado. Hoy por fin decimos completo por qué importaba:
# es lo que hace posible que, dentro de un rato, muevas tu trabajo a otra
# computadora —la de GitHub— y todo siga funcionando igual.

here()

# Debe terminar en /r-para-politologos. Si no, cierra todo y vuelve a abrir
# el .Rproj: nada de lo que sigue funciona si R no está parado ahí.


# ---- 2. Los datos que ya conoces ----

# Nada nuevo hoy en datos: los mismos resultados de la elección de 2024,
# por entidad, que abriste el primer día.

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

glimpse(resultados)


# ---- 3. Una función propia, en tres líneas ----

# En la sesión 1 calculaste esto:
#
#   sum(resultados$votos_shh) / sum(resultados$total_votos) * 100
#
# En la sesión 4 volviste a escribir prácticamente la misma cuenta, con
# otra variable. Cada vez que copias una fórmula y solo le cambias el
# nombre de una columna, esa fórmula está pidiendo ser una función.
#
# Una función tiene tres partes: un nombre, lo que recibe entre paréntesis
# —sus argumentos—, y lo que hace con eso adentro de las llaves.

# ← COMPLETA: escribe la función pct_ponderado(), que reciba dos
#   argumentos —parte y total— y regrese sum(parte) / sum(total) * 100.
#   R regresa sola la última línea que evalúa: no hace falta return()
#   para un cuerpo de una sola operación como este.

pct_ponderado <- function(parte, total) {

}

# Pruébala reproduciendo el número de la sesión 1:
pct_ponderado(resultados$votos_shh, resultados$total_votos)

# Y ahora la MISMA función, sin volver a escribir la fórmula, con otra
# coalición:
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

# Vamos a crear, con código —no arrastrando carpetas a mano en el
# explorador de archivos—, un lugar nuevo fuera de este proyecto: ahí va a
# vivir tu reporte, solo, listo para convertirse en su propio repositorio.
# here("..", ...) sube un nivel: al lado de la carpeta del curso, no adentro.

ruta_reporte <- here("..", "mi-primer-reporte")
dir.create(ruta_reporte, showWarnings = FALSE)

file.copy(
  here("datos", "limpios", "presidencial_2024_entidad.csv"),
  file.path(ruta_reporte, "presidencial_2024_entidad.csv"),
  overwrite = TRUE
)

# Confirma que quedaron ahí los dos archivos que vas a necesitar:
list.files(ruta_reporte)

# Ahora ve al panel de Files de RStudio, entra a esa carpeta —o ábrela
# como un proyecto nuevo con File > Open Project—, y ahí es donde vas a
# crear tu documento Quarto.


# ---- 5. El documento Quarto: esto NO es código de R ----

# A partir de aquí sales de este script. Ve a File > New File > Quarto
# Document..., dale un título, elige HTML como formato, y GUÁRDALO como
# "index.qmd" DENTRO de la carpeta mi-primer-reporte que acabas de crear.
# El nombre index.qmd no es cosmético: GitHub Pages busca automáticamente
# un archivo llamado index.html para mostrarlo como la página principal, y
# al renderizar index.qmd obtienes index.html sin renombrar nada.
#
# El bloque de abajo es exactamente lo que vas a copiar dentro de ese
# archivo nuevo, en el orden en que aparece. Está comentado con # porque
# esto es un script de R, no un .qmd: cópialo tal cual, quitando el "# "
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
# el número no lo escribiste tú, lo calculó Quarto al renderizar. Cópiala
# tal cual, sin el "# " del principio, dentro de tu párrafo. Aquí, en este
# script de R, no se ejecuta nada: es solo texto de referencia para copiar.)
#
# Nota sobre este chunk: a diferencia de un script .R, un documento
# Quarto corre parado en la carpeta donde vive el propio archivo .qmd. Como
# el .csv está en la misma carpeta que index.qmd, ni siquiera hace falta
# here() aquí. here() sigue siendo la regla del proyecto grande del curso;
# para un reporte de una sola carpeta, con el archivo junto al .qmd alcanza.


# ---- 6. Renderiza ----

# De vuelta en RStudio, con index.qmd abierto, aprieta el botón "Render"
# (arriba del editor). La primera vez tarda unos segundos: instala algunas
# piezas de Quarto si hacen falta. Al terminar, se abre una vista previa y
# queda un archivo nuevo, index.html, en la misma carpeta.
#
# Si el render marca un error de YAML, revisa la indentación: YAML nunca
# usa la tecla Tab, solo espacios, y la misma cantidad en cada nivel.


# ---- 7. Sube tu carpeta a GitHub, con el navegador ----

# Esto tampoco es código de R. Los pasos completos, con qué hacer si algo
# no aparece donde lo esperas, están en 10_guion.qmd. En resumen:
#
#   1. github.com, con sesión iniciada: crea un repositorio nuevo, público,
#      vacío. Llámalo, por ejemplo, mi-primer-reporte.
#   2. Arrastra a la ventana del repositorio los tres archivos de tu
#      carpeta: index.html, index.qmd y presidencial_2024_entidad.csv.
#      Confirma la subida.
#   3. Settings > Pages: publica desde la rama principal, carpeta raíz.
#   4. Espera un minuto, refresca, copia la URL que aparece.
#
# Esa URL es tu entregable de hoy.


# ==============================================================
# Antes de mandar el link, ábrelo tú primero en una pestaña nueva y
# revísalo como si no supieras qué esperar.
#
# ¿El número de participación que aparece en el texto es el mismo que
# calculaste en la consola? ¿Qué pasaría con ese número, sin que tú
# tuvieras que tocar una sola letra, si mañana cambiaran los datos de
# origen?
# ==============================================================
