# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Preparación de datos · Puente de claves municipales INE-INEGI
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Construir la tabla que resuelve el problema que enseñamos en la
#   sesión 4: las claves de municipio del INE (llamadas "ife" en las
#   bases de Eric Magar) NO coinciden con las claves oficiales de
#   INEGI. Sin esta tabla, no se puede cruzar votos por municipio
#   (identificados por sección electoral, del lado del INE) contra
#   cartografía o censo (identificados con claves INEGI).
#
# Qué necesitas antes de empezar:
#   Nada de este repositorio: este script parte de una sola URL de
#   GitHub, hasta el archivo limpio.
#
# Datos: emagar/mxDistritos (github.com/emagar/mxDistritos), de Eric
#        Magar (ITAM), licencia MIT, archivo
#        equivSecc/tablaEquivalenciasSeccionalesDesde1994.csv, que
#        trae, en el mismo registro, la clave de municipio de INEGI y
#        la clave de municipio del INE para cada una de las cerca de
#        76,000 secciones electorales del país desde 1994.
# Descargado el: 2026-08-05 (revisión visible del repositorio: 2026-04-11)
# Autor: Emiliano Miranda González (script generado por el subagente de datos)
# ==============================================================

library(tidyverse)
library(here)
library(janitor)
library(curl)

# ---- 1. Descargar el catálogo de secciones ----

url_equiv <- "https://raw.githubusercontent.com/emagar/mxDistritos/master/equivSecc/tablaEquivalenciasSeccionalesDesde1994.csv"
ruta_mxdistritos <- here("datos", "crudos", "mxDistritos")
dir.create(ruta_mxdistritos, showWarnings = FALSE, recursive = TRUE)
archivo_equiv <- file.path(ruta_mxdistritos, "tablaEquivalenciasSeccionalesDesde1994.csv")

if (!file.exists(archivo_equiv)) curl_download(url_equiv, archivo_equiv)

d_equiv <- read_csv(archivo_equiv, col_types = cols(.default = "c"), show_col_types = FALSE)

cat(nrow(d_equiv), "secciones en el catálogo histórico completo.\n")


# ---- 2. ¿Cuál es la geografía municipal "de hoy"? ----
#
# Este catálogo es un panel histórico: cada sección tiene un año de
# "alta" (cuándo se le asignó su municipio actual) y, en algunos
# casos, un año de "baja". Para esta tabla puente -- que es de
# referencia general, no de una elección en particular -- usamos el
# corte MÁS RECIENTE disponible: el registro con el año de "alta" más
# reciente para cada sección, sin importar "baja" (ver la nota sobre
# ese campo más abajo).
anio_corte <- as.integer(format(Sys.Date(), "%Y"))

d_secc_actual <- d_equiv |>
  mutate(
    edon = as.integer(edon), seccion = as.integer(seccion),
    alta_n = suppressWarnings(as.integer(alta))
  ) |>
  filter(is.na(alta_n) | alta_n <= anio_corte) |>
  group_by(edon, seccion) |>
  slice_max(order_by = alta_n, n = 1, with_ties = FALSE, na_rm = FALSE) |>
  ungroup() |>
  select(edon, seccion, inegi, ife, mun)

# DECISIÓN: no usamos la columna "baja" para decidir qué secciones
# están vigentes. La probamos primero y descubrimos que excluía
# secciones que sí tuvieron votos reales en elecciones recientes (por
# ejemplo, la sección 86 de Aguascalientes, con baja=2023, reportó
# votos válidos en junio de 2024). No encontramos documentación del
# repositorio que explique qué significa exactamente "baja", así que
# preferimos el criterio verificable con los propios datos: el
# registro de asignación más reciente por sección.


# ---- 3. Resolver ambigüedades reales entre inegi y ife ----
#
# En un puñado de municipios (4 en todo el país, cuando hicimos esta
# base) la misma clave inegi aparece asociada a dos claves ife
# distintas, o viceversa -- casi siempre porque un municipio se separó
# de otro (por ejemplo, Pesquería de Apodaca, en Nuevo León, o Juan
# José Ríos de Guasave, en Sinaloa) y un puñado de secciones quedó con
# la clave inegi del municipio "padre" pegada por error de arrastre.
# Lo resolvemos por mayoría de secciones, dejando que hable el propio
# catálogo en vez de decidir nosotros a mano cuál es la clave
# "correcta".
dominante_inegi <- d_secc_actual |>
  count(edon, ife, inegi, name = "n_secciones") |>
  arrange(edon, ife, desc(n_secciones)) |>
  distinct(edon, ife, .keep_all = TRUE) |>
  select(edon, ife, inegi_dominante = inegi)

d_secc_corregido <- d_secc_actual |>
  left_join(dominante_inegi, by = c("edon", "ife")) |>
  mutate(inegi = inegi_dominante) |>
  select(-inegi_dominante)

