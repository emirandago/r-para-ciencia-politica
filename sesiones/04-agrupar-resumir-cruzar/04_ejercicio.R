# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 04 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 04_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

library(tidyverse)
library(here)

resultados_entidad  <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))
puente               <- read_csv(here("datos", "limpios", "puente_claves_ine_inegi.csv"))


# ---- Nivel 1 · Calentamiento ----

# Reproduce el resumen por región de la sesión, pero con Movimiento
# Ciudadano (la columna pct_mc) en vez de Sigamos Haciendo Historia. Vas
# a necesitar mutate() + case_when() para crear la columna region —usa
# exactamente los mismos cinco grupos de entidades que usamos en clase—
# y después group_by(region) + summarise() con el promedio simple y el
# ponderado de pct_mc.
#
# Antes de correrlo, contesta mentalmente: Movimiento Ciudadano sacó su
# mejor resultado en algunas capitales y zonas urbanas concretas más que
# en franjas geográficas completas. ¿Esperas que la diferencia entre el
# promedio simple y el ponderado sea del mismo tamaño que la que viste
# con pct_shh, más chica, o más grande? Anota tu respuesta en un
# comentario antes de correr el código.

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----
# [PENDIENTE: sustituir por base comparada cuando exista en datos/limpios/]
# Esta pregunta está pensada para datos comparados (por ejemplo, tamaño
# de país contra participación electoral, con V-Dem o Quality of
# Government). Todavía no tenemos esa base lista, así que la resolvemos
# hoy con el mismo tipo de pregunta sobre datos mexicanos: el patrón de
# código es idéntico al que vas a necesitar cuando la base comparada
# exista.

# (a) Crea una columna "tamano" en resultados_municipio con mutate() +
#     case_when(): "chico" si lista_nominal < 5,000; "mediano" si está
#     entre 5,000 y 50,000; "grande" si es 50,000 o más. Comprueba con
#     filter(is.na(tamano)) que nadie se quedó sin clasificar.
#
# (b) Agrupa por "tamano" y calcula, con summarise(): cuántos municipios
#     hay en cada grupo (usa n() o resuélvelo con count() en un paso
#     aparte), el promedio SIMPLE de participacion, y el promedio
#     PONDERADO (con total_votos y lista_nominal, no con participacion).
#
# (c) Contesta en un comentario, con tus palabras: ¿los municipios
#     grandes participan más o menos que los chicos? ¿La diferencia entre
#     el promedio simple y el ponderado es distinta según el tamaño del
#     grupo? No hay una respuesta única correcta; hay respuestas que se
#     apoyan en el número y respuestas que se lo inventan.
#
# (d) Ahora usa el puente: filtra puente para quedarte solo con las filas
#     donde clave_municipio_inegi es distinto de clave_municipio_ife, y
#     cuenta cuántas hay por entidad con count(entidad, sort = TRUE).
#     ¿Qué entidad tiene más municipios con clave distinta entre INE e
#     INEGI? ¿Te sorprende, dado lo que viste en la sesión sobre esa
#     misma entidad y el número de sus municipios?

# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) pivot_wider() es la operación inversa de pivot_longer(): en vez de
#     acomodar columnas en filas, acomoda valores de una columna como
#     columnas nuevas. Tómate cinco minutos con una de estas tres rutas
#     —las tres son legítimas—: escribe ?pivot_wider en la consola y lee
#     la ayuda; búscalo en la documentación de tidyr en línea; o
#     pregúntale a una IA "¿cómo revierto un pivot_longer() con
#     pivot_wider()?" usando resultados_largo (la tabla que creamos en
#     clase) como ejemplo. Después VERIFICA lo que te haya contestado
#     corriéndolo: ¿el resultado de pivot_wider(resultados_largo, ...) es
#     igual a resultados_entidad, o casi?
#
# (b) Investiga qué hace el argumento relationship de left_join() —lo
#     mencionamos de pasada en clase—. ¿Qué pasaría si al intento por
#     nombre le agregas relationship = "many-to-many" en vez de
#     corregirlo por clave? Pruébalo y compara nrow() de los dos
#     resultados.
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el momento
#     de hoy en el que más te costó confiar en el resultado del código
#     —el warning del join, el NA de case_when(), otro—. Guárdalo. Vas a
#     volver a él.

# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, que no tiene código:
#
# Piensa en dos bases de datos que a ti te interese cruzar algún día
# —para una tarea, para el proyecto final, para algo que ni siquiera es
# de la escuela— y escribe aquí, en un comentario, qué columna usarías
# para unirlas y por qué sospechas, antes de intentarlo, que esa columna
# sí va a identificar una sola fila de cada lado.
#
# Mi respuesta es:
#
# ==============================================================
