# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 3 · Ejercicio para practicar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el
# tercero si te sobra tiempo o te dio curiosidad.
#
# Ninguno necesita una función que no hayamos visto en 03_script.R.
#
# La solución comentada está en 03_solucion.R. Intenta primero.
# ==============================================================

library(tidyverse)
library(here)
library(marginaleffects)
library(modelsummary)

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv")) |>
  drop_na(ventaja_shh) |>
  mutate(lista_nominal_miles = lista_nominal / 1000)


# ---- Nivel 1 · Calentamiento ----

# En el script modelaste arraso_shh: si SHH ganó por MÁS de 20 puntos.
# Construye ahora la variable contraria: perdio_shh, que valga 1 si
# SHH quedó por DEBAJO del segundo lugar (ventaja_shh < 0) y 0 en
# cualquier otro caso. Ajusta un glm(family = binomial()) de
# perdio_shh en función de lista_nominal_miles.
#
# Antes de correrlo, anticipa: en el script, lista_nominal_miles tenía
# un coeficiente NEGATIVO para explicar un triunfo arrasador (a más
# población, menos probable un triunfo arrasador). ¿Qué signo esperas
# para el coeficiente de lista_nominal_miles explicando una DERROTA de
# SHH? ¿Positivo, negativo, o no tienes manera de anticiparlo?

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# (a) Ajusta un modelo logit de arraso_shh en función de pct_mc (el
#     porcentaje de votos que sacó Movimiento Ciudadano en el
#     municipio), en vez de lista_nominal_miles.
#
# (b) Calcula avg_slopes() del modelo y las probabilidades predichas
#     con predict(..., type = "response") para pct_mc = 2, 10 y 30
#     (usa tibble(pct_mc = c(2, 10, 30)) como newdata).
#
# (c) Compara el tamaño de este efecto marginal contra el de
#     lista_nominal_miles del script (-0.00026 por cada mil personas).
#     Contesta en un comentario de dos o tres líneas: ¿cuál de las dos
#     variables mueve más la probabilidad de un triunfo arrasador,
#     dentro de su propio rango de valores observado? ¿Tiene sentido
#     politológico que la variable con más peso sea la que resultó
#     con más peso?

# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Investiga, con documentación (?plot_slopes) o con una IA —y
#     VERIFICA lo que te conteste corriendo un ejemplo—, qué hace
#     marginaleffects::plot_slopes() y en qué se diferencia de
#     plot_predictions(), que ya usaste en el script.
#
# (b) modelsummary() tiene un argumento exponentiate = TRUE que
#     convierte los coeficientes de un modelo logit a razones de
#     momios (odds ratios) en vez de log-odds. Pruébalo sobre el
#     modelo del inciso (a) de este ejercicio y mira qué número te da.
#     No te pedimos que lo interpretes con soltura —este módulo evitó
#     esa escala a propósito—, solo que lo veas una vez y notes qué
#     tan poco intuitivo es comparado con la probabilidad.
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el
#     error que más veces te salió hoy y qué significaba.

# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, sin código:
#
# Este módulo interpretó todo en probabilidades y evitó la razón de
# momios. Ahora que la viste una vez en el inciso (b) del Nivel 3,
# ¿se te ocurre alguna situación —pensando en cómo se comunica un
# hallazgo a periodistas, a tomadores de decisiones, o a un jurado de
# tesis— donde SÍ convendría reportar la razón de momios en vez de la
# probabilidad? Y otra donde definitivamente no convendría.
# ==============================================================
