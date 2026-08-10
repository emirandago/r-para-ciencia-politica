# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 08 · Describir sin mentir
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Calcular dos números que resumen una variable —media y mediana— y ver
#   que a veces cuentan historias distintas. Preguntar qué tan repartidos
#   están los datos alrededor de esos números, sin una sola fórmula. Conocer
#   el cuarteto de Anscombe, que le quita la confianza ciega a un resumen
#   numérico si no lo acompañas de un gráfico. Y solo entonces, con esa
#   lección ya aprendida, poner dos variables en un mismo plano
#   —participación y voto— y preguntar si de verdad "van juntas".
#
# Qué necesitas antes de empezar:
#   Haber corrido la sesión 03 (el pipe, filter(), mutate()) y la sesión 06
#   (theme_lab(), la fuente del tema visual del curso). No necesitas la
#   sesión 07: hoy se trabaja con las mismas bases de la elección de 2024,
#   pero en formato tabla, no en el mapa.
#
# Datos: INE, cómputos distritales de la elección presidencial de 2024, por
#        entidad y por municipio. Ver datos/README.md para las advertencias
#        de cada archivo (dos municipios de Oaxaca sin ninguna casilla
#        instalada: participación real de 0%, y el resto de sus columnas
#        en NA porque dividir votos entre cero no tiene sentido).
# Autor: Emiliano Miranda González
# ==============================================================

# ESTA ES LA VERSIÓN RESUELTA. Se publica después de la sesión.
# Si estás en clase, usa 08_script.R.


# ---- 0. Los paquetes ----

library(tidyverse)
library(here)

# El tema del curso vive en estilo/tema_lab.R, igual que desde la sesión 6.
source(here("estilo", "tema_lab.R"))

# Si esto marca "cannot open file ... tema_lab.R", no abriste el proyecto
# r-para-politologos.Rproj y R no está parado donde cree que está. Corre
# here() sola en la consola y revisa que la ruta termine en
# /r-para-politologos.


# ---- 1. Dos maneras de resumir una variable ----

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

# Ya usaste mean() en la sesión 1, con la participación de las 32 entidades.
# Hoy trabajas con lista_nominal: cuánta gente podía votar en cada uno de
# los 2,475 municipios del país. Y hoy conoces a su compañera de toda la
# vida: median().

media_lista_nominal <- mean(municipios$lista_nominal)
media_lista_nominal

# ← COMPLETA: calcula la mediana de lista_nominal con median().
#<hueco>
mediana_lista_nominal <- median(municipios$lista_nominal)
#</hueco>
mediana_lista_nominal

# Mira los dos números. No se parecen: la media ronda las 39,700 personas
# y la mediana apenas roza las 10,400. ¿Por qué el mismo conjunto de 2,475
# municipios da dos respuestas tan distintas a "cuánta gente puede votar,
# típicamente, en un municipio mexicano"?

# La media es, sin fórmula, el PUNTO DE EQUILIBRIO de la variable: si
# pusieras cada municipio sobre una regla, en el sitio que le toca según su
# lista nominal, y la balancearas como un subibaja, el punto de apoyo
# quedaría exactamente en la media. El problema es que un subibaja lo puede
# inclinar por completo alguien muy pesado en un extremo. Aquí ese peso lo
# ponen Tijuana (1.64 millones en la lista nominal), Iztapalapa (1.53
# millones) y Puebla (1.37 millones): tres municipios de 2,475
# que jalan el equilibrio hacia ellos.

# La mediana no se deja mover así. Es, sin fórmula, EL DE EN MEDIO: ordena
# los 2,475 municipios de menor a mayor lista nominal y quédate con el que
# cae justo a la mitad. No le importa qué tan extremo es el extremo, solo
# le importa cuántos municipios hay de cada lado.

# Compruébalo:

municipios |>
  filter(lista_nominal < media_lista_nominal) |>
  nrow()

# Son más de ocho de cada diez municipios del país. La media de "cuánta
# gente vive en un municipio mexicano" no describe a un municipio típico:
# describe un punto de equilibrio que casi ningún municipio ocupa. Esto no
# es un error de cálculo ni un defecto de la base: es lo que le pasa a la
# media cuando la variable está muy repartida de forma desigual. Vas a
# formalizar esto con un nombre —sesgo, o "skew"— en tu curso de
# Estadística; aquí, hoy, nada más lo viste moverse.


# ---- 2. Qué tan repartidos están: la desviación estándar ----

# La media y la mediana resumen "dónde está el centro". Falta la otra
# mitad de la pregunta: ¿qué tan apretados o qué tan repartidos están los
# datos alrededor de ese centro? Dos variables pueden compartir la misma
# media y comportarse de manera completamente distinta: una apretada
# alrededor de ella, la otra desperdigada por todos lados.

# La función se llama sd(), por standard deviation (desviación estándar).
# Sin fórmula, es una distancia típica al promedio: si pudieras medir qué
# tan lejos está cada municipio de la media, sd() te da algo parecido a esa
# distancia típica. Entre más apretados estén los datos alrededor del
# promedio, más chica es; entre más desperdigados, más grande.

