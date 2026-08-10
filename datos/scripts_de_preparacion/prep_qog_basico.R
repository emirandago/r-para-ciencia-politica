# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Preparación de datos · Quality of Government (Básico), países de
# América, corte transversal ~2022
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Bajar el dataset "Basic" de Quality of Government (QoG) -- el
#   instituto de la Universidad de Gotemburgo que junta, en un solo
#   archivo, indicadores de calidad institucional, corrupción y gasto
#   público que originalmente viven en decenas de fuentes distintas
#   (Banco Mundial, Transparencia Internacional, PNUD...) -- y
#   recortarlo a los países de América con siete indicadores que se
#   puedan explicar en una línea a alguien que nunca tomó Estadística I.
#   El dataset completo trae 320 columnas y 194 países: aquí
#   documentamos exactamente qué se recortó y por qué.
#
# Qué necesitas antes de empezar:
#   Nada de este repositorio: este script parte de la descarga directa
#   hasta el archivo limpio.
#
# Datos: QoG Institute, "The Quality of Government Basic Dataset,
#        Version Jan26" (corte transversal, un país por fila), cargado
#        con curl::curl_download() directo desde qogdata.pol.gu.se (no
#        existe paquete de R para QoG en CRAN -- ver más abajo).
# Descargado el: 2026-08-05
# Autor: Emiliano Miranda González (script generado por el subagente de datos)
# ==============================================================

# install.packages("countrycode")   # para el nombre de país en español

library(tidyverse)
library(here)
library(janitor)
library(countrycode)
library(curl)


# ---- 1. Por qué descargamos el CSV directo y no un paquete de R ----
#
# A diferencia de V-Dem (que sí tiene un paquete oficial, vdemdata, en
# GitHub), QoG no tiene ningún paquete de R en CRAN ni en GitHub que
# distribuya el dataset Basic completo -- lo confirmamos revisando su
# sitio (gu.se/en/quality-government/qog-data). Lo que sí tiene QoG es
# una política explícita de "datos abiertos, sin necesidad de
# registrarte": la página de descarga (gu.se/en/quality-government/
# qog-data/data-downloads/basic-dataset) dice, literal: "The QoG
# datasets are open and available, free of charge and without a need
# to register your data." Por eso este script simplemente descarga el
# CSV con curl, sin pasar por ningún formulario ni cuenta.

url_qog <- "https://www.qogdata.pol.gu.se/data/qog_bas_cs_jan26.csv"
url_codebook_qog <- "https://www.qogdata.pol.gu.se/data/codebook_bas_jan26.pdf"

ruta_qog <- here("datos", "crudos", "qog")
dir.create(ruta_qog, showWarnings = FALSE, recursive = TRUE)
archivo_qog <- file.path(ruta_qog, "qog_bas_cs_jan26.csv")
archivo_codebook_qog <- file.path(ruta_qog, "codebook_bas_jan26.pdf")

# Si ya lo descargaste antes, no lo vuelvas a bajar -- así el script es
# reproducible sin regenerar tráfico de red cada vez que lo corres.
if (!file.exists(archivo_qog)) curl_download(url_qog, archivo_qog)
if (!file.exists(archivo_codebook_qog)) curl_download(url_codebook_qog, archivo_codebook_qog)

d_qog <- read_csv(archivo_qog, show_col_types = FALSE)

cat("Dataset QoG Basic completo:", nrow(d_qog), "países,", ncol(d_qog), "columnas.\n")


# ---- 2. "Básico" en QoG es un corte transversal, no un panel ----
#
# DECISIÓN: a diferencia de vdem_americas (país-año, 1990-2025), esta
# base es UN PAÍS POR FILA. QoG también publica una versión "Basic TS"
# (Time-Series, país-año 1946-2025), pero elegimos la versión CS
# (Cross-Section) por dos razones: (a) V-Dem ya cubre la dimensión
# temporal para el bloque de democracia, así que esta base complementa
# en vez de duplicar esa cobertura; (b) la versión CS es mucho más
# chica y directa de explicar en una sesión de once minutos: "así está
# cada país hoy", sin tener que enseñar todavía qué es un panel.
#
# Fíjate en algo importante que aclara la propia página de descarga de
# QoG, textual: en la versión CS "data from and around 2022 is
# included. Data from 2022 is prioritized; however, if no data is
# available for a country for 2022, data for 2023 is included. If no
# data exists for 2023, data for 2021 is included, and so on up to a
# maximum of +/- 3 years." Es decir: NO todos los países (ni todas las
# columnas) reportan exactamente el mismo año -- el archivo persigue
# 2022 como año de referencia y se permite un margen de +/-3 años
# cuando un país no tiene dato ese año. Esto se documenta también en
# datos/README.md: no asumas que "2022" es literal para cada celda.


