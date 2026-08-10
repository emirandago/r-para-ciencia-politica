# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 09 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 09_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

library(tidyverse)
library(here)
library(fixest)
library(modelsummary)

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

# Reproduce el modelo de la sesión, pero cambiando UNA cosa: en vez de
# explicar ventaja_shh (la ventaja de la coalición sobre el segundo
# lugar), explica pct_shh (el porcentaje de votos de la coalición, sin
# comparar contra nadie). La variable explicativa sigue siendo la misma:
# participacion.
#
# Antes de correrlo, contesta mentalmente: ¿esperas que el coeficiente de
# participacion tenga el mismo signo que en el modelo de clase? ¿Por qué
# sí o por qué no?
#
# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# Una pregunta nueva: ¿la participación le afecta igual a todos los
# bloques políticos, o distinto a cada uno? La columna pct_fcm trae el
# porcentaje de votos de la coalición Fuerza y Corazón por México —el
# principal rival de Sigamos Haciendo Historia— en cada municipio.
#
# (a) Ajusta, con feols() y vcov = "hetero", la regresión de pct_fcm en
#     función de participacion. Guárdala en un objeto con un nombre que
#     tenga sentido para ti.
#
# (b) Arma una tabla con modelsummary() que ponga lado a lado tu modelo
#     de (a) y el modelo_1_robusto de la sesión (ventaja_shh en función
#     de participacion). Los dos comparten la misma variable explicativa,
#     así que se pueden comparar en la misma tabla sin problema.
#
# (c) Contesta en un comentario, de tres a cinco líneas: ¿el signo del
#     coeficiente de participacion es el mismo en los dos modelos, o es
#     distinto? Si tuvieras que explicarle a alguien que no sabe R qué
#     dice cada coeficiente, ¿qué oración completa —con unidades— usarías
#     para cada uno? Y una pregunta más difícil: los dos R² son muy
#     chicos. ¿Eso hace que la comparación no sirva para nada, o sirve
#     para algo distinto de lo que uno esperaría de entrada? No hay una
#     única respuesta correcta; hay respuestas defendibles y respuestas
#     flojas.
#
# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) En el modelo de la sesión, compara el error estándar clásico de
#     lm() (corre summary(modelo_1) si no lo tienes a la mano) contra el
#     error estándar robusto de feols() con vcov = "hetero"
#     (summary(modelo_1_robusto)). Anota los dos números del coeficiente
#     de participacion. Pregúntale a una IA qué significa que un error
#     estándar "robusto" sea parecido al clásico, en vez de muy distinto.
#     Después VERIFICA la respuesta: ¿la explicación de la IA es
#     consistente con lo que tú mismo calculaste? Si la IA te dice que
#     los errores robustos "siempre" son más grandes que los clásicos,
#     eso no es cierto en general — es tu oportunidad de comprobarlo con
#     tus propios números.
#
# (b) feols() acepta otros valores para vcov además de "hetero", por
#     ejemplo vcov = ~clave_entidad, que agrupa el error estándar por
#     entidad en vez de suponer que cada municipio es independiente de
#     los demás de su propio estado. Corre ?feols en la consola, busca la
#     sección de vcov, y escribe en un comentario en qué se diferencia
#     "agrupar por entidad" de "hetero". No hace falta correr el modelo
#     con esa opción todavía: con leer la ayuda y explicarlo con tus
#     palabras alcanza.
#
# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, que no tiene código:
#
# Vuelve a la pregunta sobre política mexicana que escribiste al final
# del ejercicio de la sesión 1. ¿Se parece más a "X explica Y" o a "X
# causa Y"? Si se parece a la segunda, ¿qué tendrías que descartar antes
# de poder decirlo con la misma tranquilidad con la que lo escribiste
# entonces?
#
# No hace falta contestarla hoy. Hace falta que la vuelvas a leer.
# ==============================================================
