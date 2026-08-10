# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 06 · Gráficos que se publican
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Convertir un gráfico de la sesión pasada en una figura lista para un
#   trabajo final: con paneles (facetas), una escala de color que dice la
#   verdad sobre los datos, el tema visual del curso, y un archivo PDF con
#   las dimensiones que un documento impreso necesita. Cerramos con el
#   argumento de por qué una barra tiene que arrancar en cero y un punto no.
#
# Qué necesitas antes de empezar:
#   Haber corrido la sesión 05 (la gramática de los gráficos) — usamos
#   ggplot(), aes(), geom_col() y labs() sin volver a explicarlos. También
#   damos por sabido, apenas de pasada, el pivot_longer() que viste en la
#   sesión 04: hoy es la primera vez que de verdad lo necesitas.
#
# Datos: INE, cómputos distritales 2024, agregados por entidad y por
#        municipio. Ver datos/README.md para la fuente exacta y sus
#        advertencias (dos municipios en NA por casillas no instaladas).
# Autor: Emiliano Miranda González
# ==============================================================

# ─────────────────────────────────────────────────────────────
# ESTE ARCHIVO TIENE HUECOS Y NO CORRE DE CORRIDO. Es a propósito.
# Los huecos están marcados con  ← COMPLETA  y se llenan en clase.
# Si intentas correrlo entero antes de llenarlos, va a marcar error.
# La versión resuelta (06_script_completo.R) se publica al terminar la sesión.
# ─────────────────────────────────────────────────────────────


# ---- 0. Los paquetes ----

# Hoy se suma un paquete nuevo: patchwork, que sirve para poner varios
# gráficos de ggplot2 uno junto a otro sin salir de R. Es el único paquete
# de composición que vamos a usar en todo el curso.
#
#   install.packages(c("patchwork"))
#
# viridis no aparece en esta lista a propósito: sus escalas
# (scale_fill_viridis_c(), scale_colour_viridis_d()) vienen integradas en
# ggplot2 desde su versión 3.0 y no necesitan un library() aparte.

library(tidyverse)
library(here)
library(patchwork)

# El tema del curso vive fuera de este script, en estilo/tema_lab.R, para
# que todos los gráficos del laboratorio —y los de tu trabajo final—
# combinen entre sí. source() corre ese archivo completo y te deja
# disponibles theme_lab(), scale_fill_lab_d() y el resto de sus funciones.

source(here("estilo", "tema_lab.R"))

# Si esto marca "cannot open file ... tema_lab.R", casi siempre es que no
# abriste el proyecto r-para-ciencia-politica.Rproj y R no está parado donde
# cree que está. Corre here() sola en la consola y revisa que la ruta
# termine en /r-para-ciencia-politica.


# ---- 1. Los datos de hoy ----

resultados_entidad   <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

# El archivo por municipio trae, ya calculada, la columna ventaja_shh:
# cuánto le sacó Sigamos Haciendo Historia (SHH) al segundo lugar, en
# puntos porcentuales. Puede ser negativa: significa que ahí ganó otro
# bloque. datos/README.md documenta que dos municipios de Oaxaca quedan en
# NA porque ninguna de sus casillas se instaló — no es un error de este
# script, es un hecho real de la elección de 2024.


# ---- 2. El problema que vamos a resolver: tres coaliciones, un solo panel ----

# La pregunta de hoy no es solo "¿cómo le fue a cada coalición?" —eso ya lo
# puedes contestar desde la sesión 5—. Es: ¿cómo lo pones en UNA figura que
# alguien más pueda leer sin que tú se la tengas que explicar en persona?

# Primero, un vistazo rápido de por qué "meter las tres coaliciones en el
# mismo panel" no es la solución, aunque parezca la más directa.

# ← COMPLETA: convierte pct_shh, pct_fcm y pct_mc en dos columnas (bloque
# y porcentaje) con pivot_longer(), después de renombrar cada una a su
# nombre completo con select().

entidad_bloques <-


