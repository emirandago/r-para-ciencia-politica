# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 02 · Los datos son tablas
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Abrir una base electoral real, aprender a leer lo que R nos dice al
#   importarla, distinguir los tipos de dato que trae cada columna, entender
#   qué es un NA, y sobre todo contestar la pregunta que ninguna función
#   contesta sola: ¿qué representa una fila de esta tabla?
#
# Qué necesitas antes de empezar:
#   Haber corrido la sesión 1: saber abrir el proyecto, guardar cosas en
#   objetos y usar here() para las rutas. No lo volvemos a explicar hoy.
#
# Datos: INE, cómputos distritales 2024 (presidencial, agregado por
#        entidad), y el catálogo de municipios de emagar/mxDistritos, que
#        usamos aquí solo para contrastar unidades de observación. Detalle
#        completo, con fuente y fecha de descarga, en datos/README.md.
# Autor: Emiliano Miranda González
# ==============================================================

# ESTA ES LA VERSIÓN RESUELTA. Se publica después de la sesión.
# Si estás en clase, usa 02_script.R.


# ---- 0. Los paquetes ----

# Nuevos hoy: haven (para leer archivos de Stata, .dta), readxl (para Excel,
# .xlsx) y janitor (para limpiar nombres de columna sucios). Los vas a usar
# poco en lo que resta del curso, porque casi todo lo que necesitamos ya
# vive en .csv, pero cuando alguien te mande un Excel de gobierno vas a
# agradecer tenerlos instalados.
#
#   install.packages(c("haven", "readxl", "janitor"))

library(tidyverse)   # dplyr, ggplot2, readr...: lo que ya conoces de la sesión 1
library(here)        # para las rutas, sin setwd()
library(haven)       # para leer .dta (Stata)
library(readxl)      # para leer .xlsx (Excel)
library(janitor)     # clean_names(): para cuando los nombres de columna vienen sucios


# ---- 1. Una tabla no es una hoja de cálculo ----

# En Excel se puede escribir cualquier cosa en cualquier celda: un número
# aquí, una fecha allá, una nota a mano abajo. R no funciona así. Cuando R
# guarda una tabla, la guarda como un tibble: una estructura donde cada FILA
# es un caso (una observación) y cada COLUMNA es una variable, y una columna
# completa tiene el mismo tipo de dato de arriba a abajo.
#
# Esa restricción no es una limitación: es lo que permite pedirle a R
# "calcula el promedio de esta columna" con la confianza de que no se va a
# encontrar un pedazo de texto a la mitad donde esperaba un número.


# ---- 2. Traer una base de verdad ----

# Abrimos otra vez los resultados de la elección presidencial de 2024,
# agregados por entidad. Ya la usamos en la sesión 1; hoy la vamos a mirar
# de verdad por dentro.

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

# Lee con calma lo que acaba de aparecer en la consola: es la especificación
# de columnas (column specification). read_csv() está diciendo, columna por
# columna, qué tipo de dato detectó. Eso NO es un error aunque salga en un
# color distinto — es R mostrando su trabajo, y vale la pena revisarlo
# siempre antes de seguir.
#
# Fíjate en particular en clave_entidad: tiene que salir como <chr> (texto),
# no como número. Si read_csv() la hubiera leído como número, "01" se habría
# convertido en 1 y habríamos perdido el cero — el mismo problema que
# tendría un código postal de cinco dígitos si perdiera su cero inicial.

# read_csv() (con guion bajo, del paquete readr) no es lo mismo que
# read.csv() (con punto, de R base). La de base R adivina los tipos en
# silencio y convierte texto en factor sin avisar; la de readr regresa un
# tibble y dice, línea por línea, qué decidió. Por eso en este curso usamos
# siempre read_csv().


# ---- 3. glimpse(): la manera más rápida de conocer una base ----

# head() enseña las primeras filas. glimpse() gira la tabla de lado y
# enseña cada columna con su tipo y sus primeros valores, todo en una sola
# pantalla. Es lo primero que se corre al abrir cualquier base nueva.

