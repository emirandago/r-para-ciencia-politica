# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 1 · Funciones e iteración a profundidad
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Escribir funciones propias con argumentos por omisión y con
#   condicionales adentro, entender el alcance (scope), generar
#   secuencias con rep()/seq()/replicate(), recorrer una lista con un
#   for y con purrr::map_dbl(), comparar conjuntos con intersect(),
#   union() y setdiff(), y cerrar con una función que recibe el NOMBRE
#   de una columna como argumento para producir varios mapas de México
#   con un ciclo, no con varios bloques de código pegados.
#
# Qué necesitas antes de empezar:
#   Las sesiones 1 a 4 (objetos, vectores, el pipe, group_by/summarise)
#   y la sesión 7 (mapas con sf) para el último bloque. No necesitas
#   haber visto la sesión 10: este extra es el "a fondo" de funciones
#   propias que esa sesión promete y no alcanza a dar en una hora.
#
# Este es un módulo AUTOESTUDIABLE. Este script corre completo, de
# arriba abajo, SIN huecos: nadie te lo va a explicar en voz alta.
#
# Datos: INE, cómputos distritales de la elección presidencial de 2024,
#        por entidad; INEGI, Marco Geoestadístico 2025 simplificado.
#        Ver datos/README.md.
# Autor: Emiliano Miranda González
# ==============================================================


# ---- 0. Los paquetes ----

# Nada nuevo hoy: tidyverse (que trae dplyr, ggplot2 y purrr, el
# paquete de iteración que vamos a usar más abajo), here para rutas,
# sf para el mapa del final y patchwork para acomodar varios mapas
# juntos, ya los instalaste en sesiones anteriores.
#
#   install.packages(c("tidyverse", "here", "sf", "patchwork"))

library(tidyverse)
library(here)
library(sf)
library(patchwork)

source(here("estilo", "tema_lab.R"))


# ---- 1. Por qué escribir una función propia ----

# La regla informal: si copiaste y pegaste el mismo bloque de código
# tres veces, cambiando solo un nombre, esa tercera vez debiste haber
# escrito una función. Cada copia es un lugar más donde un error se
# puede esconder sin que lo notes.

resultados_entidad <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))


# ---- 2. La anatomía de una función ----

# function(argumentos) { cuerpo } es toda la sintaxis que necesitas.
# return() es opcional: si no lo escribes, R devuelve el resultado de
# la ÚLTIMA línea que se evaluó dentro de la función. Aquí lo dejamos
# explícito porque deja clarísimo, para quien lea el código después,
# dónde termina el cálculo.

calcular_ventaja <- function(pct_primero, pct_segundo) {
  ventaja <- pct_primero - pct_segundo
  return(ventaja)
}

calcular_ventaja(resultados_entidad$pct_shh, resultados_entidad$pct_fcm)

# Fíjate que le pasamos DOS VECTORES de 32 números cada uno, no dos
# números sueltos, y la función funcionó igual: R vectoriza las
# operaciones aritméticas de adentro sin que hayas escrito una sola
# línea pensando en eso. Ese es el mismo salto de la sesión 1, ahora
# empaquetado dentro de una función propia.


# ---- 3. Argumentos por omisión y un condicional adentro ----

# Un argumento puede traer un valor de fábrica —se usa si nadie
# especifica otro— y el cuerpo de una función puede tener un if/else
# igual que cualquier otro bloque de R.

clasificar_margen <- function(ventaja, umbral = 20) {
  if (ventaja > umbral) {
    "arrasadora"
  } else if (ventaja > 0) {
    "cerrada"
  } else {
    "perdida"
  }
}

clasificar_margen(25)        # usa el umbral de fábrica: 20
clasificar_margen(25, 10)    # sobreescribe el umbral con un segundo argumento

# clasificar_margen() solo acepta UN número a la vez, no un vector
# completo, porque if() —a diferencia de las operaciones aritméticas
# de la sección 2— exige una sola condición lógica, no 32. Para
# aplicarla a las 32 entidades a la vez vamos a necesitar iterar, que
# es exactamente el tema de las siguientes tres secciones.


# ---- 4. El alcance: qué tan lejos ve una función ----

# Una variable creada DENTRO de una función no existe fuera de ella.
# Compruébalo: la siguiente línea, después de correr la función, va a
# marcar error si la corres suelta en la consola.

