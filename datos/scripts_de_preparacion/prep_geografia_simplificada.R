# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Preparación de datos · Geografía simplificada (municipios y entidades)
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Bajar el Marco Geoestadístico de INEGI y quedarnos solo con las
#   capas de municipio y de entidad (sin AGEB ni manzana, que son
#   mucho más pesadas y no las usamos en el curso), y simplificar sus
#   polígonos para que el archivo cargue en un par de segundos en la
#   sesión 7, en vez de tardar minutos.
#
# Qué necesitas antes de empezar:
#   Nada de este repositorio: este script parte de una URL de INEGI,
#   hasta el archivo .rds final.
#
# Datos: INEGI, Marco Geoestadístico 2025, producto "Marco
#        Geoestadístico Integrado 2025" (mg_2025_integrado.zip, 245 MB),
#        ficha: inegi.org.mx/app/biblioteca/ficha.html?upc=794551163061
#        Cobertura temporal declarada por INEGI: 2024-11-01 a 2025-07-31.
#        Elegimos el producto "integrado" (245 MB) y no el "Nacional"
#        completo por AGEB (2.7 GB) porque el integrado ya trae
#        exactamente las capas de entidad y municipio que necesitamos,
#        sin la desagregación a manzana que no usamos en el curso.
# Descargado el: 2026-08-05
# Autor: Emiliano Miranda González (script generado por el subagente de datos)
# ==============================================================

# install.packages(c("sf", "rmapshaper", "here", "janitor", "curl", "tidyverse", "zip"))

library(tidyverse)
library(sf)
library(rmapshaper)
library(here)
library(janitor)
library(curl)

# ---- 1. Descargar el Marco Geoestadístico integrado ----

url_mg <- "https://www.inegi.org.mx/contenidos/productos/prod_serv/contenidos/espanol/bvinegi/productos/geografia/marcogeo/794551163061/mg_2025_integrado.zip"
ruta_mg <- here("datos", "crudos", "mg2025")
dir.create(ruta_mg, showWarnings = FALSE, recursive = TRUE)
zip_mg <- file.path(ruta_mg, "mg_2025_integrado.zip")

if (!file.exists(zip_mg)) curl_download(url_mg, zip_mg)


# ---- 2. Extraer solo las capas que necesitamos ----
#
# El paquete zip::zip_list()/zip::unzip() maneja mejor que la función
# base unzip() los nombres de archivo con acentos que trae este ZIP de
# INEGI (algunos vienen codificados en Latin-1). Dentro de
# conjunto_de_datos/ hay una capa por tipo de objeto geográfico:
# 00ent = entidad, 00mun = municipio, 00a = AGEB, 00l/00lpr = localidad.
# Solo extraemos entidad y municipio.
# Ningún script del curso instala paquetes por su cuenta: se avisa y se para.
if (!requireNamespace("zip", quietly = TRUE)) {
  stop("Falta el paquete zip. Corre en la consola: install.packages(\"zip\")",
       call. = FALSE)
}

capas <- c("00ent", "00mun")
extensiones <- c("cpg", "dbf", "prj", "shp", "shx")
archivos_zip <- expand_grid(capa = capas, ext = extensiones) |>
  mutate(nombre = str_glue("conjunto_de_datos/{capa}.{ext}")) |>
  pull(nombre)

ruta_extraida <- file.path(ruta_mg, "integrado")
if (!dir.exists(file.path(ruta_extraida, "conjunto_de_datos"))) {
  zip::unzip(zip_mg, files = archivos_zip, exdir = ruta_extraida)
}

sf_mun <- st_read(file.path(ruta_extraida, "conjunto_de_datos", "00mun.shp"), quiet = TRUE)
sf_ent <- st_read(file.path(ruta_extraida, "conjunto_de_datos", "00ent.shp"), quiet = TRUE)

cat(nrow(sf_ent), "entidades,", nrow(sf_mun), "municipios en el shapefile original.\n")


