# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 2 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Si llegaste aquí sin haber peleado con el ejercicio, regrésate: la
# solución solo enseña algo a quien ya se atoró.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)

source(here("estilo", "tema_lab.R"))

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

set.seed(2026)
promedios_lista_nominal <- replicate(
  1000,
  mean(sample(municipios$lista_nominal, size = 50, replace = FALSE))
)

ggplot(tibble(promedio = promedios_lista_nominal), aes(x = promedio)) +
  geom_histogram(fill = lab_colores[["verde_itam"]], bins = 40) +
  geom_vline(xintercept = mean(municipios$lista_nominal),
             colour = lab_colores[["verde_profundo"]], linewidth = 1) +
  theme_lab() +
  labs(
    title = "Mil sorteos de 50 municipios, promedio de lista_nominal",
    x     = "Promedio de lista_nominal de cada sorteo",
    y     = "Número de sorteos"
  )

# La anticipación correcta era "distinta, y más ancha, con cola hacia
# la derecha": a diferencia de la campana casi simétrica que salió con
# participacion, esta sale con una cola larga hacia valores altos. La
# razón es exactamente la que ya conocías de la sesión 8: lista_nominal
# tiene unos cuantos municipios gigantescos (Tijuana, Iztapalapa,
# Ecatepec, más de un millón de personas cada uno) entre 2,475 en su
# mayoría chicos. Con muestras de solo 50 municipios, si el sorteo por
# azar incluye uno de esos gigantes, el promedio de ESA muestra se
# dispara muy por encima de las demás. Cuantos más municipios extremos
# tenga la variable original, más sorteos "raros" vas a ver en el
# histograma de promedios, incluso repitiendo el sorteo mil veces.


# ---- Nivel 2 · De verdad ----

# (a) Mérida, Yucatán: un municipio real, grande, con participación
#     conocida.

merida <- municipios |> filter(entidad == "Yucatán", municipio == "Merida")
merida$lista_nominal    # 782,893 personas en la lista nominal
merida$participacion    # 67.6246% de participación real en 2024

# (b) Cien réplicas del sorteo de la sección 4, guardando el
#     PORCENTAJE de cada corrida (no el conteo, que dependería del
#     tamaño del municipio y no sería comparable entre corridas si
#     cambiaras de municipio).

set.seed(2026)
porcentajes_simulados <- replicate(
  100,
  mean(rbinom(n = merida$lista_nominal, size = 1, prob = merida$participacion / 100)) * 100
)

# (c) Media y desviación estándar de los cien porcentajes.

mean(porcentajes_simulados)
sd(porcentajes_simulados)

# La media de las cien simulaciones debe salir prácticamente idéntica
# a 67.6246 —a la centésima o menos de diferencia—, y la desviación
# estándar debe salir MINÚSCULA, muy por debajo de un punto
# porcentual. Esto no es casualidad: con una lista nominal de casi
# 800,000 personas, promediar decisiones binarias independientes deja
# muy poco espacio para que el azar mueva el resultado agregado —la
# misma lógica, en reversa, que hizo que el ejercicio del Nivel 1
# saliera MUY disperso con muestras chicas de una variable con
# valores extremos. El tamaño de la muestra (aquí, personas; ahí,
# municipios) es lo que determina qué tan apretada sale la variación,
# no la naturaleza de la pregunta.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) rexp() simula TIEMPOS entre eventos que ocurren a una tasa
#     constante —por ejemplo, cuánto tiempo pasa entre una protesta y
#     la siguiente, si en promedio ocurren a un ritmo fijo—. rgeom()
#     simula cuántos INTENTOS fallidos ocurren antes del primer éxito
#     —por ejemplo, cuántas rondas de negociación fracasan antes de
#     que se firme un acuerdo, si cada ronda tiene la misma
#     probabilidad de éxito—. Las dos están emparentadas con rbinom()
#     y rpois() de este módulo: la familia completa de distribuciones
#     de probabilidad describe distintas preguntas sobre CUÁNDO,
#     CUÁNTO o CUÁNTAS VECES ocurre algo azaroso.
#
# (b) Con lambda = 4, corridas sucesivas de rpois(12, lambda = 4) dan
#     conteos mensuales que típicamente van de 0 a 8 o 9: la variación
#     absoluta es chica. Con lambda = 50, los conteos mensuales
#     típicamente varían en un rango mucho más ancho en términos
#     absolutos —fácilmente entre 35 y 65—, aunque, en términos
#     RELATIVOS al promedio, la variación en realidad se hace más
#     chica (Poisson tiene la propiedad, que puedes comprobar
#     empíricamente pero no vamos a demostrar aquí con fórmula, de que
#     su dispersión crece con la raíz cuadrada de lambda, no con
#     lambda misma). Es un buen ejemplo de por qué "cuánto varía" y
#     "qué tan importante es esa variación" son dos preguntas
#     distintas.
#
# (c) El error más frecuente de este módulo suele ser pasar un
#     porcentaje (por ejemplo, 67.6246) donde rbinom() espera una
#     proporción entre 0 y 1 (0.676246). R no marca un error rojo por
#     esto —rbinom() acepta cualquier número, no valida que esté en
#     el rango correcto—, así que el fallo es silencioso: te da un
#     resultado, y ese resultado está mal. Es el mismo tipo de error
#     silencioso que ya viste con filter(mes == 1 | 2) en la sesión 3:
#     R no siempre avisa cuando algo salió mal: a veces solo hace lo
#     que le pediste, aunque lo que le pediste no fuera lo que
#     querías.


# ==============================================================
# Sobre la pregunta de cierre del ejercicio:
#
# Cuando el número que alimenta rbinom() es un dato conocido —como la
# participación real de Mérida, que ya ocurrió y ya se contó—, la
# simulación sirve para explorar CÓMO se habría comportado el azar si
# el proceso fuera de verdad independiente persona por persona. Cuando
# el número es una adivinanza —como en una encuesta antes de la
# elección, donde nadie sabe todavía qué va a pasar—, la pregunta se
# voltea: ya no preguntas "qué tan variable sería el resultado si la
# probabilidad fuera esta", sino "qué probabilidades son compatibles
# con el resultado que sí observé". Ese giro —de simular hacia
# adelante a razonar hacia atrás, desde el dato hacia el parámetro
# desconocido— es, literalmente, la definición de inferencia
# estadística. Acabas de describirla con tus palabras, sin haberla
# cursado todavía.
# ==============================================================
