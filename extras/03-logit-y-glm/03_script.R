# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 3 · Modelos logit y GLM
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Ajustar un modelo logit con glm(family = binomial()) sobre una
#   pregunta real de sí/no, convertir su salida a probabilidades con
#   predict(type = "response"), y usar marginaleffects::avg_slopes()
#   para poner un número honesto a "cuánto cambia la probabilidad".
#
# Qué necesitas antes de empezar:
#   La sesión 9 completa (lm(), feols(), modelsummary()). Este extra
#   es la clase de GLM que Álvaro Pérez anunció en su temario y nunca
#   llegó a publicar.
#
# Este es un módulo AUTOESTUDIABLE. Este script corre completo, de
# arriba abajo, SIN huecos.
#
# ─────────────────────────────────────────────────────────────
# NOTA DE VERIFICACIÓN PARA EMG — borrar antes de publicar en el sitio.
# Los coeficientes, errores estándar y probabilidades predichas que
# aparecen en los comentarios de este script (y en 03_extra.qmd) se
# calcularon de forma independiente en Python (numpy, IRLS/Newton-
# Raphson para la regresión logística, el mismo algoritmo que usa
# glm() por dentro) sobre datos/limpios/presidencial_2024_municipio.csv.
# No se corrieron con glm()/marginaleffects en R porque la sesión de
# RStudio del proyecto estaba ocupada durante la producción de este
# material. Correr este script en R debe reproducir los mismos
# números salvo diferencias de redondeo en el último dígito:
# verifícalo antes de repartirlo.
# ─────────────────────────────────────────────────────────────
#
# Datos: INE, cómputos distritales de la elección presidencial de
#        2024, por municipio. Ver datos/README.md.
# Autor: Emiliano Miranda González
# ==============================================================


# ---- 0. Los paquetes ----

# Dos paquetes nuevos hoy: marginaleffects, para los efectos
# marginales, y modelsummary, que ya conoces de la sesión 9. glm()
# viene instalado con R —no hay que cargar ningún paquete nuevo—.
#
#   install.packages(c("marginaleffects", "modelsummary"))

library(tidyverse)
library(here)
library(marginaleffects)
library(modelsummary)

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- 1. Construir la pregunta de sí/no ----

# ventaja_shh ya la conoces de las sesiones 6, 7 y 9: cuánto le sacó
# SHH al segundo lugar, en puntos porcentuales. Hoy la convertimos en
# una pregunta binaria: ¿el municipio tuvo un triunfo ARRASADOR —más
# de 20 puntos de ventaja— o no?
#
# drop_na() quita los dos municipios de Oaxaca sin casilla instalada,
# donde ventaja_shh es NA (ver datos/README.md): glm() no sabe qué
# hacer con un NA en la variable que quiere explicar, y filtrarlos
# aquí, explícitamente, es mejor que dejar que R los descarte en
# silencio.

municipios <- municipios |>
  drop_na(ventaja_shh) |>
  mutate(
    arraso_shh          = as.numeric(ventaja_shh > 20),
    lista_nominal_miles = lista_nominal / 1000   # miles de personas, para un coeficiente legible
  )

table(municipios$arraso_shh)   # cuántos "no" (0) y cuántos "sí" (1)
mean(municipios$arraso_shh)    # el 82% de los municipios tuvo un triunfo arrasador


# ---- 2. Por qué lm() no es la herramienta correcta aquí ----

# Nada te impide correr esto —a eso se le llama modelo lineal de
# probabilidad—, pero mira lo que predice en los extremos:

modelo_lineal <- lm(arraso_shh ~ lista_nominal_miles, data = municipios)

predict(modelo_lineal, newdata = tibble(lista_nominal_miles = max(municipios$lista_nominal_miles)))
# Da 0.237: todavía dentro de 0 a 1, pero cerca del límite, para el
# municipio más grande del país (más de 1.6 millones de personas).

predict(modelo_lineal, newdata = tibble(lista_nominal_miles = 3000))
# Da un número NEGATIVO para un municipio hipotético de 3 millones de
# personas —más grande que cualquiera de los 2,473 reales—. Una
# probabilidad negativa no significa nada: es la señal de que una
# recta no es la forma correcta para esta pregunta.


# ---- 3. glm(family = binomial()): la sintaxis ----

modelo_logit <- glm(
  arraso_shh ~ lista_nominal_miles,
  data   = municipios,
  family = binomial()
)

summary(modelo_logit)

# El coeficiente de lista_nominal_miles sale negativo y pequeño
# (alrededor de -0.0018), en la escala de log-odds: el logaritmo
# natural de la razón entre "probabilidad de sí" y "probabilidad de
# no". Nadie piensa naturalmente en logaritmos de razones de
# probabilidad. No lo vamos a interpretar en esta escala.