# ---- 3. Reproyectar a coordenadas geográficas ----
#
# El Marco Geoestadístico viene en la proyección cónica de Lambert que
# usa INEGI, pensada para medir áreas con precisión. Para publicar en
# la web y para que cualquier geom_sf() del curso lo lea sin fricción,
# lo pasamos a WGS84 (longitud/latitud, EPSG:4326), que es el estándar
# de facto para mapas interactivos. Ya no es apto para medir áreas de
# todas formas, así que no perdemos nada dejando la proyección
# cónica: el archivo final queda advertido para otro uso.
sf_mun <- st_transform(sf_mun, 4326)
sf_ent <- st_transform(sf_ent, 4326)


# ---- 4. Simplificar ----
#
# rmapshaper::ms_simplify(keep = 0.05) conserva solo 5% de los
# vértices originales de cada polígono. Es agresivo, pero un mapa de
# todo el país en la pantalla de una sesión de una hora no necesita el
# detalle de un plano catastral. Usamos keep_shapes = TRUE para que
# ningún municipio pequeño desaparezca del mapa por la simplificación
# (varios municipios de Oaxaca son minúsculos y, sin este parámetro,
# rmapshaper los puede borrar por completo).
sf_mun_simple <- ms_simplify(sf_mun, keep = 0.05, keep_shapes = TRUE)
sf_ent_simple <- ms_simplify(sf_ent, keep = 0.05, keep_shapes = TRUE)

# Si rmapshaper falla en tu máquina (a veces pide una instalación de
# Node.js/mapshaper por fuera de R), usa en su lugar:
#   sf_mun_simple <- st_simplify(sf_mun, dTolerance = 0.001, preserveTopology = TRUE)
# st_simplify no conserva la topología compartida entre polígonos
# vecinos tan bien como rmapshaper (pueden quedar huecos diminutos
# entre municipios), pero sirve como respaldo.


# ---- 5. Nombres de columna y verificación ----

sf_mun_final <- sf_mun_simple |>
  clean_names() |>
  rename(clave_municipio = cvegeo, clave_entidad = cve_ent,
         clave_municipio_corta = cve_mun, municipio = nomgeo)

sf_ent_final <- sf_ent_simple |>
  clean_names() |>
  rename(clave_entidad = cvegeo, clave_entidad_corta = cve_ent, entidad = nomgeo)

stopifnot(
  sum(st_is_empty(sf_mun_final)) == 0,
  sum(st_is_empty(sf_ent_final)) == 0,
  sum(duplicated(sf_mun_final$clave_municipio)) == 0
)

cat("Peso en memoria tras simplificar -- municipios:",
    format(object.size(sf_mun_final), units = "MB"), "\n")


# ---- 6. Guardar ----
#
# Guardamos SOLO en .rds (no en .shp ni en .geojson): un objeto sf en
# .rds conserva la geometría, el CRS y los tipos de columna intactos,
# y es el formato más simple de cargar en una sesión de una hora con
# readRDS(). No lo guardamos también en .csv porque un .csv no puede
# representar geometría.

dir.create(here("datos", "geo"), showWarnings = FALSE, recursive = TRUE)
saveRDS(sf_mun_final, here("datos", "geo", "municipios_simplificado.rds"), compress = "xz")
saveRDS(sf_ent_final, here("datos", "geo", "entidades_simplificado.rds"), compress = "xz")

for (arch in c("municipios_simplificado.rds", "entidades_simplificado.rds")) {
  ruta <- here("datos", "geo", arch)
  cat(arch, ":", round(file.info(ruta)$size / 1024^2, 2), "MB\n")
}


# ==============================================================
# ADVERTENCIA que debe repetirse en cualquier sesión que use este
# archivo: la simplificación deforma los polígonos lo suficiente
# como para que CUALQUIER cálculo de área (st_area()) o de distancia
# (st_distance()) hecho sobre municipios_simplificado.rds o
# entidades_simplificado.rds dé un número incorrecto. Para eso hay
# que volver a la fuente original de INEGI sin simplificar. Este
# archivo sirve únicamente para dibujar mapas, no para medirlos.
# ==============================================================
