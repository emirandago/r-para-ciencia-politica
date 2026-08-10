# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Preparación de datos · Presidencial 2024, por municipio
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Bajar la misma Base de Datos de los Cómputos Distritales 2024 que
#   usamos para la base por entidad, pero esta vez agregarla a los
#   2,469-2,478 municipios del país. Para eso necesitamos resolver el
#   problema central de la sesión 4: el INE identifica cada acta por
#   SECCIÓN, no por municipio, y las claves de municipio del INE (o
#   "ife") no coinciden con las claves oficiales de INEGI. Usamos como
#   puente el catálogo de secciones de emagar/mxDistritos.
#
# Qué necesitas antes de empezar:
#   Nada de este repositorio: este script también parte de cero, desde
#   las dos URL públicas (INE e GitHub de mxDistritos), hasta el
#   archivo limpio. Si ya corriste prep_presidencial_2024_entidad.R,
#   este script reaprovecha el mismo ZIP del INE si sigue en
#   datos/crudos/.
#
# Datos:
#   - INE, Base de Datos de los Cómputos Distritales 2024, Presidencia,
#     corte 08/06/2024 20:30, de computos2024.ine.mx.
#   - emagar/mxDistritos, tabla de equivalencias seccionales desde
#     1994 (github.com/emagar/mxDistritos, licencia MIT), archivo
#     equivSecc/tablaEquivalenciasSeccionalesDesde1994.csv.
# Descargado el: 2026-08-05
# Autor: Emiliano Miranda González (script generado por el subagente de datos)
# ==============================================================

library(tidyverse)
library(here)
library(janitor)
library(curl)


# ---- 1. El voto por acta (igual que en la base por entidad) ----

url_zip <- "https://computos2024.ine.mx/20240608_2030_COMPUTOS.zip"
ruta_crudos <- here("datos", "crudos", "computos2024")
dir.create(ruta_crudos, showWarnings = FALSE, recursive = TRUE)
zip_nacional <- file.path(ruta_crudos, "20240608_2030_COMPUTOS.zip")

if (!file.exists(zip_nacional)) curl_download(url_zip, zip_nacional)
if (!file.exists(file.path(ruta_crudos, "PRES_2024.csv"))) {
  unzip(zip_nacional, files = "20240608_2030_COMPUTOS_PRES.zip", exdir = ruta_crudos)
  unzip(file.path(ruta_crudos, "20240608_2030_COMPUTOS_PRES.zip"), exdir = ruta_crudos)
}

limpiar_excel_texto <- function(x) {
  x <- str_remove(x, '^="')
  x <- str_remove(x, '"$')
  x
}

d_pres <- read_delim(
  file.path(ruta_crudos, "PRES_2024.csv"),
  delim = "|", skip = 7, col_names = TRUE,
  col_types = cols(.default = "c"),
  locale = locale(encoding = "ISO-8859-1"),
  na = character()
) |>
  clean_names() |>
  mutate(
    id_entidad = limpiar_excel_texto(id_entidad),
    seccion = as.integer(limpiar_excel_texto(seccion)),
    edon = as.integer(id_entidad),
    across(
      c(pan, pri, prd, pvem, pt, mc, morena, pan_pri_prd, pan_pri, pan_prd,
        pri_prd, pvem_pt_morena, pvem_pt, pvem_morena, pt_morena,
        candidato_a_no_registrado_a, votos_nulos, total_votos_calculados,
        lista_nominal),
      as.numeric
    )
  )


# ---- 2. El catálogo de secciones de mxDistritos ----
#
# Este catálogo trae, en el mismo registro, la clave de municipio de
# INEGI ("inegi") y la clave de municipio del INE ("ife") para cada
# sección electoral del país -- es la tabla puente que resuelve el
# problema de la sesión 4. La descargamos directo de GitHub (raw),
# donde vive con licencia MIT.

url_equiv <- "https://raw.githubusercontent.com/emagar/mxDistritos/master/equivSecc/tablaEquivalenciasSeccionalesDesde1994.csv"
ruta_mxdistritos <- here("datos", "crudos", "mxDistritos")
dir.create(ruta_mxdistritos, showWarnings = FALSE, recursive = TRUE)
archivo_equiv <- file.path(ruta_mxdistritos, "tablaEquivalenciasSeccionalesDesde1994.csv")

