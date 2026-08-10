# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 5 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Si llegaste aquí sin haber peleado con el ejercicio, regrésate: la
# solución solo enseña algo a quien ya se atoró.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)
library(fixest)


# ---- Nivel 1 · Calentamiento ----

diferencia_tratamiento <- 71 - 62   #  9
diferencia_control     <- 64 - 60   #  4

diferencia_en_diferencias <- diferencia_tratamiento - diferencia_control
diferencia_en_diferencias #  5

# La anticipación razonable era "positivo, y menor a 9": el grupo de
# tratamiento sí mejoró más que el de control (9 contra 4), así que la
# diferencia-en-diferencias tenía que ser positiva, y como el control
# también mejoró algo por su cuenta, el número atribuible al programa
# —5— tenía que ser menor que el cambio bruto del grupo de
# tratamiento (9).


# ---- Nivel 2 · De verdad ----

# (a)

datos_programa <- tibble(
  grupo       = c("control", "control", "tratamiento", "tratamiento"),
  periodo     = c("antes", "despues", "antes", "despues"),
  tratamiento = c(0, 0, 1, 1),
  despues     = c(0, 1, 0, 1),
  resultado   = c(60, 64, 62, 71)
)

# (b)

modelo_programa <- feols(resultado ~ tratamiento * despues, data = datos_programa)

summary(modelo_programa)

# El coeficiente de tratamiento:despues debe darte 5, exactamente el
# mismo número que calculaste a mano en el Nivel 1.

# (c) La respuesta a "el programa aumentó el resultado en 9 puntos".
#
# Esa afirmación usa solo la primera resta —dentro del grupo de
# tratamiento, después menos antes— y le atribuye TODO ese cambio al
# programa. El problema es que el grupo de control, que NO recibió el
# programa, también mejoró 4 puntos en el mismo periodo: algo más
# —una tendencia nacional, un cambio de contexto, lo que sea que
# afecta a todos los municipios por igual— también estaba empujando
# el resultado hacia arriba, con o sin programa. Atribuirle los 9
# puntos completos al programa es exactamente el error que la
# diferencia-en-diferencias corrige: la cifra honesta, una vez que
# restas lo que habría pasado de todos modos, es 5, no 9.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Con el panel del extra 4 —2024 y 2025— NO se puede verificar el
#     supuesto de tendencias paralelas de verdad, porque solo hay UN
#     periodo "antes" del supuesto cambio de régimen electoral
#     (presidencial vs. judicial). Verificar tendencias paralelas
#     exige, como mínimo, VARIOS periodos antes del tratamiento, para
#     comprobar que tratamiento y control ya venían moviéndose
#     parecido ANTES de que ocurriera cualquier diferencia entre
#     ellos. Con un solo "antes", cualquier par de números coincide
#     trivialmente en una sola diferencia, y eso no es evidencia de
#     nada: hace falta una serie de tiempo más larga, que hoy no está
#     en datos/limpios/. Nota, además, que 2024 (presidencial) y 2025
#     (judicial) NO son en realidad "el mismo tipo de elección en dos
#     momentos": son dos tipos de elección distintos, así que ni
#     siquiera calificarían de forma directa como un diseño de
#     tratamiento/control en el sentido que este módulo describió —el
#     extra 4 lo usó como panel corto, no como DiD, precisamente por
#     esto—.
#
# (b) bwselect en rdrobust() controla qué MÉTODO usa el paquete para
#     elegir el ancho de banda —cuántas observaciones alrededor del
#     corte usar para estimar el salto—, con opciones como "mserd"
#     (óptimo para el error cuadrático medio) o "cerrd" (óptimo para
#     construir un intervalo). Es exactamente el tipo de decisión
#     técnica que este módulo evita a propósito: elegir mal el ancho
#     de banda puede cambiar el resultado de un RD por completo, y
#     decidir bien exige entender el compromiso entre sesgo y
#     varianza, que es contenido de otro curso.
#
# (c) El error más frecuente de este módulo suele ser escribir
#     tratamiento:despues (con dos puntos) en vez de
#     tratamiento * despues (con asterisco) dentro de la fórmula de
#     feols(). Con dos puntos, R SOLO incluye la interacción y omite
#     tratamiento y despues por separado como términos propios —el
#     antipatrón de "omitir efectos principales" documentado en
#     mejores_practicas_r_cpol.md—, y el coeficiente que sale ya no es
#     comparable con el cálculo a mano.


# ==============================================================
# Sobre la pregunta de cierre del ejercicio:
#
# La intuición de confounder es, con diferencia, la que ya usaste sin
# nombrarla: en la sesión 8, cuando viste que la correlación entre
# participación y voto por SHH cambiaba de signo según agruparas por
# municipio o por entidad, y en la sesión 9, cuando el coeficiente de
# participacion se movió al agregar pct_mc. Cada vez que preguntaste
# "¿esto se sostiene si controlo por otra cosa?", ya estabas pensando
# como alguien que sospecha de un confusor, aunque el curso todavía no
# le hubiera puesto ese nombre.
# ==============================================================
