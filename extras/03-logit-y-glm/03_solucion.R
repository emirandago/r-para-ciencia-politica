# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 3 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Si llegaste aquí sin haber peleado con el ejercicio, regrésate: la
# solución solo enseña algo a quien ya se atoró.
#
# ─────────────────────────────────────────────────────────────
# NOTA DE VERIFICACIÓN PARA EMG — borrar antes de publicar en el sitio.
# Los coeficientes de esta solución se calcularon de forma
# independiente en Python (IRLS/Newton-Raphson) sobre
# presidencial_2024_municipio.csv, igual que en 03_script.R.
# Verifícalos al correr esta solución en R antes de repartirla.
# ─────────────────────────────────────────────────────────────
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)
library(marginaleffects)
library(modelsummary)

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv")) |>
  drop_na(ventaja_shh) |>
  mutate(lista_nominal_miles = lista_nominal / 1000)


# ---- Nivel 1 · Calentamiento ----

municipios <- municipios |>
  mutate(perdio_shh = as.numeric(ventaja_shh < 0))

table(municipios$perdio_shh)   # 128 municipios donde SHH perdió, de 2,473

modelo_perdio <- glm(
  perdio_shh ~ lista_nominal_miles,
  data   = municipios,
  family = binomial()
)

summary(modelo_perdio)

# El coeficiente de lista_nominal_miles sale POSITIVO (alrededor de
# 0.0013, con un error estándar de 0.00049: varias veces más chico que
# el coeficiente). La anticipación razonable era justamente esta:
# lista_nominal_miles tenía coeficiente NEGATIVO para explicar un
# triunfo arrasador, y aquí, para explicar una derrota, el signo se
# invierte. Los municipios grandes —más urbanos, más competidos,
# donde ninguna fuerza política suele "arrasar" con nadie— son también
# los que tienen más probabilidad de que SHH pierda de plano. Es la
# misma variable, contando una historia consistente desde sus dos
# extremos: tamaño del municipio y qué tan competida está su
# elección van de la mano.


# ---- Nivel 2 · De verdad ----

# (a)

modelo_mc <- glm(
  arraso_shh ~ pct_mc,
  data = municipios |> mutate(arraso_shh = as.numeric(ventaja_shh > 20)),
  family = binomial()
)

summary(modelo_mc)

# (b)

avg_slopes(modelo_mc, variables = "pct_mc")

predict(
  modelo_mc,
  newdata = tibble(pct_mc = c(2, 10, 30)),
  type    = "response"
)

# El efecto marginal promedio de pct_mc da, aproximadamente, -0.0126:
# por cada punto porcentual más de votos para Movimiento Ciudadano en
# el municipio, la probabilidad de un triunfo arrasador de SHH cae 1.26
# puntos porcentuales, en promedio. Las probabilidades predichas
# muestran el mismo patrón de forma más vívida: con pct_mc = 2%, la
# probabilidad de arrasar es 90.6%; con pct_mc = 10%, baja a 82.2%; con
# pct_mc = 30% —un municipio donde Movimiento Ciudadano tuvo una
# presencia fuerte de verdad—, cae hasta 42.3%.

# (c) La comparación.
#
# El efecto de pct_mc (-1.26 puntos porcentuales de probabilidad por
# cada punto porcentual de voto a MC) es casi CINCUENTA VECES más
# grande que el de lista_nominal_miles (-0.026 puntos porcentuales por
# cada mil personas). Tiene sentido politológico completo: pct_mc mide
# directamente competencia electoral EN LA MISMA ELECCIÓN que estás
# explicando —si un tercer partido se lleva votos, aritméticamente le
# quita margen a quien iba arriba—, mientras que lista_nominal_miles
# es una característica estructural del municipio (su tamaño) que solo
# se relaciona INDIRECTAMENTE con qué tan competida resultó la
# elección. No es sorpresa que la variable más directamente conectada
# con la pregunta tenga, con mucho, el efecto más grande.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) plot_slopes() grafica el EFECTO MARGINAL mismo —cómo cambia la
#     pendiente de la curva de probabilidad— a lo largo de un rango de
#     valores de x, generalmente contra otra variable (por ejemplo,
#     "¿el efecto marginal de pct_mc es el mismo cuando
#     lista_nominal_miles es chica que cuando es grande?"). Es la
#     herramienta que usarías para preguntas de INTERACCIÓN entre dos
#     variables —tema que este laboratorio deja fuera del camino
#     crítico, ver mejores_practicas_r_cpol.md—. plot_predictions(), en
#     cambio, grafica la PROBABILIDAD PREDICHA misma, no su cambio, y
#     es la que usaste en el script. Resumen: plot_predictions()
#     contesta "¿qué probabilidad predice el modelo aquí?";
#     plot_slopes() contesta "¿qué tan rápido cambia esa probabilidad
#     aquí?".
#
# (b)
#
# [VERIFICAR] modelsummary() documenta exponentiate como un valor
# lógico único o un VECTOR de lógicos, uno por modelo de la lista; si
# al correr esto tu versión instalada no acepta el vector y aplica el
# mismo valor a los dos modelos, corre las dos tablas por separado en
# su lugar:
#   modelsummary(modelo_mc, stars = TRUE)
#   modelsummary(modelo_mc, exponentiate = TRUE, stars = TRUE)

modelsummary(
  list("Logit, log-odds" = modelo_mc, "Logit, razón de momios" = modelo_mc),
  exponentiate = c(FALSE, TRUE),
  stars = TRUE,
  gof_omit = "AIC|BIC|Log|Std"
)

# El coeficiente exponenciado de pct_mc da un número cercano a 0.91:
# "por cada punto porcentual más de pct_mc, el momio de arrasar se
# multiplica por 0.91". Es una frase técnicamente correcta y, para
# casi cualquier persona fuera de un seminario de métodos, ilegible.
# Compárala con "la probabilidad cae 1.26 puntos porcentuales": la
# segunda se entiende sin explicación adicional. Esa es, en una
# frase, la razón de la decisión de diseño de todo este módulo.
#
# (c) El error más frecuente de este módulo suele ser construir la
#     variable dependiente ANTES de hacer drop_na(ventaja_shh), lo que
#     deja NA en la variable de 0/1 y hace tronar glm() con el mensaje
#     "y values must be 0 <= y <= 1". El orden de las operaciones en
#     este script no es casualidad: primero se limpia, después se
#     construye, después se modela.


# ==============================================================
# Sobre la pregunta de cierre del ejercicio:
#
# La razón de momios tiene una propiedad que la probabilidad no tiene:
# se MULTIPLICA de forma consistente sin importar el punto de partida
# —"el momio se multiplica por 0.91" significa lo mismo si partes de
# un momio alto o bajo—, mientras que un cambio de "1.26 puntos
# porcentuales" depende de en qué parte de la curva estés. Eso la hace
# atractiva para comparar coeficientes ENTRE modelos distintos, en
# literatura académica especializada donde el público ya domina la
# escala. Para comunicar un hallazgo a alguien que va a tomar una
# decisión con él —una autoridad electoral, un editor de periódico,
# un jurado de tesis que no es economista— la probabilidad casi
# siempre gana: se entiende sin que nadie tenga que explicar primero
# qué es un logaritmo de una razón.
# ==============================================================
