# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 5 · Primer vistazo a inferencia causal
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Calcular una diferencia-en-diferencias con cuatro números y dos
#   restas, dibujar el salto de una regresión discontinua sobre datos
#   simulados, y contar la intuición de un factor de confusión con un
#   ejemplo real del curso.
#
# Qué necesitas antes de empezar:
#   El extra 4 (recomendado) y la sección de correlación-no-es-causa
#   de la sesión 9.
#
# ESTO NO ES UN CURSO DE INFERENCIA CAUSAL. Sin rdrobust(), sin ancho
# de banda óptimo, sin descomposición de Goodman-Bacon, sin DiD con
# tratamiento escalonado. Es una invitación de una hora, no un
# reemplazo de un curso de métodos.
#
# Este es un módulo AUTOESTUDIABLE. Este script corre completo, de
# arriba abajo, SIN huecos.
#
# Datos: los de la sección de DiD y RD son SIMULADOS o INVENTADOS a
#        propósito, y se marcan como tales en cada bloque. La sección
#        del confounder retoma resultados reales de la sesión 9,
#        calculados sobre presidencial_2024_municipio.csv.
# Autor: Emiliano Miranda González
# ==============================================================


# ---- 0. Los paquetes ----

library(tidyverse)
library(here)
library(fixest)

source(here("estilo", "tema_lab.R"))


# ---- 1. DiD: cuatro números y dos restas ----

# El 1 de enero de 2019, el gobierno federal duplicó el salario mínimo
# en los 43 municipios de la franja fronteriza norte, y lo dejó con el
# aumento normal en el resto de México. Ese es un hecho histórico real
# y verificable. Los números de esta tabla NO lo son: son inventados,
# para el ejemplo, igual que los votos_ficticios de la sesión 1.

tabla_did <- tibble(
  grupo   = c("Franja fronteriza (tratamiento)", "Resto del país (control)"),
  antes   = c(100, 100),
  despues = c(108, 103)
)

tabla_did

diferencia_tratamiento <- tabla_did$despues[tabla_did$grupo == "Franja fronteriza (tratamiento)"] -
                           tabla_did$antes[tabla_did$grupo == "Franja fronteriza (tratamiento)"]

diferencia_control <- tabla_did$despues[tabla_did$grupo == "Resto del país (control)"] -
                       tabla_did$antes[tabla_did$grupo == "Resto del país (control)"]

diferencia_tratamiento    #  8
diferencia_control        #  3

diferencia_en_diferencias <- diferencia_tratamiento - diferencia_control
diferencia_en_diferencias #  5: la parte del cambio atribuible a la política

# Ese +5 tiene un supuesto escondido: que, SIN la política, la franja
# fronteriza habría cambiado igual que el resto del país (tendencias
# paralelas). No lo vamos a comprobar hoy —exigiría datos de varios
# años antes de la política—, pero hay que decirlo con todas sus
# letras: la aritmética es sencilla, el supuesto detrás no lo es.


# ---- 2. La misma cuenta, con una regresión ----

datos_did <- tibble(
  grupo       = c("control", "control", "tratamiento", "tratamiento"),
  periodo     = c("antes", "despues", "antes", "despues"),
  tratamiento = c(0, 0, 1, 1),
  despues     = c(0, 1, 0, 1),
  resultado   = c(100, 103, 100, 108)
)

modelo_did <- feols(resultado ~ tratamiento * despues, data = datos_did)

summary(modelo_did)

# El coeficiente de tratamiento:despues debe darte, exactamente, 5: el
# mismo número que ya calculaste a mano. tratamiento * despues, dentro
# de una fórmula de R, no es multiplicación: incluye tratamiento solo,
# despues solo, Y su interacción —los tres términos—. Si escribieras
# tratamiento:despues (con dos puntos, sin el asterisco), R incluiría
# SOLO la interacción, sin los términos por separado, lo que sesga la
# estimación: es un antipatrón documentado del curso.


# ---- 3. RD: un dibujo con un salto ----

# Datos ENTERAMENTE simulados, con set.seed() para que siempre veas el
# mismo dibujo. puntaje es una variable de asignación ficticia (podría
# representar un puntaje de elegibilidad para un programa social);
# elegible es 1 del lado derecho de un corte en puntaje = 0; y
# resultado incluye un salto de 15 unidades exactamente en ese corte,
# construido a propósito para que se vea.

