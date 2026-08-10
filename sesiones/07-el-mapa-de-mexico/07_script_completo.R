# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 07 · El mapa de México
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Convertir una tabla de resultados electorales en un mapa
#   coroplético de los municipios del país, y ver aparecer un patrón
#   regional que hasta hoy solo eran números sueltos en una columna.
#
# Qué necesitas antes de empezar:
#   Haber corrido la sesión 04 (joins) — usamos left_join() sin
#   volver a explicarlo. También usamos, sin re-presentarlas, las
#   escalas de color y theme_lab() de la sesión 06.
#
# Datos: INE, cómputos distritales 2024 (presidencial_2024_municipio.csv,
#        presidencial_2024_entidad.csv) + INEGI, Marco Geoestadístico
#        2025, ya simplificado (datos/geo/municipios_simplificado.rds,
#        datos/geo/entidades_simplificado.rds). Ver datos/README.md
#        para la fuente exacta y sus advertencias.
# Autor: Emiliano Miranda González
# ==============================================================

# ESTA ES LA VERSIÓN RESUELTA. Se publica después de la sesión.
# Si estás en clase, usa 07_script.R.


# ---- 0. Los paquetes ----

# Hoy se suma un paquete nuevo: sf ("simple features"), el estándar
# de R para trabajar con geometría. Todo lo espacial de este curso
# pasa por sf. NUNCA vamos a cargar sp, rgdal ni rgeos: los tres
# fueron retirados de CRAN en octubre de 2023, y un script que los
# cargue ya no se instala limpio en una computadora nueva.
#
#   install.packages(c("sf", "patchwork"))
#
# patchwork ya lo instalaste en la sesión 06.

library(tidyverse)
library(here)
library(sf)
library(patchwork)

# El tema del curso, con theme_lab_mapa() incluido: la variante de
# theme_lab() pensada para mapas, sin ejes ni cuadrícula.
source(here("estilo", "tema_lab.R"))


# ---- 1. Un objeto sf es una tabla con una columna rara ----

# La forma más rápida de perderle el miedo a un mapa es dejar de
# pensarlo como un mapa. Un objeto sf ES una tabla: tiene filas y
# columnas, se filtra con filter(), se cruza con left_join(), se
# describe con glimpse(), exactamente como cualquier tibble de este
# curso. Lo único distinto es una columna adicional, geometry, que
# en vez de un número o un texto guarda el contorno del polígono.
#
# El Marco Geoestadístico completo de INEGI pesa cientos de
# megabytes y st_read() tarda minutos en leerlo. Alguien ya lo hizo
# una sola vez, fuera de esta hora, y simplificó los polígonos con
# rmapshaper::ms_simplify(): hoy cargas el resultado con read_rds(),
# que tarda segundos.

municipios <- read_rds(here("datos", "geo", "municipios_simplificado.rds"))

class(municipios)
glimpse(municipios)

# Si en vez de esto hubieras corrido tú st_read() sobre el shapefile
# original (00mun.shp, el que trae INEGI), la consola te habría
# contestado algo así. No lo vas a correr hoy —perderíamos minutos
# de proyector—, pero vale la pena leerlo una vez, línea por línea:
#
#   Reading layer 00mun from data source .../00mun.shp
#     using driver ESRI Shapefile
#   Simple feature collection with 2478 features and 4 fields
#   Geometry type: MULTIPOLYGON
#   Dimension:     XY
#   Bounding box:  xmin: ... ymin: ... xmax: ... ymax: ...
#   Projected CRS: Mexico ITRF2008 / LCC
#
# "features" son las filas (aquí, municipios). "fields" son las
# columnas normales, sin contar geometry. "Geometry type" dice si
# cada fila es un solo polígono (POLYGON) o varios pegados bajo el
# mismo nombre —una isla, un exclave— (MULTIPOLYGON). Y la última
# línea es la de hoy: el CRS. Vamos a esa ahora.

#<hueco>
nrow(municipios)
#</hueco>


# ---- 2. El CRS: un acuerdo sobre cómo aplanar una esfera ----

# La Tierra es una esfera —más bien un elipsoide— y un mapa es un
# rectángulo plano. Pasar de una a otro exige elegir un sistema de
# referencia de coordenadas, CRS por sus siglas en inglés, que es,
# literalmente, un acuerdo sobre qué se sacrifica al aplanar: un CRS
# puede conservar el área real, o la forma real, o la distancia
# real, pero ningún CRS conserva las tres a la vez. Por eso existen
# decenas de CRS distintos y no uno solo.
#
# El Marco Geoestadístico de INEGI viene, de fábrica, en una
# proyección cónica de Lambert amarrada a ITRF2008 (EPSG:6372):
# pensada para medir área y distancia con precisión dentro de
# México. Antes de guardar el archivo que abriste hace un momento,
# alguien ya lo reproyectó a WGS84 (longitud/latitud, EPSG:4326),
# el estándar de facto para mapas web y para geom_sf(). Nunca des
# por sentado en qué CRS viene algo: se revisa, siempre, antes de
# dibujar una sola línea.