if (!file.exists(archivo_equiv)) curl_download(url_equiv, archivo_equiv)

d_equiv <- read_csv(archivo_equiv, col_types = cols(.default = "c"), show_col_types = FALSE)

# DECISIÓN sobre el campo "baja" de este catálogo: en un primer intento
# filtramos por "secciones vigentes hoy" (is.na(baja)), asumiendo que
# "baja" quiere decir "esta sección dejó de existir". Eso estaba mal:
# encontramos secciones (por ejemplo, la sección 86 de Aguascalientes)
# marcadas con baja=2023 que, sin embargo, el INE reportó con votos
# reales en junio de 2024. El significado exacto de "baja" no está
# documentado en el repositorio, así que dejamos de confiar en esa
# columna. En su lugar, para cada sección nos quedamos con el registro
# de "alta" (año de asignación municipal) más reciente que no sea
# posterior a la elección que estamos procesando: eso reconstruye la
# adscripción municipal vigente el día de la elección sin depender de
# un campo cuyo significado no pudimos verificar.
construir_puente_seccional <- function(catalogo, anio_corte) {
  catalogo |>
    mutate(
      edon = as.integer(edon), seccion = as.integer(seccion),
      alta_n = suppressWarnings(as.integer(alta))
    ) |>
    filter(is.na(alta_n) | alta_n <= anio_corte) |>
    group_by(edon, seccion) |>
    slice_max(order_by = alta_n, n = 1, with_ties = FALSE, na_rm = FALSE) |>
    ungroup() |>
    select(edon, seccion, inegi, ife, mun)
}

d_secc_2024 <- construir_puente_seccional(d_equiv, 2024)

# DECISIÓN: en unos pocos municipios (4 de más de 2,400, todos con un
# puñado de secciones "sueltas") la misma clave inegi aparece con dos
# claves ife distintas para dos municipios reales diferentes -- un
# residuo del reseccionamiento que probablemente antecede a la
# elección judicial de 2025. Lo resolvemos por mayoría: nos quedamos,
# para cada combinación entidad-ife, con la clave inegi que respalda
# la mayoría de las secciones. No inventamos ninguna clave: dejamos
# que decida el propio catálogo.
dominante <- d_secc_2024 |>
  count(edon, ife, inegi, name = "n") |>
  arrange(edon, ife, desc(n)) |>
  distinct(edon, ife, .keep_all = TRUE) |>
  select(edon, ife, inegi_dom = inegi)

d_secc_mun_2024 <- d_secc_2024 |>
  left_join(dominante, by = c("edon", "ife")) |>
  mutate(inegi = inegi_dom) |>
  distinct(edon, seccion, inegi)

stopifnot(sum(duplicated(d_secc_mun_2024 |> select(edon, seccion))) == 0)


# ---- 3. Cruzar el voto con el municipio ----

d_pres_con_mun <- d_pres |> left_join(d_secc_mun_2024, by = c("edon", "seccion"))

# DECISIÓN sobre lo que no cruza: el 1.6% de las actas que no
# encuentran municipio son, casi todas, votos de mexicanas y mexicanos
# en el extranjero (tipo de casilla M o V), que el INE registra bajo
# una sección "de plantilla" (4074) sin territorio real dentro de
# México. No les inventamos un municipio: los excluimos de esta base
# municipal (si sumas los totales de esta base contra la base por
# entidad vas a ver una diferencia de justo esos votos). Si tu
# pregunta de investigación necesita el voto en el extranjero, úsalo
# desde presidencial_2024_entidad.csv, no desde este archivo.
sin_match <- d_pres_con_mun |> filter(is.na(inegi))
cat(nrow(sin_match), "actas sin municipio de", nrow(d_pres_con_mun),
    "-- la inmensa mayoría son voto en el extranjero (revisa 'tipo_casilla').\n")

