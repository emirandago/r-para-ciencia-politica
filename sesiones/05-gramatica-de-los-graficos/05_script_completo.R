# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 05 · La gramática de los gráficos
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Entender por qué un gráfico de ggplot2 se arma por capas y no se elige
#   de un menú, escoger entre barras, puntos y línea según la pregunta que
#   tengamos, y justificar una paleta de color como una decisión sustantiva,
#   no un gusto estético. Al final el gráfico prestado de la sesión 1 queda
#   explicado por completo.
#
# Qué necesitas antes de empezar:
#   Haber corrido las sesiones 3 y 4. Usamos filter(), arrange(), mutate()
#   y el pipe |> sin volver a explicarlos.
#
# Datos: INE, cómputos distritales de la elección presidencial de 2024,
#        agregados por entidad y por municipio. Ver datos/README.md.
# Autor: Emiliano Miranda González
# ==============================================================

# ESTA ES LA VERSIÓN RESUELTA. Se publica después de la sesión.
# Si estás en clase, usa 05_script.R.


# ---- 0. Los paquetes ----

#   install.packages(c("tidyverse", "here"))

library(tidyverse)   # dplyr, ggplot2, readr
library(here)


# ---- 1. Los datos de hoy ----

# Dos bases, mismo origen: una agregada por entidad (32 filas, la que ya
# conoces de la sesión 1) y una por municipio (2,475 filas, mucho más fina).
# Hoy las vamos a usar para lo mismo que siempre: hacer gráficos. Lo nuevo
# no es el dato, es entender POR QUÉ el gráfico que ya sabes copiar se ve
# como se ve.

resultados_entidad   <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- 2. La gramática no es un menú ----

# "Gramática de gráficos" no es una metáfora decorativa: significa que un
# gráfico de ggplot2 tiene piezas fijas, con una función cada una, y que se
# combinan con reglas — igual que un idioma. No es un catálogo del que
# eliges "el gráfico de barras" o "el de pastel"; es una receta que armas.
#
# Las piezas, en el orden en que las vas a usar casi siempre:
#
#   1. LOS DATOS       — el tibble que le pasas a ggplot()
#   2. aes()            — qué columna va en cada canal visual (x, y, color...)
#   3. UN geom_*()       — qué forma toman esos datos (barra, punto, línea)
#   4. labs()            — qué hay que leer: título, ejes, fuente
#   5. theme() y ajustes — todo lo que NO son los datos: tamaños, cuadrícula,
#                          facetas, límites de eje
#
# Y hay una regla que resuelve la mitad de las dudas de esta hora:
#
#   TODO LO QUE DEPENDE DE UNA VARIABLE VA DENTRO DE aes().
#   LO QUE ES CONSTANTE PARA TODO EL GRÁFICO VA FUERA.
#
# Compáralas. Son casi el mismo bloque:

# Versión FIJA: un solo verde para las 32 barras, sin importar el dato.
# "#006847" no depende de ninguna columna, por eso va FUERA de aes().
ggplot(resultados_entidad, aes(x = participacion, y = reorder(entidad, participacion))) +
  geom_col(fill = "#006847") +
  labs(x = "Participación (%)", y = NULL)

# ← COMPLETA: la misma idea, pero ahora el color SÍ depende del dato.
# Mapea fill a la propia columna participacion DENTRO de aes(), para que
# cada barra se pinte según su valor. Usa la misma base y las mismas
# columnas que el bloque de arriba; solo cambia dónde va fill.
grafico_participacion_mapeada <- ggplot(
  resultados_entidad,
  aes(x = participacion, y = reorder(entidad, participacion), fill = participacion)
) +
  geom_col() +
  labs(x = "Participación (%)", y = NULL)

grafico_participacion_mapeada

# Fíjate en la diferencia: en la primera versión, fill = "#006847" es un
# argumento de geom_col(), fuera de aes(), y por eso es constante. En la
# segunda, fill = participacion está DENTRO de aes(), y por eso ggplot2
# entiende que tiene que leer la columna fila por fila y decidir un color
# distinto para cada una. La sintaxis se parece; el significado es opuesto.


# ---- 3. aes() global contra aes() local ----

# Un aes() escrito dentro de ggplot() es GLOBAL: todas las capas que
# vengan después lo heredan sin que tengas que repetirlo. Un aes() escrito
# dentro de un geom_*() es LOCAL: solo aplica a esa capa.