glimpse(resultados)

# Los tipos que vas a ver una y otra vez en este curso:
#   <chr>  texto (entidad, nombres de partido)      -> categorica, sin orden
#   <dbl>  numero con decimales (participacion)     -> numerica continua
#   <int>  numero entero (un conteo de escanos)     -> numerica discreta
#   <lgl>  TRUE / FALSE                             -> logica
#   <fct>  factor: texto con categorias fijas y, a veces, un orden
#
# En esta base en particular vas a ver sobre todo <chr> y <dbl>; <int>,
# <lgl> y <fct> los vamos a encontrar en otras bases del curso. Por qué
# importa: no se puede sacar el promedio de una columna <chr>, y no tiene
# sentido ordenar de mayor a menor una columna <lgl>. El tipo no es un
# detalle técnico: es lo que determina qué preguntas se le pueden hacer a
# esa columna.


# ---- 4. Una trampa real: el tipo equivocado ----

# ¿Qué pasa si se le pide el promedio a una columna de texto? Pruébalo:

mean(resultados$entidad)

# Sale NA con un aviso: "argument is not numeric or logical: returning NA".
# Traducción: "este argumento no es numérico ni lógico: voy a regresar NA".
# R no truena, y eso es lo peligroso: si no se lee la consola, se puede
# quedar un NA metido en un script largo sin saber de dónde salió. La
# regla: antes de resumir una columna con una función numérica, confirma
# su tipo con glimpse().


# ---- 5. NA: lo que falta, y por qué no es lo mismo que cero ----

# NA quiere decir "no disponible" (not available): R no sabe qué valor va
# ahí. No es lo mismo que 0 (que es un valor, y dice algo) ni que "" (una
# cadena vacía, que también es un valor). NA es la ausencia de dato, y R lo
# trata distinto a propósito: no hay que confundir "no hay información" con
# "la información es cero".

edad_legisladoras <- c(35, NA, 42, 29)   # ilustrativo: alguien no reporto su edad

is.na(edad_legisladoras)          # cuales son NA

n_na <- sum(is.na(edad_legisladoras))    # cuantos NA hay
n_na

# ¿Qué crees que va a pasar aquí? Piénsalo antes de correrlo:
mean(edad_legisladoras)

# Si un solo valor de un vector es NA, cualquier operación que dependa de
# TODO el vector se vuelve NA también — R no adivina qué hacer con el
# hueco, y hace bien en no adivinar. Para ignorar los NA y calcular con lo
# que sí se tiene, hay que decírselo explícitamente:

promedio_sin_na <- mean(edad_legisladoras, na.rm = TRUE)  # na.rm = "NA remove"
promedio_sin_na

# En la base de resultados por MUNICIPIO de la elección de 2024 —la vamos a
# usar en una sesión futura— hay dos municipios reales con NA en el
# porcentaje de cada coalición: Reforma (La) y Capulálpam de Méndez, ambos
# en Oaxaca. No es un error de captura: en los dos, ninguna casilla se
# instaló ese día, y dividir votos entre cero no tiene sentido. La base
# honesta dice NA en vez de inventar un 0. Vamos a volver a encontrarnos
# esa misma decisión de diseño más adelante en el curso.


# ---- 6. La pregunta que separa a quien manipula datos de quien los rompe ----

