# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 5 · Ejercicio para practicar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el
# tercero si te sobra tiempo o te dio curiosidad.
#
# La solución comentada está en 05_solucion.R. Intenta primero.
# ==============================================================

library(tidyverse)
library(here)
library(fixest)

source(here("estilo", "tema_lab.R"))


# ---- Nivel 1 · Calentamiento ----

# Un programa social FICTICIO ("Programa de Acompañamiento Escolar")
# se implementa, a partir de cierto año, en un grupo de municipios
# (tratamiento) y no en otro (control). Estos números son
# INVENTADOS, para el ejercicio, con esta tabla:
#
#   Tratamiento: antes = 62, después = 71
#   Control:     antes = 60, después = 64
#
# Calcula, con dos restas, la diferencia-en-diferencias. Antes de
# correrlo, anticipa si el resultado va a ser positivo o negativo, y
# aproximadamente de qué tamaño.

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# (a) Arma datos_programa, un tibble con la misma estructura de
#     datos_did del script (columnas grupo, periodo, tratamiento,
#     despues, resultado), pero con los cuatro números del Nivel 1.
#
# (b) Ajusta feols(resultado ~ tratamiento * despues, data = datos_programa)
#     y verifica que el coeficiente de la interacción coincide con tu
#     cálculo a mano del Nivel 1.
#
# (c) Contesta en un comentario de dos o tres líneas: si alguien te
#     dijera "el programa aumentó el resultado en 9 puntos" —usando
#     solo la diferencia DENTRO del grupo de tratamiento, sin comparar
#     contra el control—, ¿qué le responderías con lo que aprendiste
#     hoy sobre por qué esa comparación sola no basta?

# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) El supuesto de tendencias paralelas dice que, SIN el programa,
#     tratamiento y control se habrían movido igual. Con los datos que
#     tienes en datos/limpios/ (piensa en el panel del extra 4, con
#     dos elecciones mexicanas reales), ¿podrías verificar ese
#     supuesto de verdad? ¿Qué te haría falta que hoy no tienes?
#     Contesta en prosa, sin código.
#
# (b) Investiga, con documentación o con una IA —y VERIFICA lo que te
#     conteste—, qué hace el argumento bwselect del paquete rdrobust.
#     No lo vamos a usar en este módulo; solo queremos que reconozcas
#     el nombre si te lo encuentras leyendo un paper.
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el
#     error que más veces te salió hoy y qué significaba.

# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, sin código:
#
# De los tres bloques del módulo —DiD, RD, confounder—, ¿cuál se
# parece más a la lógica que ya usaste, sin nombrarla así, en algún
# otro momento de este laboratorio (piensa en las sesiones 4, 8 o 9)?
# ==============================================================
