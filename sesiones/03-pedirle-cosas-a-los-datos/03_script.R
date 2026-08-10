# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 03 · Pedirle cosas a los datos
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Cambiar los corchetes de base R por un pipe legible, y usar filter(),
#   select(), arrange() y mutate() para convertir una intuición política
#   propia en una tabla que la pone a prueba.
#
# Qué necesitas antes de empezar:
#   Haber corrido la sesión 02 — usamos read_csv() y glimpse() sin volver
#   a explicarlos.
#
# Datos: INE, cómputos distritales 2024, presidencial, por entidad y por
#        municipio. Ver datos/README.md para la fuente exacta.
# Autor: Emiliano Miranda González
# ==============================================================

# ─────────────────────────────────────────────────────────────
# ESTE ARCHIVO TIENE HUECOS Y NO CORRE DE CORRIDO. Es a propósito.
# Los huecos están marcados con  ← COMPLETA  y se llenan en clase.
# Si intentas correrlo entero antes de llenarlos, va a marcar error.
# La versión resuelta (03_script_completo.R) se publica al terminar la sesión.
# ─────────────────────────────────────────────────────────────


# ---- 0. Los paquetes ----

# Nada nuevo esta sesión: seguimos con lo de siempre.
#
#   install.packages(c("tidyverse", "here"))

library(tidyverse)
library(here)


# ---- 1. Lo de siempre: cargar la base ----

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

# Una fila es una entidad federativa. Deben ser 32. Si no las recuerdas,
# corre glimpse(resultados): es exactamente lo que hicimos la sesión pasada.


# ---- 2. Por qué no usamos corchetes ----

# Así se filtraba una tabla en R base, antes de que existiera dplyr.
# Cópialo, córrelo, y no te preocupes por entenderlo del todo: es apropósito
# incómodo de leer.

resultados[resultados$participacion > 60, c("entidad", "participacion")]

# El nombre de la tabla se repite tres veces. Un paréntesis o una coma fuera
# de lugar y todo truena, casi siempre sin decirte en qué parte del renglón
# está el problema.
#
# La misma pregunta, con el pipe |> y los verbos de dplyr:
#
# ← COMPLETA: arma el equivalente en pipe del bloque de corchetes de
#   arriba. Llama al resultado resultados_filtrados y usa filter() y
#   select().

resultados_filtrados <-


resultados_filtrados

# Fíjate: los dos bloques hacen exactamente lo mismo. Ninguno modifica
# resultados — dplyr nunca destruye tu base a menos que tú se lo pidas con
# una asignación explícita (<-).
#
# El pipe |> se lee "y luego". Se escribe con Ctrl+Shift+M (Cmd+Shift+M en
# Mac). En este curso nunca vas a ver %>%, el pipe viejo de antes de que R
# trajera uno de fábrica en 2021 — si lo ves en un tutorial o en código que
# te pase alguien, es el mismo verbo, otra letra.


# ---- 3. filter(): quedarte con las filas que cumplen algo ----

resultados |> filter(entidad == "Jalisco")

resultados |> filter(participacion > 60)

# == pregunta si dos cosas son iguales. Dentro de filter(), = sirve para otra
# cosa —nombrar un argumento— y R te va a detener con un error si lo
# confundes: a diferencia de la trampa que viene abajo, esa sí truena.
#
# Comparadores disponibles: ==, !=, >, <, >=, <=
# Para combinar más de una condición:
#   &  exige que se cumplan las dos
#   |  exige que se cumpla al menos una

resultados |> filter(pct_shh > 60 | pct_fcm > 60)


# ---- 4. La trampa silenciosa: filter(var == 1 | 2) ----

# Imagina una columna que guarda el código de la coalición ganadora en una
# entidad: 1 para Sigamos Haciendo Historia, 2 para Fuerza y Corazón por
# México. Este vector es un ejemplo didáctico, no un dato real de nuestra
# base — lo armamos aquí nomás para ver la trampa en vivo.

codigo_coalicion <- c(1, 2, 3, 1, 2)

# Alguien, con buena intención, escribe esto para quedarse con las
# entidades 1 y 2:

codigo_coalicion == 1 | 2

# R no truena. Te devuelve un vector. Míralo con cuidado: ¿de verdad marca
# TRUE solo donde el código es 1 o 2?
#
# Lo que pasa: R calcula primero codigo_coalicion == 1 (compara con 1).
# Después le hace un OR con el número 2 suelto, y R convierte cualquier
# número distinto de cero en TRUE. El resultado es TRUE en todas partes.
# Con filter(), eso significa quedarte con la tabla COMPLETA, sin ningún
# aviso de que algo salió mal. Es, de todos los errores de este curso, el
# más peligroso: no truena, solo miente.
#
# La forma correcta es %in%, que pregunta "¿está en esta lista?" y no tiene
# esa trampa:

