# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 2 · Ejercicio para practicar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el
# tercero si te sobra tiempo o te dio curiosidad. Nadie los revisa:
# son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una
# función que no hayamos visto en 02_script.R.
#
# La solución comentada está en 02_solucion.R. Intenta primero.
# ==============================================================

library(tidyverse)
library(here)

source(here("estilo", "tema_lab.R"))

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

# Reproduce el histograma de la sección 7 del script (mil sorteos,
# replicate()), pero para lista_nominal en vez de participacion, con
# muestras de tamaño 50 en vez de 100. No olvides set.seed() antes de
# replicate() para que tu resultado sea reproducible.
#
# Antes de correrlo, anticipa: con lo que sabes de la sesión 8 sobre
# lista_nominal —muy desigual entre municipios, con Tijuana,
# Iztapalapa y Ecatepec jalando la media muy por encima de la
# mediana—, ¿esperas que la campana de los promedios simulados se vea
# tan simétrica como la de participación en el script, o distinta?
# ¿Por qué?

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# (a) Elige, con filter(), un municipio real de tu interés (cualquiera
#     de los 2,475; puede ser uno que conozcas). Guarda su
#     lista_nominal y su participacion reales en dos objetos.
#
# (b) Repite CIEN veces, con replicate(), la simulación de la sección
#     4 del script: cada vez, simula con rbinom() la decisión de
#     votar de cada persona del municipio, con probabilidad igual a
#     su participación real (recuerda dividir entre 100), y guarda el
#     PORCENTAJE simulado de esa corrida, no el conteo. Al final vas a
#     tener un vector de cien porcentajes simulados.
#
# (c) Calcula la media y la desviación estándar de esos cien
#     porcentajes. Contesta en un comentario de dos o tres líneas:
#     ¿el promedio de las cien simulaciones se acerca a la
#     participación real del municipio que elegiste? ¿Qué tan
#     dispersos salieron los cien sorteos entre sí?

# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Investiga, con documentación (?rexp, ?rgeom) o con una IA —y
#     VERIFICA lo que te conteste, corriendo un ejemplo mínimo—, qué
#     simulan rexp() y rgeom(). Para cada una, escribe en un
#     comentario una pregunta politológica donde podrían servir.
#
# (b) En la sección 6 del script cambiaste, en el ejemplo, lambda = 4.
#     Ahora corre rpois() varias veces SIN set.seed(), primero con
#     lambda = 4 y después con lambda = 50. ¿Qué le pasa a la
#     variación de un sorteo a otro conforme lambda crece? (Pista:
#     recuerda lo que dijimos en el script sobre Poisson y su propia
#     dispersión.)
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el
#     error que más veces te salió hoy y qué significaba.

# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, sin código:
#
# Todas las simulaciones de hoy asumieron que sabías, de antemano, la
# probabilidad "verdadera" (participacion real, lambda real). En una
# encuesta de verdad, antes de una elección, NADIE sabe ese número:
# es justo lo que se está tratando de estimar. ¿Qué cambia en tu
# manera de pensar la simulación si el número que alimenta rbinom()
# ya no es un dato conocido, sino una adivinanza?
# ==============================================================