demostrar_alcance <- function(x) {
  resultado_interno <- x * 2
  resultado_interno
}

demostrar_alcance(21)

# Corre esta línea sola en la consola (no la vamos a dejar activa en
# el script porque el script completo tiene que correr sin errores):
#
#   resultado_interno
#
# Va a marcar "object 'resultado_interno' not found". No es un bug:
# es exactamente lo que permite que cien funciones distintas en el
# mismo script usen el mismo nombre de variable por dentro sin
# pisarse una a la otra.


# ---- 5. rep(), seq() y replicate(): generar antes de iterar ----

rep("Morena", 5)                    # repite un valor
rep(c("SHH", "FCM"), times = 3)     # repite un patrón completo, tres veces
rep(c("SHH", "FCM"), each = 3)      # repite cada elemento tres veces antes de pasar al siguiente

seq(0, 100, by = 10)                # secuencia con un salto fijo
seq(0, 100, length.out = 5)         # secuencia con un número fijo de pasos, sin importar el salto

set.seed(2026)
replicate(4, mean(sample(1:100, 10)))

# replicate() es distinta de rep()/seq(): no repite un DATO, repite
# una OPERACIÓN completa —aquí, "saca una muestra de 10 números entre
# 1 y 100 y calcula su media"— tantas veces como le pidas, y junta los
# resultados en un vector. set.seed() fija el punto de partida del
# generador aleatorio de R para que, si vuelves a correr este bloque,
# te salgan los mismos cuatro números: sin set.seed(), cada corrida
# daría resultados distintos y nadie más podría reproducir los tuyos.
# Vas a ver esto mucho más desarrollado en el extra 2.


# ---- 6. El bucle for ----

columnas_pct <- c("pct_shh", "pct_fcm", "pct_mc")

# vector("double", n) reserva, antes de empezar, un espacio del
# tamaño correcto para guardar los resultados. Un for que va
# agrandando un vector con c() dentro de cada vuelta funciona igual
# de bien con tres columnas y se vuelve perceptiblemente lento con
# miles de vueltas, porque R copia el vector completo cada vez que
# crece. Reservar el espacio primero evita el problema desde el inicio.

promedios_for <- vector("double", length(columnas_pct))
names(promedios_for) <- columnas_pct

for (columna in columnas_pct) {
  promedios_for[columna] <- mean(resultados_entidad[[columna]])
}

promedios_for

# resultados_entidad[[columna]] saca la columna cuyo NOMBRE está
# guardado en la variable columna. Con corchetes dobles, R busca lo
# que la variable dice, no un nombre fijo tecleado: eso es lo que le
# permite a este mismo for funcionar sin cambios si mañana agregas una
# cuarta columna al vector columnas_pct.


# ---- 7. La alternativa moderna: purrr::map_dbl() ----

# El mismo resultado que el for de arriba, en menos líneas:

promedios_map <- resultados_entidad |>
  select(all_of(columnas_pct)) |>
  map_dbl(mean)

promedios_map

# map_dbl() recorre cada columna de la tabla, le aplica mean() y
# devuelve un vector de números (_dbl es por double, el tipo numérico
# decimal de R). La ventaja sobre el for no es velocidad —para este
# tamaño de datos no la notarías—: es que map_dbl() GARANTIZA que la
# salida es un vector de números y avisa con un error si alguna
# columna no lo produce. Compara los dos resultados: promedios_for y
# promedios_map deben ser exactamente iguales.

identical(unname(promedios_for), unname(promedios_map))


# ---- 8. Operaciones de conjuntos: intersect(), union(), setdiff() ----

entidades_shh_alto <- resultados_entidad |>
  filter(pct_shh > 60) |>
  pull(entidad)

entidades_participacion_alta <- resultados_entidad |>
  filter(participacion > 65) |>
  pull(entidad)

length(entidades_shh_alto)               # cuántas entidades pasan el primer filtro
length(entidades_participacion_alta)     # cuántas pasan el segundo

intersect(entidades_shh_alto, entidades_participacion_alta)  # en las DOS listas
union(entidades_shh_alto, entidades_participacion_alta)      # en CUALQUIERA de las dos
setdiff(entidades_shh_alto, entidades_participacion_alta)    # en la primera, NO en la segunda
setdiff(entidades_participacion_alta, entidades_shh_alto)    # en la segunda, NO en la primera