# Antes de filtrar, agrupar o graficar nada, hay una pregunta que hay que
# contestar siempre y que ningún glimpse() contesta sola: ¿qué representa
# una fila de esta tabla?
#
# En resultados, cada fila es una entidad federativa, en un solo momento (la
# elección de 2024). Eso la hace una base de corte transversal: una FOTO.
#
# Compáralo con estas otras formas en que una tabla puede estar armada
# (los números son inventados, solo para ver la forma):
#
#   SERIE DE TIEMPO (una sola entidad, varios años: una PELICULA de una) -
#     anio   participacion
#     2012   63
#     2018   63
#     2024   61
#
#   POOLED / CORTE TRANSVERSAL REPETIDO (entidades distintas cada anio,
#   nadie se repite a proposito):
#     anio   entidad      participacion
#     2012   Sonora       58
#     2018   Puebla       61
#     2024   Yucatan      66
#
#   PANEL (las mismas entidades, anio tras anio: una PELICULA de varias) -
#     entidad    2018   2024
#     Sonora     58     60
#     Puebla     61     59
#
# EL SALTO: la pregunta no es "¿cuántas filas tiene mi base?", es "¿qué
# representa cada fila, y puede repetirse?". Esa sola pregunta decide si lo
# que tenemos en las manos es una foto o una película, y con cada una se
# puede contestar un tipo de pregunta politológica distinto: una foto
# compara entidades entre sí; una película compara una entidad consigo
# misma a través del tiempo. Vamos a volver a esta distinción en la sesión
# 4, cuando comparemos "entre" con "dentro de".


# ---- 7. La misma clase de dato, mirado con otra unidad de observación ----

# resultados tiene 32 filas: una por entidad. Para ver una unidad de
# observación distinta sin salirnos del mismo país y la misma clave de
# entidad, abramos el catálogo de municipios que vamos a necesitar de
# verdad en la sesión 4: el puente de claves entre el INE y el INEGI. No
# trae resultados electorales — trae el catálogo de los 2,477 municipios
# del país—, pero sirve perfecto para el contraste.

municipios <- read_csv(here("datos", "limpios", "puente_claves_ine_inegi.csv"))

nrow(resultados)     # 32: una fila = una entidad
nrow(municipios)      # 2477: una fila = un municipio

# Mismo país, misma clave de entidad, pero un cambio en la unidad de
# observación multiplica el número de filas por casi 80. Antes de escribir
# una sola línea de dplyr sobre una base nueva, pregúntate siempre: ¿qué es
# una fila aquí?


# ---- 8. Dos formatos más, para cuando los necesites ----

# read_csv() no es el único formato que vas a encontrar en ciencia política.
# Vas a toparte con Excel de gobierno (.xlsx) y con bases de Stata (.dta)
# todo el curso. No los corremos en vivo hoy porque en este repositorio los
# datos limpios viven como .csv y .rds (ver datos/README.md), pero la
# sintaxis es casi idéntica a la de read_csv(), y este bloque queda aquí
# para cuando lo necesites:

# read_excel(here("datos", "limpios", "algun_archivo.xlsx"))
# read_dta(here("datos", "limpios", "algun_archivo.dta"))

# Tres cosas que muerden la primera vez:
#   - read_excel() lee la primera hoja por default. Si el archivo tiene
#     varias, usa el argumento sheet = "nombre_de_la_hoja" o sheet = 2.
#   - Un .dta de Stata trae "etiquetas de valor" (value labels) que R no
#     siempre traduce solo: si una columna se ve rara despues de importar
#     un .dta, prueba haven::as_factor() sobre ella antes de seguir.
#   - Si el Excel viene de una dependencia de gobierno, casi seguro los
#     nombres de columna vienen sucios ("Nombre de la Entidad ", con
#     mayusculas y espacios de sobra). janitor::clean_names() los deja en
#     snake_case de un solo golpe:
#
#     datos_crudos |> clean_names()


# ---- 9. Cámbiale algo ----

# Vuelve a correr glimpse(), esta vez sobre municipios en vez de resultados.
# Busca una columna que no hayamos mencionado hoy. ¿Qué tipo tiene? ¿Tiene
# sentido ese tipo para lo que esa columna representa?

glimpse(municipios)


# ==============================================================
# ¿Y si en vez de presidencial_2024_entidad.csv hubieras abierto
# presidencial_2024_municipio.csv? Antes de contestar, piénsalo: ¿cuántas
# filas esperarías? ¿Qué sería, ahora, una fila? ¿Sigue siendo una foto, o
# ya es otra cosa?
# ==============================================================
