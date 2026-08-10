# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 09 · La regresión como instrumento politológico
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Nombrar la recta que la sesión pasada solo dibujamos: ajustar tu
#   primera regresión con lm() y con feols(), leer una tabla con
#   modelsummary() sin haberla derivado, y escribir en una oración
#   completa qué dice un coeficiente y qué no dice.
#
# Qué necesitas antes de empezar:
#   Haber corrido la sesión 08. Usamos el mismo diagrama de dispersión y
#   la misma correlación entre participación y ventaja de la coalición,
#   ahora con nombre y con número.
#
# Datos: INE, cómputos distritales de la elección presidencial de 2024,
#        agregados por municipio. Ver datos/README.md.
# Autor: Emiliano Miranda González
# ==============================================================

# ─────────────────────────────────────────────────────────────
# ESTE ARCHIVO TIENE HUECOS Y NO CORRE DE CORRIDO. Es a propósito.
# Los huecos están marcados con  ← COMPLETA  y se llenan en clase.
# Si intentas correrlo entero antes de llenarlos, va a marcar error.
# La versión resuelta (09_script_completo.R) se publica al terminar la sesión.
# ─────────────────────────────────────────────────────────────


# ---- 0. Los paquetes ----

# Dos paquetes nuevos hoy: fixest, para feols(), y modelsummary, para
# tablas de regresión que no se copian y pegan de la consola.
#
# Se instalan una sola vez, en la consola, nunca desde aquí:
#
#   install.packages(c("fixest", "modelsummary"))

library(tidyverse)     # dplyr, ggplot2, readr, de siempre
library(here)           # rutas relativas, de siempre
library(fixest)         # feols(): el estándar profesional para regresiones
library(modelsummary)   # tablas de regresión, no salidas de consola pegadas


# ---- 1. La nube de la sesión pasada, otra vez ----

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

# La sesión pasada viste esta nube: cada punto es un municipio, el eje x
# es la participación y el eje y es la ventaja de la coalición Sigamos
# Haciendo Historia sobre quien quedó en segundo lugar. Le pusiste encima
# una línea con geom_smooth(method = "lm") y calculaste que las dos
# variables correlacionan negativo y débil: -0.13.
#
# Hoy esa línea deja de ser un adorno del gráfico. Le vamos a poner
# nombre y le vamos a sacar sus dos números.


# ---- 2. La primera regresión: lm() ----

# lm() viene instalado con R —no hay que cargar ningún paquete nuevo— y
# es la función que vas a ver en Estadística I. "lm" es la sigla en
# inglés de linear model, modelo lineal.
#
# Fíjate en la fórmula: ventaja_shh ~ participacion se lee "ventaja_shh
# en función de participacion". A la izquierda del ~ va lo que quieres
# explicar; a la derecha, con qué lo explicas.

# ← COMPLETA: ajusta con lm() la regresión de ventaja_shh en función de
#   participacion, con los datos de municipios, y guárdala en modelo_1.

modelo_1 <-


summary(modelo_1)

# EL SALTO: ese resumen que acaba de imprimirse no es una salida de
# consola más. Tiene dos números que valen la pena aislar: el Intercept
# (dónde arranca la recta) y el coeficiente de participacion (cuánto sube
# o baja por cada unidad de x). En el momento en que los lees con sus
# unidades y los conviertes en una oración, dejan de ser números de R y
# se vuelven una afirmación sobre México que alguien más puede discutir:
#
#   "Por cada punto porcentual más de participación, la ventaja de la
#    coalición cae, en promedio, 0.29 puntos porcentuales."
#
# Sin las unidades ("puntos porcentuales" en los dos lados), esa frase no
# significa nada. Un coeficiente nunca se lee solo: se lee con unidades.


# ---- 3. La misma pregunta, con feols() ----

# feols() viene del paquete fixest y ajusta la misma recta que lm(), con
# una diferencia que aquí sí importa: calcula, de fábrica, un error
# estándar que no asume que la dispersión de los datos es igual en todo
# el rango de x. Eso se llama heterocedasticidad —lo vas a formalizar en
# Estadística— y aquí basta con saber que vcov = "hetero" es la manera de
# pedirlo.

# ← COMPLETA: ajusta la misma regresión con feols(), pidiendo el error
#   estándar robusto con vcov = "hetero", y guárdala en modelo_1_robusto.

modelo_1_robusto <-


summary(modelo_1_robusto)

# Compara los dos resúmenes. El coeficiente de participacion es
# EXACTAMENTE el mismo en los dos: -0.287. lm() y feols() ajustan la
# misma recta. Lo que cambia es el error estándar —el número entre
# paréntesis—: eso afecta qué tan segura es la estimación, no la
# estimación misma. Aquí el clásico (0.045) y el robusto (0.044) casi no
# difieren, y eso también es información: dice que la heterocedasticidad,
# en este modelo, no era severa.
#
# Si esto marca "could not find function 'feols'", casi siempre falta
# correr library(fixest) del bloque 0, aunque ya hayas cargado tidyverse.


# ---- 4. Por qué dos funciones para lo mismo ----