ggplot(resultados_entidad, aes(x = participacion, y = reorder(entidad, participacion))) +
  geom_col(fill = "#006847") +                        # hereda x e y; no necesita más
  geom_point(aes(colour = participacion), size = 2)    # aes() local: solo esta capa mapea colour

# Este gráfico no es bonito a propósito: es para ver la mecánica, no para
# publicarse. Las barras se quedaron fijas en verde porque su fill sigue
# fuera de aes(); los puntos encima sí cambian de color porque su aes()
# local mapeó colour a participacion. Cuando en la sesión 7 escribas
# ggplot(datos, aes(...)) + geom_sf(...), es exactamente esta misma regla.


# ---- 4. Tres geoms, un mismo esqueleto ----

# El catálogo completo de geoms de ggplot2 tiene decenas de funciones. Con
# tres alcanza para casi todo lo que vas a necesitar en el resto del curso:
# barras para comparar magnitudes entre categorías, puntos para comparar
# valores finos o relaciones entre dos variables, y línea para series
# donde el orden en el eje x significa algo. (El resto — histograma,
# boxplot, geom_smooth() — llega cuando hace falta, en las sesiones 6 y 8.)

# Barras: geom_col(). La longitud codifica la magnitud, y una longitud se
# lee desde cero — por eso una barra que no arranca en cero miente.
ggplot(resultados_entidad, aes(x = participacion, y = reorder(entidad, participacion))) +
  geom_col(fill = "#006847") +
  labs(x = "Participación (%)", y = NULL)

# ← COMPLETA: el mismo esqueleto de arriba, cambiando solo el geom.
# Copia el bloque anterior y sustituye geom_col() por geom_point(size = 3).
# Deja aes() exactamente igual.
grafico_puntos_participacion <- ggplot(
  resultados_entidad,
  aes(x = participacion, y = reorder(entidad, participacion))
) +
  geom_point(colour = "#006847", size = 3) +
  labs(x = "Participación (%)", y = NULL)

grafico_puntos_participacion

# Puntos: la magnitud queda codificada en la POSICIÓN, no en la longitud.
# Por eso un scatter no necesita empezar en cero: puedes acercar la vista
# al rango donde de verdad están los datos y ver diferencias que en barras
# quedarían aplastadas contra el eje.

# Línea: geom_line() conecta puntos consecutivos siguiendo el orden del
# eje x. Sirve cuando ese orden significa algo de verdad — casi siempre
# tiempo. Aquí no tenemos una serie de tiempo: usamos la línea solo para
# ver qué hace, no para insinuar una tendencia entre entidades.
ggplot(resultados_entidad, aes(x = reorder(entidad, participacion), y = participacion, group = 1)) +
  geom_line(colour = "#006847", linewidth = 1) +
  geom_point(colour = "#006847", size = 2) +
  labs(x = NULL, y = "Participación (%)")

# El group = 1 no es decorativo: bórralo y corre el bloque otra vez. Sin
# él, ggplot2 agrupa por cada valor distinto del eje x — y como cada
# entidad aparece una sola vez, cada una queda en su propio grupo de un
# solo punto. Un grupo de un punto no tiene nada que conectar, así que la
# línea sencillamente no aparece. Es la trampa más común de geom_line()
# con un eje categórico.

# Y la trampa hermana, la de fill contra colour: geom_line() no tiene
# relleno, tiene trazo. Prueba esto y lee la advertencia con cuidado:
ggplot(resultados_entidad, aes(x = reorder(entidad, participacion), y = participacion, group = 1)) +
  geom_line(aes(fill = participacion))

# "Warning: Ignoring unknown aesthetics: fill" — R está diciendo, en
# criollo, "no sé qué hacer con fill aquí, así que lo ignoro". geom_line()
# no tiene una región que rellenar, solo un trazo: el argumento correcto
# es colour, no fill. El mismo par fill/colour reaparece en geom_col()
# —donde sí hay relleno— y en la sesión 7, en geom_sf().


# ---- 5. labs(): qué hay que ver, no qué es ----

# Ya lo dijimos en la sesión 1 y hoy se vuelve regla: un buen título dice
# qué hay que ver, no qué es. Compara estas dos versiones del mismo dato.

