# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 01 · Tu primera hora en R
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Entender dónde está parado R cuando abrimos RStudio, guardar cosas en
#   objetos, hacer una operación sobre las 32 entidades del país de un
#   solo golpe, y producir nuestro primer gráfico de la elección de 2024.
#
# Qué necesitas antes de empezar:
#   Tener R y RStudio instalados y haber abierto el archivo
#   r-para-politologos.Rproj. Si no lo hiciste, ve a la página
#   "Empieza aquí" del sitio: son diez minutos y se hacen una sola vez.
#
# Datos: INE, cómputos distritales de la elección presidencial de 2024,
#        agregados por entidad. Ver datos/README.md para la fuente exacta.
# Autor: Emiliano Miranda González
# ==============================================================

# ESTA ES LA VERSIÓN RESUELTA. Se publica después de la sesión.
# Si estás en clase, usa 01_script.R.


# ---- 0. Los paquetes ----

# Un paquete es una caja de herramientas que alguien más escribió y regaló.
# R viene con unas cuantas de fábrica; las demás se instalan una sola vez.
#
# ESTA LÍNEA NO SE CORRE DESDE EL SCRIPT. Está comentada a propósito.
# Cópiala a la consola, córrela una vez en tu vida, y olvídate:
#
#   install.packages(c("tidyverse", "here"))
#
# ¿Por qué no dejarla suelta en el script? Porque instalar tarda minutos y
# el script se corre muchas veces. Un script que reinstala paquetes cada vez
# que lo abres es un script que nadie quiere correr.

library(tidyverse)   # el paquete que usaremos todo el curso: leer, ordenar, graficar
library(here)        # para no pelearnos nunca con las rutas de archivo

# Si al correr library(tidyverse) sale un error rojo que dice
# "there is no package called 'tidyverse'", significa que no lo instalaste.
# Corre la línea de install.packages() de arriba en la consola y vuelve.


# ---- 1. ¿Dónde está parado R? ----

# La primera pregunta que hay que saber contestar en R no es "cómo hago un
# gráfico". Es "dónde estoy". R siempre está parado en una carpeta, y todo
# lo que le pidas —abrir un archivo, guardar una imagen— lo va a buscar
# a partir de ahí.
#
# Esa carpeta se llama, en inglés, working directory: el directorio de trabajo.
# Como abrimos el proyecto r-para-politologos.Rproj, R quedó parado en la
# carpeta del proyecto. Compruébalo:

here()

# Debe imprimir la ruta que termina en /r-para-politologos.
# Si termina en otra cosa, cierra todo y vuelve a abrir el .Rproj.
#
# A partir de ahora nunca vas a escribir una ruta completa como
# "/Users/tu-nombre/Desktop/...". Vas a escribir here("datos", "limpios", ...)
# y aunque le pases el proyecto a alguien más, o lo muevas de carpeta, va a
# seguir funcionando. Esa es toda la magia y es más importante de lo que parece:
# la mitad del código de internet no corre en tu computadora por esta razón.


# ---- 2. La consola contra el script ----

# Tienes dos lugares donde escribir código y hacen cosas distintas.
#
# La CONSOLA (el panel de abajo) es donde R contesta. Lo que escribes ahí se
# ejecuta y se pierde. Sirve para probar, para preguntar, para equivocarse.
#
# El SCRIPT (este panel, el de arriba) es donde se escribe lo que quieres
# conservar. No se ejecuta solo: tú decides qué línea corre y cuándo, poniendo
# el cursor en la línea y apretando Ctrl+Enter (Cmd+Enter en Mac).
#
# Prueba: pon el cursor en la línea de abajo y aprieta Ctrl+Enter.

2 + 2

# El resultado aparece en la consola. La línea sigue aquí, guardada.
# Ese es el punto: el script es tu cuaderno, la consola es tu voz.


# ---- 3. Guardar cosas: los objetos ----

# Cuando calculas algo, R lo dice y lo olvida. Para que se acuerde, hay que
# guardarlo en un objeto con la flecha <- (que se escribe con Alt+guion, o
# Option+guion en Mac; no tienes que teclear los dos símbolos).

curules_diputados <- 500

# Fíjate: no imprimió nada. Guardó. Para verlo, escribe su nombre:

curules_diputados

# Y ahora puedes usarlo:

curules_diputados / 2

# R distingue mayúsculas de minúsculas. Esto va a fallar, y está bien que falle:
#
#   Curules_Diputados
#
# El error dice: object 'Curules_Diputados' not found. Traducido:
# "no encuentro nada que se llame así". Es el error más común de tu vida en R
# y casi siempre es una letra.


# ---- 4. Vectores: donde empieza a ponerse interesante ----

# Un vector es varios valores del mismo tipo, guardados juntos. Se arma con
# c(), que viene de "combine".

