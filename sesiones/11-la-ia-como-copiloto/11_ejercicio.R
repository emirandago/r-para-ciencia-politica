# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 11 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles, y aquí cambian de naturaleza respecto de las diez
# sesiones anteriores: el nivel 2 ya no pide una función nueva, pide
# cerrar el proyecto. El nivel 3 no pide documentación, pide someter tu
# propia interpretación a una objeción.
#
# Nadie los revisa: son tuyos. La solución comentada se publica después
# de la sesión, en 11_solucion.R, y no va a "resolver" la interpretación
# por ti: eso es exactamente lo que no se delega.
# ==============================================================

library(tidyverse)
library(here)
library(fixest)

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

# El modelo de la sesión 9, para tener un coeficiente real a la mano en
# todo el ejercicio.
modelo_1_robusto <- feols(ventaja_shh ~ participacion, data = municipios, vcov = "hetero")


# ---- Nivel 1 · Calentamiento ----

# Repite la comprobación 1 del script de hoy —exists()— pero con dos
# funciones nuevas, una real y una inventada con un nombre parecido a
# una real:
#
#   a. scale_fill_viridis_d(), la escala de viridis para variables
#      categóricas (discretas).
#   b. scale_fill_viridis_discreto(), con esa ortografía en español.
#
# Antes de correr nada, anota qué esperas que conteste exists() para
# cada una. Después corre las dos líneas y compara con lo que anotaste.
#
# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad: cerrar el proyecto ----

# Aquí no hay una función nueva que aprender. Con el mapa de la sesión 7
# y la regresión de tu proyecto final ya hechos —tu propia versión de
# feols(pct_bloque_a ~ ventaja_shh, data = municipios, vcov = "hetero"),
# con tu codificación de votos_bloque_a— escribe los tres párrafos que
# cierran el proyecto. Cada uno en un comentario, en prosa, sin viñetas:
#
#   (a) QUÉ ENCONTRAMOS. Con las unidades de tu variable. Sin la
#       palabra "causa" salvo que expliques primero por qué no puedes
#       usarla.
#
#   (b) QUÉ NO PODEMOS AFIRMAR. Al menos dos límites reales del diseño
#       —no "faltan datos": eso no cuenta como límite según la rúbrica
#       del proyecto (§5). Piensa en la codificación de votos_bloque_a,
#       en que es un corte transversal, en que dos elecciones de
#       naturaleza distinta se están comparando.
#
#   (c) QUÉ HARÍAMOS CON MÁS TIEMPO. Algo concreto y factible, no "más
#       datos" en abstracto: por ejemplo, correr el análisis completo
#       con la codificación alternativa y más restrictiva de
#       votos_bloque_a que pide el §3 del documento del proyecto, y ver
#       si el resultado cambia.
#
# Si tu propio modelo con pct_bloque_a todavía no existe porque la
# codificación no está lista, usa modelo_1_robusto (ventaja_shh en
# función de participacion) como sustituto para practicar la forma de
# los tres párrafos, y dilo explícitamente en tu respuesta.
#
# Escribe tus tres párrafos aquí abajo, como comentarios:




# ---- Nivel 3 · Si te sobra tiempo: objeta tu propia interpretación ----

# (a) Toma el párrafo que escribiste en el inciso (a) del nivel 2 —QUÉ
#     ENCONTRAMOS— y pégaselo a una IA. Pídele, textual: "dame tres
#     razones por las que esta interpretación podría estar mal o ser
#     incompleta." Anota las tres razones que te dio, en un comentario.
#
# (b) De esas tres, ¿cuántas son en el fondo la misma razón disfrazada
#     de "faltan datos" o "se necesita una muestra más grande"? Esas no
#     cuentan: la rúbrica del proyecto (§5) pide límites reconocidos que
#     no sean esa excusa. Descártalas y quédate solo con las razones que
#     de verdad cuestionan tu diseño o tu codificación.
#
# (c) De lo que quede, elige la objeción que más te preocupa —la que,
#     si alguien te la hiciera en una presentación, te costaría más
#     trabajo contestar— y responde en prosa, en un comentario: ¿tu
#     interpretación aguanta con un matiz, o tienes que cambiarla? Que
#     una objeción sea razonable no significa que gane siempre: a veces
#     el argumento correcto es explicar por qué, aun con esa objeción
#     sobre la mesa, tu lectura sigue siendo la más defendible.
#
# Escribe tu código y tus respuestas aquí abajo:




# ==============================================================
# La pregunta de cierre, sin código.
#
# Saca la pregunta que escribiste al final del ejercicio de la sesión 1.
# Léela. ¿Con lo que sabes hacer hoy alcanza para contestarla? Si la
# respuesta es "todavía no", nombra en una oración qué específicamente
# te falta.
# ==============================================================
