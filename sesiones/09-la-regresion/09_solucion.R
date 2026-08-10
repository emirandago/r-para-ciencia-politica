# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 09 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Se publica después de la sesión. Si llegaste aquí sin haber peleado
# con el ejercicio, regrésate: la solución solo enseña algo a quien ya
# se atoró. Leer código correcto sin haberlo intentado se siente como
# aprender y no lo es.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)
library(fixest)
library(modelsummary)

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

modelo_pct <- feols(pct_shh ~ participacion, data = municipios, vcov = "hetero")

summary(modelo_pct)

# El coeficiente de participacion sale -0.156: negativo, igual que en el
# modelo de clase (-0.287 sobre ventaja_shh). Tenía que salir con el mismo
# signo, y aquí está el porqué: ventaja_shh se CONSTRUYE a partir de
# pct_shh (es pct_shh menos el segundo lugar), así que si la participación
# le pega negativo a pct_shh, casi seguro le va a pegar negativo también a
# la ventaja. No son dos hallazgos independientes: son el mismo patrón
# visto desde dos variables emparentadas. El R² también es parecido:
# 0.015 contra 0.016. Ninguno de los dos modelos explica gran cosa.


# ---- Nivel 2 · De verdad ----

# (a) La regresión de Fuerza y Corazón por México.

modelo_fcm <- feols(pct_fcm ~ participacion, data = municipios, vcov = "hetero")

summary(modelo_fcm)

# (b) La tabla lado a lado. Aquí modelo_1_robusto es el de la sesión
# (ventaja_shh ~ participacion); si no lo tienes cargado, corre primero
# 09_script_completo.R o vuelve a ajustarlo con la línea de la sesión.

modelo_1_robusto <- feols(ventaja_shh ~ participacion, data = municipios, vcov = "hetero")

modelsummary(
  list("Ventaja SHH" = modelo_1_robusto, "Voto FCM" = modelo_fcm),
  stars = TRUE,
  gof_omit = "AIC|BIC|Log|Std"
)

# (c) La interpretación, que es la parte que importa.
#
# El signo SÍ cambia entre los dos modelos, y es el hallazgo central de
# este ejercicio: el coeficiente de participacion sobre la ventaja de SHH
# es negativo (-0.287), y el coeficiente de participacion sobre el voto
# de FCM es POSITIVO (+0.107).
#
# En oraciones completas, con unidades:
#   "Por cada punto porcentual más de participación, la ventaja de SHH
#    cae, en promedio, 0.29 puntos porcentuales."
#   "Por cada punto porcentual más de participación, el porcentaje de
#    votos de FCM sube, en promedio, 0.11 puntos porcentuales."
#
# Los dos R² son minúsculos: 0.016 para SHH y apenas 0.010 para FCM. Eso
# NO vuelve inútil la comparación; vuelve inútil pretender que la
# participación es una explicación importante de por qué un municipio
# vota como vota. Lo que sí sostiene, con la humildad debida, es una
# hipótesis chica y defendible: en los municipios con más participación,
# el bloque que gobierna pierde un poco de terreno y el principal rival
# gana un poco. Es consistente con una historia de "más participación,
# elección más competida" —pero con un R² de una cifra decimal, es una
# hipótesis para investigar más, no una conclusión para escribir en un
# trabajo final. Y, como toda la sesión insistió: ninguno de los dos
# coeficientes dice qué CAUSA qué. Podría ser que la propia competitividad
# de un municipio explique tanto la participación como el reparto del
# voto, sin que una le haga nada a la otra.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Errores clásicos contra robustos, con números reales.

modelo_1_clasico <- lm(ventaja_shh ~ participacion, data = municipios)

summary(modelo_1_clasico)       # error estándar clásico: 0.045
summary(modelo_1_robusto)       # error estándar robusto:  0.044

# Una IA típicamente va a explicarte que el error estándar robusto
# "corrige" el clásico cuando la dispersión de los residuos no es igual
# en todo el rango de x (heterocedasticidad), y que por eso SUELE ser más
# grande que el clásico —porque casi siempre está corrigiendo hacia
# arriba—. Eso es cierto en general, pero "suele" no es "siempre", y aquí
# tienes la prueba: en este modelo el robusto (0.044) es prácticamente
# igual, incluso un poco MÁS CHICO, que el clásico (0.045). Si le
# preguntas a una IA y te contesta "el error robusto siempre es mayor al
# clásico", esa respuesta es una sobregeneralización: verifícalo con tus
# propios números antes de repetirlo, que es exactamente la doctrina que
# vas a formalizar en la sesión 11.

# (b) vcov = "hetero" contra vcov agrupado por entidad.
#
# ?feols (sección "vcov") explica que vcov = "hetero" corrige el error
# estándar por heterocedasticidad TRATANDO CADA MUNICIPIO COMO
# INDEPENDIENTE de los demás. vcov = ~clave_entidad, en cambio, agrupa
# ("clusteriza") el error estándar por entidad: asume que los municipios
# de un mismo estado pueden parecerse entre sí por razones que el modelo
# no está capturando —el mismo gobierno estatal, la misma coyuntura
# local—, y ya no los trata como observaciones completamente
# independientes. La consecuencia práctica casi siempre es un error
# estándar más grande (y por lo tanto menos asteriscos): agrupar reconoce
# que 2,473 municipios repartidos en 32 estados no son, en realidad,
# 2,473 piezas de información totalmente independientes entre sí. Este
# tema —qué tan agrupados están tus datos y qué le hace eso a tu
# confianza en un coeficiente— se retoma con más calma en extras/panel y
# efectos fijos.


# ==============================================================
# Sobre la pregunta de cierre, la de la sesión 1:
#
# La mayoría de las preguntas politológicas que de verdad importan se
# parecen más a "X causa Y" que a "X explica Y". Eso no es un problema
# del curso: es el problema central de la disciplina. Lo que sí puedes
# llevarte de hoy es el hábito de notar la diferencia entre las dos, y de
# no pasar de una a la otra sin decir, con todas sus letras, qué te haría
# falta para poder hacerlo.
# ==============================================================