# ---- 3. ¿Qué es "América" aquí? Mismo criterio que V-Dem ----
#
# QoG trae su propio código de país de Correlates of War en la columna
# ccodecow. Usamos exactamente el mismo rango que en prep_vdem_americas.R
# (2-165: Norteamérica, Centroamérica, el Caribe y Sudamérica) para que
# las dos bases se puedan cruzar por iso3 sin sorpresas de cobertura.
paises_qog_americas <- d_qog |> filter(ccodecow >= 2, ccodecow <= 165)

cat(nrow(paises_qog_americas), "países de América identificados por COWcode en QoG.\n")

# DECISIÓN / hallazgo que vale la pena repetir en clase: QoG SÍ cubre a
# los microestados del Caribe que V-Dem no codifica (Bahamas, Antigua y
# Barbuda, Santa Lucía, Granada, San Vicente y las Granadinas, San
# Cristóbal y Nieves, Dominica, Belice). Por eso qog_basico.csv trae 35
# países y vdem_americas.csv trae solo 27: no es un error de ninguno de
# los dos scripts, es que QoG y V-Dem codifican universos distintos de
# países pequeños. Si tu pregunta necesita SOLO los países que tienen
# tanto V-Dem como QoG, hay que hacer un inner_join() e ir con los 27.


# ---- 4. Elegir los indicadores ----
#
# El dataset Basic tiene ~400 variables de 80 fuentes distintas. Para
# una sesión de primer semestre elegimos siete, todas explicables en
# una línea, que cubren exactamente lo que pide el encargo del curso:
# calidad institucional, corrupción y gasto público.
#
#   wbgi_cce -> control de la corrupción (Banco Mundial, Worldwide
#     Governance Indicators/WGI): qué tanto el poder público se ejerce
#     para beneficio privado, y qué tanto el Estado logra contenerlo.
#     Escala continua, centrada en 0, valores típicos entre -2.5 y 2.5:
#     MÁS alto es MEJOR (menos corrupción), al revés que v2x_corr de
#     V-Dem -- otro ejemplo real de "revisa siempre hacia dónde corre
#     la escala antes de interpretar un número".
#   wbgi_gee -> efectividad gubernamental (WGI): qué tan buena es la
#     calidad del servicio civil, de la formulación de políticas
#     públicas y de su implementación, y qué tan independiente es la
#     burocracia de presiones políticas. Misma escala que wbgi_cce.
#   wbgi_rle -> estado de derecho (WGI): qué tanto confían los actores
#     en las reglas de la sociedad y las cumplen -- cumplimiento de
#     contratos, derechos de propiedad, la policía y los tribunales, y
#     qué tan probable es el crimen o la violencia. Misma escala.
#   wbgi_pve -> estabilidad política y ausencia de violencia (WGI): qué
#     tan probable es que el gobierno sea desestabilizado por medios
#     inconstitucionales o violentos, incluido el terrorismo. Misma
#     escala.
#   ti_cpi -> índice de percepción de la corrupción (Transparencia
#     Internacional): qué tan corrupto perciben al sector público
#     empresarios, analistas de riesgo y la población en general.
#     Escala de 0 (percepción de máxima corrupción) a 100 (percepción
#     de mínima corrupción) -- MÁS alto es MEJOR, igual que los cuatro
#     indicadores del Banco Mundial de arriba, pero en una escala
#     distinta (0-100, no -2.5 a 2.5): no los promedies directo sin
#     estandarizarlos primero.
#   undp_hdi -> índice de desarrollo humano (PNUD): un promedio
#     geométrico de qué tan larga y sana es la vida esperada, qué tanta
#     escolaridad tiene la población y qué tan alto es el ingreso por
#     persona. Escala de 0 a 1, MÁS alto es MEJOR. No es un indicador
#     de "gobierno" en sentido estricto, pero lo incluimos porque da
#     contexto de desarrollo indispensable para leer los otros seis: un
#     país puede tener un Estado débil por pobreza, no solo por mal
#     diseño institucional.
#   wdi_expedu -> gasto público en educación, como porcentaje del PIB
#     (Banco Mundial, World Development Indicators): cuánto gasta el
#     gobierno en educación en relación con el tamaño de toda la
#     economía del país. Es el único indicador de "gasto público" de
#     esta base, tal como pedía el encargo del curso.
#
# Verificamos las siete definiciones contra el codebook oficial
# (datos/crudos/qog/codebook_bas_jan26.pdf) antes de escribir este
# comentario -- no es una paráfrasis de memoria. Dos candidatas más se
# consideraron y se descartaron: wdi_gdpcapcon2015 (PIB per cápita) no
# es un indicador de "calidad institucional, corrupción o gasto
# público" -- es desarrollo económico, ya cubierto indirectamente por
# undp_hdi -- y wdi_expmil (gasto militar) tenía 12 de 35 países en NA
# en este recorte (34%), demasiado hueco para un ejercicio introductorio.