# ---- 4. De log-odds a probabilidades: predict(type = "response") ----

nuevos_municipios <- tibble(lista_nominal_miles = c(1, 10, 100, 300))

predict(modelo_logit, newdata = nuevos_municipios, type = "response")

# type = "response" es el argumento que hace la conversión: sin él,
# predict() devuelve log-odds. Un municipio de mil personas en la
# lista nominal tiene una probabilidad predicha de triunfo arrasador
# de 83.3%; uno de cien mil, 80.6%; uno de trescientas mil, 74.3%. La
# probabilidad baja conforme el municipio crece, siempre entre 0 y 1.

# Si esto marca "Error: could not find function 'predict'", no debería
# pasar nunca: predict() viene con R base. Revisa que no hayas
# desinstalado o enmascarado accidentalmente esa función.


# ---- 5. avg_slopes(): un número para "cuánto cambia" ----

avg_slopes(modelo_logit, variables = "lista_nominal_miles")

# El efecto marginal promedio da, aproximadamente, -0.00026: por cada
# MIL personas más en la lista nominal, la probabilidad de un triunfo
# arrasador cae, en promedio, 0.026 puntos porcentuales —casi 2.65
# puntos porcentuales por cada CIEN MIL personas más—. A diferencia de
# un coeficiente de regresión lineal, este número es un PROMEDIO sobre
# todas las observaciones reales, no una constante: en logit, cuánto
# cambia la probabilidad depende de en qué parte de la curva estás
# parado.

# Un vistazo visual a la misma idea: la curva de probabilidad predicha
# a lo largo de todo el rango de lista_nominal_miles, con una banda
# alrededor que resume qué tan segura es la estimación en cada punto
# —vas a formalizar exactamente qué significa esa banda en
# Estadística; aquí basta con leerla como "más ancha donde el modelo
# está menos seguro"—.

plot_predictions(modelo_logit, condition = "lista_nominal_miles")


# ---- 6. Una segunda variable ----

modelo_logit_2 <- glm(
  arraso_shh ~ lista_nominal_miles + participacion,
  data   = municipios,
  family = binomial()
)

modelsummary(
  list("Modelo 1" = modelo_logit, "Modelo 2" = modelo_logit_2),
  stars = TRUE,
  gof_omit = "AIC|BIC|Log|Std"
)

# Agregar participacion no cambia el signo del coeficiente de
# lista_nominal_miles, y su magnitud casi no se mueve. participacion
# también sale negativa: municipios con más participación tienen, en
# promedio, menor probabilidad de un triunfo arrasador. Los dos
# efectos marginales:

avg_slopes(modelo_logit_2, variables = c("lista_nominal_miles", "participacion"))

# El de participacion da, aproximadamente, -0.0016 por punto
# porcentual de participación: casi -1.6 puntos porcentuales de
# probabilidad por cada diez puntos más de participación.


# ---- 7. La misma humildad de siempre ----

# Ninguno de los dos coeficientes es enorme, y el pseudo-R² de
# McFadden del modelo —el equivalente aproximado, para un logit, del
# R² de una regresión lineal— ronda apenas 0.01. Un coeficiente puede
# ser varias veces más grande que su error estándar y aun así explicar
# una fracción diminuta de por qué un municipio arrasa y otro no. Es
# la misma lección de la sesión 9, otra vez: significativo y
# sustantivo son dos preguntas distintas.


# ---- 8. Cámbiale algo ----

# Cambia el umbral de "triunfo arrasador" de 20 a 30 puntos de
# ventaja, arma de nuevo la variable arraso_shh, y vuelve a correr el
# modelo 1. Antes de correrlo, anticipa: ¿esperas que el coeficiente
# de lista_nominal_miles se haga más grande, más chico, o cambie de
# signo, al exigir un margen todavía más extremo para contar como
# "arrasador"?

municipios <- municipios |>
  mutate(arraso_shh_30 = as.numeric(ventaja_shh > 30))

modelo_logit_30 <- glm(
  arraso_shh_30 ~ lista_nominal_miles,
  data   = municipios,
  family = binomial()
)

avg_slopes(modelo_logit_30, variables = "lista_nominal_miles")


# ==============================================================
# La pregunta abierta del cierre.
#
# En la sesión 9 viste que agregar pct_mc a un modelo de ventaja_shh
# movía el coeficiente de participacion. Aquí, agregar participacion a
# un modelo de arraso_shh apenas movió el coeficiente de
# lista_nominal_miles. ¿Qué te dice esa diferencia sobre si
# lista_nominal_miles y participacion están relacionadas entre sí en
# el territorio mexicano, comparado con participacion y pct_mc? No lo
# contestes con una prueba formal —no la tienes todavía—: contéstalo
# mirando los números y escribiendo una oración.
# ==============================================================