codigo_coalicion %in% c(1, 2)

resultados |> filter(clave_entidad %in% c("01", "02", "09"))


# ---- 5. select(): quedarte con las columnas que importan ----

resultados |> select(entidad, participacion)

resultados |> select(-clave_entidad)   # con - excluyes en vez de escoger

# select() también entiende patrones, no solo nombres exactos:

resultados |> select(starts_with("pct_"))

# Hay más atajos como starts_with() —ends_with(), contains()— en el
# acordeón del curso; con este te alcanza para casi todo.
#
# Dos verbos más de la misma familia, que sirven para inspeccionar:

resultados |> rename(part_pct = participacion)   # cambia un nombre, no los datos

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

municipios |> distinct(entidad) |> nrow()

# Ese último número debe dar 32: una confirmación barata de que el archivo
# municipal cubre las 32 entidades del país, ni una de más ni una de menos.


# ---- 6. arrange(): ordenar ----

resultados |> arrange(desc(participacion))

# Sin desc(), arrange() ordena siempre de menor a mayor.
#
# Para "los primeros N", hay un atajo más legible que arrange()+head():

resultados |> slice_max(participacion, n = 5)


# ---- 7. mutate(): crear una columna nueva ----

# ← COMPLETA: crea la columna ventaja, que es pct_shh menos el mayor de
#   pct_fcm y pct_mc (el segundo lugar, sea cual sea la coalición). Usa
#   pmax(), que compara par por par y se queda con el mayor de los dos.
#   Recuerda reasignar: mutate() no modifica resultados por sí solo.

resultados <-


# Si después de esto filtras por ventaja y R te dice
# "Error: object 'ventaja' not found", casi siempre es que corriste el
# mutate() de arriba sin la asignación resultados <-, y el resultado se
# imprimió en la consola y se perdió.


# ---- 8. EL SALTO: de la intuición a la tabla ----

# "Siento que Morena arrasó en el sur" es una intuición.
# filter(ventaja > 20) es una pregunta empírica.
#
# EL SALTO: convertir una intuición política propia en una línea que
# cualquiera puede correr, revisar y refutar. Eso es lo que acabas de hacer
# con estas tres líneas:

resultados |>
  filter(ventaja > 20) |>
  arrange(desc(ventaja)) |>
  select(entidad, ventaja)

# Esa tabla contesta, a nivel estatal, la pregunta con la que abrió la
# sesión de hoy.


# ---- 9. La misma pregunta, en 2,475 municipios ----

# municipios ya trae una columna ventaja_shh calculada de fábrica —mira
# datos/README.md si quieres ver exactamente cómo se construyó. No tuviste
# que hacer la resta 2,475 veces: eso es lo que aprendiste en la sesión 1
# sobre vectores, otra vez, a otra escala.

# ← COMPLETA: filtra municipios donde ventaja_shh sea mayor a 20 y cuenta
#   cuántos son con nrow().



# Compara ese número con cuántas entidades pasaron el mismo umbral en el
# paso 8. ¿Es la misma proporción, o cambia mucho al bajar de escala?


# ---- 10. Tu propia pregunta ----

# Este es el entregable de la hora, y hoy tienes tiempo de sobra para
# hacerlo bien: escribe TU pregunta política —no la de este script— y
# contéstala con un pipe de filter(), select() y arrange() sobre
# resultados o sobre municipios.
#
# Si no se te ocurre ninguna, aquí tienes tres para empezar:
#   ¿Dónde ganó Fuerza y Corazón por México, aunque sea en pocas entidades?
#   ¿En qué municipios la participación fue menor al 50%?
#   ¿Hay municipios donde Movimiento Ciudadano superó el 20% de la votación?
#
# Escribe tu código aquí abajo:




# ==============================================================
# La pregunta abierta del cierre.
#
# Mira la tabla que acabas de producir. ¿Contesta de verdad tu pregunta, o
# contesta una pregunta parecida pero no exactamente la tuya? Esa diferencia
# —entre lo que preguntaste y lo que tu código realmente pregunta— es el
# oficio completo de trabajar con datos, y vas a volver a tropezar con ella
# toda tu vida profesional.
# ==============================================================
