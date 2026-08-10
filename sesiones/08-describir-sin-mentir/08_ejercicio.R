# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 08 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 08_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

# [PENDIENTE: sustituir por base comparada cuando exista]
# Esta es una sesión par, y la regla del curso es que el ejercicio para
# llevar de las sesiones pares use una base comparada (V-Dem,
# Latinobarómetro o Quality of Government) en vez de una mexicana.
# Todavía no hay ninguna base comparada publicada en datos/limpios/, así
# que este ejercicio usa datos mexicanos con exactamente la misma lógica
# que usaría con datos comparados: dos variables continuas, muchas
# unidades, ¿"van juntas" o no? Cuando exista la base comparada, se
# sustituye aquí sin tocar la estructura de los tres niveles, y el nivel 3
# ya deja escrita la pregunta comparada que vas a poder contestar entonces.

library(tidyverse)
library(here)

source(here("estilo", "tema_lab.R"))

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

# En el script de hoy calculaste media, mediana y desviación estándar de
# lista_nominal y de participacion. Reproduce el mismo trío de números,
# pero con pct_fcm (el porcentaje de Fuerza y Corazón por México).
#
# Antes de correrlo, contesta mentalmente: pct_fcm es un porcentaje, como
# participacion, no un conteo de personas, como lista_nominal. ¿Esperas
# que su media y su mediana se parezcan entre sí, como pasó con
# participacion, o que se separen mucho, como pasó con lista_nominal?

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# En clase calculaste que participación y voto por SHH casi no van
# juntas (-0.12 a nivel municipio). Ahora hazlo con el otro bloque grande.
#
# (a) Calcula la correlación entre participacion y pct_fcm con cor() y el
#     mismo use = "complete.obs" que usaste en clase.
#
# (b) Grafica el mismo tipo de scatter que en clase —geom_point() más
#     geom_smooth(method = "lm")— con pct_fcm en el eje y.
#
# (c) En un comentario de dos o tres líneas: ¿el signo de esta correlación
#     es el opuesto del que viste con pct_shh, el mismo, o algo distinto?
#     ¿Qué historia política, si acaso alguna, cuenta ese patrón? No hay
#     respuesta correcta; hay respuestas defendibles y respuestas flojas.

# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Repite el cálculo de (a) del Nivel 2 pero con la base por entidad
#     (presidencial_2024_entidad.csv, que ya conoces desde la sesión 1).
#     Compara el número con el de nivel municipio: ¿el signo también
#     cambia entre las dos unidades de análisis, como pasó en clase con
#     pct_shh? Escribe, en un comentario, en cuál de los dos números
#     confiarías más para escribir "el voto por FCM y la participación
#     están relacionados" en un trabajo final, y por qué.
#
# (b) [PENDIENTE: sustituir por base comparada cuando exista] Esta es la
#     pregunta que este ejercicio contestaría con una base comparada: ¿el
#     patrón mexicano de hoy —participación casi no predice el bloque
#     ganador— se repite en otras democracias de la región, o México es un
#     caso raro? Pregúntale a una IA en qué variables de V-Dem o
#     Latinobarómetro buscarías participación electoral y apoyo al
#     partido en el gobierno para varios países. VERIFICA que los nombres
#     de variable que te dé existan de verdad en el codebook público de
#     esa base antes de darlos por buenos: una IA puede inventar con toda
#     seguridad el nombre de una columna que no existe.

# Escribe tu código aquí abajo:




# ==============================================================
# La pregunta de cierre, sin código.
#
# El diagrama de dispersión de hoy —participación en el eje x, voto por un
# bloque en el eje y— es, con otras columnas, el mismo tipo de gráfico que
# vas a necesitar en la sesión 11 para comparar el poder electoral de
# Morena con el voto por candidaturas morenistas a la Corte. Si esa
# correlación te sale, otra vez, cercana a cero, ¿qué harías distinto de
# lo que hiciste hoy antes de escribir "no hay relación" en tu proyecto
# final?
# ==============================================================
