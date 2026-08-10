# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 6 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Si llegaste aquí sin haber peleado con el ejercicio, regrésate: la
# solución solo enseña algo a quien ya se atoró.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)
library(fixest)
library(modelsummary)

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))
entidades  <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))


# ---- Nivel 1 · Calentamiento ----

municipios <- municipios |> mutate(ventaja_mc = pct_mc - pct_fcm)

resumen_ventaja_mc <- municipios |>
  group_by(entidad) |>
  summarise(ventaja_mc_promedio = mean(ventaja_mc)) |>
  arrange(desc(ventaja_mc_promedio))

resumen_ventaja_mc

# Campeche tiene la mayor ventaja promedio de Movimiento Ciudadano
# sobre Fuerza y Corazón por México (alrededor de +3.3 puntos), la
# única entidad donde ese balance sale positivo en promedio entre sus
# municipios; Coahuila, Aguascalientes y Chihuahua están en el extremo
# opuesto, con FCM más de 27 puntos arriba de MC en promedio. gen se
# tradujo con mutate() + reasignación (municipios <- municipios |>
# mutate(...)); collapse (mean) ..., by(entidad) se tradujo con
# group_by(entidad) + summarise(mean(...)).


# ---- Nivel 2 · De verdad ----

# (a)

entidades <- entidades |> mutate(ventaja_mc = pct_mc - pct_fcm)

modelo_entidad <- feols(participacion ~ ventaja_mc, data = entidades, vcov = "hetero")

modelsummary(modelo_entidad, stars = TRUE, gof_omit = "AIC|BIC|Log|Std")

# (b) Lectura del coeficiente.

range(entidades$ventaja_mc)

# El coeficiente de ventaja_mc sale alrededor de 0.036: "por cada
# punto porcentual más de ventaja de MC sobre FCM, la participación
# sube, en promedio, 0.036 puntos porcentuales". El rango real de
# ventaja_mc entre las 32 entidades va de valores muy negativos
# (FCM muy por encima de MC) hasta apenas positivo (Campeche). Un
# coeficiente de 0.036 por punto es MINÚSCULO frente a ese rango: aun
# en el extremo más favorable a MC, el modelo predice un cambio de
# apenas un par de puntos de participación. Es la misma lección de
# humildad de la sesión 9 y del extra 3: un número puede existir y ser
# sustantivamente irrelevante al mismo tiempo.

# (c)

municipios <- municipios |>
  mutate(grupo_mc = if_else(pct_mc > median(pct_mc, na.rm = TRUE), "alto", "bajo"))

municipios |>
  group_by(grupo_mc) |>
  summarise(varianza_participacion = var(participacion))

# Las dos varianzas NO son parecidas: el grupo "bajo" tiene una
# varianza más del DOBLE que la del grupo "alto" (alrededor de 181
# contra 84). Aquí sí importaría la elección entre var.equal = TRUE
# (el default de Stata) y el default de R (Welch, que no asume
# varianzas iguales): con varianzas tan distintas entre los dos
# grupos, un t.test() con var.equal = TRUE y uno sin ese argumento
# pueden dar grados de libertad y estadísticos t apreciablemente
# distintos. Es exactamente el escenario donde el gotcha de esta
# página deja de ser una curiosidad técnica y se vuelve una decisión
# que sí cambia un número que alguien podría reportar.

t.test(participacion ~ grupo_mc, data = municipios)                    # Welch (default de R)
t.test(participacion ~ grupo_mc, data = municipios, var.equal = TRUE)  # replica el default de Stata


# ---- Nivel 3 · Si te sobra tiempo ----

# (a)

oaxaca_ranking <- municipios |>
  filter(entidad == "Oaxaca") |>
  arrange(desc(participacion)) |>
  mutate(rango_participacion = row_number())

oaxaca_ranking |> select(municipio, participacion, rango_participacion) |> head(5)

# bysort entidad: gen rango = _n numera las filas DENTRO de cada grupo
# en el orden en que están (por eso "bysort", que primero ordena por
# grupo). El equivalente de dplyr necesita DOS pasos explícitos que en
# Stata están implícitos en un solo comando: arrange() para fijar el
# orden (aquí, de mayor a menor participación) y row_number() para
# numerar filas según ESE orden. Si quisieras la versión que numera
# TODAS las entidades a la vez, cada una arrancando en 1, agregarías
# group_by(entidad) antes de arrange() y row_number().

# (b) relevel() cambia la categoría de REFERENCIA de un factor que YA
#     existe, sin tener que reescribir todos sus niveles:
#
#       es_grande_factor <- factor(municipios$grupo_mc)
#       es_grande_factor <- relevel(es_grande_factor, ref = "alto")
#
#     Se parece a factor(x, levels = c(...)) en que las dos formas
#     terminan fijando cuál nivel es la referencia (la que no recibe
#     su propia columna de variable dummy en un modelo). Se
#     diferencia en que factor(x, levels = c(...)) reescribe el ORDEN
#     COMPLETO de todos los niveles de una vez, mientras que relevel()
#     solo mueve UN nivel al frente y deja el resto del orden como
#     estaba —más cómodo cuando el factor tiene muchas categorías y
#     solo te importa cuál es la de referencia—.

# (c) El error más frecuente de este módulo suele ser, otra vez,
#     olvidar la reasignación con <-: escribir
#     municipios |> mutate(ventaja_mc = pct_mc - pct_fcm) suelto, sin
#     guardarlo, y después preguntarse por qué la columna ventaja_mc
#     "no existe" en la siguiente línea. R no modifica nada en su
#     lugar; si no reasignas, el resultado se calcula, se muestra —o
#     ni eso, si está dentro de un pipe más largo— y se pierde.


# ==============================================================
# Sobre la pregunta de cierre del ejercicio:
#
# Una oración posible: "en Stata, cada comando cambia la única base
# que existe; en R, cada línea produce un resultado nuevo que se
# pierde si no le pones nombre con <-, así que la pregunta que
# siempre tienes que hacerte no es 'qué comando corro' sino 'dónde
# quiero que viva el resultado'".
# ==============================================================
