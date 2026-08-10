# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 11 · La IA como copiloto, no como piloto
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Recargar el mapa de la sesión 7 y la regresión de la sesión 9 sin
#   rehacerlos desde cero, correr un bloque de verificación sobre tres
#   afirmaciones reales que una inteligencia artificial hizo sobre este
#   mismo proyecto, contar antes y después de cada filtro y cada cruce,
#   y cerrar el proyecto final con tres párrafos y un registro de qué se
#   le pidió a la IA y qué se decidió aquí.
#
# Qué necesitas antes de empezar:
#   Haber corrido la sesión 07 (el mapa) y la sesión 09 (la regresión).
#   Hoy no se explican de nuevo left_join(), geom_sf() ni feols(): se
#   usan.
#
# Datos: INE, cómputos distritales de la elección presidencial de 2024 y
#        de la elección judicial de 2025, agregados por municipio, más
#        INEGI, Marco Geoestadístico 2025. Ver datos/README.md para la
#        fuente exacta y sus advertencias.
# Autor: Emiliano Miranda González
# ==============================================================

# ─────────────────────────────────────────────────────────────
# ESTE ARCHIVO TIENE HUECOS Y NO CORRE DE CORRIDO. Es a propósito.
# Los huecos están marcados con  ← COMPLETA  y se llenan en clase.
# Si intentas correrlo entero antes de llenarlos, va a marcar error.
# La versión resuelta (11_script_completo.R) se publica al terminar la sesión.
# ─────────────────────────────────────────────────────────────


# ---- 0. Los paquetes ----

# Ningún paquete nuevo hoy: los cinco ya los conoces de sesiones
# anteriores. Los volvemos a cargar porque cada sesión de R arranca en
# blanco — nada de lo que corriste ayer sigue en memoria hoy, ni
# siquiera en la misma computadora.

library(tidyverse)     # dplyr, ggplot2, readr
library(here)           # rutas relativas
library(sf)             # el mapa de la sesión 7
library(fixest)         # feols(), la regresión de la sesión 9
library(modelsummary)   # tablas de regresión

# El tema del curso, con theme_lab_mapa() incluido, igual que en la
# sesión 7.
source(here("estilo", "tema_lab.R"))


# ---- 1. Recargar el proyecto, sin rehacerlo desde cero ----

# El proyecto final no se construye hoy. Se construyó a lo largo de las
# sesiones 2 a 9 y hoy lo cerramos. Lo que sigue NO es una explicación
# nueva de left_join(), de geom_sf() ni de feols(): son las mismas
# líneas que ya corriste en la sesión 7 y en la sesión 9, comprimidas,
# para tener los objetos otra vez a la mano.

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

# El mapa de la sesión 7.

mapa_geo <- read_rds(here("datos", "geo", "municipios_simplificado.rds"))
entidades_geo <- read_rds(here("datos", "geo", "entidades_simplificado.rds"))

# ← COMPLETA: une mapa_geo con las columnas de resultados que necesitas
#   (clave_municipio, participacion, votos_shh, pct_shh, ventaja_shh) con
#   left_join(), por clave_municipio. Es la misma línea de la sesión 7.

mapa_municipios <-


mapa_ventaja <- ggplot() +
  geom_sf(data = mapa_municipios, aes(fill = ventaja_shh), color = NA) +
  scale_fill_gradient2(low = "#7B1113", mid = "white", high = "#006847", midpoint = 0) +
  geom_sf(data = entidades_geo, fill = NA, color = "white", linewidth = 0.25) +
  theme_lab_mapa() +
  labs(
    title    = "¿Dónde le ganó SHH al segundo lugar, y por cuánto?",
    subtitle = "Ventaja de Sigamos Haciendo Historia sobre el segundo lugar, por municipio, 2024",
    fill     = "Ventaja (pp)",
    caption  = "Fuente: INE, cómputos distritales 2024. INEGI, Marco Geoestadístico 2025."
  )

mapa_ventaja

# La regresión de la sesión 9: ventaja_shh en función de participacion,
# con error estándar robusto.

# ← COMPLETA: ajusta con feols() la regresión de ventaja_shh en función
#   de participacion, con los datos de municipios, con vcov = "hetero", y
#   guárdala en modelo_1_robusto. Es la misma línea de la sesión 9.

modelo_1_robusto <-


