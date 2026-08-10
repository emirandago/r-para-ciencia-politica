# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 10 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 10_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

library(tidyverse)
library(here)

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

# La función de hoy, por si la necesitas y no la copiaste completa en clase:
pct_ponderado <- function(parte, total) {
  sum(parte) / sum(total) * 100
}


# ---- Nivel 1 · Calentamiento ----

# Usa pct_ponderado() —sin volver a escribir la fórmula— para calcular el
# porcentaje nacional ponderado de Movimiento Ciudadano (la columna
# votos_mc). Compáralo con el promedio simple de pct_mc entre las 32
# entidades: mean(resultados$pct_mc).
#
# Antes de correrlo, contesta mentalmente: Movimiento Ciudadano tuvo un
# resultado más parejo entre estados que las otras dos coaliciones.
# ¿Esperas que la diferencia entre el número simple y el ponderado sea
# más chica que la que viste con Sigamos Haciendo Historia, o más grande?
#
# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad — comparado ----
# [PENDIENTE: sustituir por una base verdaderamente comparada —cruzar
# países con V-Dem, Latinobarómetro o Quality of Government— cuando esa
# base exista en datos/limpios/. Por ahora este ejercicio compara dos
# elecciones mexicanas en vez de dos países: el patrón de código —de
# duplicados, group_by(), y la misma función de hoy— es idéntico al que
# vas a necesitar cuando la base comparada exista.]
#
# Vamos a comparar la participación ponderada de dos elecciones: la
# presidencial de 2024 (la que ya tienes cargada) y la judicial de 2025.
#
# El archivo judicial_2025_scjn_municipio.csv trae una fila por cada
# combinación de municipio y candidatura —158,528 filas—, así que
# lista_nominal_2025 y personas_votaron_2025 vienen REPETIDAS 64 veces por
# cada municipio (una vez por candidatura a la Corte). Si agrupas y sumas
# sin quitar antes esa repetición, tu resultado va a salir 64 veces más
# grande de lo que debería. Por eso este primer paso ya viene resuelto:
# no es el punto de hoy, es una trampa ya documentada en datos/README.md.

judicial <- read_csv(here("datos", "limpios", "judicial_2025_scjn_municipio.csv"))

judicial_municipio <- judicial |>
  distinct(clave_municipio, .keep_all = TRUE) |>          # una fila por municipio
  select(clave_municipio, entidad, lista_nominal_2025, personas_votaron_2025)

# (a) Usa pct_ponderado() sobre judicial_municipio para calcular la
#     participación nacional ponderada de la elección judicial de 2025.
#     El dato ya verificado en datos/README.md es 13.02% —si tu resultado
#     no se acerca a ese número, algo se cargó o se filtró mal.
#
# (b) Usa la MISMA función sobre resultados (la base presidencial de 2024)
#     para calcular la participación nacional ponderada de esa elección.
#     Recuerda que el denominador correcto es lista_nominal, no una de las
#     columnas de voto por coalición.
#
# (c) En un comentario de tres o cuatro líneas, con tus palabras: ¿qué
#     tan distintas son las dos participaciones? Nombra al menos una razón
#     por la que podrían ser distintas —el tipo de elección, lo desconocida
#     que era la boleta judicial para la mayoría, lo que se te ocurra— y
#     di si tu explicación es algo que puedes defender con estos datos o
#     si es una intuición que tendrías que investigar más para sostener.
#
# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Repite el flujo completo de publicación con este segundo hallazgo:
#     crea un nuevo documento Quarto (puede ser un segundo .qmd dentro de
#     la misma carpeta mi-primer-reporte, o un repositorio nuevo) que
#     compare, en prosa y con código en línea, las dos participaciones que
#     acabas de calcular. Renderízalo y súbelo con el mismo procedimiento
#     de hoy.
#
# (b) Pregúntale a una IA: "¿por qué mi página de GitHub Pages muestra un
#     404 después de activarla?". Vas a recibir varias respuestas posibles
#     —desde "espera un minuto" hasta configuraciones más raras—. Antes de
#     aplicar cualquiera, decide cuál es la más probable dado lo que
#     acabas de ver en clase, y solo entonces pruébala.
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el paso de
#     hoy que más te costó confiar —el YAML, el render, subir los archivos
#     a GitHub, otro—. Guárdalo. Vas a volver a él.
#
# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, que no tiene código:
#
# Manda el link de tu reporte publicado a alguien —un compañero, alguien
# de tu familia, quien sea— y pídele que lo abra sin ninguna instrucción
# tuya de por medio. Escribe aquí, en un comentario, qué fue lo primero
# que esa persona vio, y si eso es lo que tú querías que viera primero.
#
# Mi respuesta es:
#
# ==============================================================
