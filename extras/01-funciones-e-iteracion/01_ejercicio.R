# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 1 · Ejercicio para practicar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el
# tercero si te sobra tiempo o te dio curiosidad. Nadie los revisa:
# son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una
# función que no hayamos visto en 01_script.R. Si sientes que te
# falta una herramienta, no te falta: te falta acordarte de cuál.
#
# La solución comentada está en 01_solucion.R. Intenta primero: el
# punto no es tener la respuesta, es haber peleado diez minutos con
# ella.
# ==============================================================

library(tidyverse)
library(here)

resultados_entidad   <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

# Repite el bloque de promedios_for/promedios_map del script, pero con
# resultados_municipio (2,475 filas) en vez de resultados_entidad (32
# filas). Antes de correrlo: anticipa si esperas que los tres
# promedios (pct_shh, pct_fcm, pct_mc) cambien mucho respecto a los
# que calculaste con las 32 entidades, y por qué. Piensa en la trampa
# del promedio simple contra el ponderado que ya viste en las
# sesiones 1 y 4: aquí no estás ponderando por votos, estás cambiando
# la UNIDAD DE ANÁLISIS completa, de entidad a municipio.

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# (a) Escribe una función propia, clasificar_margen_seguro(), muy
#     parecida a clasificar_margen() del script, con esta diferencia:
#     si el argumento ventaja llega como NA, la función tiene que
#     devolver "sin datos" en vez de tronar. (Pista: if(NA > 20) da
#     un error porque R no puede decidir si una comparación con NA es
#     verdadera o falsa. Revisa is.na(ventaja) ANTES de comparar con
#     el umbral, y sal de la función de inmediato si es TRUE.)
#
# (b) Aplícala a la columna ventaja_shh de resultados_municipio con
#     map_chr(), y guarda el resultado en una columna nueva llamada
#     categoria_margen.
#
# (c) Cuenta cuántos municipios caen en cada categoría con count().
#     Contesta en un comentario de dos o tres líneas: ¿la mayoría de
#     los municipios del país tuvo un margen "arrasadora", "cerrada"
#     o "perdida" para SHH en 2024? ¿Te sorprende, comparado con lo
#     que sabías de la cobertura periodística de esa elección?

# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Usa intersect() y setdiff() para comparar dos conjuntos de
#     municipios: los que quedaron clasificados como "arrasadora" en
#     categoria_margen, contra los que tienen lista_nominal por
#     debajo de la MEDIANA nacional (municipios "chicos" en
#     población). ¿Se traslapan mucho los dos conjuntos? Antes de
#     correrlo, anticipa una respuesta con lo que ya sabes de este
#     módulo y del extra sobre cómo se reparte la población en
#     México (sesión 8).
#
# (b) Investiga qué hace purrr::map2_dbl(), con la documentación
#     (?map2_dbl) o con una IA —y VERIFICA lo que te conteste,
#     corriendo un ejemplo mínimo—. ¿Para qué serviría si quisieras
#     iterar sobre DOS vectores a la vez —por ejemplo, pct_primero y
#     pct_segundo de calcular_ventaja()— en vez de uno solo?
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el
#     error que más veces te salió hoy y qué significaba.

# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, sin código:
#
# En el script viste que un if() dentro de una función solo acepta
# UNA condición a la vez, y que por eso tuviste que envolverla en
# map_chr() para aplicarla a una columna completa. ¿Se te ocurre
# alguna otra situación, de las que ya viste en las sesiones 1 a 4,
# donde una herramienta que funcionaba perfecto con un solo valor
# necesitó ayuda extra para funcionar con una columna completa?
# ==============================================================