st_crs(municipios)

entidades <- read_rds(here("datos", "geo", "entidades_simplificado.rds"))

st_crs(entidades) == st_crs(municipios)

# TRUE: las dos capas comparten CRS. Si algún día sobrepones dos
# capas con CRS distinto, sf no te para con un error rojo: los
# polígonos simplemente no coinciden en el mapa, corridos unos
# metros o unos países enteros según el caso. Ese es un error mucho
# más difícil de detectar que uno rojo, y por eso se verifica ANTES
# de dibujar, no después de que algo se vea raro.


# ---- 3. El primer geom_sf() ----

ggplot(municipios) +
  geom_sf()

# geom_sf() ya sabe leer la columna geometry sin que se lo digas
# dentro de aes(): es la única geometría de ggplot2 que no necesita
# x ni y. Fíjate en algo más: no hay ejes con números. Nadie lee
# "19.4° N" en un mapa de México, así que theme_lab_mapa() —la
# variante del tema del curso para mapas— los quita.

ggplot(municipios) +
  geom_sf(fill = lab_colores[["verde_claro"]], color = "white", linewidth = 0.1) +
  theme_lab_mapa() +
  labs(title = "2,478 municipios, sin un solo dato electoral todavía")


# ---- 4. Unir el mapa con los datos: el left_join() de la sesión 4 ----

# Esto ya lo sabes hacer. La sesión 4 enseñó left_join() a fondo; hoy
# lo aplicamos sin volver a explicarlo, con una sola diferencia: uno
# de los dos lados es un objeto sf. A left_join() no le importa:
# sigue cruzando por clave, fila por fila, y la columna geometry
# viaja junto con el resto.

resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv")) |>
  select(clave_municipio, participacion, votos_shh, pct_shh, ventaja_shh)

# Seleccionamos solo estas columnas a propósito: resultados_municipio
# también trae clave_entidad y municipio, y el objeto municipios YA
# trae esas dos. Si las unieras tal cual, left_join() no truena —no
# es un error rojo—, pero te deja clave_entidad.x, clave_entidad.y,
# municipio.x, municipio.y: un tropiezo silencioso que solo notas
# cuando buscas una columna y no está donde la dejaste.

#<hueco>
mapa_municipios <- left_join(municipios, resultados_municipio, by = "clave_municipio")
#</hueco>

nrow(mapa_municipios)
sum(is.na(mapa_municipios$ventaja_shh))

# nrow() debe seguir dando 2,478: left_join() nunca quita filas del
# lado izquierdo. Vas a encontrar unos cuantos NA en ventaja_shh —
# documentados en datos/README.md: municipios del shapefile más
# reciente de INEGI sin fila en la base electoral de 2024, más los
# de Oaxaca donde ninguna casilla se instaló. No es un error tuyo.

resultados_entidad <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv")) |>
  select(clave_entidad, participacion, votos_shh, pct_shh)

mapa_entidades <- left_join(entidades, resultados_entidad, by = "clave_entidad")


# ---- 5. El mapa de conteos contra el mapa de proporciones ----

# En la sesión 1 dijimos, de pasada, que un mapa de "número de
# homicidios" es, en buena medida, un mapa de dónde vive la gente, y
# prometimos que lo veríamos otra vez, y peor, aquí. Este es el
# momento.

mapa_conteo <- ggplot(mapa_municipios) +
  geom_sf(aes(fill = votos_shh), color = NA) +
  scale_fill_viridis_c(option = "viridis", labels = scales::comma) +
  theme_lab_mapa() +
  labs(title = "Votos de SHH por municipio (conteo)", fill = "Votos")

mapa_proporcion <- ggplot(mapa_municipios) +
  geom_sf(aes(fill = pct_shh), color = NA) +
  scale_fill_viridis_c(option = "viridis") +
  theme_lab_mapa() +
  labs(title = "Votos de SHH por municipio (porcentaje)", fill = "%")

mapa_conteo | mapa_proporcion

