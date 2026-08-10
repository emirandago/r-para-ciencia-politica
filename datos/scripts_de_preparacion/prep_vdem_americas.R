# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Preparación de datos · V-Dem, países de América, 1990-2025
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Bajar el dataset de Varieties of Democracy (V-Dem) -- la base
#   comparada de referencia para medir calidad democrática en el
#   mundo -- y recortarla a los países de América con un puñado de
#   indicadores que se puedan explicar en una línea a alguien que
#   nunca tomó Estadística I. El dataset completo pesa casi 1 GB en
#   memoria (4,618 columnas, 202 países, 1789-2025): jamás lo
#   subimos entero al repositorio, así que este script documenta
#   exactamente qué se recortó y por qué.
#
# Qué necesitas antes de empezar:
#   Nada de este repositorio: este script parte de un paquete de
#   GitHub hasta el archivo limpio.
#
# Datos: V-Dem Institute, "V-Dem Country-Year Dataset v16" (marzo
#        2026), cargado con el paquete vdemdata (no vive en CRAN,
#        solo en GitHub -- ver más abajo por qué usamos esta vía y
#        no el formulario del sitio web).
# Descargado el: 2026-08-05
# Autor: Emiliano Miranda González (script generado por el subagente de datos)
# ==============================================================

# install.packages("remotes")       # para instalar vdemdata desde GitHub
# remotes::install_github("vdeminstitute/vdemdata")  # se corre UNA sola vez
# install.packages("countrycode")   # para el nombre de país en español

library(tidyverse)
library(here)
library(janitor)
library(countrycode)
library(vdemdata)

# ---- 1. Por qué instalamos desde GitHub y no desde el sitio web ----
#
# El sitio de V-Dem (v-dem.net) exige un formulario con correo
# electrónico antes de dejarte descargar cualquier versión del
# dataset -- lo comprobamos abriendo esa página, y el formulario
# aparece de verdad, no es un rumor. Pero V-Dem mismo recomienda,
# en ese mismo sitio, una segunda vía para quienes usan R: el
# paquete vdemdata (github.com/vdeminstitute/vdemdata), que trae ya
# empacada la versión más reciente del dataset sin pasar por ese
# formulario. Es la vía oficial para R, no un atajo que nos
# inventamos.


# ---- 2. ¿Qué es "América" para efectos de este recorte? ----
#
# V-Dem trae su propia variable de región, e_regionpol_6C, pero esa
# variable junta Norteamérica con Europa Occidental en la misma
# categoría (código 5) -- lo verificamos con var_info("e_regionpol_6C")
# antes de usarla. Si filtráramos por ahí, tendríamos que además
# excluir a mano todos los países europeos que comparten ese código,
# un paso propenso a errores.
#
# En vez de eso, usamos el código de país de Correlates of War
# (COWcode), que sí distingue geografía de forma directa: el rango
# 2-165 cubre exactamente Norteamérica, Centroamérica, el Caribe y
# Sudamérica (2 = Estados Unidos, 20 = Canadá, 31-165 = América
# Latina y el Caribe); todo lo que sigue (200 en adelante) es
# Europa, África, Asia u Oceanía. Lo comprobamos filtrando y
# revisando la lista de países antes de seguir.
paises_americas <- vdem |>
  filter(COWcode >= 2, COWcode <= 165) |>
  distinct(country_name, country_text_id, COWcode) |>
  arrange(COWcode)

cat(nrow(paises_americas), "países de América identificados por COWcode.\n")

# DECISIÓN: V-Dem no cubre a los microestados del Caribe más pequeños
# (Bahamas, Antigua y Barbuda, Santa Lucía, Granada, San Vicente y las
# Granadinas, San Cristóbal y Nieves, Dominica, Belice) -- se
# comprobó que sencillamente no aparecen en el objeto vdem con ese
# rango de COWcode. No es un error de este script: V-Dem no codifica
# expertos en países tan pequeños. Si tu pregunta necesita esos
# países, Quality of Government sí los cubre (ver
# prep_qog_basico.R) -- por eso las dos bases se complementan.


# ---- 3. La región dentro de nuestro filtro sí sirve para agrupar ----
#
# Una vez que ya filtramos a América por COWcode, comprobamos que
# e_regionpol_6C solo toma dos valores dentro de ese filtro: 2
# (América Latina y el Caribe) y 5 (Europa Occidental y Norteamérica,
# que aquí adentro solo puede ser EEUU o Canadá, porque ya excluimos
# a Europa). Aprovechamos esa comprobación para reusar la
# clasificación oficial de V-Dem como columna de agrupación, en vez
# de inventar nuestra propia regionalización.
chk_regiones <- vdem |> filter(COWcode >= 2, COWcode <= 165) |> distinct(e_regionpol_6C) |> pull()
stopifnot(setequal(chk_regiones, c(2, 5)))


