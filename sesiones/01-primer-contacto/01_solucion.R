# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 01 · Solución comentada del ejercicio
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

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))


# ---- Nivel 1 · Calentamiento ----

# Solo hay que cambiar la variable en dos lugares: dentro de reorder() y en
# el eje y. Es el mismo esqueleto. Que sea el mismo esqueleto es justamente
# lo que se quería mostrar: un gráfico de ggplot2 no se escribe de cero cada
# vez, se adapta.

ggplot(resultados, aes(x = reorder(entidad, lista_nominal), y = lista_nominal)) +
  geom_col(fill = "#006847") +
  coord_flip() +
  labs(
    title    = "Cuánta gente podía votar en 2024",
    subtitle = "Lista nominal por entidad",
    x        = NULL,
    y        = "Personas en la lista nominal",
    caption  = "Fuente: INE, cómputos distritales 2024."
  ) +
  theme_minimal()

# Sobre la pregunta previa: el orden CAMBIA por completo, y tenía que cambiar.
# La lista nominal mide tamaño de población; la participación mide una
# proporción. El Estado de México y la Ciudad de México se van hasta arriba
# en este gráfico por razones demográficas, no políticas.
#
# Ese contraste es el primer hábito estadístico del curso y vale más que
# cualquier función: casi siempre queremos proporciones, no conteos. Un mapa
# de "número de homicidios" es, en buena medida, un mapa de dónde vive la
# gente. Lo veremos otra vez, y peor, en la sesión 7.


# ---- Nivel 2 · De verdad ----

# (a) Mismo esqueleto otra vez.

ggplot(resultados, aes(x = reorder(entidad, pct_shh), y = pct_shh)) +
  geom_col(fill = "#006847") +
  coord_flip() +
  labs(
    title    = "¿Dónde le fue mejor a Sigamos Haciendo Historia?",
    subtitle = "Porcentaje de votos de la coalición, por entidad, 2024",
    x        = NULL,
    y        = "Porcentaje de votos (%)",
    caption  = "Fuente: INE, cómputos distritales 2024."
  ) +
  theme_minimal()

# (b) La comparación entre los dos gráficos.
#
# Comparar dos gráficos poniéndolos uno al lado del otro es un método
# legítimo y también es el más débil que hay: el ojo humano es pésimo para
# comparar órdenes entre dos listas de 32 elementos. Lo que de verdad
# contesta la pregunta es poner las dos variables en un mismo plano, una en
# cada eje, y ver si hay patrón. Eso se llama diagrama de dispersión y llega
# en la sesión 8, junto con la correlación.
#
# Por ahora, lo honesto es decir: parecen no coincidir del todo, y no puedo
# afirmar más con lo que sé hoy. Esa frase —"no puedo afirmar más con lo que
# sé hoy"— es una respuesta profesional, no una excusa.
#
# Y hay una razón sustantiva para desconfiar de la coincidencia: participación
# y voto por un partido responden a cosas distintas. Que en Yucatán vote mucha
# gente no dice nada, por sí solo, sobre a quién votan.

# (c) La media, y por qué no es lo que parece.

mean(resultados$pct_shh)

# Ese número es el promedio simple de 32 porcentajes. Le da exactamente el
# mismo peso a Colima, con unos cientos de miles de votantes, que al Estado
# de México, con millones. El porcentaje nacional real es una media PONDERADA
# por el número de votos de cada entidad, y sale distinto.
#
# Se calcula así, con las herramientas de hoy:

sum(resultados$votos_shh) / sum(resultados$total_votos) * 100

# Compara los dos números. La diferencia entre ellos es, literalmente, la
# diferencia entre "el estado promedio" y "el país". Son dos preguntas
# distintas y las dos son legítimas; lo que no es legítimo es calcular una
# y decir que contestaste la otra.
#
# En la sesión 4, cuando veamos group_by() y summarise(), este cálculo va a
# quedar en dos líneas legibles en vez de una operación con sum() anidados.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) geom_col() contra geom_point().

ggplot(resultados, aes(x = reorder(entidad, pct_shh), y = pct_shh)) +
  geom_point(color = "#006847", size = 2.5) +
  coord_flip() +
  labs(
    title    = "El mismo dato, con puntos en vez de barras",
    x        = NULL,
    y        = "Porcentaje de votos (%)",
    caption  = "Fuente: INE, cómputos distritales 2024."
  ) +
  theme_minimal()

# ¿Cuál es mejor? Depende de la pregunta, y esta es una decisión de diseño
# con un argumento detrás, no un gusto.
#
# La barra codifica la magnitud en su LONGITUD, y una longitud se lee desde
# cero. Por eso una barra que no arranca en cero miente. El punto codifica la
# magnitud en su POSICIÓN, y una posición no necesita el cero: por eso con
# puntos puedes acercarte al rango donde están los datos y ver diferencias
# que en barras quedan aplastadas.
#
# Regla práctica: barras para conteos y para cuando el cero importa; puntos
# para porcentajes y comparaciones finas. Volveremos a esto en la sesión 6,
# donde se llama ética visual y tiene bibliografía.

# (b) coord_flip() y su alternativa moderna.
#
# coord_flip() intercambia los ejes DESPUÉS de construir el gráfico. Funciona
# perfectamente y no está deprecada.
#
# Pero desde ggplot2 3.3 hay una forma más directa: poner la variable
# categórica en el eje y desde el principio. Las funciones de ggplot2
# entienden las dos orientaciones solas.

ggplot(resultados, aes(x = pct_shh, y = reorder(entidad, pct_shh))) +
  geom_col(fill = "#006847") +
  labs(
    title   = "Sin coord_flip(): la categoría va directo al eje y",
    x       = "Porcentaje de votos (%)",
    y       = NULL,
    caption = "Fuente: INE, cómputos distritales 2024."
  ) +
  theme_minimal()

# Las dos versiones producen prácticamente el mismo gráfico. La segunda es
# más corta y más fácil de razonar, porque lo que escribes es lo que ves.
#
# Nota sobre el camino (b) del ejercicio, si le preguntaste a una IA: es muy
# probable que te haya dado esta respuesta y que sea correcta. También es
# posible que te haya dicho que coord_flip() está "deprecada", que NO lo está,
# o que te haya inventado un argumento que no existe. La diferencia entre las
# dos situaciones no la ves leyendo: la ves corriendo el código. Ese es el
# reflejo que la sesión 11 quiere dejarte instalado.

# (c) El error más frecuente.
#
# En una primera sesión, casi siempre es uno de estos tres:
#
#   Error: object 'x' not found
#     → no corriste la línea donde se creó, o lo escribiste distinto.
#
#   Error in library(tidyverse) : there is no package called 'tidyverse'
#     → no lo instalaste. install.packages("tidyverse"), una vez, en la consola.
#
#   + parpadeando en la consola y nada pasa
#     → no es un error: R está esperando a que termines. Te faltó cerrar un
#       paréntesis o una comilla. Aprieta Esc y revisa la línea.
#
# Los tres están en recursos/errores-comunes.qmd, con más. Ese documento no
# es un anexo: es parte del temario.


# ==============================================================
# Sobre la pregunta que escribiste al final del ejercicio:
#
# Guárdala. En serio. Ponla en un archivo aparte si quieres.
#
# Casi todo lo que sigue del laboratorio va a tener más sentido si lo
# lees como intentos sucesivos de acercarte a una pregunta tuya, en vez
# de como una lista de funciones que hay que aprenderse.
# ==============================================================
