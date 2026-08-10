# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 03 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Se publica después de la sesión. Si llegaste aquí sin haber peleado
# con el ejercicio, regrésate: la solución solo enseña algo a quien ya
# se atoró. Leer código correcto sin haberlo intentado se siente como
# aprender y no lo es.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv")) |>
  mutate(ventaja = pct_shh - pmax(pct_fcm, pct_mc))

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

resultados |>
  filter(ventaja > 10) |>
  arrange(desc(ventaja))

nrow(resultados |> filter(ventaja > 10))   # 29
nrow(resultados |> filter(ventaja > 20))   # 25, la que hicimos en clase

# Bajar el umbral de 20 a 10 tenía que dejar entrar MÁS entidades, nunca
# menos: cualquier entidad que ya cumplía "ventaja > 20" también cumple
# "ventaja > 10", porque 10 es un umbral menos exigente. Si tu intuición
# decía "menos", vale la pena que revises por qué —es un error de lectura
# común y detectarlo aquí, con un ejercicio sin consecuencias, es barato.
# Con datos reales, esa misma confusión de sentido puede colarse en un
# trabajo final sin que nadie la note.


# ---- Nivel 2 · De verdad ----

# (a) el código

municipios_fcm <- municipios |>
  mutate(ventaja_fcm = pct_fcm - pmax(pct_shh, pct_mc)) |>
  filter(ventaja_fcm > 15) |>
  arrange(desc(ventaja_fcm))

nrow(municipios_fcm)   # 48

# (b) distinct() sobre la tabla ya filtrada

municipios_fcm |> distinct(entidad)

nrow(municipios_fcm |> distinct(entidad))   # 11

# (c) la interpretación, que es la parte que importa.
#
# Cuarenta y ocho municipios de 2,475 (menos del 2% del país) le dieron a
# Fuerza y Corazón por México una ventaja mayor a 15 puntos, y esos 48 NO
# están repartidos parejo: aparecen en solo 11 de las 32 entidades, y la
# mitad se concentra en dos: Jalisco (16 municipios) y Chihuahua (9). Nuevo
# León, Tamaulipas, Chiapas, Veracruz y Guanajuato aportan un puñado cada
# una; el resto de las entidades no aportan ninguno.
#
# Eso es un patrón, no un accidente —pero con lo que sabemos hoy solo
# podemos DESCRIBIRLO, no explicarlo. Para argumentar por qué la ventaja de
# fcm se concentra ahí (¿geografía electoral histórica del PAN? ¿el tipo de
# municipio, urbano o rural? ¿algo del candidato local?) haría falta cruzar
# esta tabla con otras variables —tamaño de población, resultados de
# elecciones anteriores— que hoy no tenemos cargadas. Esa es exactamente la
# clase de pregunta para la que sirve un left_join(), que llega la próxima
# sesión.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) slice_min(): el opuesto de slice_max().

resultados |> slice_min(ventaja, n = 1)

# Aguascalientes: ventaja = -3.24. Un número NEGATIVO en esta columna
# significa que pct_shh es MENOR que el mayor de pct_fcm y pct_mc — o sea,
# que en Aguascalientes Sigamos Haciendo Historia no ganó frente al segundo
# lugar. Es la única entidad, de las 32, donde eso pasa: el resto de este
# curso vas a encontrarte varias veces con la idea de que un solo caso
# distinto al patrón general suele ser el más interesante de mirar de cerca.

# (b) %in% con más de dos valores.

resultados |>
  filter(clave_entidad %in% c("09", "14", "15", "19", "21"))

# Ciudad de México, Jalisco, México, Nuevo León, Puebla — cinco entidades
# cualesquiera, una sola condición. %in% no tiene límite de cuántos
# valores le des dentro de c().

# (c) pmax() con tres columnas o más.
#
# Es muy probable que una IA te haya contestado que pmax() acepta
# directamente más de dos vectores, y esa respuesta es correcta:
# pmax(x, y, z, ...) compara TODOS los argumentos que le des, par por par,
# posición por posición. Verifícalo:

resultados |>
  mutate(maximo_de_los_tres = pmax(pct_shh, pct_fcm, pct_mc)) |>
  select(entidad, pct_shh, pct_fcm, pct_mc, maximo_de_los_tres)

# Si la IA te propuso, en cambio, algo con rowwise() y max(), o con
# do.call(pmax, ...), no está mal —son caminos que también funcionan—, pero
# para este caso concreto son más código para el mismo resultado. Preferir
# la solución más corta que sí resuelve el problema, y no la primera que
# funciona, es un criterio que vas a afinar todo el curso.


# ==============================================================
# Sobre la pregunta de la sesión 1 con la que cerraba el ejercicio:
#
# Si ya pudiste escribir una línea que la contesta, aunque sea a medias,
# acabas de vivir el arco completo de este laboratorio en miniatura: una
# intuición, convertida en código, convertida en una tabla que se puede
# defender. Si todavía no, no es una falla tuya — es que probablemente
# necesitas un verbo que todavía no hemos visto (group_by(), un join, un
# mapa). Guarda la pregunta. Le va a llegar su sesión.
# ==============================================================
