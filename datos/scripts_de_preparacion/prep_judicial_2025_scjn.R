# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Preparación de datos · Elección judicial 2025, SCJN, por municipio
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Bajar la Base de Datos de los Cómputos Distritales Judiciales 2025
#   para la Suprema Corte, agregar el voto de cada candidatura a nivel
#   municipio, y dejarlo en FORMATO LARGO (una fila por municipio y
#   por candidatura). A propósito NO construimos aquí ninguna columna
#   de "bloque morenista": qué candidaturas cuentan como abiertamente
#   afines a Morena es una decisión de codificación que le toca a EMG,
#   con su fuente hemerográfica caso por caso (ver proyecto final,
#   sección 3). Lo que este script entrega es la materia prima ya
#   verificada para que esa codificación se pueda aplicar después con
#   un simple filter() + group_by() sobre no_candidato.
#
# Qué necesitas antes de empezar:
#   Haber corrido prep_puente_claves_ine_inegi.R al menos una vez (o
#   este script lo reconstruye solo si no encuentra el archivo).
#
# Datos: INE, Base de Datos de los Cómputos Distritales Judiciales
#        2025, cargo "Ministra/o de la Suprema Corte de Justicia de la
#        Nación", corte 09/06/2025 20:50 (hora del centro), de
#        computospj2025.ine.mx/base-datos.
# Descargado el: 2026-08-05
# Autor: Emiliano Miranda González (script generado por el subagente de datos)
# ==============================================================

library(tidyverse)
library(here)
library(janitor)
library(curl)
library(zip)

# ---- 1. Descargar la base de la SCJN ----
#
# Igual que en computos2024.ine.mx, este portal es una aplicación de
# una sola página: no hay una URL de descarga visible sin abrir el
# paquete de JavaScript del sitio o inspeccionar la red del navegador
# mientras se usa el botón "Descargar". La URL real que encontramos
# así fue esta (el nombre del archivo trae la fecha y hora del último
# corte publicado, que fue también el corte final: 84,266 de 84,266
# actas, 100% computadas):

url_zip <- "https://computospj2025.ine.mx/assets/20250609_2050_COMPUTOS.zip"
ruta_crudos <- here("datos", "crudos", "computospj2025")
dir.create(ruta_crudos, showWarnings = FALSE, recursive = TRUE)
zip_pj <- file.path(ruta_crudos, "20250609_2050_COMPUTOS.zip")

if (!file.exists(zip_pj)) curl_download(url_zip, zip_pj)

# El zip nacional trae, adentro, un zip por cargo (Suprema Corte,
# Tribunal de Disciplina Judicial, Sala Superior y Salas Regionales
# del TEPJF, Tribunales Colegiados, Juzgados de Distrito). Usamos
# zip::unzip() en vez de la función base porque maneja mejor los
# nombres de archivo de este ZIP.
if (!file.exists(file.path(ruta_crudos, "MIN_2025.csv"))) {
  zip::unzip(zip_pj, files = "20250609_2050_SCJN.zip", exdir = ruta_crudos)
  zip::unzip(file.path(ruta_crudos, "20250609_2050_SCJN.zip"), exdir = ruta_crudos)
}


# ---- 2. Leer los resultados por acta ----
#
# A diferencia de PRES_2024.csv (que está en Latin-1), este archivo sí
# está en UTF-8 -- lo confirmamos con readr::guess_encoding() antes de
# suponerlo. No asumas que todos los archivos del INE comparten
# codificación solo porque vienen del mismo instituto.

d_min_raw <- read_csv(
  file.path(ruta_crudos, "MIN_2025.csv"),
  skip = 6,
  col_types = cols(.default = "c"),
  locale = locale(encoding = "UTF-8")
)

d_min <- d_min_raw |> clean_names()
cand_cols <- names(d_min)[str_detect(names(d_min), "^cand\\d+$")]

d_min <- d_min |>
  mutate(
    edon = as.integer(id_entidad),
    seccion = as.integer(seccion),
    across(all_of(c(cand_cols, "votos_nulos", "recuadros_no_utilizados",
                     "total_votos_casilla", "numero_personas_votaron",
                     "lista_nominal_casilla")),
           as.numeric)
  )