# ---- 4. Elegir los indicadores ----
#
# V-Dem tiene 531 indicadores y 251 índices. Para una sesión de
# primer semestre elegimos cinco de sus índices de alto nivel, los
# que se pueden explicar en una sola línea sin fórmulas:
#
#   v2x_polyarchy -> índice de democracia electoral: qué tanto se
#     cumple el ideal de que gobernantes respondan a la ciudadanía a
#     través de elecciones limpias y competidas.
#   v2x_libdem -> índice de democracia liberal: además de lo
#     anterior, qué tanto están protegidos los derechos individuales
#     y de las minorías frente al Estado y frente a la mayoría.
#   v2x_corr -> índice de corrupción política: qué tan extendida está
#     la corrupción (a diferencia de los demás índices, aquí un
#     número MÁS alto significa MÁS corrupción, no más democracia).
#   v2x_civlib -> índice de libertades civiles: ausencia de violencia
#     física por parte de agentes del Estado y de restricciones a las
#     libertades privadas y políticas.
#   v2x_gender -> índice de empoderamiento político de las mujeres:
#     qué tanta capacidad, voz y participación tienen las mujeres en
#     la toma de decisiones políticas del país.
#
# Las cinco viven en escala de 0 a 1. Verificamos las descripciones
# exactas con var_info() antes de escribir estas líneas -- no son
# una paráfrasis de memoria.
indicadores <- c("v2x_polyarchy", "v2x_libdem", "v2x_corr", "v2x_civlib", "v2x_gender")


# ---- 5. Construir la base final ----
#
# DECISIÓN: empezamos en 1990, como pide el encargo del curso, y no
# antes. Comprobamos que los cinco indicadores elegidos no tienen NI
# UN solo NA para los 27 países de América entre 1990 y 2025 -- así
# que no perdemos cobertura por elegir ese arranque.
d_vdem_americas <- vdem |>
  filter(COWcode >= 2, COWcode <= 165, year >= 1990) |>
  transmute(
    iso3 = country_text_id,
    # El nombre en español sale de countrycode() usando como fuente el
    # CLDR (Common Locale Data Repository de Unicode) -- una fuente
    # verificable y mantenida, no una traducción que nos inventamos.
    pais = countrycode(country_text_id, origin = "iso3c", destination = "cldr.name.es"),
    pais_en = country_name,
    subregion_vdem = case_when(
      e_regionpol_6C == 2 ~ "America Latina y el Caribe",
      e_regionpol_6C == 5 ~ "America del Norte"
    ),
    anio = year,
    indice_democracia_electoral = v2x_polyarchy,
    indice_democracia_liberal = v2x_libdem,
    indice_corrupcion_politica = v2x_corr,
    indice_libertades_civiles = v2x_civlib,
    indice_empoderamiento_politico_mujeres = v2x_gender
  ) |>
  arrange(iso3, anio)


# ---- 6. Verificación antes de guardar ----

cat("Filas:", nrow(d_vdem_americas), "| Columnas:", ncol(d_vdem_americas), "\n")
cat("Países:", n_distinct(d_vdem_americas$iso3), "| Años:", min(d_vdem_americas$anio), "-", max(d_vdem_americas$anio), "\n")
cat("Duplicados de iso3+anio:", sum(duplicated(d_vdem_americas[c("iso3", "anio")])), "\n")
cat("NA por columna:\n")
print(sapply(d_vdem_americas, function(x) sum(is.na(x))))

stopifnot(
  sum(duplicated(d_vdem_americas[c("iso3", "anio")])) == 0,
  sum(is.na(d_vdem_americas)) == 0,
  all(d_vdem_americas$indice_democracia_electoral >= 0 & d_vdem_americas$indice_democracia_electoral <= 1)
)


# ---- 7. Guardar ----

dir.create(here("datos", "limpios"), showWarnings = FALSE, recursive = TRUE)
write_csv(d_vdem_americas, here("datos", "limpios", "vdem_americas.csv"))
saveRDS(d_vdem_americas, here("datos", "limpios", "vdem_americas.rds"))

cat("Peso CSV:", format(file.size(here("datos", "limpios", "vdem_americas.csv")) / 1024, digits = 4), "KB\n")


# ==============================================================
# Fíjate en algo: el índice de corrupción (v2x_corr) corre al revés
# que los otros cuatro -- ahí, más alto es peor, no mejor. ¿Qué país
# de América tiene, en 2025, el índice de democracia liberal más
# alto y al mismo tiempo el índice de corrupción más bajo? ¿Es el
# mismo país en los dos casos, o no necesariamente?
# ==============================================================