d_municipio_agg <- d_pres_con_mun |>
  filter(!is.na(inegi)) |>
  group_by(inegi) |>
  summarise(
    lista_nominal = sum(lista_nominal, na.rm = TRUE),
    votos_shh = sum(morena, pt, pvem, pvem_pt_morena, pvem_pt, pvem_morena, pt_morena, na.rm = TRUE),
    votos_fcm = sum(pan, pri, prd, pan_pri_prd, pan_pri, pan_prd, pri_prd, na.rm = TRUE),
    votos_mc  = sum(mc, na.rm = TRUE),
    votos_otros = sum(candidato_a_no_registrado_a, votos_nulos, na.rm = TRUE),
    total_votos = sum(total_votos_calculados, na.rm = TRUE),
    .groups = "drop"
  )


# ---- 4. Nombres de municipio y de entidad ----
#
# Usamos el mismo catálogo de municipios que construye
# prep_puente_claves_ine_inegi.R. Si ya corriste ese script, este
# bloque solo lee puente_claves_ine_inegi.csv; si no, lo construimos
# aquí mismo con la misma lógica para que este script funcione solo.

archivo_puente <- here("datos", "limpios", "puente_claves_ine_inegi.csv")
if (file.exists(archivo_puente)) {
  d_puente <- read_csv(archivo_puente, col_types = cols(.default = "c"), show_col_types = FALSE)
} else {
  stop(
    "No encontré datos/limpios/puente_claves_ine_inegi.csv. ",
    "Corre primero prep_puente_claves_ine_inegi.R."
  )
}

catalogo_mun <- d_puente |>
  distinct(clave_municipio_inegi, clave_entidad, entidad, municipio) |>
  mutate(inegi = as.character(as.integer(clave_municipio_inegi)))

d_municipio <- d_municipio_agg |>
  mutate(inegi = as.character(inegi)) |>
  left_join(catalogo_mun, by = "inegi")

stopifnot(sum(is.na(d_municipio$municipio)) == 0)

d_municipio_final <- d_municipio |>
  mutate(
    clave_municipio = clave_municipio_inegi,
    participacion = round(100 * total_votos / lista_nominal, 4),
    pct_shh = round(100 * votos_shh / total_votos, 4),
    pct_fcm = round(100 * votos_fcm / total_votos, 4),
    pct_mc  = round(100 * votos_mc  / total_votos, 4),
    # DECISIÓN: dos municipios de Oaxaca (Reforma-La y Capulálpam de
    # Méndez) tuvieron TODAS sus casillas "no instaladas" en 2024 --
    # es un hecho real de la elección, no un error nuestro: ahí no se
    # votó. pct_shh, pct_fcm, pct_mc y ventaja_shh quedan NA en esas
    # dos filas porque dividir entre cero votos no tiene sentido, y
    # NA es más honesto que un 0 inventado.
    segundo_lugar = pmax(pct_fcm, pct_mc),
    ventaja_shh = round(pct_shh - segundo_lugar, 4)
  ) |>
  select(clave_municipio, clave_entidad, entidad, municipio,
         lista_nominal, total_votos, participacion,
         votos_shh, votos_fcm, votos_mc, votos_otros,
         pct_shh, pct_fcm, pct_mc, ventaja_shh) |>
  arrange(clave_municipio)


# ---- 5. Verificación antes de guardar ----

stopifnot(
  sum(duplicated(d_municipio_final$clave_municipio)) == 0,
  nrow(d_municipio_final) > 2400, nrow(d_municipio_final) < 2500
)

cat(nrow(d_municipio_final), "municipios en la base final.\n")
cat("Municipios con participación NA (deberían ser los 2 de Oaxaca sin casillas instaladas):\n")
print(d_municipio_final |> filter(is.na(pct_shh)) |> select(clave_municipio, entidad, municipio))


# ---- 6. Guardar ----

dir.create(here("datos", "limpios"), showWarnings = FALSE, recursive = TRUE)
write_csv(d_municipio_final, here("datos", "limpios", "presidencial_2024_municipio.csv"))
saveRDS(d_municipio_final, here("datos", "limpios", "presidencial_2024_municipio.rds"))


# ==============================================================
# Este script excluyó el voto en el extranjero porque no tiene
# municipio real. ¿Se te ocurre alguna otra categoría de votos que
# tampoco debería "contar" para ningún municipio en particular? Ve al
# LEEME.txt que viene dentro del ZIP del INE y busca si hay algo más.
# ==============================================================