stopifnot(nrow(d_min) == 84266)  # ACTAS_ESPERADAS del corte que descargamos


# ---- 3. Verificación (a): ¿el distrito judicial es el distrito electoral de 2024? ----
#
# El archivo trae, en el mismo registro, DOS geografías distintas:
# DISTRITO_JUDICIAL_ELECTORAL (propia de esta elección, creada por
# acuerdo del Consejo General del INE, DOF 22/ene/2025) e
# ID_DISTRITO_FEDERAL (el distrito electoral ordinario, el mismo que
# usa PRES_2024.csv). Lo comprobamos en vez de asumirlo:
comparacion_distritos <- mean(d_min$distrito_judicial_electoral == d_min$id_distrito_federal, na.rm = TRUE)
n_distritos_judiciales <- d_min |> distinct(edon, distrito_judicial_electoral) |> nrow()
n_distritos_federales  <- d_min |> distinct(edon, id_distrito_federal) |> nrow()

cat("Coincidencia numérica distrito judicial vs. distrito federal:",
    round(100 * comparacion_distritos, 1), "% de las actas\n")
cat("Distritos judiciales distintos:", n_distritos_judiciales,
    "| Distritos electorales federales distintos:", n_distritos_federales, "\n")

# RESULTADO (verificado en la descarga del 2026-08-05): coinciden en
# apenas ~11% de las actas, y hay 93 distritos judiciales contra 300
# distritos electorales federales. NO son la misma geografía. Por eso
# este script cruza por SECCIÓN, no por distrito, tal como anticipaba
# el reconocimiento de la ola 1 (reconocimiento/17d_datos.md).
stopifnot(comparacion_distritos < 0.5)  # si esto llega a fallar, la geografía cambió: revisa antes de seguir


# ---- 4. Verificación (b) y (c): cómo se cuentan las boletas y la participación ----
#
# La Suprema Corte elige 9 cargos, así que cada boleta tenía 9
# recuadros. Si alguien marcó menos de 9 candidaturas, los recuadros
# que dejó en blanco NO se descuentan de nadie ni se tratan como
# "boleta anulada": se cuentan aparte, en RECUADROS_NO_UTILIZADOS.
# Comprobamos la identidad contable que sostiene esto:
chk_contable <- d_min |> summarise(
  suma_candidaturas = sum(across(all_of(cand_cols)), na.rm = TRUE),
  nulos = sum(votos_nulos, na.rm = TRUE),
  no_utilizados = sum(recuadros_no_utilizados, na.rm = TRUE),
  total_votos_casilla = sum(total_votos_casilla, na.rm = TRUE),
  personas = sum(numero_personas_votaron, na.rm = TRUE)
)
diferencia <- with(chk_contable, suma_candidaturas + nulos + no_utilizados - total_votos_casilla)
cat("Suma candidaturas + nulos + no utilizados - total_votos_casilla =", diferencia, "(debe ser 0)\n")
cat("Votos por boleta en promedio (total_votos_casilla / personas):",
    round(chk_contable$total_votos_casilla / chk_contable$personas, 3), "(esperado: 9, una marca posible por cargo)\n")
stopifnot(diferencia == 0)

# CONCLUSIÓN, para el codebook: el denominador correcto de
# "participación" es NUMERO_PERSONAS_VOTARON (personas, boletas), NUNCA
# la suma de votos por candidatura ni TOTAL_VOTOS_CASILLA (que cuenta
# marcas, hasta 9 por persona). Por eso participacion_judicial, en
# esta base, se calcula como personas_votaron_2025 / lista_nominal_2025,
# exactamente como lo documenta el propio LEEME.txt del INE en su
# fórmula de PORCENTAJE_PARTICIPACION_CIUDADANA.
cat("Participación nacional recalculada desde el detalle por acta:",
    round(100 * chk_contable$personas / sum(d_min$lista_nominal_casilla, na.rm = TRUE), 4), "%\n")
# RESULTADO verificado: 13.0184%, IDÉNTICO al que reporta el resumen
# oficial del propio archivo y al que muestra en vivo el sitio del
# INE (computospj2025.ine.mx) bajo "Participación ciudadana". Esta es
# la cifra final y puntual que reemplaza al rango 12.57%-13.32% que
# el INE dio la noche de la jornada (comunicado 192) y a la cifra de
# 12.86% que circuló en prensa sin fuente primaria confirmada.