# El nombre del municipio también trae variantes de ortografía y
# nombres truncados para la misma clave (p. ej. "TLAQUEPAQUE" y "SAN
# PEDRO TLAQUEPAQUE" para el mismo municipio). Nos quedamos con el
# nombre que respalda más secciones -- no inventamos ninguna grafía,
# solo elegimos la dominante en los propios datos.
dominante_nombre <- d_secc_corregido |>
  count(edon, inegi, ife, mun, name = "n_secciones") |>
  arrange(edon, inegi, ife, desc(n_secciones)) |>
  distinct(edon, inegi, ife, .keep_all = TRUE) |>
  select(edon, inegi, ife, mun)

# Verifica que ya no queden ambigüedades reales
stopifnot(
  sum(duplicated(dominante_nombre$inegi[!is.na(dominante_nombre$inegi)])) == 0 |
    nrow(dominante_nombre |> count(inegi) |> filter(n > 1)) == 0
)


# ---- 4. Formato final ----

# DECISIÓN: hay 7 secciones del Estado de México (15) que el propio
# catálogo trae sin municipio, sin clave inegi y sin clave ife (todo
# en blanco). No tienen votos asociados en la elección 2024 que
# revisamos, así que su ausencia no afecta ninguna de las bases
# electorales de este repositorio, pero las dejamos fuera de esta
# tabla puente porque no podemos rellenarlas sin inventar. Si en algún
# momento aparecen votos reales en esas secciones (3187 a 3193 de la
# entidad 15), hay que volver a este catálogo y resolverlo con una
# fuente adicional.

minusculas_conectoras <- c("de", "del", "la", "las", "los", "y")
texto_titulo_es <- function(x) {
  x |>
    str_to_lower() |>
    str_split(" ") |>
    map_chr(function(palabras) {
      palabras <- str_to_title(palabras)
      idx <- which(str_to_lower(palabras) %in% minusculas_conectoras)
      idx <- setdiff(idx, 1)
      palabras[idx] <- str_to_lower(palabras[idx])
      paste(palabras, collapse = " ")
    })
}

# Necesitamos el nombre "bonito" de la entidad; lo tomamos de la base
# presidencial (que ya lo trae verificado contra el INE) si existe, y
# si no, del propio catálogo de mxDistritos.
archivo_entidad <- here("datos", "limpios", "presidencial_2024_entidad.csv")
if (file.exists(archivo_entidad)) {
  lookup_entidad <- read_csv(archivo_entidad, col_types = cols(.default = "c"), show_col_types = FALSE) |>
    select(clave_entidad, entidad)
} else {
  lookup_entidad <- dominante_nombre |>
    mutate(clave_entidad = str_pad(edon, 2, pad = "0")) |>
    distinct(clave_entidad) |>
    mutate(entidad = NA_character_)  # se llenaría a mano si no existe la otra base
}

d_puente <- dominante_nombre |>
  filter(!is.na(inegi), !is.na(ife)) |>
  mutate(
    clave_entidad = str_pad(edon, 2, pad = "0"),
    clave_municipio_inegi = str_pad(inegi, 5, pad = "0"),
    clave_municipio_ife = str_pad(ife, 5, pad = "0"),
    municipio = texto_titulo_es(mun)
  ) |>
  left_join(lookup_entidad, by = "clave_entidad") |>
  select(clave_entidad, entidad, clave_municipio_inegi, clave_municipio_ife, municipio) |>
  arrange(clave_entidad, clave_municipio_inegi)


# ---- 5. Verificación antes de guardar ----

stopifnot(
  sum(duplicated(d_puente$clave_municipio_inegi)) == 0,
  sum(duplicated(d_puente$clave_municipio_ife)) == 0,
  sum(is.na(d_puente$entidad)) == 0
)

cat(nrow(d_puente), "municipios en el puente.\n")
cat(sum(d_puente$clave_municipio_inegi != d_puente$clave_municipio_ife),
    "de esos municipios tienen clave INE distinta de su clave INEGI --",
    "ese es exactamente el problema que resuelve esta tabla.\n")


# ---- 6. Guardar ----

dir.create(here("datos", "limpios"), showWarnings = FALSE, recursive = TRUE)
write_csv(d_puente, here("datos", "limpios", "puente_claves_ine_inegi.csv"))
saveRDS(d_puente, here("datos", "limpios", "puente_claves_ine_inegi.rds"))


# ==============================================================
# En la sesión 4 vamos a unir una base electoral con este puente
# primero por NOMBRE de municipio, a propósito, para que falle.
# Antes de llegar a esa sesión: ¿cuántos nombres de municipio crees
# que se van a repetir en más de una entidad? Anota tu apuesta y
# compárala con lo que encuentres con count(municipio, sort = TRUE).
# ==============================================================
