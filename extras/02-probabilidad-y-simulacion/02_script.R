# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 2 · Probabilidad y simulación
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Fijar la semilla del generador aleatorio con set.seed(), sortear
#   con sample(), generar números con runif()/rbinom()/rnorm()/
#   rpois(), y repetir un sorteo miles de veces con replicate() para
#   ver, en un histograma, cómo varía un promedio calculado sobre una
#   muestra.
#
# Qué necesitas antes de empezar:
#   Las sesiones 1 y 2 (objetos, vectores). Si viste el extra 1, ya
#   conoces replicate() de pasada; aquí la usamos en serio.
#
# AVISO IMPORTANTE sobre alcance: este módulo prefigura la
# SIMULACIÓN, no la inferencia. No vamos a calcular un p-valor, un
# intervalo de confianza ni el poder de una prueba: ese vocabulario se
# formaliza en Estadística I y II. Si alguna vez necesitas un p-valor,
# la regla de este laboratorio es nombrarlo, decir que se formaliza
# más adelante, y no usarlo como herramienta de decisión aquí.
#
# Este es un módulo AUTOESTUDIABLE. Este script corre completo, de
# arriba abajo, SIN huecos.
#
# Datos: INE, cómputos distritales de la elección presidencial de
#        2024, por municipio. Ver datos/README.md.
# Autor: Emiliano Miranda González
# ==============================================================


# ---- 0. Los paquetes ----

# Nada nuevo: tidyverse y here, de siempre.
#
#   install.packages(c("tidyverse", "here"))

library(tidyverse)
library(here)

source(here("estilo", "tema_lab.R"))

municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- 1. set.seed(): el azar de R no es azar de verdad ----

# Lo que R llama "números al azar" es una secuencia determinista que
# SE VE como azarosa. set.seed(n) le dice a R en qué punto exacto de
# esa secuencia empezar. Corre estas dos líneas juntas, varias veces:

set.seed(2026)
sample(1:100, 5)

# Sin importar cuántas veces lo corras, mientras pongas set.seed(2026)
# justo antes, te va a salir siempre el mismo resultado. Prueba a
# quitar el set.seed() y correr solo sample(1:100, 5) dos veces
# seguidas: ahora sí van a salir números distintos cada vez.


# ---- 2. sample(): sortear sin fórmula ----

# Un sorteo real: elegir, al azar y sin repetir, un comité de 5
# municipios de Oaxaca para una auditoría hipotética. Oaxaca tiene 570
# municipios en esta base —el estado con más municipios del país, ya
# lo viste en la sesión 4—, así que hay de sobra para sortear.

municipios_oaxaca <- municipios |>
  filter(entidad == "Oaxaca") |>
  pull(municipio)

length(municipios_oaxaca)

set.seed(2026)
comite_auditoria <- sample(municipios_oaxaca, size = 5, replace = FALSE)
comite_auditoria

# replace = FALSE (el valor de fábrica) es un sorteo sin devolver la
# bolita a la urna: ningún municipio puede salir dos veces. Compáralo
# con un sorteo CON reemplazo, que sí permite repeticiones —útil para
# simular algo que de verdad puede repetirse, como lanzar una moneda
# varias veces—:

set.seed(2026)
sample(c("aguila", "sol"), size = 10, replace = TRUE)


# ---- 3. runif(): números continuos, todos igual de probables ----

set.seed(2026)
runif(5, min = 0, max = 100)

# Cualquier número entre 0 y 100 tiene la misma probabilidad de salir.
# Es la distribución más simple de las cuatro que vas a ver hoy, y
# sirve como ruido sin ningún patrón: ni una zona más probable que
# otra.


# ---- 4. rbinom(): decisiones binarias, una por una ----

# Un municipio real: Asientos, Aguascalientes. 38,773 personas en la
# lista nominal; 65.231% participó en 2024.

asientos <- municipios |> filter(entidad == "Aguascalientes", municipio == "Asientos")
asientos$lista_nominal
asientos$participacion

# Simulamos, persona por persona, la decisión de votar o no votar,
# COMO SI cada quien decidiera de forma independiente con la misma
# probabilidad (65.231%, expresada como proporción: 0.65231, NO como
# 65.231 -- rbinom() espera una probabilidad entre 0 y 1).

set.seed(2026)
votos_simulados <- rbinom(n = asientos$lista_nominal, size = 1, prob = asientos$participacion / 100)

sum(votos_simulados)                       # cuántos "sí" salieron
mean(votos_simulados) * 100                # el porcentaje simulado

# El porcentaje simulado debería salir CERCA de 65.231%, no exacto.
# Esa distancia entre "cerca" y "exacto" es la primera pista de por
# qué existe la estadística inferencial: el mundo real casi nunca se
# comporta como monedas perfectamente independientes.


# ---- 5. rnorm(): la campana, cuando aplica ----

# La participación municipal real de 2024 tiene media 63.12 y
# desviación estándar 11.72 (ya la calculaste, con sd(), en la
# sesión 8). Generamos una variable simulada con esos mismos dos
# parámetros:

mean(municipios$participacion)
sd(municipios$participacion)

