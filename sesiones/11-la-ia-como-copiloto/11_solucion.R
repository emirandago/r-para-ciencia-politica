# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 11 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Se publica después de la sesión. Si llegaste aquí sin haber peleado
# con el ejercicio, regrésate: la solución solo enseña algo a quien ya
# se atoró.
#
# Un aviso que vale más aquí que en cualquier sesión anterior: esta
# solución NO contesta el nivel 2 ni el nivel 3 por ti. No puede. La
# interpretación de tu proyecto es tuya, con tu codificación de
# votos_bloque_a, y es exactamente la parte que un asistente de IA —y
# esta solución— no debe escribir en tu lugar. Lo que sí hace esta
# solución es mostrarte la FORMA de una respuesta defendible, con un
# coeficiente real, para que puedas comparar la tuya contra algo
# concreto.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)
library(fixest)

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
municipios <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

modelo_1_robusto <- feols(ventaja_shh ~ participacion, data = municipios, vcov = "hetero")


# ---- Nivel 1 · Calentamiento ----

exists("scale_fill_viridis_d")
# TRUE. Es la versión de la escala de viridis para variables categóricas
# (discretas): existe en ggplot2 desde la versión 3.0, junto a
# scale_fill_viridis_c() (continua), que ya usaste en la sesión 7.

exists("scale_fill_viridis_discreto")
# FALSE. No existe con esa ortografía. Es exactamente el patrón de
# geom_barplot(): un nombre que suena razonable —"discreto" en vez de
# "d"— y que una IA puede proponer con total seguridad sin que exista.
# La diferencia entre las dos funciones de este inciso no se adivina
# por lo bien que suenan: se comprueba con exists(), en un segundo.


# ---- Nivel 2 · De verdad: cerrar el proyecto ----

# (a) Un ejemplo de la FORMA de un párrafo defendible, no de SU
# contenido —porque el contenido depende de tu propia codificación de
# votos_bloque_a, que esta solución no tiene. Usamos modelo_1_robusto
# como sustituto declarado, tal como pedía el ejercicio si tu modelo con
# pct_bloque_a todavía no existe:
#
# QUÉ ENCONTRAMOS: en los 2,473 municipios con dato completo de la
# elección de 2024, una mayor participación electoral está asociada, en
# promedio, con una ventaja MENOR de la coalición Sigamos Haciendo
# Historia sobre el segundo lugar: por cada punto porcentual más de
# participación, la ventaja cae, en promedio, 0.287 puntos porcentuales
# (error estándar robusto, p < 0.01). La relación es estadísticamente
# distinguible de cero, pero el modelo explica una fracción mínima de
# por qué la ventaja cambia de un municipio a otro (R² = 0.016): la
# mayor parte de esa variación depende de algo que esta única variable
# no captura.
#
# Fíjate en tres decisiones de la frase de arriba, y no son accidente:
# lleva las unidades de las dos variables ("puntos porcentuales" en los
# dos lados), usa "está asociada" en vez de un verbo causal, y menciona
# el R² para no dejar que el asterisco de significancia cargue solo con
# el peso de la afirmación.
#
# (b) QUÉ NO PODEMOS AFIRMAR, con dos límites reales en vez de "faltan
# datos":
#
#   Primero, este modelo usa una sola variable explicativa a propósito
#   —la especificación mínima del proyecto—, así que "participación"
#   podría estar de compañera de viaje de otra característica del
#   municipio (tamaño, región, competitividad histórica) que es la que
#   de verdad mueve la ventaja. No lo sabemos con este modelo solo.
#
#   Segundo, esto es un corte transversal de un solo momento: no dice
#   qué pasaría si la participación de un municipio específico
#   cambiara, porque nunca observamos al mismo municipio dos veces con
#   distinta participación. Comparar municipios entre sí no es lo mismo
#   que observar a uno cambiar en el tiempo.
#
# (c) QUÉ HARÍAMOS CON MÁS TIEMPO, concreto y factible:
#
#   Correr el mismo modelo separando municipios por tamaño de lista
#   nominal (grandes contra chicos) para ver si el coeficiente se
#   mantiene parecido en los dos grupos, o si el -0.287 promedio
#   esconde dos historias distintas. Y, en el proyecto real con
#   votos_bloque_a, repetir el análisis completo con la codificación
#   alternativa y más restrictiva que pide el §3 del documento del
#   proyecto, para ver si el resultado depende de esa decisión.