# lm() es la que vas a ver en Estadística I, la que aparece en todos los
# libros de texto, y la que cualquiera que revise tu código reconoce de
# inmediato. feols() es el estándar profesional en ciencia política
# cuantitativa: además del error estándar robusto de fábrica, es más
# rápida y —lo vas a ver en la sesión 11, con el proyecto final— sabe
# absorber efectos fijos sin que tengas que crear una columna dummy por
# cada categoría.
#
# La regla de este curso, para que no haya duda: lm() se enseña porque es
# lo que vas a encontrar en tu formación estadística y porque su salida
# es legible. Lo que se REPORTA como resultado final, en este curso y en
# la práctica profesional, es feols() con un error estándar robusto.
# Guárdate ese criterio.


# ---- 5. Una tabla que se lee, no se deriva ----

# Nunca copies y pegues la salida de summary() como si fuera una tabla:
# no tiene el formato de un trabajo final y es fácil que se te vaya un
# número al transcribirlo a mano. modelsummary() arma la tabla por ti.
#
# Nota: desde la versión 2.0 de modelsummary, el motor que arma la tabla
# por defecto es {tinytable}, no {kableExtra}. Si tu tabla se ve distinta
# a la de aquí, revisa la versión del paquete antes de sospechar de tu
# código.

modelsummary(
  list("Modelo 1" = modelo_1_robusto),
  stars = TRUE,
  gof_omit = "AIC|BIC|Log|Std"
)

# Leer esta tabla es un oficio distinto de derivarla. Cada FILA es una
# variable; el número de arriba es el coeficiente, el número entre
# paréntesis abajo es el error estándar; los asteriscos avisan qué tan
# lejos está el coeficiente de cero, no qué tan importante es.
#
# EL SALTO otra vez, pero ahora con una advertencia: un coeficiente
# pequeño con muchos asteriscos no necesariamente importa, y uno grande
# sin asteriscos no necesariamente no importa. Mira el R² de este modelo:
# apenas 0.016. La participación es estadísticamente significativa —hay
# 2,473 municipios, y con esa cantidad de datos hasta una relación débil
# deja de parecer casualidad— pero explica un pedazo minúsculo de por qué
# la ventaja de la coalición cambia de un municipio a otro. Significativo
# y sustantivo son dos preguntas distintas, y una tabla nunca contesta la
# segunda por ti.


# ---- 6. Un segundo modelo, y la tentación que resistimos ----

# La especificación del proyecto final usa una sola variable explicativa,
# a propósito. Aquí, solo para verlo pasar una vez, añadimos una segunda:
# el porcentaje de votos de Movimiento Ciudadano en el municipio.

# ← COMPLETA: ajusta con feols() la regresión de ventaja_shh en función
#   de participacion Y pct_mc (con +), robusta, y guárdala en modelo_2.

modelo_2 <-


modelsummary(
  list("Modelo 1" = modelo_1_robusto, "Modelo 2" = modelo_2),
  stars = TRUE,
  gof_omit = "AIC|BIC|Log|Std"
)

# Fíjate en el coeficiente de participacion: en el Modelo 1 era -0.29 y
# en el Modelo 2 es -0.18. Se movió. ¿Qué significa que se haya movido?
# No lo vamos a contestar hoy, y esa es la lección, no un pendiente: sin
# un diseño que aísle qué está causando qué, agregar una variable más no
# te acerca a la causalidad. Solo cambia el número, y cambia porque
# participacion y pct_mc no son independientes entre sí en el
# territorio: los municipios donde Movimiento Ciudadano sacó más votos no
# son un sorteo aleatorio de municipios.
#
# La tentación, en cualquier trabajo final, es seguir agregando variables
# hasta que aparezca el coeficiente que uno quería encontrar. Resístela.
# Un modelo con más variables no es automáticamente un modelo más
# honesto.
#
# Esta misma variable, ventaja_shh, va a reaparecer en la sesión 11, pero
# del otro lado de la ecuación: ahí vas a explicar el voto morenista en
# la elección judicial CON ventaja_shh, no al revés:
#
#   feols(pct_bloque_a ~ ventaja_shh, data = municipios, vcov = "hetero")
#
# Guárdate el nombre.


# ---- 7. Correlación no es causa ----

# Un caso real, de la ciencia política de Estados Unidos: legisladores
# con más hijas tienden a votar más a favor de temas relacionados con
# mujeres que legisladores con más hijos. ¿Tener hijas CAUSA ese voto?
#
# Antes de contestar que sí, piensa en las otras historias que producen
# la misma correlación sin que haya una causa directa: las familias
# grandes en general podrían tener otras características —ingreso,
# religión, región— que también predicen ese voto, y entonces el número
# de hijas no sería la causa, sino solo un compañero de viaje de la causa
# real.
#
# Ese es el ejercicio mental que hay que hacer CADA VEZ que un
# coeficiente sale distinto de cero: ¿qué otra historia, además de "X
# causa Y", explica el mismo número?


# ---- 8. Cámbiale algo ----

# Cambia la variable explicativa del modelo 1: en vez de participacion,
# usa lista_nominal (el tamaño de la lista de votantes del municipio).
# Antes de correrlo, anticipa: ¿esperas un coeficiente parecido, más
# grande o más chico? ¿Y en qué unidades quedaría, si lista_nominal se
# mide en personas y no en puntos porcentuales?
#
# Escribe tu código aquí abajo:




# ==============================================================
# Miraste el mismo coeficiente —el de participacion— cambiar de tamaño
# según qué otra variable tenía al lado, sin que la pregunta politológica
# cambiara.
#
# Si tu trabajo final reportara un solo modelo, ¿qué tendrías que poder
# explicar primero para que ese modelo sea el correcto para reportar, y
# no solo el que te dio el número que andabas buscando?
# ==============================================================