# Descriptivo: dice lo que el gráfico YA es. No dirige la mirada a nada.
ggplot(resultados_entidad, aes(x = participacion, y = reorder(entidad, participacion))) +
  geom_col(fill = "#006847") +
  labs(
    title    = "Participacion en la eleccion de 2024, por entidad",
    subtitle = "Porcentaje de la lista nominal que voto",
    x        = "Participacion (%)",
    y        = NULL,
    caption  = "Fuente: INE, computos distritales 2024."
  )

# ← COMPLETA: reescribe el título de arriba como una pregunta que dirija
# la mirada a algo concreto (por ejemplo, a los extremos). Conserva el
# resto del bloque igual — subtitle, ejes y caption no cambian.
grafico_participacion_pregunta <- ggplot(
  resultados_entidad,
  aes(x = participacion, y = reorder(entidad, participacion))
) +
  geom_col(fill = "#006847") +
  labs(
    title    = "¿En qué entidades casi nadie se quedó en casa en 2024?",
    subtitle = "Porcentaje de la lista nominal que votó",
    x        = "Participación (%)",
    y        = NULL,
    caption  = "Fuente: INE, cómputos distritales 2024."
  )

grafico_participacion_pregunta

# labs() tiene cuatro argumentos que casi nunca faltan: title (la
# pregunta), subtitle (la precisión que no cupo en el título), x/y (con
# qué unidad, y NULL cuando el eje ya se explica solo), y caption (la
# fuente: un gráfico sin fuente no se entrega). Todos son texto que
# depende de tu criterio, no de una columna — por eso van fuera de aes(),
# como argumentos de labs() y no como mapeos.


# ---- 6. Color con criterio: el contraejemplo primero ----

# El material heredado de este laboratorio coloreaba mapas de México con
# rainbow(), la función de paletas de R base. Vamos a verla, entender por
# qué parece razonable, y tumbarla.

entidades_top8 <- resultados_entidad |>
  arrange(desc(participacion)) |>
  head(8)

# MAL: rainbow() reparte a mano ocho colores por categoría.
ggplot(entidades_top8, aes(x = participacion, y = reorder(entidad, participacion), fill = entidad)) +
  geom_col() +
  scale_fill_manual(values = rainbow(8)) +
  labs(
    title   = "Las 8 entidades con mayor participación en 2024",
    x       = "Participación (%)",
    y       = NULL,
    caption = "Fuente: INE, cómputos distritales 2024."
  )

# rainbow() reparte matices del círculo cromático a distancias iguales EN
# GRADOS, no en percepción humana: el amarillo se ve mucho más brillante
# que el azul o el morado aunque estén a la misma distancia angular, así
# que el ojo no lee "ocho pasos iguales": lee unos colores que saltan y
# otros que se hunden. Y como buena parte de esos matices pasa por la zona
# rojo-verde, alguien con daltonismo rojo-verde —la forma más común—
# pierde la distinción entre varias barras que para el resto del salón se
# ven clarísimamente distintas.
#
# La corrección no es "usar menos colores brillantes": es usar una paleta
# diseñada para esto. RColorBrewer marca en su propio catálogo qué
# paletas son seguras para daltonismo, y "Dark2" es una de ellas, con un
# techo documentado de 8 categorías — justo las que tenemos aquí.

# BIEN: mismo esqueleto, mismos datos, se cambia solo la escala.
ggplot(entidades_top8, aes(x = participacion, y = reorder(entidad, participacion), fill = entidad)) +
  geom_col() +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    title   = "Las 8 entidades con mayor participación en 2024",
    x       = "Participación (%)",
    y       = NULL,
    caption = "Fuente: INE, cómputos distritales 2024."
  )

# Esta es la paleta CUALITATIVA del curso: sirve para categorías sin orden
# natural (aquí, el nombre de la entidad), con colores de máximo contraste
# entre sí y sin gradiente. Si alguna vez necesitas más de 8 categorías,
# la respuesta no es forzar más colores: es agrupar, usar facetas
# (sesión 6) o pasar a una escala continua con leyenda ordenada.


# ---- 7. La misma pregunta, dos formas más: secuencial y divergente ----

# Cualitativa ya la viste arriba. Faltan las otras dos familias, y cada
# una responde a un tipo de variable distinto — no a un gusto.

# SECUENCIAL: para una magnitud que va de menos a más, sin dos bandos.
# participacion es exactamente eso: no hay un "lado positivo" y un "lado
# negativo" de participar más o menos.
ggplot(resultados_entidad, aes(x = participacion, y = reorder(entidad, participacion), fill = participacion)) +
  geom_col() +
  scale_fill_viridis_c() +
  labs(
    title   = "Participación en 2024, por entidad",
    x       = "Participación (%)",
    y       = NULL,
    caption = "Fuente: INE, cómputos distritales 2024."
  )

