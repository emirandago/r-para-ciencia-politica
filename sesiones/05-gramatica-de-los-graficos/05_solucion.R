# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 05 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Se publica después de la sesión. Si llegaste aquí sin haber peleado
# con el ejercicio, regrésate: la solución solo enseña algo a quien ya
# se atoró. Leer código correcto sin haberlo intentado se siente como
# aprender y no lo es.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)

resultados_entidad   <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

# Mismo esqueleto, otra columna. Es justo lo que se quería mostrar: un
# gráfico de ggplot2 no se escribe de cero cada vez, se adapta.

ggplot(resultados_entidad, aes(x = pct_shh, y = reorder(entidad, pct_shh), fill = pct_shh)) +
  geom_col() +
  scale_fill_viridis_c() +
  labs(
    title   = "¿Dónde le fue mejor a Sigamos Haciendo Historia en 2024?",
    x       = "Porcentaje de votos de la coalición (%)",
    y       = NULL,
    caption = "Fuente: INE, cómputos distritales 2024."
  )

# Sobre la pregunta previa: el orden SÍ cambia, y no tenía por qué ser el
# mismo. participacion mide cuánta gente salió a votar; pct_shh mide, de
# quienes votaron, cuántos eligieron esa coalición. Son preguntas
# distintas y no hay ninguna razón para esperar que el estado más
# participativo sea también el más favorable a un bloque en particular.
# Ese es el mismo hábito que ya viste en la sesión 1 con lista_nominal
# contra participacion: dos variables pueden estar correlacionadas o no,
# y "no tengo por qué asumir que sí" es la postura por defecto.


# ---- Nivel 2 · De verdad ----

# (a) Filtrar los municipios grandes.

municipios_grandes <- resultados_municipio |>
  filter(lista_nominal > 300000)

nrow(municipios_grandes)  # 69 municipios con más de 300 mil personas en la lista nominal

# (b) El gráfico divergente, con midpoint = 0 explícito.

ggplot(municipios_grandes, aes(x = ventaja_shh, y = reorder(municipio, ventaja_shh), fill = ventaja_shh)) +
  geom_col() +
  scale_fill_gradient2(low = "#B2182B", mid = "white", high = "#2166AC", midpoint = 0) +
  labs(
    title   = "¿Qué tan cerrada estuvo la elección en las 69 ciudades más grandes?",
    x       = "Ventaja de SHH sobre el segundo lugar (puntos porcentuales)",
    y       = NULL,
    caption = "Fuente: INE, cómputos distritales 2024."
  )

# Con 69 municipios, este gráfico sale altísimo y las etiquetas del eje y
# se amontonan — es un problema real y honesto de esta base, no un error
# tuyo. Dos salidas razonables, ninguna obligatoria en este ejercicio:
# quedarte solo con los 20-25 municipios más grandes con head() después
# de arrange(), o esperar a la sesión 6, donde facet_wrap() y las figuras
# pensadas para imprimirse resuelven exactamente este problema.

# (c) Por qué divergente aquí y no en participacion.

# ventaja_shh tiene un cero SUSTANTIVO: no es un punto que inventamos
# calculando un promedio, es el lugar exacto donde cambia la respuesta a
# la pregunta "¿quién va ganando?". Positivo quiere decir que Sigamos
# Haciendo Historia le gana al segundo lugar; negativo, que le gana el
# otro bloque. Hay dos bandos reales, y el cero es la frontera entre
# ambos: es exactamente la situación que una escala divergente está
# hecha para mostrar.
#
# participacion no tiene esa estructura. No hay un "bando de la baja
# participación" y un "bando de la alta participación" que diverjan desde
# un centro: es una sola magnitud continua, de menos a más. Cualquier
# punto que uses como midpoint —el promedio, la mediana, un número
# redondo— sería un corte que TÚ decidiste, no uno que la variable trae
# consigo. Usar una escala divergente ahí inventaría una frontera que no
# existe, que es exactamente el error que se nombró en la sesión como
# EL SALTO.

# (d) Cuántos municipios grandes tuvieron ventaja negativa.

municipios_ventaja_negativa <- municipios_grandes |>
  filter(ventaja_shh < 0)

nrow(municipios_ventaja_negativa)  # 8 de 69

# Ocho de sesenta y nueve —poco más del 11%— no es un número enorme, pero
# tampoco es anecdótico, y su composición es más interesante que la
# cifra sola: son sobre todo capitales y ciudades del centro-norte y del
# occidente (Aguascalientes, Chihuahua capital, León, Zapopan, Monterrey,
# San Nicolás de los Garza) más dos alcaldías de la Ciudad de México
# (Benito Juárez, con la ventaja más negativa de toda la lista, y Miguel
# Hidalgo). Esto no es una prueba de nada por sí solo —ocho casos no
# permiten generalizar, y este ejercicio no controla por ningún otro
# factor— pero sí es exactamente el tipo de patrón geográfico que un
# mapa (sesión 7) va a poder mostrar mejor que esta lista.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) rainbow() sobre 69 municipios.

