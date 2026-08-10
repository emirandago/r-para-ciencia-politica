# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Preparación de datos · Latinobarómetro 2024, agregado por país
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Bajar la encuesta de opinión pública Latinobarómetro (ola 2024,
#   19,214 personas entrevistadas en 17 países) y resumirla en seis
#   indicadores de país que se puedan explicar en una línea: apoyo a
#   la democracia, satisfacción con la democracia, confianza
#   interpersonal, confianza en el gobierno, confianza en el poder
#   judicial y percepción de corrupción. El archivo original es una
#   base de personas (microdatos, 332 columnas); aquí la convertimos
#   en una base de países.
#
# Qué necesitas antes de empezar:
#   Nada de este repositorio: este script parte de la descarga directa
#   hasta el archivo limpio.
#
# Datos: Corporación Latinobarómetro, "Estudio Latinobarómetro 2024",
#        versión agregada v2024.1 (archivo Stata, v20250817), 18
#        países/territorios anunciados por el sitio -- 17 aparecen
#        efectivamente en el archivo Stata descargado, ver DECISIÓN
#        más abajo.
# Descargado el: 2026-08-05
# Autor: Emiliano Miranda González (script generado por el subagente de datos)
# ==============================================================

# install.packages("countrycode")   # para el nombre de país en español

library(tidyverse)
library(here)
library(janitor)
library(countrycode)
library(haven)
library(curl)


# ---- 1. Por qué descargamos el ZIP directo y no pedimos registro ----
#
# Se verificó en vivo, abriendo el sitio real (no de memoria): la
# página de datos de Latinobarómetro (latinobarometro.org/agregados y
# la página específica de la ola 2024) NO pide correo, ni contraseña,
# ni formulario antes de mostrar el enlace de descarga -- se comprobó
# leyendo el HTML de esas páginas y buscando "registr", "login",
# "formulario", ninguno aparece. Lo que SÍ exige el sitio, de forma
# explícita, es una política de uso (ver el bloque de licencia más
# abajo): investigación no comercial, docencia y publicaciones sí;
# redistribuir los datos en otro sitio, no.

url_lb <- "https://www.latinobarometro.org/documents/LAT-2024/latinobarometro-2024-stata-v20250817.zip"
ruta_lb <- here("datos", "crudos", "latinobarometro")
dir.create(ruta_lb, showWarnings = FALSE, recursive = TRUE)
zip_lb <- file.path(ruta_lb, "latinobarometro-2024-stata.zip")
archivo_dta <- file.path(ruta_lb, "Latinobarometro_2024_Stata_esp_v20250817.dta")

if (!file.exists(zip_lb)) curl_download(url_lb, zip_lb)
if (!file.exists(archivo_dta)) zip::unzip(zip_lb, exdir = ruta_lb)

# Es un archivo de Stata (.dta) con formato, no un CSV: usamos
# haven::read_dta(), que conserva las etiquetas de cada pregunta
# (attr(x, "label")) y de cada categoría de respuesta
# (attr(x, "labels")) -- las necesitamos para el paso 3.
d_lb_raw <- read_dta(archivo_dta)

cat("Microdatos crudos:", nrow(d_lb_raw), "personas entrevistadas,", ncol(d_lb_raw), "columnas.\n")


# ---- 2. Los 17 países que sí llegaron en el archivo ----
#
# DECISIÓN / [VERIFICAR]: la página de la ola 2024 en el sitio de
# Latinobarómetro anuncia "datos de 18 países/territorios", pero el
# archivo Stata que se descarga trae only 17 códigos distintos en
# IDENPA (la columna de país). Comparando la lista contra el universo
# habitual de 18 países de Latinobarómetro, el que falta es Nicaragua.
# No encontramos, dentro del propio archivo ni en la página pública,
# una nota que explique la ausencia -- es consistente con reportes
# periodísticos de que Nicaragua ha quedado fuera de mediciones
# recientes de organismos internacionales por restricciones del
# gobierno a la investigación de opinión pública en el país, pero esa
# explicación puntual no se verificó contra un documento oficial de
# Latinobarómetro. Se deja marcado [VERIFICAR] en datos/README.md.
cat("Países en el archivo:", length(unique(d_lb_raw$IDENPA)), "de los 18 que anuncia el sitio.\n")


# ---- 3. Elegir las preguntas y sus valores válidos ----
#
# El cuestionario tiene más de 300 preguntas. Elegimos seis, todas
# indicadores clásicos y muy citados de la propia Latinobarómetro,
# verificando el código exacto de la pregunta y las categorías de
# respuesta contra las etiquetas que trae el propio archivo (con
# attr(x, "label") y attr(x, "labels")) -- no es una paráfrasis de
# memoria del cuestionario:
#
#   P11STGBS -> apoyo a la democracia: "¿Con cuál de las siguientes
#     frases está usted más de acuerdo?" Contamos como apoyo SOLO la
#     categoría 1, "La democracia es preferible a cualquier otra forma
#     de gobierno" (las alternativas son que un gobierno autoritario
#     puede ser preferible, o que da lo mismo un régimen u otro).
#   P12STGBS.A -> satisfacción con la democracia: "¿Qué tan
#     satisfecho/a está con el funcionamiento de la democracia en
#     {país}?" Contamos como satisfecho las categorías 1 ("Muy
#     satisfecho") y 2 ("Más bien satisfecho"), frente a 3 y 4
#     ("No muy" / "Nada satisfecho").
#   P10STGBS -> confianza interpersonal: "¿Diría usted que se puede
#     confiar en la mayoría de las personas, o que uno nunca es lo
#     suficientemente cuidadoso...?" Categoría 1 = confía.
#   P14ST.E -> confianza en el gobierno: escala de 4 puntos ("Mucha",
#     "Algo", "Poca", "Ninguna" confianza). Contamos "mucha" + "algo"
#     (categorías 1-2) como confianza.
#   P14ST.F -> confianza en el poder judicial: misma escala y mismo
#     criterio (categorías 1-2) que la de gobierno.
#   P54N -> percepción de corrupción: "Pensando en {país}, en una
#     escala de 0 a 10, donde 0 es 'para nada corrupto' y 10 es
#     'totalmente corrupto', ¿qué tan corrupto/a cree usted que es
#     {país}?" Se deja como promedio simple de 0 a 10, NO como
#     porcentaje: MÁS alto significa MÁS corrupción percibida.
#
# DECISIÓN IMPORTANTE sobre ponderación: cada persona entrevistada
# trae un peso muestral en la columna WT (el diseño de Latinobarómetro
# no es una muestra autoponderada pura entre países ni siempre dentro
# de cada país). Calculamos los seis indicadores con
# stats::weighted.mean(..., w = WT), NO con mean() simple. Se comprobó
# que, para estos seis indicadores, la diferencia entre ponderar y no
# ponderar es pequeña (décimas de punto porcentual) salvo, ocasionalmente,
# para el promedio de percepción de corrupción -- pero ponderar es lo
# metodológicamente correcto siempre que el archivo trae un peso, así
# que no hay razón para no usarlo aquí, igual que no promediamos
# `participacion` directo en la sesión 1 sin ponderar por lista nominal.


# ---- 4. Construir la base agregada por país ----

c_latinobarometro_reciente <- d_lb_raw |>
  mutate(iso3 = countrycode(IDENPA, origin = "iso3n", destination = "iso3c")) |>
  group_by(iso3) |>
  summarise(
    n_encuestados = n(),
    apoyo_democracia_pct = round(100 * weighted.mean(P11STGBS == 1, w = WT, na.rm = TRUE), 1),
    satisfaccion_democracia_pct = round(100 * weighted.mean(`P12STGBS.A` %in% c(1, 2), w = WT, na.rm = TRUE), 1),
    confianza_interpersonal_pct = round(100 * weighted.mean(P10STGBS == 1, w = WT, na.rm = TRUE), 1),
    confianza_gobierno_pct = round(100 * weighted.mean(`P14ST.E` %in% c(1, 2), w = WT, na.rm = TRUE), 1),
    confianza_poder_judicial_pct = round(100 * weighted.mean(`P14ST.F` %in% c(1, 2), w = WT, na.rm = TRUE), 1),
    percepcion_corrupcion_prom = round(weighted.mean(P54N, w = WT, na.rm = TRUE), 2),
    .groups = "drop"
  ) |>
  mutate(pais = countrycode(iso3, origin = "iso3c", destination = "cldr.name.es"), .after = iso3) |>
  arrange(iso3)


# ---- 5. Verificación antes de guardar ----

cat("Filas:", nrow(c_latinobarometro_reciente), "| Columnas:", ncol(c_latinobarometro_reciente), "\n")
cat("Duplicados de iso3:", sum(duplicated(c_latinobarometro_reciente$iso3)), "\n")
cat("NA por columna:\n")
print(sapply(c_latinobarometro_reciente, function(x) sum(is.na(x))))

stopifnot(
  sum(duplicated(c_latinobarometro_reciente$iso3)) == 0,
  sum(is.na(c_latinobarometro_reciente)) == 0,
  all(c_latinobarometro_reciente |> select(ends_with("_pct")) |> unlist() |> between(0, 100)),
  all(c_latinobarometro_reciente$percepcion_corrupcion_prom >= 0 & c_latinobarometro_reciente$percepcion_corrupcion_prom <= 10)
)


# ---- 6. Guardar ----

dir.create(here("datos", "limpios"), showWarnings = FALSE, recursive = TRUE)
write_csv(c_latinobarometro_reciente, here("datos", "limpios", "latinobarometro_reciente.csv"))
saveRDS(c_latinobarometro_reciente, here("datos", "limpios", "latinobarometro_reciente.rds"))

cat("Peso CSV:", format(file.size(here("datos", "limpios", "latinobarometro_reciente.csv")) / 1024, digits = 4), "KB\n")


# ==============================================================
# Fíjate en algo: apoyo_democracia_pct y satisfaccion_democracia_pct
# miden cosas distintas -- una es si crees que la democracia es la
# mejor forma de gobierno EN ABSTRACTO, la otra es si estás contento
# con CÓMO FUNCIONA en tu país concretamente. ¿Hay países donde la
# gente apoya la democracia en principio pero está muy insatisfecha
# con cómo funciona en la práctica? Cruza esta base con
# vdem_americas.csv (filtrando a 2024) por iso3: ¿los países con mayor
# indice_democracia_liberal de V-Dem son también los que reportan más
# satisfaccion_democracia_pct aquí, o no necesariamente?
# ==============================================================