# Te acuerdas de pivot_longer() de la sesión 4, aunque ahí apenas lo
# probaste: aquí es donde por fin sirve para algo que no podrías hacer de
# otra forma. Tres columnas (pct_shh, pct_fcm, pct_mc) se vuelven dos: una
# que dice DE QUÉ BLOQUE es cada número (bloque) y otra que trae EL NÚMERO
# (porcentaje). ggplot2 casi siempre prefiere los datos así: una fila por
# cada cosa que vas a dibujar, no una columna por cada cosa que quieres
# comparar.

glimpse(entidad_bloques)

# El intento directo: las tres coaliciones en el mismo panel, una barra
# junto a la otra por cada entidad.

grafico_saturado <- ggplot(entidad_bloques, aes(x = entidad, y = porcentaje, fill = bloque)) +
  geom_col(position = "dodge") +
  coord_flip() +
  scale_fill_lab_d() +
  theme_lab() +
  labs(
    title = "Las tres coaliciones, en un solo panel",
    x     = NULL,
    y     = "Porcentaje de votos (%)"
  )

grafico_saturado

# Se puede leer, a duras penas. Con 32 entidades y tres barras por cada una
# son 96 barras en un solo rectángulo. Fíjate en que scale_fill_lab_d() no
# truena aquí: tenemos exactamente tres categorías, que es justo el límite
# que documenta estilo/tema_lab.R para su paleta monocromática. Si
# agregaras una cuarta —"otros", por ejemplo— la función te lo advertiría
# sola con un warning.


# ---- 3. La solución: una faceta por bloque ----

# EL SALTO: la intuición "esto se ve saturado" se vuelve una decisión
# técnica concreta. En vez de pedirle a UN panel que cargue con tres
# variables a la vez, le pides a ggplot2 que te dé tres paneles, uno por
# bloque, con el mismo eje para que se puedan comparar entre sí. Eso es
# una faceta, y es buena parte de la diferencia entre un gráfico y una
# figura publicable.

# Antes de facetar, fijamos un orden de las entidades que valga para las
# tres coaliciones a la vez: si no, cada panel se ordenaría distinto y no
# podrías comparar uno contra otro. Ordenamos por qué tan bien le fue a
# SHH, que es la coalición que ganó la elección.

orden_por_shh <- resultados_entidad |>
  arrange(pct_shh) |>
  pull(entidad)

entidad_bloques <- entidad_bloques |>
  mutate(entidad = factor(entidad, levels = orden_por_shh))

grafico_final <- ggplot(entidad_bloques, aes(x = entidad, y = porcentaje, fill = bloque)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ bloque, ncol = 3) +
  scale_fill_lab_d() +
  guides(fill = "none") +   # el encabezado del panel ya dice el bloque: la leyenda sobra
  theme_lab() +
  labs(
    title    = "¿Cómo se repartió el voto de 2024 entre las tres coaliciones?",
    subtitle = "Porcentaje de votos por entidad, ordenado por el resultado de Sigamos Haciendo Historia",
    x        = NULL,
    y        = "Porcentaje de votos (%)",
    caption  = "Fuente: INE, cómputos distritales 2024."
  )

grafico_final

# Compara este gráfico con grafico_saturado. Es la misma información,
# exactamente los mismos 96 números. Lo único que cambió es la gramática:
# un canal (el panel) en vez de dos (el panel y el color) para decir "de
# qué bloque es esta barra". Esa es la idea completa de facet_wrap(): parte
# tu gráfico en paneles según una variable categórica, y deja todo lo
# demás —ejes, colores, tema— igual en cada uno para que se puedan
# comparar de verdad.


# ---- 4. La progresión de las escalas continuas ----

# facet_wrap() resuelve "demasiadas categorías en un panel". Pero hay una
# pregunta distinta y más frecuente en ciencia política: ¿cómo le dices a
# un color que represente un NÚMERO, no una categoría? La vas a necesitar
# todo el tiempo: margen de victoria, PIB per cápita, un índice de
# democracia.
#
# Trabajamos ahora con el archivo municipal y su columna ventaja_shh:
# cuánto le ganó SHH al segundo lugar, municipio por municipio. Quitamos
# primero los dos municipios en NA que ya documentó datos/README.md.

municipios_ordenados <- resultados_municipio |>
  filter(!is.na(ventaja_shh)) |>
  arrange(ventaja_shh) |>
  mutate(posicion = row_number())

