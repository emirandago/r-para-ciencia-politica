# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 07 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 07_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

library(tidyverse)
library(here)
library(sf)
library(patchwork)

source(here("estilo", "tema_lab.R"))

municipios <- read_rds(here("datos", "geo", "municipios_simplificado.rds"))
entidades  <- read_rds(here("datos", "geo", "entidades_simplificado.rds"))

resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv")) |>
  select(clave_municipio, participacion, votos_shh, pct_shh, ventaja_shh)

resultados_entidad <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv")) |>
  select(clave_entidad, entidad, participacion, votos_shh, pct_shh, pct_fcm, pct_mc)

mapa_municipios <- left_join(municipios, resultados_municipio, by = "clave_municipio")
mapa_entidades  <- left_join(entidades, resultados_entidad, by = "clave_entidad")


# ---- Nivel 1 · Calentamiento ----

# En el script de hoy armaste mapa_ventaja: un mapa coroplético de
# ventaja_shh con una escala divergente. Reprodúcelo, pero cambia UNA
# cosa: usa la columna participacion en vez de ventaja_shh (sigue
# siendo un número por municipio, así que el mismo esqueleto de
# geom_sf() + scale_fill_...() funciona sin tocar nada más).
#
# Antes de correrlo, contesta mentalmente la misma pregunta que ya te
# hiciste en la sesión 6 sobre esta variable, pero ahora sobre un
# mapa: ¿tiene sentido una escala DIVERGENTE para participación, con
# un midpoint en algún valor? ¿Por qué sí o por qué no?

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# Una pregunta distinta: si en vez de mirar el mapa por MUNICIPIO
# miras el mismo dato por ENTIDAD, ¿el patrón se sostiene o se
# desdibuja?
#
# (a) resultados_entidad no trae una columna ventaja_shh ya hecha
#     (esa columna solo existe en el archivo municipal). Créala tú,
#     con la misma definición que usa datos/README.md: pct_shh menos
#     el mayor entre pct_fcm y pct_mc. La función que calcula el
#     mayor de dos números, elemento por elemento, es pmax() — no
#     max(), que colapsaría toda la columna en un solo número.
#
#       mutate(ventaja_shh = pct_shh - pmax(pct_fcm, pct_mc))
#
# (b) Une esa columna nueva a mapa_entidades (o vuelve a hacer el
#     left_join incluyéndola) y arma el mapa por entidad, con la
#     misma escala divergente del script de hoy.
#
# (c) Ponlo al lado del mapa_ventaja municipal del script de hoy
#     (con patchwork, mapa_municipio | mapa_entidad_nuevo) y mira los
#     dos. En un comentario de dos o tres líneas: ¿el mapa estatal
#     esconde algo que el municipal sí mostraba, o al revés? No hay
#     respuesta correcta; hay respuestas defendibles y respuestas
#     flojas.

# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Pídele a una IA que te explique, en sus palabras, la diferencia
#     entre un CRS "geográfico" (como EPSG:4326, en grados de
#     longitud/latitud) y uno "proyectado" (como EPSG:6372, en
#     metros). Después VERIFICA una parte concreta de la respuesta
#     corriendo tú mismo:
#
#       sf::st_is_longlat(municipios)
#
#     ¿Coincide lo que devuelve esa función con lo que te dijo la IA
#     sobre si nuestro archivo está en un CRS geográfico o proyectado?
#
# (b) Pregúntale además si sería seguro calcular el área de cada
#     municipio con st_area() sobre el objeto municipios de esta
#     sesión. Es una pregunta con trampa: datos/README.md ya lo
#     advierte explícitamente y la respuesta es que NO, precisamente
#     porque este archivo está simplificado. Si la IA te contesta que
#     sí sin ninguna advertencia, eso es justo el tipo de afirmación
#     que hay que verificar contra la fuente antes de creerla —la
#     sesión 11 va a tratar exactamente de esto.

# Escribe tu código aquí abajo:




# ==============================================================
# La pregunta de cierre, sin código.
#
# El proyecto final del laboratorio (sesión 11) va a sobreponer este
# mapa —el de la ventaja de SHH en 2024— con un segundo mapa del voto
# por candidaturas morenistas a ministra de la Corte en 2025. Si esos
# dos mapas coincidieran casi perfectamente, ¿qué conclusión política
# te sentirías cómodo sacando? ¿Y si coincidieran solo a medias?
# Escribe, en dos o tres líneas, qué tendrías que ver en el mapa para
# convencerte de cada una de las dos historias.
# ==============================================================
