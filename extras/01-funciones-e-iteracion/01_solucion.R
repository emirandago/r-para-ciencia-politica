# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 1 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Se publica junto con el ejercicio, porque este módulo es
# autoestudiable: no hay una sesión después de la cual "liberar" la
# solución. Aun así, si llegaste aquí sin haber peleado con el
# ejercicio, regrésate: la solución solo enseña algo a quien ya se
# atoró.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)

resultados_entidad   <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

columnas_pct <- c("pct_shh", "pct_fcm", "pct_mc")

promedios_municipio <- resultados_municipio |>
  select(all_of(columnas_pct)) |>
  map_dbl(mean, na.rm = TRUE)

promedios_municipio

# Compáralos contra los de entidad, del script (60.66 / 26.41 / 10.45
# aproximadamente). Con municipios salen distintos: 66.41 / 21.44 /
# 8.96. La anticipación correcta era "sí van a cambiar, y no por una
# razón estadística sutil sino por la unidad de análisis": con
# entidad, Colima pesa lo mismo que el Estado de México (32 números,
# uno por entidad, sin ponderar por población). Con municipio, el
# promedio simple de 2,473 números sigue sin ponderar por población,
# pero ahora la mayoría de esos 2,473 números son municipios chicos y
# rurales, donde SHH típicamente sacó un porcentaje más alto que en
# las zonas urbanas grandes. Cambiar la unidad de análisis, aunque
# sigas sin ponderar, cambia la pregunta que en realidad estás
# contestando. Nótese que aquí SÍ hizo falta na.rm = TRUE dentro de
# map_dbl(mean, ...): dos municipios de Oaxaca tienen NA en estas
# columnas (ver datos/README.md), y mean() sin na.rm devuelve NA para
# toda la columna si encuentra un solo NA.


# ---- Nivel 2 · De verdad ----

# (a) La función, con el caso NA resuelto ANTES de comparar con el
#     umbral. La palabra clave es "salir de inmediato" (return()
#     explícito) apenas se detecta el NA, para que el resto de la
#     función ni siquiera se evalúe.

clasificar_margen_seguro <- function(ventaja, umbral = 20) {
  if (is.na(ventaja)) {
    return("sin datos")
  }
  if (ventaja > umbral) {
    "arrasadora"
  } else if (ventaja > 0) {
    "cerrada"
  } else {
    "perdida"
  }
}

# (b) map_chr() porque el resultado es texto, no un número: la versión
#     de _dbl marcaría error si se lo pidieras aquí.

resultados_municipio <- resultados_municipio |>
  mutate(categoria_margen = map_chr(ventaja_shh, clasificar_margen_seguro))

# (c) El conteo, y la interpretación en prosa.

resultados_municipio |> count(categoria_margen, sort = TRUE)

# 2,030 municipios (82%) quedan en "arrasadora", 315 (13%) en
# "cerrada", 128 (5%) en "perdida" para SHH, y 2 en "sin datos" —los
# mismos dos municipios de Oaxaca sin casilla instalada, que ya
# conoces del resto del curso—.
#
# Esto SÍ es sorprendente si tu referencia era la cobertura
# periodística de la elección de 2024, que habló todo el tiempo de
# entidades y de la elección nacional, casi nunca de municipio por
# municipio: a nivel municipio, un triunfo por más de veinte puntos
# fue, con mucho, la norma y no la excepción. Ese es un hallazgo real
# de este módulo, no una curiosidad de la función: la elección se vio
# "cerrada" en el marcador nacional (59.76% contra el resto) pero
# geográficamente estuvo dominada por una enorme cantidad de
# municipios chicos donde el margen fue aplastante. Volvemos a esto
# en el inciso (a) del Nivel 3.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) intersect() entre "arrasadora" y "municipio chico".

mediana_lista_nominal <- median(resultados_municipio$lista_nominal)

municipios_chicos <- resultados_municipio |>
  filter(lista_nominal < mediana_lista_nominal) |>
  pull(clave_municipio)

municipios_arrasadora <- resultados_municipio |>
  filter(categoria_margen == "arrasadora") |>
  pull(clave_municipio)

interseccion <- intersect(municipios_chicos, municipios_arrasadora)

length(municipios_chicos)
length(municipios_arrasadora)
length(interseccion)

# 1,022 municipios están en las dos listas a la vez. Eso es 50.3% de
# los 2,030 municipios "arrasadora" —la mitad exacta de los triunfos
# aplastantes ocurrió en la mitad más chica del país por población—, y
# 82.6% de los 1,237 municipios "chicos" tuvo un triunfo aplastante.
# La anticipación razonable, con lo que ya sabías de la sesión 8
# (media muy jalada por Tijuana/Iztapalapa/Ecatepec, mediana apenas
# 10,423 personas en la lista nominal), era esperar justamente esto:
# el país tiene muchísimos municipios chicos y rurales, y ahí es donde
# el margen de SHH fue más contundente. El patrón que viste como
# "curiosidad estadística" en la sesión 8 —media y mediana muy
# distintas— es, aquí, una pista política real sobre dónde vive la
# ventaja electoral de la coalición.

# (b) map2_dbl().
#
# map2_dbl(.x, .y, .f) aplica una función a DOS vectores EN PARALELO,
# elemento por elemento: toma el primer valor de .x con el primer
# valor de .y, el segundo con el segundo, y así. Es exactamente lo que
# calcular_ventaja() del script ya hacía por su cuenta gracias a la
# vectorización aritmética normal de R (pct_primero - pct_segundo), así
# que aquí map2_dbl() sería redundante; su verdadero caso de uso es
# cuando la operación entre los dos valores NO es una simple resta
# vectorizable, sino algo que de verdad necesita evaluarse un par a la
# vez —por ejemplo, si quisieras aplicar clasificar_margen_seguro() con
# un umbral DISTINTO para cada fila en vez de uno fijo para toda la
# columna—:
#
#   map2_chr(resultados_municipio$ventaja_shh, umbral_por_fila, clasificar_margen_seguro)
#
# Si le preguntaste a una IA, es razonable que te haya dado una
# respuesta parecida a esta. Es también posible que te haya sugerido
# usar map2_dbl() donde una simple operación vectorizada bastaba —es
# un patrón de sobre-ingeniería frecuente en respuestas de IA sobre
# purrr—: la manera de comprobarlo es, otra vez, correr las dos
# versiones y comparar que dan el mismo resultado, como hiciste con
# identical() en la sección 7 del script.

# (c) El error más frecuente en este módulo, para la mayoría, es:
#
#   Error in if (ventaja > umbral) : missing value where TRUE/FALSE needed
#
# Aparece apenas intentas usar if() directo sobre una columna que trae
# algún NA, sin el chequeo de is.na() primero. R no sabe si NA > 20 es
# verdadero o falso —literalmente no lo sabe: NA significa "no sé"—, y
# un if() exige una respuesta de sí o no, sin punto medio.


# ==============================================================
# Sobre la pregunta de cierre del ejercicio:
#
# filter() ya "sabe" aplicarse fila por fila sin que lo pidas aparte
# —es vectorizado por diseño de dplyr—; sum() y mean() igual. Lo que
# NO sabe aplicarse solo, fila por fila, es un if() suelto o una
# función tuya que tenga un if() por dentro: ahí es donde map_chr(),
# map_dbl() o, en el peor de los casos, un for explícito, tienen que
# entrar a hacer ese trabajo por ti. Reconocer esa frontera —qué se
# vectoriza solo y qué necesita ayuda— es, más que cualquier función
# suelta, el aprendizaje real de este módulo.
# ==============================================================