algunas_entidades <- c("Tabasco", "Chiapas", "Ciudad de México", "Guanajuato")
algunas_entidades

# Cuántos hay:
length(algunas_entidades)

# Ahora un vector de números. Estos son inventados, para el ejemplo:
votos_ficticios <- c(120, 340, 890, 410)

# Y aquí está lo que hace a R distinto de una calculadora y de Excel:
# una operación sobre un vector se aplica a TODOS sus elementos de un golpe.

votos_ficticios * 1000

# No escribiste cuatro multiplicaciones. Escribiste una.
#
# EL SALTO: eso, con cuatro números, es un truco. Con las 32 entidades del
# país, es una herramienta. Con los 2,469 municipios, es la diferencia entre
# poder contestar una pregunta y no poder. Cuando dentro de un momento
# calculemos el porcentaje de participación de las 32 entidades, va a ser
# una sola línea. Ese es el oficio.


# ---- 5. Una base de datos de verdad ----

# Vamos a abrir los resultados de la elección presidencial de 2024,
# agregados por entidad. Una fila es una entidad federativa; hay 32.

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

# read_csv() te avisa en la consola qué columnas encontró y de qué tipo son.
# Eso no es un error: es R diciéndote lo que entendió. Léelo.

# Las primeras filas:
head(resultados)

# Cuántas filas y cuántas columnas:
nrow(resultados)
ncol(resultados)

# Si nrow() no dice 32, algo se cargó mal. Son 31 estados y la Ciudad de México.


# ---- 6. Una operación sobre las 32 entidades a la vez ----

# El $ sirve para sacar una columna de la base. Es un poco tosco y a partir
# de la sesión 3 casi no lo vamos a usar, pero hoy sirve para ver el vector.

resultados$participacion

# Ahí están las 32 cifras. La media nacional de participación por entidad:

mean(resultados$participacion)

# Ojo con lo que acabas de calcular, porque es una trampa clásica: ese número
# NO es la participación nacional. Es el promedio de las 32 participaciones
# estatales, y trata a Colima igual que al Estado de México. La participación
# nacional se calcula con los votos totales, no promediando porcentajes.
# Todavía no tenemos las herramientas para hacerlo bien; en la sesión 4 sí.
# Por ahora quédate con la desconfianza: un promedio de porcentajes casi
# nunca es el porcentaje que crees.


# ---- 7. Tu primer gráfico ----

# Esto es un gráfico prestado. No vas a entender cada pieza hoy y no importa:
# hoy se trata de ver salir la imagen. El mecanismo llega en la sesión 5.

ggplot(resultados, aes(x = reorder(entidad, participacion), y = participacion)) +
  geom_col(fill = "#006847") +
  coord_flip() +
  labs(
    title    = "Participación en la elección presidencial de 2024",
    subtitle = "Porcentaje de la lista nominal que votó, por entidad",
    x        = NULL,
    y        = "Participación (%)",
    caption  = "Fuente: INE, cómputos distritales 2024."
  ) +
  theme_minimal()

# Tres cosas que sí puedes leer de ese bloque, aunque no entiendas el resto:
#
#   ggplot(resultados, ...)  → con qué datos
#   aes(x = ..., y = ...)    → qué va en cada eje
#   geom_col()               → qué forma tiene (col = columnas, o sea barras)
#
# Y una advertencia que vale para todo el curso: en ggplot2 las capas se
# encadenan con un signo +, y el + va SIEMPRE al final de la línea, nunca
# al principio de la siguiente. Si lo pones al principio, R cree que
# terminaste el gráfico y te va a marcar un error que parece de otra cosa.


# ---- 8. Cámbiale algo ----

# Cambia el color a "#00402C" (el verde profundo del curso) y vuelve a correr
# el bloque completo. Después cambia el título por una pregunta en vez de una
# descripción. Un buen título de gráfico dice qué hay que ver, no qué es.

ggplot(resultados, aes(x = reorder(entidad, participacion), y = participacion)) +
  geom_col(fill = "#00402C") +
  coord_flip() +
  labs(
    title    = "¿Dónde salió a votar más gente en 2024?",
    subtitle = "Porcentaje de la lista nominal que votó, por entidad",
    x        = NULL,
    y        = "Participación (%)",
    caption  = "Fuente: INE, cómputos distritales 2024."
  ) +
  theme_minimal()


# ==============================================================
# Mira el gráfico un minuto antes de cerrarlo.
#
# ¿Te esperabas ese orden? ¿Hay alguna entidad arriba o abajo que te
# sorprenda? ¿Y qué tendrías que saber, además de este gráfico, para
# explicar por qué está donde está?
#
# Esa última pregunta es la que hace politólogo a un politólogo. R solo
# te dejó verla más rápido.
# ==============================================================