# Si te saltas el filter(), el gráfico de todas formas se dibuja, pero R te
# avisa con un mensaje parecido a "Removed 2 rows containing missing
# values": dos municipios que se quedaron fuera sin que tú lo decidieras.
# Ese mensaje no detiene el script —no es un error—, pero vale la pena
# leerlo siempre: te está diciendo que algo se cayó del gráfico sin tu
# permiso.

# El esqueleto se repite en las siguientes versiones. Solo va a cambiar la
# escala de color, así que lo guardamos una vez.

esqueleto <- ggplot(municipios_ordenados, aes(x = posicion, y = ventaja_shh, fill = ventaja_shh)) +
  geom_col(width = 1) +
  theme_lab() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(x = "Municipios, ordenados de menor a mayor ventaja", y = "Ventaja de SHH (pp)")

# 4.1 — Secuencial: solo importa la magnitud, de menos a más.
escala_secuencial <- esqueleto +
  scale_fill_gradient(low = "#A8D5BE", high = "#00402C") +
  labs(title = "gradient(): secuencial")

# 4.2 — Divergente: aquí sí hay un cero real —nadie ganó— y dos direcciones
# posibles a partir de él.
escala_divergente <- esqueleto +
  scale_fill_gradient2(low = "#7B1113", mid = "white", high = "#006847", midpoint = 0) +
  labs(title = "gradient2(): divergente, centrada en cero")

# 4.3 — viridis: perceptualmente uniforme y segura para daltonismo. Es el
# default razonable cuando no tienes una razón concreta para otra cosa.
escala_viridis <- esqueleto +
  scale_fill_viridis_c(option = "viridis") +
  labs(title = "viridis_c(): uniforme y segura para daltonismo")

# 4.4 — Por umbrales automáticos: en vez de un degradado continuo, R corta
# el rango en tramos y le da un color sólido a cada tramo.
# ← COMPLETA: repite el esqueleto, pero con scale_fill_steps2(), centrada
# en cero igual que la escala divergente de arriba.

escala_por_umbrales <-


(escala_secuencial | escala_divergente) / (escala_viridis | escala_por_umbrales) +
  plot_layout(guides = "collect")

# Fíjate en que las cuatro cuentan la misma historia —dónde ganó SHH por
# mucho, dónde perdió— con un énfasis distinto. La secuencial esconde el
# cero; la divergente lo pone al centro; viridis prioriza que se lea igual
# con cualquier tipo de daltonismo; los tramos cambian precisión por
# categorías que se explican en una frase.

# Una quinta opción, para cuando los tramos no deben salir automáticos sino
# decididos por ti con un criterio político. Usamos los mismos veinte
# puntos que ya viste en la sesión 1 para hablar de "goleadas":

escala_por_franjas <- esqueleto +
  scale_fill_stepsn(
    colours = c("#7B1113", "#A8D5BE", "#006847"),
    breaks  = c(-20, 20)
  ) +
  labs(title = "stepsn(): tres franjas políticas, con tus propios cortes")

escala_por_franjas

# scale_fill_steps2() decide los tramos por sí sola; scale_fill_stepsn()
# te deja decidir dónde están los cortes. Aquí "-20" y "20" no son un
# capricho estético: son la misma frontera de "goleada" que usamos en la
# sesión 1 para filtrar municipios_arrasados.


# ---- 5. Guardar de verdad: ggsave() ----

# Hasta ahora, cada gráfico solo existe adentro de R. Para que entre a un
# documento —un trabajo final, una tesis, un PDF que vas a imprimir— tiene
# que salir como un archivo con un tamaño explícito, no como una captura
# de pantalla de lo que se ve en el panel de RStudio.

# Creamos primero la carpeta donde va a vivir la figura. showWarnings =
# FALSE evita que R se queje si la carpeta ya existía.

dir.create(here("sesiones", "06-graficos-que-se-publican", "figuras"), showWarnings = FALSE)

# ← COMPLETA: guarda grafico_final como PDF dentro de la carpeta figuras,
# con ancho y alto explícitos en pulgadas.