# ---- 5. Cruzar con municipio (usando la misma tabla puente) ----

archivo_puente <- here("datos", "limpios", "puente_claves_ine_inegi.csv")
if (!file.exists(archivo_puente)) {
  stop("No encontré datos/limpios/puente_claves_ine_inegi.csv. Corre primero prep_puente_claves_ine_inegi.R.")
}
d_puente <- read_csv(archivo_puente, col_types = cols(.default = "c"), show_col_types = FALSE)

# Reconstruimos el catálogo de secciones con el mismo criterio
# temporal que usamos para 2024, pero con corte en 2025: para cada
# sección, el registro de "alta" más reciente que no sea posterior a
# esta elección. Ver prep_puente_claves_ine_inegi.R para la discusión
# completa de por qué no usamos la columna "baja".
url_equiv <- "https://raw.githubusercontent.com/emagar/mxDistritos/master/equivSecc/tablaEquivalenciasSeccionalesDesde1994.csv"
ruta_mxdistritos <- here("datos", "crudos", "mxDistritos")
dir.create(ruta_mxdistritos, showWarnings = FALSE, recursive = TRUE)
archivo_equiv <- file.path(ruta_mxdistritos, "tablaEquivalenciasSeccionalesDesde1994.csv")
if (!file.exists(archivo_equiv)) curl_download(url_equiv, archivo_equiv)
d_equiv <- read_csv(archivo_equiv, col_types = cols(.default = "c"), show_col_types = FALSE)

d_secc_2025 <- d_equiv |>
  mutate(edon = as.integer(edon), seccion = as.integer(seccion),
         alta_n = suppressWarnings(as.integer(alta))) |>
  filter(is.na(alta_n) | alta_n <= 2025) |>
  group_by(edon, seccion) |>
  slice_max(order_by = alta_n, n = 1, with_ties = FALSE, na_rm = FALSE) |>
  ungroup() |>
  select(edon, seccion, inegi, ife)

dominante_2025 <- d_secc_2025 |>
  count(edon, ife, inegi, name = "n") |>
  arrange(edon, ife, desc(n)) |>
  distinct(edon, ife, .keep_all = TRUE) |>
  select(edon, ife, inegi_dom = inegi)

d_secc_mun_2025 <- d_secc_2025 |>
  left_join(dominante_2025, by = c("edon", "ife")) |>
  mutate(inegi = inegi_dom) |>
  distinct(edon, seccion, inegi)

d_min_mun <- d_min |> left_join(d_secc_mun_2025, by = c("edon", "seccion"))

# DECISIÓN: las actas sin municipio son, en esta elección, casi todas
# de "voto anticipado" (tipo de casilla "A"), que el INE registra bajo
# SECCION = 0 -- un valor de plantilla sin territorio real, repetido
# en las 32 entidades. Representan apenas 0.04% de la participación
# nacional (5,041 de 12,965,574 personas). Las excluimos de la base
# municipal por la misma razón que excluimos el voto en el extranjero
# de la base presidencial 2024: no tienen un municipio real al cual
# asignarse.
sin_match <- d_min_mun |> filter(is.na(inegi))
cat(nrow(sin_match), "actas sin municipio (deberían ser, casi todas, voto anticipado con seccion = 0).\n")
stopifnot(all(sin_match$tipo_casilla_seccional == "A" | sin_match$seccion == 0))

d_min_mun_ok <- d_min_mun |> filter(!is.na(inegi))


# ---- 6. Agregar a municipio, en formato largo por candidatura ----

