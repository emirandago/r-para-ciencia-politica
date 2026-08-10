# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 4 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Si llegaste aquí sin haber peleado con el ejercicio, regrésate: la
# solución solo enseña algo a quien ya se atoró.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)
library(fixest)

presidencial_2024 <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv")) |>
  select(clave_municipio, entidad, municipio, participacion)

judicial_2025 <- read_csv(here("datos", "limpios", "judicial_2025_scjn_municipio.csv")) |>
  distinct(clave_municipio, .keep_all = TRUE) |>
  select(clave_municipio, participacion_judicial)

panel_largo <- presidencial_2024 |>
  inner_join(judicial_2025, by = "clave_municipio") |>
  rename(participacion_2024 = participacion) |>
  pivot_longer(
    cols      = c(participacion_2024, participacion_judicial),
    names_to  = "eleccion",
    values_to = "participacion_pct"
  ) |>
  mutate(
    anio    = if_else(eleccion == "participacion_2024", 2024, 2025),
    es_2025 = as.numeric(anio == 2025)
  )


# ---- Nivel 1 · Calentamiento ----

panel_noroeste <- panel_largo |>
  filter(entidad %in% c("Baja California", "Baja California Sur", "Chihuahua",
                          "Durango", "Sinaloa", "Sonora"))

media_noroeste <- panel_noroeste |>
  group_by(clave_municipio) |>
  summarise(media = mean(participacion_pct))

sd_between_noroeste <- sd(media_noroeste$media)

panel_noroeste_within <- panel_noroeste |>
  group_by(clave_municipio) |>
  mutate(desviacion = participacion_pct - mean(participacion_pct)) |>
  ungroup()

sd_within_noroeste <- sd(panel_noroeste_within$desviacion)

sd_between_noroeste   # alrededor de 6.7
sd_within_noroeste    # alrededor de 23.7
sd_within_noroeste / sd_between_noroeste   # alrededor de 3.6

# La razón within/between de Noroeste (cerca de 3.6) es un poco más
# alta que la del país completo. La anticipación correcta era que el
# tamaño de población de la región no tenía por qué predecir nada
# aquí: lo que domina el resultado es qué tan PAREJO fue el colapso de
# participación entre los municipios de la región, y ese colapso fue,
# otra vez, un fenómeno nacional que golpeó a Noroeste casi tan parejo
# como al resto del país.


# ---- Nivel 2 · De verdad ----

# (a)

por_entidad <- panel_largo |>
  group_by(entidad) |>
  summarise(
    participacion_2024      = mean(participacion_pct[anio == 2024]),
    participacion_judicial  = mean(participacion_pct[anio == 2025]),
    diferencia               = participacion_judicial - participacion_2024
  )

# (b)

por_entidad |> arrange(diferencia) |> tail(3)    # las caídas MÁS CHICAS (menos negativas)
por_entidad |> arrange(diferencia) |> head(3)    # las caídas MÁS GRANDES (más negativas)

# La caída más CHICA, entre las 32 entidades, es Durango (alrededor de
# -28.5 puntos). Las caídas más GRANDES son Yucatán (alrededor de
# -66.1 puntos), Tlaxcala (alrededor de -57.6) y Sonora (alrededor de
# -56.3).

# (c) La interpretación.
#
# Yucatán es, precisamente, una de las tres entidades con la mayor
# participación en la elección presidencial de 2024 (por encima de
# 65%, ver el extra 1 de este laboratorio, donde apareció en la
# intersección de "alto pct_shh" y "alta participación"). Una entidad
# que salió a votar mucho en 2024 tenía, aritméticamente, más terreno
# que perder en 2025 si el interés colapsó de forma pareja: no es que
# Yucatán se haya "desinteresado más" que el resto del país en
# términos relativos, es que partía de un nivel más alto. Esta es una
# hipótesis razonable y verificable con estas mismas herramientas —
# compara la RAZÓN participacion_judicial / participacion_2024 en vez
# de la diferencia absoluta, y fíjate si el orden de las entidades
# cambia—; no es la única hipótesis posible, y una politóloga
# cuidadosa probaría varias antes de quedarse con una.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a)

modelo_dos_fe <- feols(
  participacion_pct ~ 1 | clave_municipio + anio,
  data = panel_largo
)

summary(modelo_dos_fe)

# Un modelo sin ninguna variable explicativa a la derecha del ~ no
# tiene ningún coeficiente que reportar en la tabla de resultados: no
# hay "efecto de X sobre Y" que estimar, porque no hay X. Lo que SÍ
# hace un modelo así es descomponer completamente participacion_pct en
# tres piezas: lo que es constante de cada municipio (el efecto fijo
# de clave_municipio), lo que es constante de cada año para TODOS los
# municipios por igual (el efecto fijo de anio, que aquí es
# esencialmente "el colapso nacional de 2025"), y lo que sobra después
# de quitar esas dos piezas (el residuo). Es una herramienta de
# DESCOMPOSICIÓN, no de estimación de un efecto causal, y por eso no
# reporta coeficientes: reporta, entre otras cosas, qué tanto de la
# varianza total se explica solo con esas dos capas de efectos fijos.

# (b) Un panel BALANCEADO tiene el mismo número de periodos para cada
#     unidad, sin huecos: cada municipio aparece exactamente el mismo
#     número de veces. Nuestro panel_largo SÍ es balanceado: cada uno
#     de los 2,475 municipios tiene exactamente dos filas (2024 y
#     2025), ni una de más ni una de menos, porque lo construimos con
#     un inner_join() que solo se quedó con los municipios presentes
#     en las DOS bases. Un panel DESBALANCEADO tendría, por ejemplo,
#     algunos municipios con solo un año de datos —si un municipio se
#     creó después de 2024, o si sus datos de una de las dos
#     elecciones se perdieran—. Comprueba que el nuestro es
#     balanceado:

panel_largo |> count(clave_municipio) |> count(n)   # todos los municipios deben tener n = 2

# (c) El error más frecuente de este módulo suele ser confundir
#     summarise() con mutate() en los bloques de between/within: usar
#     summarise() donde hacía falta mutate() colapsa el panel a una
#     fila por municipio DEMASIADO PRONTO, y entonces la resta
#     participacion_pct - media_municipio truena porque
#     participacion_pct ya no existe en la tabla resultante —summarise()
#     se quedó solo con las columnas que pediste explícitamente—.


# ==============================================================
# Sobre la pregunta de cierre del ejercicio:
#
# Con una tercera elección, group_by(clave_municipio) + lag() seguiría
# funcionando exactamente igual, SIN cambiar una línea: lag() no sabe
# ni le importa cuántos periodos hay en total, solo mira "la fila de
# antes, dentro del mismo grupo". Lo que SÍ tendrías que revisar es
# cualquier cálculo que asumiera, de forma implícita, que solo hay dos
# periodos —como el truco de la sección 6 del script, donde restar
# los dos únicos promedios de anio bastaba para obtener la diferencia
# completa—: con tres periodos, "la diferencia" deja de ser un solo
# número y se vuelve una pregunta que hay que precisar (¿entre cuáles
# dos periodos?, ¿el cambio total o el cambio promedio por periodo?).
# ==============================================================