modelsummary(
  list("Ventaja ~ participación" = modelo_1_robusto),
  stars = TRUE,
  gof_omit = "AIC|BIC|Log|Std"
)

# Con estos dos objetos otra vez en memoria —mapa_ventaja y
# modelo_1_robusto— ya podemos entrar al bloque que de verdad importa
# hoy.


# ---- 2. El bloque de verificación: el corazón de la sesión ----

# Tres afirmaciones que una inteligencia artificial hizo sobre este
# mismo proyecto. Ninguna se verifica leyendo: las tres se verifican
# corriendo algo.


# -- Comprobación 1: ¿la función existe? --

# La IA escribió: "Para graficar el voto por entidad puedes usar
# geom_barplot(), que es la funcion de ggplot2 para graficos de barras."

exists("geom_barplot")

# FALSE. Con eso ya alcanza para no creerle: la función no existe en
# ningún paquete que tengamos cargado. exists() es más rápido que abrir
# ?geom_barplot porque no intenta abrir nada, solo contesta sí o no.
#
# Si de todos modos quieres ver el error tal cual aparecería en la
# consola, atrápalo con tryCatch() para que no tumbe el resto del
# script:

tryCatch(
  ggplot(resultados, aes(entidad, pct_shh)) + geom_barplot(),
  error = function(e) message("Error real: ", conditionMessage(e))
)

# La consola, sin atrapar el error, diría literal:
#   Error in geom_barplot(): could not find function "geom_barplot"
# La función nunca existió. Las que sí existen, para lo mismo, son
# geom_bar() y geom_col().


# -- Comprobación 2: ¿el paquete es el correcto? --

# find() dice de qué paquete viene de verdad una función, sin abrir
# documentación.

find("geom_bar")
# "package:ggplot2" — geom_bar() sí viene de donde la IA dijo.

find("geom_barplot")
# character(0), vacío. Ningún paquete cargado la tiene, porque no existe.

find("filter")
# "package:dplyr" "package:stats" — dos paquetes tienen una función
# filter(). Gana dplyr porque tidyverse lo carga después de stats, y
# cuando escribes filter() sin paquete, R usa la primera de la lista.
# Si algún día cargas otro paquete que también tenga filter() y se
# cargue todavía más tarde, ese gana en su lugar, en silencio.
#
# La manera de no dejarlo a la suerte es escribir el paquete a mano:

dplyr::filter(resultados, pct_shh > 60) |> nrow()

# Ese :: no es cosmético. Si dplyr no fuera el paquete que crees, esta
# línea marcaría un error de inmediato en vez de correr con la función
# de otro paquete sin que te enteres.


# -- Comprobación 3: ¿el número dice lo que dice? --

# La IA escribió: "Para quedarte con los municipios donde la
# participacion fue alta, filtra asi: filter(pct_shh > 60 | 50)"

nrow(resultados)
nrow(resultados |> filter(pct_shh > 60 | 50))
nrow(resultados |> filter(pct_shh > 60))

# El filtro de la IA no truena. Corre, no marca ni una advertencia, y
# devuelve las 32 entidades — las mismas que había antes de filtrar. El
# 50 suelto se evalúa como verdadero y el | hace que la condición se
# cumpla siempre, sin importar pct_shh. El filtro correcto, sin el 50
# suelto, devuelve 19.
#
# Esta es la comprobación más peligrosa de las tres porque es la única
# que no truena y la única que un vistazo rápido a la consola no
# delata: hay que comparar el número contra algo que ya sabías, no solo
# confirmar que "corrió bien".
#
# La misma comprobación 3 aplica a algo todavía más traicionero: no
# solo si el número es correcto, sino si la frase que lo acompaña dice
# lo que ese número permite decir.
#
# La IA escribió sobre modelo_1_robusto: "El coeficiente de
# participación es -0.287, es decir, que la participación REDUCE la
# ventaja de la coalición. Cada punto más de participación le cuesta
# casi tres décimas de punto."

coef(modelo_1_robusto)["participacion"]

# La aritmética está bien: el coeficiente es -0.287, dígito por dígito.
# El verbo no. "Reduce" afirma una causa que este diseño no identifica:
# son 2,473 municipios distintos entre sí en un mismo corte del tiempo,
# no el mismo municipio observado antes y después de algo. Lo correcto
# es "va acompañada de". La diferencia entre las dos frases no se ve en
# la salida de R —el número es idéntico en las dos—, así que esta parte
# de la comprobación 3 no se hace corriendo código: se hace leyendo la
# frase con cuidado.


