# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 03 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 03_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

library(tidyverse)
library(here)

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv")) |>
  mutate(ventaja = pct_shh - pmax(pct_fcm, pct_mc))

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

# En la sesión filtramos las entidades donde ventaja > 20. Reproduce ese
# filtro, pero cambia el umbral a 10.
#
# Antes de correrlo, contesta mentalmente: ¿esperas que entren más
# entidades o menos que con el umbral de 20? ¿Por qué?

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# Una pregunta nueva, esta vez sobre Fuerza y Corazón por México (fcm) y a
# nivel municipal, donde el patrón puede ser muy distinto al de las 32
# entidades.
#
# (a) En municipios, crea una columna ventaja_fcm: pct_fcm menos el mayor
#     de pct_shh y pct_mc (usa pmax(), igual que hicimos en clase con
#     ventaja). Filtra los municipios donde ventaja_fcm sea mayor a 15 y
#     ordénalos de mayor a menor ventaja_fcm.
#
# (b) Sobre esa tabla ya filtrada, usa distinct() sobre la columna entidad
#     para ver en cuántas entidades DISTINTAS aparecen esos municipios.
#     (group_by() y count() los vemos hasta la sesión 4 — con lo de hoy
#     alcanza para contestar esto.)
#
# (c) Contesta en un comentario, con tus palabras: ¿los municipios donde
#     ganó fcm por más de 15 puntos están repartidos por todo el país, o
#     concentrados en pocas entidades? ¿Qué tendrías que saber, además de
#     esta tabla, para explicar por qué pasa eso?
#
# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Así como slice_max() te da los de arriba, slice_min() te da los de
#     abajo. Investiga qué hace y úsala sobre resultados para encontrar la
#     entidad con la ventaja MÁS BAJA de las 32 —la elección más cerrada.
#     ¿El número que te da es positivo o negativo? ¿Qué significaría que
#     fuera negativo?
#
# (b) %in% no está limitado a dos valores. Escribe un filter() sobre
#     resultados que se quede con cinco entidades de tu elección, todas
#     con un solo %in%.
#
# (c) pmax() lo usamos hoy con dos columnas. Pregúntale a una IA si existe
#     una forma de usar pmax() —o alguna alternativa— para quedarte con el
#     mayor valor entre TRES O MÁS columnas a la vez, y VERIFICA lo que te
#     conteste corriéndolo sobre pct_shh, pct_fcm y pct_mc. La sesión 11
#     va a tratar precisamente de esto: verificar antes de creer.
#
# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, que no tiene código:
#
# Vuelve a la pregunta que escribiste al final de la sesión 1 —la tuya,
# sobre política mexicana—. Con filter(), select(), arrange() y mutate(),
# ¿ya puedes contestarla, aunque sea a medias? Si sí, escribe abajo la
# línea de código que la contestaría. Si todavía no, escribe qué te falta:
# ¿otra base de datos, otro verbo, o una pregunta más precisa?
#
# Mi respuesta es:
#
# ==============================================================