sd_participacion <- sd(municipios$participacion)
sd_participacion

# La participación es un porcentaje: vive, casi siempre, entre 0 y 100. Una
# desviación estándar de poco más de 11 puntos te dice que la mayoría de
# los municipios no anda ni cerca del extremo: se agolpan alrededor del
# promedio, que ronda 63%.
#
# (El mínimo real es 0%, y no es un error: son Reforma —La— y Capulálpam de
# Méndez, dos municipios de Oaxaca donde ninguna casilla se instaló en
# 2024. datos/README.md ya lo documentó. Vale la pena mirar siempre los
# extremos de una variable antes de confiar en su resumen.)

# ← COMPLETA: calcula la desviación estándar de lista_nominal con sd().
#<hueco>
sd_lista_nominal <- sd(municipios$lista_nominal)
#</hueco>
sd_lista_nominal

# Compara los dos números. La desviación estándar de lista_nominal es MÁS
# GRANDE que su propia media: hay más "distancia típica al promedio" que
# promedio. Eso solo pasa con variables muy desiguales, con una cola larga
# de casos extremos —otra vez Tijuana, Iztapalapa, Puebla—. La
# participación, en cambio, se comporta: nunca vas a ver una desviación
# estándar de 100 puntos en una variable que solo puede valer entre 0 y
# 100.
#
# Vas a formalizar esto con una fórmula en tu curso de Estadística. Hoy,
# quédate con la intuición: la desviación estándar es el número que te
# dice si confiar en la media es razonable o es un riesgo.


# ---- 3. El cuarteto que le quita la confianza a un número ----

# Ahora vas a ver por qué "razonable" no es lo mismo que "seguro". El
# estadístico Francis Anscombe construyó, en 1973, cuatro conjuntos de
# datos —los llamó I, II, III y IV— diseñados a propósito para tener la
# MISMA media, la MISMA desviación estándar en cada variable y, aunque
# todavía no lo puedas comprobar tú mismo, hasta el MISMO número que resume
# qué tanto van juntas sus dos variables.
#
# Viene incluido en R, sin instalar nada: se llama anscombe.

anscombe

# Cuatro pares de columnas —(x1,y1), (x2,y2), (x3,y3), (x4,y4)—: un
# cuarteto de conjuntos, once observaciones cada uno. bind_rows() apila
# tablas una debajo de otra; lo usamos para volver esto una sola tabla
# larga, con una columna que dice de qué conjunto es cada fila.

anscombe_largo <- bind_rows(
  tibble(conjunto = "I",   x = anscombe$x1, y = anscombe$y1),
  tibble(conjunto = "II",  x = anscombe$x2, y = anscombe$y2),
  tibble(conjunto = "III", x = anscombe$x3, y = anscombe$y3),
  tibble(conjunto = "IV",  x = anscombe$x4, y = anscombe$y4)
)

# Los números resumen, uno por conjunto, con las dos funciones que acabas
# de usar:

anscombe_largo |>
  group_by(conjunto) |>
  summarise(
    media_x = mean(x),
    media_y = mean(y),
    sd_x    = sd(x),
    sd_y    = sd(y)
  )

# Revisa la tabla con calma. Las cuatro medias de x son iguales; las cuatro
# medias de y son casi iguales; las desviaciones estándar, también. Si
# solo tuvieras esta tabla, dirías que los cuatro conjuntos son la misma
# variable, medida cuatro veces. Ahora grafícalos.

ggplot(anscombe_largo, aes(x = x, y = y)) +
  geom_point(colour = lab_colores[["verde_itam"]], size = 2.5) +
  facet_wrap(~ conjunto) +
  theme_lab() +
  labs(
    title    = "Cuatro conjuntos, los mismos números resumen",
    subtitle = "Cuarteto de Anscombe (1973)",
    x        = NULL,
    y        = NULL
  )

# EL SALTO: de "confío en un número porque lo calculé bien" a "un número
# resumen puede ser aritméticamente correcto y aun así esconder una
# historia completamente distinta". El conjunto I es más o menos una recta
# con ruido: justo lo que uno imagina al oír "misma media, misma
# desviación". El II es una curva casi perfecta, no una recta: resumir esa
# relación con un solo número lineal es, directamente, la pregunta
# equivocada. El III es una recta casi perfecta arruinada por un solo dato
# atípico. El IV ni siquiera tiene una relación real: es una nube vertical
# más un punto solitario que decide, él solo, toda la pendiente.
#
# Y hay más, aunque todavía no lo puedas comprobar tú mismo: si a cada uno
# de estos cuatro conjuntos le calculas qué tanto van juntas x y y —lo que
# vas a hacer ahora mismo, con datos de la elección de 2024— y le trazas la
# línea que mejor resume hacia dónde va la nube, los cuatro dan casi el
# mismo número y casi la misma línea. Compáralo con lo que acabas de ver.


# ---- 4. "Van juntas": correlación y línea de tendencia ----

# En el ejercicio de la sesión 1 quedó una pregunta pendiente: ¿las
# entidades donde más gente sale a votar son las mismas donde le fue mejor
# a Sigamos Haciendo Historia (SHH)? La respuesta honesta, entonces, fue
# "no puedo afirmar más con lo que sé hoy". Hoy sí puedes.