d_mun_totales <- d_min_mun_ok |>
  group_by(inegi) |>
  summarise(
    lista_nominal_2025 = sum(lista_nominal_casilla, na.rm = TRUE),
    personas_votaron_2025 = sum(numero_personas_votaron, na.rm = TRUE),
    votos_nulos_2025 = sum(votos_nulos, na.rm = TRUE),
    recuadros_no_utilizados_2025 = sum(recuadros_no_utilizados, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(participacion_judicial = round(100 * personas_votaron_2025 / lista_nominal_2025, 4))

d_mun_cand <- d_min_mun_ok |>
  group_by(inegi) |>
  summarise(across(all_of(cand_cols), \(x) sum(x, na.rm = TRUE)), .groups = "drop") |>
  pivot_longer(cols = all_of(cand_cols), names_to = "no_candidato", values_to = "votos") |>
  mutate(no_candidato = str_to_upper(no_candidato))

# El catálogo de candidaturas sí trae acentos y sí está en UTF-8
# (lo volvemos a verificar aquí, porque MIN_2025.csv y
# MIN_CANDIDATURAS_2025.csv no comparten codificación con las demás
# bases del INE que usamos en el curso).
d_cand <- read_csv(
  file.path(ruta_crudos, "MIN_CANDIDATURAS_2025.csv"),
  col_types = cols(.default = "c"),
  locale = locale(encoding = "UTF-8")
) |>
  clean_names() |>
  mutate(
    no_candidato = str_to_upper(no_candidato),
    nombre_candidato = str_trim(nombre_candidato),
    genero = str_trim(genero),
    estatus_cancelado = str_trim(estatus_cancelado)
  ) |>
  select(no_candidato, nombre_candidato, genero, poder_postulante, estatus_cancelado)

catalogo_mun <- d_puente |>
  distinct(clave_municipio_inegi, clave_entidad, entidad, municipio) |>
  mutate(inegi = as.character(as.integer(clave_municipio_inegi)))

d_judicial_final <- d_mun_cand |>
  left_join(d_cand, by = "no_candidato") |>
  left_join(d_mun_totales, by = "inegi") |>
  left_join(catalogo_mun, by = "inegi") |>
  mutate(clave_municipio = clave_municipio_inegi) |>
  select(
    clave_municipio, clave_entidad, entidad, municipio,
    lista_nominal_2025, personas_votaron_2025, participacion_judicial,
    no_candidato, nombre_candidato, genero, poder_postulante, estatus_cancelado,
    votos,
    votos_nulos_2025, recuadros_no_utilizados_2025
  ) |>
  arrange(clave_municipio, no_candidato)


# ---- 7. Verificación antes de guardar ----

stopifnot(
  sum(is.na(d_judicial_final$municipio)) == 0,
  sum(is.na(d_judicial_final$votos)) == 0
)

# Reproducimos, sumando esta base municipal, el top de votación
# nacional -- debe coincidir con las 9 personas que la cobertura
# periodística reporta como electas a la Corte (verificación cruzada
# de la lista de electos contra el propio dato primario, no contra
# prensa).
top_nacional <- d_judicial_final |>
  group_by(nombre_candidato) |>
  summarise(votos_nacionales = sum(votos), .groups = "drop") |>
  arrange(desc(votos_nacionales))

cat("Top 9 nacional por votos (debe coincidir con las 9 ministras/os electos):\n")
print(head(top_nacional, 9))


# ---- 8. Guardar ----

dir.create(here("datos", "limpios"), showWarnings = FALSE, recursive = TRUE)
write_csv(d_judicial_final, here("datos", "limpios", "judicial_2025_scjn_municipio.csv"))
saveRDS(d_judicial_final, here("datos", "limpios", "judicial_2025_scjn_municipio.rds"))


# ==============================================================
# Este archivo queda EN FORMATO LARGO a propósito: cada fila es un
# municipio y una candidatura, no un municipio con una sola columna
# de "votos morenistas". Cuando definas tu criterio de codificación
# (ver proyecto final, sección 3), lo que sigue es:
#
#   candidaturas_bloque_a <- c("NO_CANDIDATO_1", "NO_CANDIDATO_2", ...)
#   d_bloque_a <- d_judicial_final |>
#     filter(no_candidato %in% candidaturas_bloque_a) |>
#     group_by(clave_municipio) |>
#     summarise(votos_bloque_a = sum(votos))
#
# ¿Qué crees que va a pasar con el resultado si tu criterio de
# codificación es un poco más generoso o un poco más restrictivo?
# Esa pregunta es, literalmente, el corazón del proyecto final.
# ==============================================================