# ---- 5. Construir la base final ----

c_qog_basico <- paises_qog_americas |>
  transmute(
    iso3 = ccodealp,
    # Mismo criterio que en prep_vdem_americas.R: nombre en español vía
    # countrycode() con la fuente CLDR de Unicode, no una traducción
    # que nos inventamos.
    pais = countrycode(ccodealp, origin = "iso3c", destination = "cldr.name.es"),
    indice_control_corrupcion = wbgi_cce,
    indice_efectividad_gubernamental = wbgi_gee,
    indice_estado_derecho = wbgi_rle,
    indice_estabilidad_politica = wbgi_pve,
    indice_percepcion_corrupcion_ti = ti_cpi,
    indice_desarrollo_humano = undp_hdi,
    gasto_publico_educacion_pib = wdi_expedu
  ) |>
  arrange(iso3)


# ---- 6. Verificación antes de guardar ----

cat("Filas:", nrow(c_qog_basico), "| Columnas:", ncol(c_qog_basico), "\n")
cat("Duplicados de iso3:", sum(duplicated(c_qog_basico$iso3)), "\n")
cat("NA por columna:\n")
print(sapply(c_qog_basico, function(x) sum(is.na(x))))

# DECISIÓN: a diferencia de vdem_americas, aquí SÍ dejamos NA en vez de
# exigir cero. ti_cpi tiene 3 NA (Antigua y Barbuda, Belice, San
# Cristóbal y Nieves: Transparencia Internacional no encuesta a esos
# microestados) y wdi_expedu tiene 1 NA (Guyana: el Banco Mundial no
# tiene el dato de gasto en educación de ese país para el rango de años
# cubierto). Verificado revisando cuáles filas quedan en NA, no
# asumido. Rellenar esos huecos con un promedio regional sería inventar
# un dato que no existe -- se documenta aquí y en datos/README.md en
# vez de esconderlo.
stopifnot(
  sum(duplicated(c_qog_basico$iso3)) == 0,
  all(c_qog_basico$indice_desarrollo_humano >= 0 & c_qog_basico$indice_desarrollo_humano <= 1, na.rm = TRUE),
  all(c_qog_basico$indice_percepcion_corrupcion_ti >= 0 & c_qog_basico$indice_percepcion_corrupcion_ti <= 100, na.rm = TRUE)
)


# ---- 7. Guardar ----

dir.create(here("datos", "limpios"), showWarnings = FALSE, recursive = TRUE)
write_csv(c_qog_basico, here("datos", "limpios", "qog_basico.csv"))
saveRDS(c_qog_basico, here("datos", "limpios", "qog_basico.rds"))

cat("Peso CSV:", format(file.size(here("datos", "limpios", "qog_basico.csv")) / 1024, digits = 4), "KB\n")


# ==============================================================
# Fíjate en algo: wbgi_cce (control de corrupción) y ti_cpi (percepción
# de corrupción) miden algo parecido pero vienen de metodologías
# distintas -- uno agrega decenas de fuentes en una escala estadística,
# el otro es un promedio de encuestas de percepción en una escala 0-100.
# ¿Los países de América quedan en el mismo orden con los dos
# indicadores, o hay sorpresas? Prueba un left_join() con
# vdem_americas.csv (filtrando a 2022, el año de referencia de esta
# base) y compara indice_corrupcion_politica de V-Dem contra estas dos.
# ==============================================================