# "Van juntas" quiere decir algo preciso y modesto: cuando una variable
# sube, la otra TIENDE a subir (o a bajar) también. cor() le pone un número
# a ese "tiende": va de -1 a 1. Cerca de 1, cuando una sube la otra casi
# siempre sube con ella. Cerca de -1, cuando una sube la otra casi siempre
# baja. Cerca de 0, no hay ningún patrón en línea recta entre las dos.

# Ojo con lo que pasa si lo intentas directo:

cor(municipios$participacion, municipios$pct_shh)

# NA. datos/README.md ya lo advirtió: los dos municipios de Oaxaca sin
# casilla instalada quedaron con pct_shh en NA en vez de un cero inventado.
# cor() no ignora los NA por su cuenta: hay que decírselo, igual que le
# dijiste na.rm a mean() en su momento.

# ← COMPLETA: calcula la correlación entre participacion y pct_shh con
# cor(), y no te olvides de use = "complete.obs": ya viste por qué.
#<hueco>
correlacion_shh <- cor(municipios$participacion, municipios$pct_shh, use = "complete.obs")
#</hueco>
correlacion_shh

# El número da apenas -0.12. Prácticamente nada: los municipios donde más
# gente sale a votar no son, de manera sistemática, ni los que más apoyan
# a SHH ni los que menos. Si acaso hay una relación levísima y negativa, no
# la que la intuición de "más participación, más apoyo al bloque que
# gobierna" hubiera adivinado.

# Ahora grafícalo, con la línea que resume hacia dónde va la nube:

ggplot(municipios, aes(x = participacion, y = pct_shh)) +
  geom_point(colour = lab_colores[["verde_claro"]], alpha = 0.5, size = 1.6) +
  geom_smooth(method = "lm", colour = lab_colores[["verde_profundo"]], se = FALSE) +
  theme_lab() +
  labs(
    title    = "¿La participación y el voto por SHH van juntas?",
    subtitle = "Cada punto es un municipio, elección presidencial 2024",
    x        = "Participación (%)",
    y        = "Voto por Sigamos Haciendo Historia (%)",
    caption  = "Fuente: INE, cómputos distritales 2024."
  )

# geom_smooth(method = "lm") traza, sin correr una regresión por tu cuenta,
# la recta que mejor resume hacia dónde va la nube. Vas a formalizar cómo
# se calcula esa recta en la sesión 9; hoy basta con leerla: casi
# horizontal. Una recta casi horizontal es, en un gráfico, la misma
# noticia que -0.12 en un número: casi no hay relación.

# Un aviso que vale para el resto de tu vida politóloga: un número de
# correlación NUNCA dice qué causa qué, y ni siquiera dice que la relación
# entre dos variables es de verdad débil, si esa relación no es una recta.
# El cuarteto de Anscombe, que acabas de ver, existe precisamente para que
# no se te olvide la segunda parte.


# ---- 5. La misma pregunta, dos unidades de análisis ----

# Repite el cálculo, pero con la base agregada por entidad en vez de por
# municipio.

entidades <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

cor(entidades$participacion, entidades$pct_shh)

# Con 32 entidades el número da 0.06: prácticamente cero, pero POSITIVO.
# Con 2,473 municipios daba -0.12: prácticamente cero, pero NEGATIVO. Ni
# siquiera el signo coincide entre las dos unidades de análisis.
#
# Esto no es un error de ninguno de los dos cálculos: es lo que le pasa a
# una relación ya de por sí débil cuando cambia cuántos casos tienes y cómo
# los agrupas. Adrián Lucardi cuenta, en su curso de métodos, el caso de
# los "ataques de tiburones" y la elección de Estados Unidos de 1916
# [VERIFICAR la referencia exacta: Achen y Bartels contra Fowler y Hall]:
# con apenas 21 observaciones, un solo criterio de codificación —qué cuenta
# como "condado costero"— cambiaba el resultado completo del análisis. La
# moraleja cabe en una frase: entre menos casos tengas, o entre más se
# pueda discutir cómo agruparlos, más cuidado hay que tener antes de
# creerte un número.


# ---- 6. Cámbiale algo ----

# Repite el bloque de la sección 4, pero cambia pct_shh por pct_fcm en las
# tres líneas donde aparece (el cor(), el eje y del gráfico, y su etiqueta).
# ¿El signo de la correlación se invierte, se mantiene, o hace algo que no
# esperabas?




# ==============================================================
# Tienes un número (-0.12) y una nube de puntos que lo confirma: casi no
# hay relación en línea recta entre participación y voto por SHH a nivel
# municipio. Pero el cuarteto de Anscombe te acaba de enseñar que un
# número —incluso acompañado de su nube de puntos correcta— puede no ser
# toda la historia si la relación de verdad no es una recta.
#
# ¿Se te ocurre una razón política por la que participación y voto por un
# bloque pudieran estar relacionados de una forma que geom_smooth(method =
# "lm") no alcanza a capturar? No la contestes con código. Escríbela.
# ==============================================================
