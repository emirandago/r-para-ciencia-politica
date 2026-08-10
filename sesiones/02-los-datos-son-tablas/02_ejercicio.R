# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 02 · Ejercicio para llevar
# ---------------------------------------------------------------
# [PENDIENTE: sustituir por una base comparada (V-Dem, Latinobarometro o
# Quality of Government) cuando exista en datos/limpios/. Segun el reparto
# del curso, el ejercicio de una sesion par deberia ser comparado; por ahora
# esa base todavia no esta en el repositorio, asi que este ejercicio se
# construyo contra bases mexicanas ya verificadas y documentadas.]
#
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 02_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

library(tidyverse)
library(here)

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))


# ---- Nivel 1 · Calentamiento ----

# En clase cargaste puente_claves_ine_inegi.csv en un objeto llamado
# municipios. Vuelve a cargarlo aquí y corre glimpse() sobre él.
#
# Antes de correrlo, anticipa mentalmente: ¿cuántas filas esperas?
# ¿Esperas que clave_municipio_inegi y clave_municipio_ife salgan como
# <chr> o como número? Piénsalo antes de mirar la respuesta en la consola.
#
# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# Vamos a abrir una base que NO usamos en clase: los resultados de la misma
# elección de 2024, pero por MUNICIPIO en vez de por entidad. El archivo se
# llama presidencial_2024_municipio.csv y vive en el mismo lugar que las
# demás bases limpias.
#
# (a) Cárgala en un objeto llamado resultados_municipio y corre glimpse().
#     ¿Cuántas filas tiene? ¿Qué es, en esta base, una fila?
#
# (b) La columna pct_shh trae el porcentaje de votos de la coalición
#     Sigamos Haciendo Historia, por municipio. Cuenta cuántos NA tiene esa
#     columna con sum(is.na(...)).
#
# (c) El dato de README.md dice que esos NA no son un error: en los
#     municipios donde aparecen, ninguna casilla se instaló el día de la
#     elección. En un comentario de dos o tres líneas, con tus palabras,
#     explica por qué convertir esos NA en 0 sería una mala decisión para
#     cualquier análisis que se haga con esta base después.
#
# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) R tiene otro valor especial que se parece a NA y no es lo mismo:
#     NULL. Investiga la diferencia entre NA y NULL. Tienes tres caminos y
#     los tres son legítimos:
#       · escribe ?NULL en la consola y lee la ayuda;
#       · búscalo en la documentación de R en línea;
#       · pregúntale a una IA.
#     Si usas la IA, pídele además un ejemplo de código que muestre la
#     diferencia, y VERIFÍCALO corriéndolo tú. Prueba en particular qué
#     regresan length(NA) y length(NULL): ese solo contraste suele bastar
#     para entender por qué son cosas distintas.
#
# (b) Escribe en un comentario, en una sola oración, cuál fue el error o
#     el aviso que más veces te salió hoy y qué significaba. Guárdalo.
#
# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, que no tiene código:
#
# Vuelve a la pregunta que escribiste al final del ejercicio de la
# sesión 1 —la que te interesa de verdad—. Si la contestaras con una
# tabla, ¿qué sería una fila? ¿Sería una foto (corte transversal), una
# película de un solo caso (serie de tiempo), o una película de varios
# casos (panel)? Escríbelo aquí abajo, en un comentario. No hace falta
# tener la base todavía: solo hace falta poder nombrar qué es una fila.
#
# Mi respuesta es:
#
# ==============================================================
