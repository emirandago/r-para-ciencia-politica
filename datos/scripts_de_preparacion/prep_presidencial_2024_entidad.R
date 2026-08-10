# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Preparación de datos · Presidencial 2024, por entidad
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Bajar la Base de Datos de los Cómputos Distritales 2024 del INE
#   (voto por acta de casilla, a nivel nacional), sumar las dos
#   coaliciones y Movimiento Ciudadano, y agregar todo a las 32
#   entidades. Esta es la base que usamos desde la sesión 1.
#
# Qué necesitas antes de empezar:
#   Nada de este repositorio: este script parte de cero, desde la
#   URL pública del INE, hasta el archivo limpio.
#
# Datos: INE, Base de Datos de los Cómputos Distritales 2024,
#        elección de Presidencia, descargada de computos2024.ine.mx.
#        Corte de la descarga: 08/06/2024 20:30 (hora del centro),
#        el mismo corte que trae el archivo oficial.
# Descargado el: 2026-08-05
# Autor: Emiliano Miranda González (script generado por el subagente de datos)
# ==============================================================

# ---- 0. Paquetes ----
#
#   install.packages(c("tidyverse", "here", "janitor", "curl"))
#
library(tidyverse)
library(here)
library(janitor)
library(curl)

# ---- 1. De dónde sale el archivo ----
#
# El sitio de Cómputos 2024 del INE es una aplicación de una sola página
# (no hay un simple botón "click derecho, copiar liga"): el botón
# "Descargar" arma el nombre del archivo con la fecha y hora del último
# corte y lo pide a la raíz del dominio. Verificamos ese patrón abriendo
# el paquete de JavaScript del sitio y confirmando la URL con una
# descarga real. El nombre del corte más reciente disponible cuando
# construimos esta base fue el siguiente:

url_zip <- "https://computos2024.ine.mx/20240608_2030_COMPUTOS.zip"

ruta_crudos <- here("datos", "crudos", "computos2024")
dir.create(ruta_crudos, showWarnings = FALSE, recursive = TRUE)
zip_nacional <- file.path(ruta_crudos, "20240608_2030_COMPUTOS.zip")

# Si ya lo descargaste antes, no lo volvemos a bajar: nos ahorra
# tiempo y no le pega innecesariamente al servidor del INE.
if (!file.exists(zip_nacional)) {
  curl_download(url_zip, zip_nacional)
}

# El zip nacional trae, adentro, un zip por tipo de elección
# (presidencia, senadurías, diputaciones). Solo necesitamos el de
# presidencia.
unzip(zip_nacional, files = "20240608_2030_COMPUTOS_PRES.zip", exdir = ruta_crudos)
unzip(file.path(ruta_crudos, "20240608_2030_COMPUTOS_PRES.zip"), exdir = ruta_crudos)

# Si esto marca "cannot open the connection", casi seguro es que la URL
# ya cambió (el INE puede retirar cortes viejos). Repite el proceso de
# abrir computos2024.ine.mx, ir a "Presidencia > Base de Datos" y
# capturar la URL real del botón "Descargar" antes de seguir.


# ---- 2. Leer el archivo tal como lo entrega el INE ----
#
# PRES_2024.csv no es un CSV limpio de entrada: trae dos filas de
# encabezado, una fila de resumen nacional y una fila en blanco antes
# de que empiecen los datos por acta. Además usa "|" como separador
# (lo dice la primera línea, "sep=|") y está codificado en Latin-1
# (ISO-8859-1), no en UTF-8 -- lo confirmamos con
# readr::guess_encoding() antes de dar esto por sentado. Si lo lees
# como UTF-8 vas a ver nombres de entidad rotos, como "MXICO"
# en vez de "MÉXICO".

d_pres_raw <- read_delim(
  file.path(ruta_crudos, "PRES_2024.csv"),
  delim = "|",
  skip = 7,
  col_names = TRUE,
  col_types = cols(.default = "c"),
  locale = locale(encoding = "ISO-8859-1"),
  na = character()
)

# DECISIÓN: leemos TODAS las columnas como texto (col_types = "c") y
# convertimos a número nosotros mismos más abajo. Si dejamos que
# read_delim adivine el tipo de columna, confunde columnas como
# ID_ENTIDAD (que trae el valor envuelto como ="01" para forzar texto
# en Excel) y las vuelve NA.


# ---- 3. Limpiar las claves que el INE envuelve para Excel ----

# El INE escribe ="01" en vez de 01 en varias columnas (ID_ENTIDAD,
# SECCION, ID_CASILLA...) para que Excel no le quite los ceros a la
# izquierda. Nosotros no usamos Excel para esto, así que le quitamos
# ese envoltorio.
limpiar_excel_texto <- function(x) {
  x <- str_remove(x, '^="')
  x <- str_remove(x, '"$')
  x
}

d_pres <- d_pres_raw |>
  clean_names() |>
  mutate(
    id_entidad = limpiar_excel_texto(id_entidad),
    across(
      c(pan, pri, prd, pvem, pt, mc, morena, pan_pri_prd, pan_pri, pan_prd,
        pri_prd, pvem_pt_morena, pvem_pt, pvem_morena, pt_morena,
        candidato_a_no_registrado_a, votos_nulos, total_votos_calculados,
        lista_nominal),
      as.numeric
    )
  )