# ---- 3. Contar antes y después de cada filtro y cada cruce ----

# Contar es la defensa más barata que existe contra el código que corre
# y miente. La aprendiste en la sesión 4 y hoy tiene nombre: es,
# literalmente, la comprobación 3 convertida en hábito para cualquier
# filter() o join() que escribas, no solo para los de arriba.

# Antes de creerle a un filtro, cuenta antes y después:
nrow(resultados)
nrow(resultados |> filter(pct_shh > 60))

# Antes de creerle a un cruce, cuenta las dos tablas por separado y
# cuenta lo que sale.

judicial <- read_csv(here("datos", "limpios", "judicial_2025_scjn_municipio.csv"))

# judicial viene en formato largo: una fila por municipio POR
# candidatura (158,528 filas para ~2,477 municipios × 64 candidaturas;
# ver datos/README.md, sección 5). Antes de cruzarlo con nada, lo
# resumimos a una fila por municipio con las columnas que ya vienen
# repetidas idénticas en cada candidatura del mismo municipio.

judicial_resumen <- judicial |>
  select(clave_municipio, lista_nominal_2025, personas_votaron_2025, participacion_judicial) |>
  distinct()

nrow(judicial)             # 158,528: municipio × candidatura
nrow(judicial_resumen)     # una fila por municipio

# ← COMPLETA: une municipios con judicial_resumen con left_join(), por
#   clave_municipio, y guárdalo en municipios_con_judicial.

municipios_con_judicial <-


nrow(municipios)                 # antes del cruce
nrow(municipios_con_judicial)    # después del cruce: tiene que ser el mismo número
sum(is.na(municipios_con_judicial$participacion_judicial))  # cuántos no encontraron pareja

# Si nrow() cambió, el cruce hizo algo que no pediste: casi siempre es
# que la clave tenía duplicados de un lado y left_join() multiplicó
# filas en vez de solo unirlas. Si sum(is.na(...)) no da cero, hay
# municipios de un lado que no encontraron pareja del otro — y antes de
# seguir, hay que decidir si eso es un error o un hecho real de los
# datos, como el voto en el extranjero de la sesión 1 o los municipios
# de Oaxaca donde no se instaló ninguna casilla.


# ---- 4. Cámbiale algo ----

# Repite la comprobación 1, pero con una función que sí existe:
# geom_boxplot(), en vez de geom_barplot(). Antes de correrlo, anticipa:
# ¿qué esperas que conteste exists()?




# ---- 5. Cerrar el proyecto ----

# Con el mapa (mapa_ventaja) y la regresión (modelo_1_robusto, o la que
# ya tengas con tu propia codificación de votos_bloque_a) ya hechos, lo
# único que falta es lo que ninguna máquina puede hacer por ti: decir
# qué significa. Tres párrafos, en prosa, dentro de comentarios. No hay
# relleno de ejemplo porque no hay una respuesta que valga para todo el
# mundo: la respuesta es la que puedas defender en voz alta.

# QUÉ ENCONTRAMOS:
#
#
#
# QUÉ NO PODEMOS AFIRMAR:
#
#
#
# QUÉ HARÍAMOS CON MÁS TIEMPO:
#
#
#


# ---- 6. Registro de uso de IA ----

# Esto no es un anexo: es parte del entregable. Llena una fila por cada
# intercambio real que hayas tenido con un asistente de IA mientras
# trabajabas en este proyecto.
#
# | Qué le pedimos                           | Qué decidimos nosotros |
# |-------------------------------------------|--------------------------|
# |                                             |                          |
# |                                             |                          |
# |                                             |                          |
#
# Si no usaste IA en ninguna parte de este proyecto, escríbelo también:
# "No se usó IA en este trabajo" es una respuesta legítima y se
# registra igual de explícita que cualquier otra.


# ==============================================================
# Antes de cerrar el archivo, saca la pregunta que escribiste al final
# del ejercicio de la sesión 1 — la que prometiste guardar.
#
# Léela otra vez. ¿Con lo que sabes hacer hoy alcanza para contestarla?
# Si la respuesta es "todavía no", ¿qué específicamente te falta: un
# dato que no tienes, una herramienta que no aprendiste, o una decisión
# de juicio que todavía no sabes cómo tomar?
# ==============================================================
