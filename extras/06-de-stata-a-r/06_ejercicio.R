# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 6 · Ejercicio para practicar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el
# tercero si te sobra tiempo o te dio curiosidad.
#
# La solución comentada está en 06_solucion.R. Intenta primero.
# ==============================================================

library(tidyverse)
library(here)
library(fixest)
library(modelsummary)

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))
entidades  <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))


# ---- Nivel 1 · Calentamiento ----

# Traduce este bloque de Stata a R, y córrelo:
#
#   use presidencial_2024_municipio, clear
#   gen ventaja_mc = pct_mc - pct_fcm
#   collapse (mean) ventaja_mc, by(entidad)
#
# (recuerda: gen se traduce con mutate() Y una reasignación con <-;
# collapse (mean) ... , by(g) se traduce con group_by() + summarise()).
# Al final, ordena el resultado de mayor a menor y contesta: ¿qué
# entidad tiene, en promedio, la mayor ventaja de Movimiento Ciudadano
# sobre Fuerza y Corazón por México?

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# (a) Traduce a R:
#
#   use presidencial_2024_entidad, clear
#   gen ventaja_mc = pct_mc - pct_fcm
#   reg participacion ventaja_mc, robust
#
#   (usa entidades, no municipios, para este inciso: la base ya está
#   cargada arriba)
#
# (b) Lee el coeficiente de ventaja_mc con sus unidades, en una
#     oración completa, igual que en la sesión 9. ¿El efecto te
#     parece grande o chico, comparado con el rango real que toma
#     ventaja_mc entre las 32 entidades? (Usa range() para ver ese
#     rango).
#
# (c) Calcula, sobre municipios, dos grupos según si pct_mc está por
#     encima o por debajo de la mediana nacional (llama a la columna
#     nueva grupo_mc, con valores "alto" y "bajo"). Corre var() de
#     participacion en cada grupo por separado (con filter() +
#     pull() + var(), o con group_by() + summarise(var(participacion))).
#     ¿Las dos varianzas son parecidas o muy distintas? ¿Importaría,
#     en este caso concreto, usar var.equal = TRUE o dejar el default
#     de R en un t.test() entre estos dos grupos?

# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) En Stata, un patrón muy común es:
#
#   bysort entidad: gen rango_participacion = _n
#
#   que numera las filas DENTRO de cada grupo, después de ordenarlas.
#   Investiga, con documentación o con una IA —y VERIFICA corriendo un
#   ejemplo—, cómo se traduce esto con group_by() + arrange() +
#   row_number() de dplyr. Aplícalo para numerar los municipios de
#   Oaxaca de mayor a menor participación.
#
# (b) Investiga la función relevel(), de R base, como alternativa a
#     escribir factor(x, levels = c(...)) para cambiar la categoría de
#     referencia de un factor. ¿En qué se parece a lo que hiciste en
#     la sección 8 del script, y en qué se diferencia?
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el
#     error que más veces te salió hoy y qué significaba.

# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, sin código:
#
# Si tuvieras que explicarle a alguien de tu generación, que solo
# conoce Stata, en UNA sola oración, por qué "modificar la base sin
# reasignar" es el error de traducción más común de todos, ¿qué le
# dirías?
# ==============================================================