# ---- Nivel 3 · Si te sobra tiempo: objeta tu propia interpretación ----

# Aquí es donde esta solución hace lo único que puede hacer con
# honestidad: no te da LA respuesta correcta sobre tu coeficiente,
# porque no la hay. Te muestra DOS interpretaciones distintas del mismo
# número —el -0.287 de modelo_1_robusto—, las dos defendibles, las dos
# publicables en un trabajo final, y te explica qué las separa. Elegir
# entre ellas —o construir una tercera— es tu trabajo, no el de esta
# solución.

coef(modelo_1_robusto)["participacion"]

# INTERPRETACIÓN A · la conservadora.
#
# "En este corte transversal de 2,473 municipios, una mayor
# participación está asociada con una ventaja menor de la coalición,
# en promedio y sujeto al error estándar reportado. No propongo un
# mecanismo: me quedo en el nivel de la asociación estadística, porque
# es lo único que este diseño de una sola variable permite sostener sin
# apelar a supuestos adicionales que no puedo verificar aquí."
#
# INTERPRETACIÓN B · la que arriesga un mecanismo.
#
# "El patrón es consistente con una historia sustantiva: municipios de
# baja participación suelen tener un electorado más chico y más leal a
# la maquinaria territorial de un partido dominante, mientras que
# municipios de participación alta suelen ser más urbanos y más
# competidos entre fuerzas políticas, lo que por sí solo —sin que la
# participación 'cause' nada— también reduciría la ventaja de la
# coalición. Nombro esa historia porque es plausible y porque conozco
# casos donde se ha documentado, aunque este modelo no la prueba."
#
# QUÉ LAS SEPARA.
#
# No es que una sea correcta y la otra un error: las dos son lecturas
# legítimas del mismo número, y las dos evitan la palabra "causa" sin
# haberla ganado. Lo que cambia es cuánto riesgo interpretativo asume
# cada una y qué le debe al lector a cambio.
#
# La interpretación A es más segura porque dice menos: no ofrece
# ningún mecanismo, así que no tiene nada sustantivo que defender más
# allá del número mismo. Es difícil de refutar, y por la misma razón es
# menos útil para alguien que quiera entender POR QUÉ pasa lo que pasa
# en el territorio.
#
# La interpretación B dice más, y por eso carga una obligación que la A
# no tiene: tiene que nombrar explícitamente las historias alternativas
# que producirían el mismo patrón sin que el mecanismo propuesto sea el
# que opera —aquí, la urbanización como variable que mueve tanto la
# participación como la ventaja por su cuenta— y tiene que explicar por
# qué, aun así, la historia que propone sigue siendo la más plausible o,
# si no puede hacerlo, decir que no puede.
#
# La pregunta que de verdad separa a alguien que usó la IA como
# copiloto de alguien que la dejó pilotar no es cuál de las dos
# interpretaciones eligió. Es si puede explicar, sin volver a
# preguntarle a nadie, por qué eligió esa y no la otra.


# ==============================================================
# Cierre: qué se llevó de este ejercicio y hacia dónde apunta.
#
# Las diez sesiones anteriores terminaban con una pregunta que empujaba
# hacia la siguiente función o el siguiente dato. Esta termina distinto,
# porque no hay sesión 12: termina empujando de vuelta hacia la pregunta
# que escribiste el primer día, en la sesión 1, y que esta vez sí tienes
# con qué intentar contestar —o con qué decir, con precisión, qué te
# falta todavía.
# ==============================================================
