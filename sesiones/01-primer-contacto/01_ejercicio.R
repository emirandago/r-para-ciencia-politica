# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 01 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 01_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

library(tidyverse)
library(here)

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))


# ---- Nivel 1 · Calentamiento ----

# Reproduce el gráfico de la sesión, pero cambiando una sola cosa: en vez de
# la participación, grafica la lista nominal de cada entidad — o sea, cuánta
# gente podía votar. Deja el resto igual.
#
# Antes de correrlo, contesta mentalmente: ¿esperas que el orden de las
# barras sea muy distinto? ¿Por qué sí o por qué no?
#
# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# Una pregunta nueva: ¿en qué entidades le fue mejor a la coalición Sigamos
# Haciendo Historia? La columna se llama pct_shh y trae el porcentaje de
# votos que obtuvo esa coalición en cada entidad.
#
# (a) Haz un gráfico de barras horizontal de pct_shh por entidad, ordenado
#     de mayor a menor, con título, etiquetas de eje y fuente.
#
# (b) Ponlo al lado del gráfico de participación de la sesión y mira los dos.
#     ¿Las entidades donde más gente salió a votar son las mismas donde la
#     coalición sacó más porcentaje? Contesta en un comentario de dos o tres
#     líneas aquí mismo, con tus palabras. No hay respuesta correcta; hay
#     respuestas defendibles y respuestas flojas.
#
# (c) Calcula la media de pct_shh entre las 32 entidades. Después acuérdate
#     de la advertencia de la sesión: ¿ese número es el porcentaje nacional
#     de la coalición? Explica en un comentario por qué no.
#
# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) En el gráfico, cambia geom_col() por geom_point(). Córrelo. ¿Qué pasó?
#     ¿Se ve mejor o peor? ¿Para qué pregunta serviría cada uno?
#
# (b) Investiga qué hace exactamente coord_flip(). Tienes tres caminos y los
#     tres son legítimos:
#       · escribe ?coord_flip en la consola y lee la ayuda;
#       · búscalo en la documentación de ggplot2 en línea;
#       · pregúntale a una IA.
#     Si usas la IA, hazle además esta pregunta: "¿hay una forma más moderna
#     de hacer un gráfico de barras horizontal en ggplot2 sin coord_flip()?".
#     Y después VERIFICA lo que te conteste corriéndolo. La sesión 11 va a
#     tratar precisamente de eso: la IA es buena dando pistas y es capaz de
#     inventarte una función que no existe con toda seguridad del mundo.
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el error que
#     más veces te salió hoy y qué significaba. Guárdalo. Vas a volver a él.
#
# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, que no tiene código:
#
# Piensa en una pregunta sobre política mexicana que te interese de verdad
# y escríbela aquí abajo, en un comentario. Cualquiera. No importa si hoy
# no sabes contestarla; importa que esté escrita.
#
# Vamos a volver a ella. En la sesión 11 quiero que puedas mirarla y decidir,
# tú, si con lo que aprendiste alcanza para contestarla o no.
#
# Mi pregunta es:
#
# ==============================================================