set.seed(2026)
datos_rd <- tibble(
  puntaje   = runif(500, min = -10, max = 10),
  elegible  = as.numeric(puntaje >= 0),
  resultado = 50 + 2 * puntaje + 15 * elegible + rnorm(500, sd = 5)
)

ggplot(datos_rd, aes(x = puntaje, y = resultado, colour = factor(elegible))) +
  geom_point(alpha = 0.5, size = 1.6) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = lab_colores[["gris_texto"]]) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_colour_lab_d(name = "Elegible", labels = c("No", "Sí")) +
  theme_lab() +
  labs(
    title    = "El salto que define una regresión discontinua",
    subtitle = "Datos simulados: un salto de 15 unidades, construido a propósito, en puntaje = 0",
    x        = "Puntaje de asignación (variable ficticia)",
    y        = "Resultado (variable ficticia)"
  )

# El salto se ve a simple vista, justo en la línea punteada. Eso es
# TODO lo que este extra te pide de una regresión discontinua: no la
# vamos a estimar con rdrobust(), no vamos a correr una prueba de
# manipulación en el corte, no vamos a elegir un ancho de banda. Es
# anécdota para ver una vez, no técnica para practicar aquí.


# ---- 4. La intuición de un confounder, con un caso real del curso ----

# Retomamos el resultado real de la sesión 9, sin volver a correr el
# modelo aquí (ya lo corriste ahí; esto es un repaso con otro
# propósito):
#
#   modelo_1: ventaja_shh ~ participacion              -> coeficiente de participacion: -0.29
#   modelo_2: ventaja_shh ~ participacion + pct_mc      -> coeficiente de participacion: -0.18
#
# El coeficiente de participacion se movió de -0.29 a -0.18 al agregar
# pct_mc. Esa es, sin ninguna fórmula, la prueba de mesa de un posible
# confusor: si el número de interés se mueve MUCHO al controlar por
# otra variable, es señal de que esa otra variable estaba conectada
# con las dos originales. Cuando el movimiento es chico o nulo, es
# señal de lo contrario: que esa variable no estaba haciendo de
# confusor para esta relación en particular.
#
# El caso clásico de la literatura, que ya conoces de la sesión 9: en
# EE. UU., legisladores con más hijas votan más a favor de temas de
# mujeres. ¿Tener hijas CAUSA ese voto? La sospecha de un confusor
# dice: quizás las familias grandes en general —no las hijas en
# particular— comparten otras características (ingreso, religión,
# región) que también predicen ese voto. La prueba sería la misma:
# controlar por tamaño de familia y ver si el coeficiente de "número
# de hijas" se sostiene o se derrumba.


# ---- 5. Cámbiale algo ----

# En la sección 1, cambia el número 103 (el "después" del grupo
# control) por 108 —el mismo valor que el grupo de tratamiento—.
# Antes de correrlo, anticipa: si el control y el tratamiento cambian
# EXACTAMENTE igual, ¿qué debería dar la diferencia-en-diferencias?

tabla_did_alt <- tibble(
  grupo   = c("Franja fronteriza (tratamiento)", "Resto del país (control)"),
  antes   = c(100, 100),
  despues = c(108, 108)
)

(tabla_did_alt$despues[1] - tabla_did_alt$antes[1]) -
  (tabla_did_alt$despues[2] - tabla_did_alt$antes[2])

# Debe darte 0: si el "resto del país" hubiera cambiado exactamente
# igual que la franja fronteriza, no habría ninguna evidencia de que
# la política tuvo un efecto propio, aunque el cambio ABSOLUTO en la
# franja siga siendo +8. Ese es, en una línea, todo el argumento de
# por qué un antes-y-después solo no basta.


# ==============================================================
# La pregunta abierta del cierre.
#
# Los tres bloques de hoy —DiD, RD, confounder— comparten una
# estructura: los tres son maneras de intentar aislar UNA causa
# concreta, en un mundo donde muchas cosas cambian al mismo tiempo.
# De las tres ideas que viste hoy, ¿cuál se te ocurre que sería más
# fácil de aplicar con datos electorales mexicanos reales que ya
# conoces de este laboratorio (2024, 2025), y cuál sería la más
# difícil? Justifica en un par de líneas qué dato adicional
# necesitarías para cada una que hoy no tienes en datos/limpios/.
# ==============================================================
