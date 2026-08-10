# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 6 · Guía de Stata a R
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Recorrer, con código que corre de verdad sobre datos electorales
#   mexicanos, las equivalencias más comunes entre Stata y R: cómo se
#   traduce gen/replace, collapse, merge, reg con errores robustos, y
#   los tres "gotchas" donde el mismo comando sin argumentos NO
#   significa lo mismo en los dos programas.
#
# Qué necesitas antes de empezar:
#   Nada estrictamente: esta página funciona como referencia. Se
#   aprovecha más si ya viste las sesiones 2 a 4 y la sesión 9.
#
# Este es un módulo AUTOESTUDIABLE. Este script corre completo, de
# arriba abajo, SIN huecos.
#
# Datos: INE, cómputos distritales de la elección presidencial de
#        2024, por municipio. Ver datos/README.md.
# Autor: Emiliano Miranda González
# ==============================================================


# ---- 0. Los paquetes ----

# Un paquete nuevo: haven, para leer archivos .dta de Stata —lo vas a
# necesitar si algún día te entregan datos en ese formato—.
#
#   install.packages(c("haven"))

library(tidyverse)
library(here)
library(fixest)
library(modelsummary)
library(haven)


# ---- 1. La filosofía: sin base "activa", con objetos con nombre ----

# En Stata, "use archivo.dta, clear" carga la base y la deja como LA
# base activa. En R no existe ese concepto: cada tabla es un objeto
# con su propio nombre.

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

# Podrías tener, al mismo tiempo, otra tabla cargada sin que nada le
# pase a municipios:

entidades <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

# Las dos coexisten. En Stata, cargar la segunda con "use ..., clear"
# habría borrado la primera de la memoria.


# ---- 2. gen / replace, contra mutate() con reasignación ----

# gen ventaja = pct_shh - pct_fcm            (Stata: modifica la base activa sola)
#
# El equivalente en R NO modifica municipios solo. Fíjate en las dos
# versiones:

municipios |> mutate(ventaja = pct_shh - pct_fcm)   # esto se IMPRIME y se DESCARTA

"ventaja" %in% names(municipios)   # FALSE: la línea de arriba no guardó nada

# La versión correcta reasigna con <-:

municipios <- municipios |> mutate(ventaja = pct_shh - pct_fcm)

"ventaja" %in% names(municipios)   # TRUE, ahora sí

# replace var = x if cond            (Stata)
# mutate(var = if_else(cond, x, var))   (R, con la misma reasignación de siempre)

municipios <- municipios |>
  mutate(ventaja = if_else(ventaja < 0, 0, ventaja))   # ejemplo: recortar los negativos a 0


# ---- 3. collapse, contra group_by() + summarise() ----

# collapse (mean) participacion, by(entidad)     (Stata)

resumen_por_entidad <- municipios |>
  group_by(entidad) |>
  summarise(participacion_promedio = mean(participacion))

resumen_por_entidad


# ---- 4. merge 1:1, contra left_join() ----

# merge 1:1 clave_entidad using entidades.dta     (Stata)

resumen_con_geo <- resumen_por_entidad |>
  left_join(entidades |> select(entidad, lista_nominal), by = "entidad")

resumen_con_geo

# A diferencia de merge en Stata, que reporta cuántas filas
# encontraron pareja en un resumen de texto (_merge == 1, 2, 3),
# left_join() no imprime ningún resumen por default: para saber si
# algo no encontró pareja, usa anti_join(), que ya conoces de la
# sesión 4.


# ---- 5. tab, contra table() y janitor::tabyl() ----

# tab entidad     (Stata: conteo simple)

table(municipios$entidad) |> head(5)

# janitor::tabyl() da, de fábrica, porcentajes además del conteo:

# library(janitor)
# municipios |> janitor::tabyl(entidad) |> head(5)


# ---- 6. reg con errores robustos, contra feols() ----

# reg ventaja participacion, robust     (Stata)

modelo <- feols(ventaja ~ participacion, data = municipios, vcov = "hetero")

modelsummary(modelo, stars = TRUE, gof_omit = "AIC|BIC|Log|Std")

# reg ventaja participacion, cluster(clave_entidad)     (Stata)

modelo_clusterizado <- feols(ventaja ~ participacion, data = municipios, vcov = ~clave_entidad)

modelsummary(modelo_clusterizado, stars = TRUE, gof_omit = "AIC|BIC|Log|Std")


# ---- 7. El gotcha de t.test() y las varianzas ----

# ttest participacion, by(es_grande)     (Stata, asume varianzas iguales por default)

municipios <- municipios |>
  mutate(es_grande = if_else(lista_nominal > median(lista_nominal), "grande", "chico"))

# t.test() en R asume, por default, LO CONTRARIO: varianzas distintas
# (prueba de Welch). Compara los dos resultados:

t.test(participacion ~ es_grande, data = municipios)                     # default de R: Welch
t.test(participacion ~ es_grande, data = municipios, var.equal = TRUE)   # replica el default de Stata

# Los dos números de "t" y los grados de libertad no tienen por qué
# coincidir. Ninguno de los dos está "mal": son dos supuestos
# distintos sobre las varianzas, y cada programa eligió un default
# diferente. Si tu objetivo es reproducir EXACTAMENTE un resultado que
# ya corriste en Stata, necesitas var.equal = TRUE.


# ---- 8. El gotcha de la categoría base de un factor ----

# Stata usa, por default, el valor MÁS BAJO como categoría de
# referencia. R usa, por default, el PRIMER NIVEL EN ORDEN
# ALFABÉTICO, que casi nunca coincide si tus categorías son texto.

es_grande_factor <- factor(municipios$es_grande)
levels(es_grande_factor)   # "chico" antes que "grande": alfabético, no por tamaño

# Si quieres fijar tú la categoría de referencia (por ejemplo, que
# "chico" sea la base explícitamente, sin depender del alfabeto):

es_grande_factor_fijo <- factor(municipios$es_grande, levels = c("chico", "grande"))
levels(es_grande_factor_fijo)


# ---- 9. Cámbiale algo ----

# Corre summary(lm(ventaja ~ participacion, data = municipios)) —a
# propósito con lm(), no con feols()— y busca, hasta el final de la
# salida, una línea que empiece con un paréntesis y diga algo de
# "observations deleted". Esa es la manera en que R SÍ te avisa, a
# diferencia del silencio de Stata, cuántas filas se excluyeron por
# tener algún valor faltante.

summary(lm(ventaja ~ participacion, data = municipios))


# ==============================================================
# La pregunta abierta del cierre.
#
# De las tres diferencias de "mismo comando, distinto default" que
# viste hoy (t.test/varianzas, categoría base de un factor, aviso de
# valores perdidos), ¿cuál te parece más peligrosa para alguien que
# traduce mecánicamente, sin saber que la diferencia existe? ¿Por qué
# esa y no las otras dos?
# ==============================================================