# viridis va de un tono claro a uno oscuro y está diseñada para verse
# perceptualmente uniforme y ser legible bajo las formas comunes de
# daltonismo — es la escala secuencial segura por defecto de este curso.

# DIVERGENTE: para una variable con un punto medio SUSTANTIVO, casi
# siempre un cero real. ventaja_shh (a nivel municipio) sí lo tiene: es
# positiva donde Sigamos Haciendo Historia va adelante, y negativa donde
# va adelante el otro bloque. El cero no es un promedio inventado: es el
# punto donde cambia quién va ganando.

municipios_grandes <- resultados_municipio |>
  arrange(desc(lista_nominal)) |>
  head(15)

ggplot(municipios_grandes, aes(x = ventaja_shh, y = reorder(municipio, ventaja_shh), fill = ventaja_shh)) +
  geom_col() +
  scale_fill_gradient2(low = "#B2182B", mid = "white", high = "#2166AC", midpoint = 0) +
  labs(
    title   = "¿Qué tan cerrada estuvo la elección en los municipios más grandes?",
    x       = "Ventaja de SHH sobre el segundo lugar (puntos porcentuales)",
    y       = NULL,
    caption = "Fuente: INE, cómputos distritales 2024."
  )


# ---- 8. EL SALTO: la escala de color es una decisión sustantiva ----

# Hasta aquí, la elección entre secuencial, divergente y cualitativa
# pareció una cuestión de qué función escribir. No lo es. Mira esto:

# MAL: una escala divergente sobre una variable que NO tiene un cero real.
ggplot(resultados_entidad, aes(x = participacion, y = reorder(entidad, participacion), fill = participacion)) +
  geom_col() +
  scale_fill_gradient2(midpoint = mean(resultados_entidad$participacion))

# Esto compila. Hasta se ve prolijo: rojo para abajo del promedio, azul
# para arriba. El problema no es de sintaxis, es de sustancia. La
# participación no tiene dos bandos que diverjan desde un centro: es una
# sola magnitud que va de menos a más, y el promedio que acabamos de
# pasarle a midpoint no es un cero natural — es un número que inventamos
# nosotros al calcular mean(). La escala divergente le está diciendo a
# quien la mira que hay una frontera sustantiva en ese punto, y no la hay.
#
# EL SALTO: elegir una escala de color no es una decisión estética, es una
# afirmación sobre la estructura de la variable. Una paleta divergente
# sobre una variable sin punto medio natural no es fea: es una afirmación
# falsa, hecha en color en vez de en palabras.

# ← COMPLETA: ahora aplícalo bien. ventaja_shh SÍ tiene un cero real (ver
# el bloque 7). Completa la escala divergente correcta para ese caso, con
# midpoint = 0 explícito — no calculado con mean().
grafico_ventaja_divergente <- ggplot(
  municipios_grandes,
  aes(x = ventaja_shh, y = reorder(municipio, ventaja_shh), fill = ventaja_shh)
) +
  geom_col() +
  scale_fill_gradient2(low = "#B2182B", mid = "white", high = "#2166AC", midpoint = 0) +
  labs(
    title   = "Aquí el cero sí es real: quién va adelante en cada municipio",
    x       = "Ventaja de SHH (puntos porcentuales)",
    y       = NULL,
    caption = "Fuente: INE, cómputos distritales 2024."
  )

grafico_ventaja_divergente


# ---- 9. Cámbiale algo ----

# Cambia option = "viridis" del bloque 7 por option = "magma" o
# option = "plasma", y los dos colores de la escala divergente del bloque
# 8 por otro par (por ejemplo, los mismos verde y guinda del curso).
# Vuelve a correr los dos bloques y compara.




# ==============================================================
# El gráfico de la sesión 1 ya no es un gráfico prestado.
#
# Vuelve a él (está en 01_script_completo.R) y léelo con lo de hoy:
# ¿qué va dentro de aes() y qué va fuera? ¿Por qué geom_col() y no
# geom_point()? ¿El título dice qué es el gráfico, o qué hay que ver?
#
# Y una última pregunta, para la sesión 6: si tuvieras que enseñar este
# gráfico en un trabajo final, ¿qué le falta todavía?
# ==============================================================