# ---- 4. Sumar las coaliciones ----
#
# En la boleta de 2024 compitieron dos coaliciones y un partido en
# solitario:
#   - Sigamos Haciendo Historia (SHH): Morena + PT + PVEM
#   - Fuerza y Corazón por México (FCM): PAN + PRI + PRD
#   - Movimiento Ciudadano (MC): fue solo
#
# El archivo del INE no trae una columna "votos de la coalición": trae
# una columna por cada combinación de logotipos que pudo marcar la
# persona que votó (un solo partido, o dos, o los tres). Sumamos los
# votos de Morena, PT y PVEM, más TODAS las combinaciones entre ellos,
# porque cualquiera de esas marcas es un voto válido para la candidata
# de la coalición. Si solo sumáramos la columna "MORENA" estaríamos
# subestimando muchísimo a la coalición: la mayoría de sus votos
# vienen marcados con más de un logotipo.
#
# DECISIÓN: la composición de las coaliciones está verificada contra
# el registro público de las coaliciones del proceso electoral federal
# 2023-2024 del INE, no inventada.

d_entidad <- d_pres |>
  group_by(id_entidad, entidad) |>
  summarise(
    lista_nominal = sum(lista_nominal, na.rm = TRUE),
    votos_shh = sum(morena, pt, pvem, pvem_pt_morena, pvem_pt, pvem_morena, pt_morena, na.rm = TRUE),
    votos_fcm = sum(pan, pri, prd, pan_pri_prd, pan_pri, pan_prd, pri_prd, na.rm = TRUE),
    votos_mc  = sum(mc, na.rm = TRUE),
    # DECISIÓN: "votos_otros" junta candidaturas no registradas y votos
    # nulos. No los repartimos entre las coaliciones porque no hay
    # ninguna base para decidir a quién "le tocarían".
    votos_otros = sum(candidato_a_no_registrado_a, votos_nulos, na.rm = TRUE),
    total_votos = sum(total_votos_calculados, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    participacion = round(100 * total_votos / lista_nominal, 4),
    pct_shh = round(100 * votos_shh / total_votos, 4),
    pct_fcm = round(100 * votos_fcm / total_votos, 4),
    pct_mc  = round(100 * votos_mc  / total_votos, 4)
  )

# Verifica: nrow(d_entidad) debe ser exactamente 32 (31 estados + CDMX).
# Si no, algo salió mal en el agrupamiento.
stopifnot(nrow(d_entidad) == 32)


# ---- 5. Nombres legibles ----
#
# El INE entrega los nombres de entidad en MAYÚSCULAS. Los pasamos a
# formato "Título" para que se lean mejor en una gráfica, cuidando que
# preposiciones y artículos cortos ("de", "la"...) no queden con
# mayúscula si no abren el nombre (para que "Ciudad de México" no
# salga "Ciudad De México").
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

d_entidad <- d_entidad |>
  mutate(entidad = texto_titulo_es(entidad)) |>
  rename(clave_entidad = id_entidad) |>
  arrange(clave_entidad) |>
  select(clave_entidad, entidad, lista_nominal, total_votos, participacion,
         votos_shh, votos_fcm, votos_mc, votos_otros, pct_shh, pct_fcm, pct_mc)


# ---- 6. Verificación antes de guardar ----
#
# Nunca guardes una base sin comprobar, aunque sea con lo básico, que
# no la arruinaste en el camino.

stopifnot(
  nrow(d_entidad) == 32,
  sum(duplicated(d_entidad$clave_entidad)) == 0,
  all(!is.na(d_entidad$entidad))
)

# El total nacional de votos por la coalición SHH que da esta base debe
# rondar el 59.8% (Claudia Sheinbaum) según la cobertura oficial del
# INE del proceso 2024. Lo dejamos como número, no como aserción dura,
# porque no vamos a re-verificar prensa desde un script.
cat("Participación nacional (promedio simple de las 32 entidades, ¡ojo que NO es la nacional real!):\n")
print(mean(d_entidad$participacion))

cat("\npct_shh nacional (con votos, no promedio de porcentajes):\n")
print(round(100 * sum(d_entidad$votos_shh) / sum(d_entidad$total_votos), 2))


# ---- 7. Guardar ----

dir.create(here("datos", "limpios"), showWarnings = FALSE, recursive = TRUE)
write_csv(d_entidad, here("datos", "limpios", "presidencial_2024_entidad.csv"))
saveRDS(d_entidad, here("datos", "limpios", "presidencial_2024_entidad.rds"))


# ==============================================================
# ¿Qué pasaría si, en vez de sumar TODAS las combinaciones de la
# coalición, solo sumaras la columna del partido ancla (MORENA o PAN)?
# Corre esa versión alternativa y compara qué tanto cambia pct_shh.
# ¿Esa diferencia te parece pequeña o enorme?
# ==============================================================