ggplot(municipios_grandes, aes(x = ventaja_shh, y = reorder(municipio, ventaja_shh), fill = municipio)) +
  geom_col() +
  scale_fill_manual(values = rainbow(nrow(municipios_grandes))) +
  labs(x = "Ventaja de SHH (puntos porcentuales)", y = NULL)

# Con 69 colores, rainbow() ya ni siquiera intenta distinguir categorías:
# el círculo cromático completo se reparte en pasos tan finos que colores
# vecinos son casi indistinguibles para cualquiera, con o sin daltonismo.
# Y en este gráfico en particular el color es redundante de todos modos:
# cada municipio ya tiene su propia fila en el eje y, así que fill no
# está aportando ninguna información que la posición no dé ya. Es un
# segundo error, distinto del de la sesión: usar color para una variable
# que no lo necesita, "porque se ve más completo".
#
# La regla práctica de la sesión (6 a 8 colores categóricos como techo)
# no es arbitraria: es, aproximadamente, donde la discriminación humana
# de colores cualitativos empieza a degradarse rápido. Pasado ese número,
# la salida no es "más colores", es reagrupar, facetar o quitar el color.

# (b) ggokabeito y colorBlindness::cvdPlot().
#
#   # install.packages(c("ggokabeito", "colorBlindness"))
#
# ggokabeito implementa la paleta de Okabe & Ito (2008): ocho colores
# diseñados a propósito para distinguirse bajo cualquier forma común de
# daltonismo, la misma que R usa desde la versión 4.0.0 como paleta
# cualitativa por defecto de grDevices::palette(). Se usa como cualquier
# otra escala de ggplot2:
#
#   library(ggokabeito)
#   ggplot(entidades_top8, aes(x = participacion, y = reorder(entidad, participacion), fill = entidad)) +
#     geom_col() +
#     scale_fill_okabe_ito()
#
# colorBlindness::cvdPlot() hace algo distinto y complementario: no te da
# una paleta, TE MUESTRA cómo se ve un gráfico ya hecho bajo distintos
# tipos de daltonismo, en un panel comparativo. Es la herramienta que
# usarías para verificar una paleta que armaste a mano con
# scale_fill_manual(), en vez de confiar en que "se ve bien en tu
# pantalla" — que es precisamente la trampa en la que cae rainbow().
#
# Si le preguntaste esto a una IA, es probable que te haya dado una
# respuesta correcta en lo esencial (que existen paletas colorblind-safe
# y herramientas para verificar), pero conviene desconfiar de cualquier
# nombre de función que no hayas visto correr con tus propios ojos: es
# exactamente el tipo de detalle —el nombre exacto del argumento, si el
# paquete se llama así o casi así— donde una IA inventa con total
# seguridad. Instalar y correr el ejemplo es la única verificación que
# cuenta. Nota aparte, y vale la pena repetirla: "colorblind-safe" y
# "perceptualmente uniforme" no son lo mismo. Una paleta puede distinguir
# bien las categorías bajo daltonismo (colorblind-safe, el caso de
# Okabe-Ito o de Dark2) sin que sus pasos representen intervalos iguales
# de magnitud (perceptualmente uniforme, el caso de viridis). La primera
# propiedad importa sobre todo para paletas CUALITATIVAS; la segunda,
# para paletas SECUENCIALES y DIVERGENTES.

# (c) El error o advertencia más frecuente.
#
# En esta sesión, casi siempre es uno de estos tres:
#
#   Warning: Ignoring unknown aesthetics: fill
#     → se mapeó fill en un geom que solo tiene trazo (geom_line(),
#       geom_point()). El argumento correcto ahí es colour.
#
#   Un geom_line() que no dibuja nada
#     → falta group = 1 cuando el eje x es una categoría y cada valor
#       aparece una sola vez en los datos.
#
#   Error in `scale_fill_manual()` / `scale_fill_brewer()`: valores
#   insuficientes
#     → se le pasó a la escala menos colores de los que hay categorías
#       (por ejemplo, rainbow(5) para un fill con 8 niveles).
#
# Los tres, con más detalle, están en recursos/errores-comunes.qmd.


# ==============================================================
# Sobre la pregunta de cierre, la que conecta con tu pregunta de la
# sesión 1:
#
# No hay una respuesta única, y no se califica. Lo que sí vale la pena
# notar es el patrón: la mayoría de las preguntas politológicas reales
# —quién ganó, cuánto cambió, qué tan parejo estuvo— traen su propio tipo
# de escala ya implícito en cómo está formulada la pregunta. Aprender a
# leer eso ANTES de escribir scale_fill_*() es más importante que
# memorizar los nombres de las funciones.
# ==============================================================