# En el mapa de la izquierda casi todo el país se ve oscuro salvo un
# puñado de puntos brillantes: Iztapalapa, Tijuana, Ecatepec, Puebla,
# Ciudad Juárez, Guadalajara. No son los municipios donde SHH ganó
# por más: son los municipios más poblados del país. En el de la
# derecha, con el mismo color representando un porcentaje en vez de
# un conteo, el patrón cambia por completo: ahora se encienden
# municipios chicos de Oaxaca y Chiapas, del tamaño de un pueblo,
# donde casi nadie votó distinto. Es la misma trampa de la sesión 1
# —contar sin ponderar por tamaño de población— pero en dos
# dimensiones y mucho más difícil de ignorar: un mapa se ve
# autoritativo aunque, sin darte cuenta, esté midiendo dónde vive la
# gente y no a quién votó.


# ---- 6. La coropleta que vas a entregar hoy ----

# ventaja_shh ya la conoces de la sesión 6: cuánto le sacó SHH al
# segundo lugar, en puntos porcentuales, con NA donde ninguna casilla
# se instaló. Tiene un cero real —el empate— así que la escala es
# DIVERGENTE, el mismo criterio de la sesión pasada. Lo nuevo es que
# hoy el "panel" es el mapa completo del país.

#<hueco>
mapa_ventaja <- ggplot() +
  geom_sf(data = mapa_municipios, aes(fill = ventaja_shh), color = NA) +
  scale_fill_gradient2(low = "#7B1113", mid = "white", high = "#006847", midpoint = 0) +
  geom_sf(data = mapa_entidades, fill = NA, color = "white", linewidth = 0.25) +
  theme_lab_mapa() +
  labs(
    title    = "¿Dónde le ganó SHH al segundo lugar, y por cuánto?",
    subtitle = "Ventaja de Sigamos Haciendo Historia sobre el segundo lugar, por municipio, 2024",
    fill     = "Ventaja (pp)",
    caption  = "Fuente: INE, cómputos distritales 2024. INEGI, Marco Geoestadístico 2025."
  )
#</hueco>

mapa_ventaja

# Este mapa —conteos contra proporciones, resuelto con la ventaja de
# SHH— es, literalmente, uno de los dos mapas del proyecto final del
# laboratorio: en la sesión 11 vas a sobreponerle el voto por
# candidaturas morenistas a ministra de la Corte y vas a preguntarte
# si coinciden en el territorio. Ese proyecto no empieza en la
# sesión 11: empieza aquí, con este archivo.

dir.create(here("sesiones", "07-el-mapa-de-mexico", "figuras"), showWarnings = FALSE)

ggsave(
  filename = here("sesiones", "07-el-mapa-de-mexico", "figuras", "07_mapa_ventaja_shh.pdf"),
  plot     = mapa_ventaja,
  width    = 8,
  height   = 6,
  units    = "in",
  device   = "pdf"
)


# ---- 7. Cámbiale algo ----

# Cambia scale_fill_gradient2() por scale_fill_viridis_c() en
# mapa_ventaja y vuelve a correr el bloque. ¿Sigue viéndose dónde
# está el cero —el empate entre SHH y el segundo lugar— igual de
# claro que con la escala divergente?

mapa_ventaja_viridis <- ggplot() +
  geom_sf(data = mapa_municipios, aes(fill = ventaja_shh), color = NA) +
  scale_fill_viridis_c(option = "viridis") +
  geom_sf(data = mapa_entidades, fill = NA, color = "white", linewidth = 0.25) +
  theme_lab_mapa() +
  labs(title = "Lo mismo, con viridis en vez de una escala divergente", fill = "Ventaja (pp)")

mapa_ventaja_viridis

# La respuesta corta: no. viridis es perceptualmente uniforme, pero
# no tiene un punto de quiebre en cero — el empate desaparece en
# algún tono intermedio de verde, en vez de marcarse en blanco. Es
# el mismo argumento de la sesión 6, aplicado sobre un mapa en vez
# de sobre una barra: la escala no es un adorno, es parte del
# argumento.


# ==============================================================
# Mira el mapa final un minuto antes de cerrarlo.
#
# Hay una región del país que no encaja del todo en un relato simple
# de "norte contra sur": un grupo de estados del centro-occidente
# que se comporta distinto de sus vecinos inmediatos. ¿La ves? No
# hace falta que la nombres bien todavía —eso es trabajo de
# politólogo, no de R—, pero fíjate que la viste EN EL MAPA, y que
# hace un minuto era solo una columna de números sin ningún orden
# espacial.
#
# Esa es la pregunta que te llevas: ¿qué tendrías que saber, además
# de este mapa, para explicar por qué esa región se comporta así?
# ==============================================================
