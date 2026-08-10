# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 08 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Se publica después de la sesión. Si llegaste aquí sin haber peleado
# con el ejercicio, regrésate: la solución solo enseña algo a quien ya
# se atoró. Leer código correcto sin haberlo intentado se siente como
# aprender y no lo es.
#
# Autor: Emiliano Miranda González
# ==============================================================

# [PENDIENTE: sustituir por base comparada cuando exista]
# Esta solución sigue usando datos mexicanos por la misma razón que el
# ejercicio: todavía no hay ninguna base comparada en datos/limpios/.

library(tidyverse)
library(here)

source(here("estilo", "tema_lab.R"))

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))
entidades  <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))


# ---- Nivel 1 · Calentamiento ----

mean(municipios$pct_fcm, na.rm = TRUE)
median(municipios$pct_fcm, na.rm = TRUE)
sd(municipios$pct_fcm, na.rm = TRUE)

# La media ronda 21.4 y la mediana ronda 19.2: se parecen mucho más entre
# sí que la media y la mediana de lista_nominal (39,700 contra 10,400), y
# la razón es exactamente la que anticipaste. pct_fcm es un porcentaje: no
# importa qué tan grande sea un municipio, su voto por FCM está acotado
# entre 0 y 100. lista_nominal, en cambio, es un conteo de personas sin
# techo real, y unos cuantos municipios enormes —Tijuana, Iztapalapa,
# Ecatepec— pueden estirar la media sin que la mediana se entere. Que una
# variable esté acotada no la vuelve "mejor": la vuelve, casi siempre,
# menos susceptible a que unos pocos casos extremos secuestren su media.


# ---- Nivel 2 · De verdad ----

# (a) La correlación.

correlacion_fcm <- cor(municipios$participacion, municipios$pct_fcm, use = "complete.obs")
correlacion_fcm

# (b) El gráfico, con el mismo esqueleto de la sesión.

ggplot(municipios, aes(x = participacion, y = pct_fcm)) +
  geom_point(colour = lab_colores[["verde_claro"]], alpha = 0.5, size = 1.6) +
  geom_smooth(method = "lm", colour = lab_colores[["verde_profundo"]], se = FALSE) +
  theme_lab() +
  labs(
    title    = "¿La participación y el voto por FCM van juntas?",
    subtitle = "Cada punto es un municipio, elección presidencial 2024",
    x        = "Participación (%)",
    y        = "Voto por Fuerza y Corazón por México (%)",
    caption  = "Fuente: INE, cómputos distritales 2024."
  )

# (c) La interpretación, que es la parte que de verdad importa.
#
# El número da 0.10: positivo, y del mismo orden de magnitud que el -0.12
# de SHH, pero con el signo cambiado. No es una casualidad numérica ni un
# error de dedo: participación, pct_shh y pct_fcm no son tres variables
# sueltas, son tres formas de repartir el mismo 100%. Si SHH tiende
# (débilmente) a hacerlo peor donde hay más participación, es casi
# aritmético que el bloque opositor tienda (débilmente) a hacerlo mejor
# ahí. Los dos números cuentan, en espejo, la misma historia leve: en
# 2,473 municipios, participación explica casi nada de quién gana.
#
# La palabra clave es "casi nada". 0.10 y -0.12 son correlaciones débiles
# en cualquier estándar razonable: no alcanzan para escribir "la
# participación favorece a la oposición" en un trabajo final. Alcanzan
# para escribir que, a nivel municipio, la participación por sí sola no
# es un buen predictor de qué bloque gana —lo cual es, en sí mismo, un
# hallazgo interesante y defendible, solo que modesto.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) La comparación entre unidades de análisis.

cor(entidades$participacion, entidades$pct_fcm)

# A nivel entidad (32 casos) el número da -0.06: otra vez cercano a cero,
# y otra vez con el signo invertido respecto al nivel municipio (0.10).
# Es el mismo patrón que viste en clase con pct_shh: ni el tamaño ni
# siquiera el signo se sostienen entre las dos unidades de análisis,
# porque ambos números están tan cerca de cero que cualquier cambio en
# cómo agrupas los casos los puede empujar para el otro lado.
#
# De los dos, el de municipio merece más confianza para un trabajo final,
# y no porque "más N siempre es mejor" en abstracto, sino porque aquí el
# de entidad promedia apenas 32 números ya de por sí agregados —perdiendo
# toda la variación que hay DENTRO de cada entidad— mientras que el de
# municipio conserva 2,473 observaciones reales de la elección. Aun así,
# la conclusión honesta con cualquiera de los dos números es la misma:
# la relación es demasiado débil para sostener una afirmación fuerte.

# (b) La pregunta comparada.
#
# [PENDIENTE: sustituir por base comparada cuando exista] Una IA
# consultada sobre esto suele proponer, para V-Dem, algo como
# `v2x_partip` o variables del bloque de participación electoral, y para
# Latinobarómetro, preguntas de la batería de "voto" y de "aprobación de
# gobierno" por país-año. Esos nombres HAY que verificarlos contra el
# codebook público de cada proyecto antes de usarlos: es exactamente el
# tipo de afirmación —"esta columna existe y significa esto"— que una IA
# puede entregar con total seguridad y estar equivocada, porque los
# nombres de variable cambian entre versiones de V-Dem y Latinobarómetro
# no publica un codebook único para todas sus rondas. Verificar aquí no es
# opcional: es el paso que evita construir un análisis completo sobre una
# columna que no existe.


# ==============================================================
# Cierre: hoy contestaste, con datos reales, la pregunta que la sesión 1
# dejó pendiente. La respuesta no fue "sí" ni "no": fue "casi nada, y el
# signo depende de cómo agrupes los casos". Esa clase de respuesta modesta
# y verificada vale más, en un trabajo final, que una afirmación fuerte
# construida sobre un solo número sin mirarlo desde más de un ángulo.
# ==============================================================
