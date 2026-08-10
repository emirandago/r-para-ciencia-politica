# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 06 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 06_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

# [PENDIENTE: sustituir por base comparada cuando exista]
# Esta es una sesión par, y la regla del curso es que el ejercicio para
# llevar de las sesiones pares use una base comparada (V-Dem,
# Latinobarómetro o Quality of Government) en vez de una mexicana.
# Todavía no hay ninguna base comparada publicada en datos/limpios/, así
# que este ejercicio usa datos mexicanos con exactamente la misma lógica
# que usaría con datos comparados: una variable continua, muchas
# unidades, ¿se agrupan o se dispersan por región? Cuando exista la base
# comparada, se sustituye aquí sin tocar la estructura de los tres
# niveles.

library(tidyverse)
library(here)
library(patchwork)

source(here("estilo", "tema_lab.R"))

resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

# En el script de hoy armaste un "skyline" de ventaja_shh: ordenaste los
# municipios de menor a mayor y coloreaste con scale_fill_viridis_c().
# Reprodúcelo, pero cambia UNA cosa: usa la columna participacion en vez
# de ventaja_shh (sigue siendo un número por municipio, así que el mismo
# esqueleto de código funciona sin tocar nada más).
#
# Antes de correrlo, contesta mentalmente: ¿tiene sentido usar una escala
# DIVERGENTE (gradient2, centrada en un midpoint) para participación,
# igual que la usaste para ventaja_shh? ¿Por qué sí o por qué no? (Pista:
# piensa en si 0% de participación es un punto de referencia político —
# como un empate— o solo el mínimo posible de la escala.)

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# Una pregunta distinta: ¿la ventaja de SHH se concentra en ciertas
# entidades o está repartida por todo el país? No te estamos pidiendo un
# mapa —eso es la sesión 7—: te estamos pidiendo una figura de paneles.
#
# (a) Crea una columna nueva, region_norte_sur, que clasifique cada fila
#     de resultados_municipio en "Norte" o "Sur" con case_when() y un
#     vector con las nueve entidades fronterizas o inmediatamente
#     contiguas al norte del país (Baja California, Baja California Sur,
#     Chihuahua, Coahuila, Durango, Nuevo León, Sinaloa, Sonora,
#     Tamaulipas); todo lo demás, "Sur". (Esta clasificación es solo para
#     el ejercicio — no es una regionalización oficial de INEGI.)
#
# (b) Quita los municipios con ventaja_shh en NA, y con esa columna arma
#     un gráfico de ventaja_shh con facet_wrap(~ region_norte_sur) y una
#     escala divergente centrada en cero.
#
# (c) En un comentario de dos o tres líneas: ¿el patrón que ves confirma o
#     contradice la intuición de que Morena y sus aliados tienen su
#     bastión en el sur del país? No hay respuesta correcta; hay
#     respuestas defendibles y respuestas flojas.
#
# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Pídele a una IA que te explique la diferencia entre
#     scale_fill_viridis_c(option = "viridis") y
#     scale_fill_viridis_c(option = "magma"). Después VERIFICA la
#     respuesta corriendo las dos sobre el mismo gráfico y mirando si de
#     verdad cambia lo que la IA te dijo que iba a cambiar.
#
# (b) Pregúntale además si existe alguna paleta de la familia viridis que
#     NO sea segura para daltonismo. Es una pregunta con trampa: la razón
#     de ser de toda la familia viridis —viridis, magma, inferno, plasma,
#     cividis, mako, rocket, turbo— es que las ocho están diseñadas para
#     leerse igual bajo las formas comunes de daltonismo. Si la IA te dice
#     que alguna no lo es, pídele la fuente y decide tú si te convence.
#
# Escribe tu código aquí abajo:




# ==============================================================
# La pregunta de cierre, sin código.
#
# El proyecto final del laboratorio (sesión 11) te va a pedir comparar el
# poder electoral de Morena con el voto por candidaturas morenistas a la
# Corte. Si tuvieras que resumir esa comparación en UNA figura publicable,
# ¿usarías facetas, una escala de color, o las dos? Escribe, en dos
# líneas, por qué.
# ==============================================================