set.seed(2026)
participacion_simulada <- rnorm(n = nrow(municipios), mean = 63.12, sd = 11.72)

# Comparamos la real contra la simulada en un mismo histograma:

comparacion <- bind_rows(
  tibble(valor = municipios$participacion,   tipo = "Real (2024)"),
  tibble(valor = participacion_simulada,      tipo = "Simulada (rnorm)")
)

ggplot(comparacion, aes(x = valor, fill = tipo)) +
  geom_histogram(position = "identity", alpha = 0.55, bins = 40) +
  scale_fill_lab_d() +
  theme_lab() +
  labs(
    title    = "La participación real, contra una campana perfecta con la misma media y sd",
    subtitle = "Municipios, elección presidencial 2024",
    x        = "Participación (%)",
    y        = "Número de municipios",
    fill     = NULL
  )

# Las dos se parecen —están centradas casi en el mismo sitio, con un
# ancho similar— pero no son idénticas: la real tiene más municipios
# de participación muy baja de lo que una campana perfectamente
# simétrica predeciría. rnorm() es un MODELO, no una copia; superponer
# el modelo contra el dato real es la manera más honesta de ver en qué
# se parecen y en qué no.


# ---- 6. rpois(): contar eventos raros ----

# Un ejemplo INVENTADO, para el ejemplo, igual que los votos_ficticios
# de la sesión 1: un OPLE hipotético recibe, en promedio, 4 quejas por
# prácticas indebidas al mes. Simulamos doce meses:

set.seed(2026)
quejas_por_mes <- rpois(n = 12, lambda = 4)
quejas_por_mes

# Ningún mes tiene por qué dar exactamente 4: Poisson predice que la
# variación alrededor del promedio crece junto con el promedio mismo.
# Súmalos para ver el total simulado del año:

sum(quejas_por_mes)

# Una nota, sin desarrollarla: las cuatro distribuciones de este
# módulo son UNIVARIADAS, generan una sola columna de números a la
# vez. Existen versiones MULTIVARIADAS —MASS::mvrnorm() para simular
# varias variables normales correlacionadas entre sí, o
# faux::rnorm_multi(), pensada para no tener que escribir la matriz de
# correlaciones a mano— que sirven cuando quieres simular, por
# ejemplo, participación y voto por un partido a la vez, ya
# correlacionados entre sí desde el sorteo. Requieren especificar una
# matriz de covarianza, que es exactamente el tipo de álgebra que este
# laboratorio evita: se quedan fuera de este módulo, pero vale la pena
# que sepas que existen si algún día simulas más de una variable a la
# vez.


# ---- 7. replicate(): repetir el sorteo, no solo hacerlo una vez ----

# La pregunta de cierre: si sorteas 100 municipios al azar y calculas
# su participación promedio, ¿qué tan distinto sale ese promedio de
# una muestra a otra? En vez de sortear una sola vez, sorteamos MIL
# veces con replicate() y guardamos los mil promedios.

set.seed(2026)
promedios_simulados <- replicate(
  1000,
  mean(sample(municipios$participacion, size = 100, replace = FALSE))
)

length(promedios_simulados)   # mil promedios, uno por sorteo
mean(promedios_simulados)     # el promedio DE los promedios
sd(promedios_simulados)       # qué tan dispersos salieron entre sí

ggplot(tibble(promedio = promedios_simulados), aes(x = promedio)) +
  geom_histogram(fill = lab_colores[["verde_itam"]], bins = 40) +
  geom_vline(xintercept = mean(municipios$participacion),
             colour = lab_colores[["verde_profundo"]], linewidth = 1) +
  theme_lab() +
  labs(
    title    = "Mil sorteos de 100 municipios, mil promedios distintos",
    subtitle = "La línea vertical es el promedio real de los 2,475 municipios",
    x        = "Promedio de participación de cada sorteo (%)",
    y        = "Número de sorteos"
  )

# La mayoría de los mil sorteos cae cerca de la línea vertical —el
# promedio real—; unos pocos, los que por azar sacaron demasiados
# municipios extremos, se alejan más. Esa campana es, sin que le
# hayas puesto todavía un nombre técnico, la intuición completa
# detrás de "qué tan confiable es un número que viene de una
# muestra". El nombre y el aparato formal llegan en Estadística.


# ---- 8. Cámbiale algo ----

# Repite la sección 7, pero cambia size = 100 por size = 20 (muestras
# más chicas) y corre el bloque completo otra vez. Antes de correrlo,
# anticipa: ¿esperas que la campana del histograma salga más ancha,
# más angosta, o igual que con muestras de 100? ¿Por qué?


# ==============================================================
# La pregunta abierta del cierre.
#
# En la sección 4 simulaste, persona por persona, la decisión de
# votar en Asientos, COMO SI cada quien decidiera solo, sin que le
# importara lo que decidieran sus vecinos o su familia. ¿Qué se
# pierde de la política real al hacer ese supuesto? Y una segunda,
# más difícil: ¿se te ocurre una manera de simular turnout donde la
# decisión de una persona SÍ dependa de la de sus vecinos? No la
# escribas en código todavía —esa herramienta no la has visto—; nada
# más descríbela en un comentario.
# ==============================================================