# Fíjate que las últimas dos líneas dan resultados distintos: setdiff()
# NO es simétrica. Con los datos reales de 2024, diecinueve entidades
# tienen más de 60% de votos para SHH y solo cinco tienen más de 65%
# de participación; la intersección son exactamente tres: Puebla,
# Tlaxcala y Yucatán. pull() es el atajo que saca una sola columna de
# una tabla como vector, igual que $, pero sí se puede encadenar
# dentro de un pipe |>.


# ---- 9. EL SALTO: una función que recibe el NOMBRE de una columna ----

# Hasta aquí, cada gráfico del curso escribió el nombre de una columna
# tecleado directo dentro de aes(): aes(fill = pct_shh). Eso funciona
# porque ggplot2 sabe buscar pct_shh sin que vaya entre comillas. El
# problema aparece cuando TÚ quieres que el nombre de la columna sea
# una VARIABLE —el argumento de una función— en vez de un texto fijo.

entidades_geo <- read_rds(here("datos", "geo", "entidades_simplificado.rds"))

mapa_entidades <- entidades_geo |>
  left_join(resultados_entidad, by = "clave_entidad")

# .data es un objeto especial de tidyverse que representa "la tabla
# de datos que se está usando en este momento". .data[[variable]] le
# pide la columna cuyo NOMBRE está guardado en la variable variable
# —el mismo patrón de corchetes dobles de la sección 6, ahora
# funcionando dentro de un aes()—. Esto se llama evaluación diferida
# (tidy evaluation): es, sin exagerar, lo más avanzado de todo el
# laboratorio.

mapa_por_variable <- function(datos, variable, titulo) {
  ggplot(datos) +
    geom_sf(aes(fill = .data[[variable]]), color = "white", linewidth = 0.15) +
    scale_fill_viridis_c() +
    theme_lab_mapa() +
    labs(title = titulo, fill = NULL)
}

# Si esto marca "object 'variable' not found", casi siempre llamaste
# a la función sin comillas en el nombre de columna: mapa_por_variable
# (mapa_entidades, pct_shh, "...") en vez de mapa_por_variable
# (mapa_entidades, "pct_shh", "..."). Dentro de .data[[ ]], el nombre
# tiene que llegar como texto.

mapa_participacion <- mapa_por_variable(mapa_entidades, "participacion", "Participación (%)")
mapa_shh           <- mapa_por_variable(mapa_entidades, "pct_shh",       "Voto SHH (%)")
mapa_fcm           <- mapa_por_variable(mapa_entidades, "pct_fcm",       "Voto FCM (%)")
mapa_mc            <- mapa_por_variable(mapa_entidades, "pct_mc",        "Voto MC (%)")

(mapa_participacion | mapa_shh) / (mapa_fcm | mapa_mc)

# Cuatro mapas, con una función escrita UNA sola vez. Este patrón
# —una función con .data[[var]] adentro, llamada una vez por columna—
# viene, con muy pocos cambios, del curso de Aldo Gómez, que la usó
# para construir seis mapas de la Ciudad de México con una sola
# función llamada map_var(). Es la pieza de código más avanzada de
# los tres cursos heredados, y por eso vive aquí y no en el camino
# crítico de las once sesiones.


# ---- 10. Cámbiale algo ----

# Agrega un quinto mapa a la cuadrícula: usa mapa_por_variable() sobre
# la columna votos_shh (el CONTEO, no el porcentaje) y compáralo
# contra mapa_shh. ¿Se parecen? Si no, ¿por qué no? (Pista: la sesión
# 7 ya contestó exactamente esta pregunta con los municipios; aquí la
# vas a ver otra vez, con las entidades.)

mapa_conteo <- mapa_por_variable(mapa_entidades, "votos_shh", "Votos de SHH (conteo)")
mapa_conteo | mapa_shh


# ==============================================================
# La pregunta abierta del cierre.
#
# Escribiste una función, mapa_por_variable(), que funciona para
# CUALQUIER columna numérica de mapa_entidades con solo cambiar un
# argumento de texto. ¿Qué tendría que cambiar en esa función para que
# también sirviera para mapa_municipios, el objeto de la sesión 7 con
# 2,478 filas en vez de 32? Y una segunda: ¿qué pasaría si le pidieras
# que graficara una columna de texto, como "entidad", en vez de una
# numérica? Pruébalo y lee el error con calma.
# ==============================================================
