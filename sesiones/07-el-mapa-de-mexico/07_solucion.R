# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 07 · Solución comentada del ejercicio
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

ggplot(mapa_municipios) +
  geom_sf(aes(fill = participacion), color = NA) +
  scale_fill_viridis_c(option = "viridis") +
  theme_lab_mapa() +
  labs(
    title   = "Participación municipal en 2024",
    fill    = "Participación (%)",
    caption = "Fuente: INE, cómputos distritales 2024."
  )

# Sobre la pregunta previa: NO tiene sentido una escala divergente
# aquí, por la misma razón que ya viste en la sesión 6 con esta
# misma variable. Una escala divergente le dice a quien mira "hay un
# punto de referencia sustantivo a la mitad, y lo que importa es de
# qué lado y qué tan lejos estás de él" — eso es exactamente lo que
# pasa con ventaja_shh, donde cero es el empate. Participación no
# tiene ese punto medio: 0% no es un "empate", es simplemente el
# mínimo posible de la escala. Ahí corresponde una escala
# SECUENCIAL (viridis_c(), que es lo que usamos arriba): solo
# importa la magnitud, de menos a más, sin un punto de quiebre.


# ---- Nivel 2 · De verdad ----

# (a) La columna que no viene hecha, con la misma definición del
# README: pct_shh menos el mayor entre pct_fcm y pct_mc. pmax() —no
# max()— porque queremos el máximo ENTRE LAS DOS COLUMNAS, fila por
# fila, no un solo número que colapse las 32 entidades.

resultados_entidad_ventaja <- resultados_entidad |>
  mutate(ventaja_shh = pct_shh - pmax(pct_fcm, pct_mc))

mapa_entidades_ventaja <- entidades |>
  left_join(resultados_entidad_ventaja, by = "clave_entidad")

# (b) El mapa por entidad, con la misma escala divergente del script
# de hoy.

mapa_entidad_final <- ggplot() +
  geom_sf(data = mapa_entidades_ventaja, aes(fill = ventaja_shh), color = "white", linewidth = 0.3) +
  scale_fill_gradient2(low = "#7B1113", mid = "white", high = "#006847", midpoint = 0) +
  theme_lab_mapa() +
  labs(
    title   = "Lo mismo, agregado por entidad",
    fill    = "Ventaja (pp)",
    caption = "Fuente: INE, cómputos distritales 2024."
  )

mapa_municipio_final <- ggplot() +
  geom_sf(data = mapa_municipios, aes(fill = ventaja_shh), color = NA) +
  scale_fill_gradient2(low = "#7B1113", mid = "white", high = "#006847", midpoint = 0) +
  geom_sf(data = mapa_entidades, fill = NA, color = "white", linewidth = 0.2) +
  theme_lab_mapa() +
  labs(title = "Por municipio (el de la sesión de hoy)", fill = "Ventaja (pp)")

mapa_municipio_final | mapa_entidad_final

# (c) La comparación, con números reales.
#
# El mapa por entidad SUAVIZA el patrón: solo hay 32 tonos posibles
# en vez de 2,478, así que un estado con municipios muy distintos
# entre sí —zonas urbanas donde SHH pierde por poco junto a zonas
# rurales donde gana por goleada— termina pintado de un solo color
# promedio. Esto es exactamente lo que en política comparada se
# discute como el riesgo de agregar demasiado: la unidad de análisis
# que eliges cambia la historia que el mapa cuenta, no solo su nivel
# de detalle.
#
# Con las cifras reales de resultados_entidad, calculadas con la
# misma fórmula de arriba:
#
#   Aguascalientes: -3.24 pp (el único caso donde el mapa ESTATAL
#     muestra a SHH perdiendo, aunque sea por muy poco)
#   Tabasco:        69.40 pp (el máximo del país a nivel estatal)
#   Guanajuato:       7.23 pp
#   Jalisco:          8.68 pp
#   Querétaro:       14.18 pp
#
# Guanajuato, Jalisco y Querétaro —el Bajío— ya se habían visto
# comportarse distinto del resto del sur en el promedio municipal de
# la sesión 6. Acá, a nivel estatal, el patrón se sostiene: las tres
# entidades quedan con ventajas de SHH bastante más chicas que sus
# vecinas del centro y del sureste. Es una región que el mapa
# municipal ya insinuaba y que el mapa estatal, pese a suavizar
# todo lo demás, sigue dejando ver — evidencia de que el patrón no
# es un artefacto de mirar municipios chicos uno por uno, sino algo
# que se sostiene también a una escala más gruesa.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) CRS geográfico contra proyectado, verificado.

sf::st_is_longlat(municipios)

# Debe dar TRUE: nuestro archivo está en EPSG:4326 (WGS84), que es
# un CRS GEOGRÁFICO — sus coordenadas son longitud y latitud, en
# grados, no en metros. Un CRS PROYECTADO, como EPSG:6372 (el que
# usa INEGI de fábrica para el Marco Geoestadístico), sí mide en
# metros sobre un plano ya aplanado con una fórmula matemática
# concreta —en este caso, una proyección cónica de Lambert—. Una IA
# consultada sobre esto típicamente contesta bien esta distinción
# conceptual; donde conviene desconfiar es de cualquier afirmación
# sobre CUÁL de los dos usa nuestro archivo en particular, porque
# eso no lo puede saber sin ver el archivo: por eso lo verificamos
# nosotros mismos con st_crs() y st_is_longlat(), no le preguntamos.

# (b) La pregunta con trampa sobre st_area().
#
# NO es seguro calcular áreas sobre este archivo, y datos/README.md
# lo advierte de forma explícita: la simplificación con
# rmapshaper::ms_simplify() deforma los polígonos lo suficiente como
# para que cualquier st_area() o st_distance() sobre
# municipios_simplificado.rds o entidades_simplificado.rds dé un
# número incorrecto. Sirven para DIBUJAR, no para MEDIR. Si una IA
# te contesta que sí es seguro, sin mencionar esta advertencia, es
# una señal de que no tiene forma de saber que este archivo en
# particular fue simplificado —no puede ver tu carpeta de datos— y
# está respondiendo en general sobre qué hace st_area(), no sobre si
# es seguro usarla AQUÍ. Esa distinción —"la función existe y hace
# lo que dice" contra "es correcto usarla con este dato concreto"—
# es central para la sesión 11.


# ==============================================================
# Cierre: si los dos mapas del proyecto final coincidieran casi
# perfectamente, la historia defendible sería que el voto por
# Morena y el voto por sus candidaturas judiciales comparten una
# misma base territorial de apoyo. Si coincidieran solo a medias
# —como ya viste que pasa entre el mapa municipal y el estatal de
# hoy—, la historia defendible sería más interesante todavía: que
# hay algo que separa el voto por un partido del voto por personas
# específicas dentro del mismo campo político, y que ESO es lo que
# valdría la pena investigar. Ninguna de las dos respuestas es mejor
# que la otra de antemano; las dos son preguntas de politólogo, no
# de R. Guarda este script: la sesión 11 va a volver exactamente a
# este punto.
# ==============================================================
