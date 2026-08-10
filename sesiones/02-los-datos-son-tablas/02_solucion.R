# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 02 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# [PENDIENTE: sustituir por una base comparada cuando exista en
# datos/limpios/ — ver la nota al inicio de 02_ejercicio.R.]
#
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

municipios <- read_csv(here("datos", "limpios", "puente_claves_ine_inegi.csv"))

glimpse(municipios)

# Son 2,477 filas: una por municipio del país (contando la Ciudad de México
# como si sus alcaldías fueran municipios, que es como las trata el
# catálogo electoral). Nota lo distinto que es ese número de las 32 filas
# de resultados: la unidad de observación cambió, y el tamaño de la base
# cambió con ella.
#
# Sobre el tipo de clave_municipio_inegi y clave_municipio_ife: las dos
# salen como <chr>, no como número, exactamente por la misma razón que
# clave_entidad en resultados. Son claves de cinco dígitos con cero a la
# izquierda ("01001"), y un cero al principio de un número no sobrevive si
# R lo trata como cantidad. Si esperabas que salieran como número, no es un
# error de intuición: es justo la trampa que la sesión de hoy quería que
# vieras venir.


# ---- Nivel 2 · De verdad ----

# (a) Una base nueva, con otra unidad de observación.

resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

glimpse(resultados_municipio)
nrow(resultados_municipio)

# Son 2,475 filas — casi las mismas 2,477 del catálogo de municipios del
# Nivel 1, con una diferencia mínima documentada en datos/README.md (dos o
# tres municipios sin fila, por causas distintas y ya explicadas ahí). Una
# fila, aquí, es un municipio en la elección de 2024: sigue siendo una
# FOTO (corte transversal), solo que con una unidad de observación mucho
# más fina que la de resultados.

# (b) Contar los NA de pct_shh.

n_na_pct_shh <- sum(is.na(resultados_municipio$pct_shh))
n_na_pct_shh

# Da 2. Son exactamente los dos municipios que documenta datos/README.md:
# Reforma (La) y Capulálpam de Méndez, ambos en Oaxaca.

# (c) Por qué convertir esos NA en 0 sería una mala decisión.
#
# Convertir esos NA en 0 diría, en los datos, que en esos dos municipios
# la coalición Sigamos Haciendo Historia sacó exactamente cero por ciento
# de los votos — es decir, que hubo una elección y que esa coalición no
# sacó ni un solo voto. Eso es falso: lo que pasó es que NO HUBO elección
# ahí ese día, porque ninguna casilla se instaló. Cero por ciento de algo
# que sí ocurrió y cero por ciento de algo que nunca ocurrió son dos
# situaciones completamente distintas, y un 0 numérico no distingue entre
# ellas. El NA sí distingue: dice, con honestidad, "aquí no hay dato que
# reportar", en vez de inventar uno que cambiaría cualquier promedio o
# cualquier mapa que se construya después con esta columna.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) NA contra NULL.
#
# Los dos representan "ausencia de algo", pero de maneras distintas.
# NA vive DENTRO de un vector: ocupa un lugar, tiene una posición, y el
# vector conserva su longitud.

vector_con_na <- c(35, NA, 42)
length(vector_con_na)   # 3: el NA cuenta como un elemento

# NULL representa la ausencia del vector mismo: no ocupa lugar.

vector_con_null <- c(35, NULL, 42)
length(vector_con_null)   # 2: NULL desaparece, no deja hueco

# Es exactamente el contraste que pide el ejercicio: NA es un valor
# desconocido dentro de una estructura que sigue teniendo ese espacio;
# NULL es la ausencia de la estructura misma. Si le preguntaste a una IA,
# es muy probable que te haya dado una explicación parecida a esta, y
# también es posible que te haya dado un ejemplo que no corre tal cual
# (algunas funciones de dplyr, por ejemplo, no aceptan NULL donde esperan
# un vector). La única manera de saber cuál pasó es correr el código, no
# leerlo.

# (b) El error o aviso más frecuente de hoy.
#
# Casi siempre fue uno de estos:
#
#   Warning: argument is not numeric or logical: returning NA
#     -> se le pidio una funcion numerica (como mean()) a una columna de
#        texto. Se corrige confirmando el tipo con glimpse() antes.
#
#   Error in read_dta(...) : could not find function "read_dta"
#     -> no se corrio library(haven) antes de usar read_dta().
#
#   Error: object 'municipios' not found
#     -> no se corrio la linea que crea el objeto, o se escribio distinto.
#
# Los tres, con más detalle, están en recursos/errores-comunes.qmd.


# ==============================================================
# Sobre tu pregunta del cierre:
#
# No hay una respuesta correcta, pero sí hay una prueba honesta: si no
# puedes decir en una frase qué sería una fila de tu base, todavía no
# tienes una pregunta de investigación lo bastante concreta como para
# empezar a programar. Eso está bien — es exactamente lo que las próximas
# sesiones van a ayudarte a precisar.
# ==============================================================