# Si esto marca "cannot open file ... : No such file or directory", casi
# siempre es que la carpeta "figuras" no se creó — vuelve a correr la
# línea de dir.create() de arriba.
#
# ¿Por qué PDF y no PNG? Un PDF es un formato VECTORIAL: no guarda una
# cuadrícula de píxeles, guarda las instrucciones para dibujar cada barra
# y cada letra. Eso significa que se puede meter en un documento de Word o
# de LaTeX, ampliarlo o imprimirlo en tamaño carta, sin que se pixele ni
# una línea de texto. Un PNG es un formato RASTER: guarda píxeles a una
# resolución fija (dpi), y si el documento lo estira más de lo que mide
# esa cuadrícula, se ve borroso.
#
# La excepción que vale la pena conocer: si tu gráfico tiene decenas de
# miles de puntos traslapados —un scatter enorme, un mapa de calor con
# millones de celdas—, un PDF vectorial puede pesar más que un PNG
# equivalente, porque intenta dibujar cada punto como un objeto aparte.
# Ahí sí conviene un PNG a buena resolución (300 dpi o más). Pero una
# figura de barras o de paneles, como la de hoy, es exactamente el caso en
# el que el PDF gana siempre.


# ---- 6. Ética visual: lo que la barra promete ----

# Volvemos a algo que ya viste de pasada en el ejercicio de la sesión 1:
# una barra codifica una magnitud en su LONGITUD, y una longitud solo se
# lee bien si arranca en cero. Hoy lo completamos con un ejemplo, no solo
# con el argumento.

# Las seis entidades con más participación en 2024, con los mismos números
# exactos, en dos versiones del mismo gráfico.

participacion_top <- resultados_entidad |>
  arrange(desc(participacion)) |>
  head(6)

base_participacion <- ggplot(participacion_top, aes(x = reorder(entidad, participacion), y = participacion)) +
  geom_col(fill = lab_colores[["verde_itam"]]) +
  theme_lab() +
  labs(x = NULL, y = "Participación (%)")

grafico_honesto  <- base_participacion + coord_flip() +
  labs(title = "Con el eje completo")

grafico_truncado <- base_participacion + coord_flip(ylim = c(63, 74)) +
  labs(title = "Con el eje recortado")

grafico_honesto | grafico_truncado

# EL SALTO: son el mismo dato, las mismas seis cifras, la misma función
# geom_col(). Lo único que cambió es dónde empieza el eje. En la versión
# recortada, Yucatán se ve casi el doble de alto que México; en la versión
# completa, la diferencia real —ocho puntos porcentuales sobre setenta— se
# ve exactamente como lo que es: apreciable, pero no abismal. Esto no es
# una diferencia de gusto entre dos estilos de gráfico. Es una decisión de
# diseño que puede hacer que una relación se vea más fuerte de lo que es,
# y eso es un problema de honestidad, no de estética.
#
# Por eso este curso prohíbe, sin excepción, en cualquier gráfico que vaya
# a salir de tu computadora: gráficos 3D, gráficos de pastel, ejes duales
# (dos escalas distintas en el mismo eje) y barras que no arrancan en
# cero. Los cuatro comparten el mismo defecto: le piden al ojo que compare
# magnitudes que el gráfico ya dejó de medir de forma proporcional.
#
# La salida, cuando de verdad necesitas ver diferencias finas en números
# que no arrancan cerca de cero, no es recortar la barra: es cambiar de
# geometría. Un punto codifica la magnitud en su POSICIÓN, no en su
# longitud, así que sí puedes acercarte a la zona donde están los datos
# sin mentir — geom_point() en vez de geom_col(), con el eje completo.


# ---- 7. Cámbiale algo ----

# Cambia option = "viridis" por option = "magma" en escala_viridis y
# vuelve a correr el patchwork de la sección 4. ¿Sigue leyéndose igual de
# bien la frontera entre "ganó SHH" y "ganó otro bloque"?




# ==============================================================
# El gráfico de la sección 3 —el de las tres coaliciones en paneles— podría
# terminar tal cual en un trabajo final tuyo, en una tesis, en una
# presentación frente a alguien que no sabe R.
#
# ¿Qué pregunta política concreta —tuya, no de este script— podrías
# contestar con una figura de paneles como esa, en vez de con un solo
# gráfico saturado? No la contestes todavía: solo escríbela.
# ==============================================================
