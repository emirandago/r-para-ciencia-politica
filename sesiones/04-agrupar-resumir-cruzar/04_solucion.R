# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 04 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Se publica después de la sesión. Si llegaste aquí sin haber peleado
# con el ejercicio, regrésate: la solución solo enseña algo a quien ya
# se atoró. Leer código correcto sin haberlo intentado se siente como
# aprender y no lo es.
#
# Autor: Emiliano Miranda González
# ==============================================================

library(tidyverse)
library(here)

resultados_entidad   <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))
puente                <- read_csv(here("datos", "limpios", "puente_claves_ine_inegi.csv"))


# ---- Nivel 1 · Calentamiento ----

resultados_entidad <- resultados_entidad |>
  mutate(
    region = case_when(
      entidad %in% c("Baja California", "Baja California Sur", "Chihuahua",
                      "Durango", "Sinaloa", "Sonora")                   ~ "Noroeste",
      entidad %in% c("Coahuila", "Nuevo León", "Tamaulipas")            ~ "Noreste",
      entidad %in% c("Aguascalientes", "Colima", "Guanajuato", "Jalisco",
                      "Michoacán", "Nayarit", "Querétaro",
                      "San Luis Potosí", "Zacatecas")                   ~ "Occidente y Bajío",
      entidad %in% c("Ciudad de México", "México", "Hidalgo",
                      "Morelos", "Puebla", "Tlaxcala")                  ~ "Centro",
      entidad %in% c("Campeche", "Chiapas", "Guerrero", "Oaxaca",
                      "Quintana Roo", "Tabasco", "Veracruz", "Yucatán") ~ "Sur-sureste"
    )
  )

resumen_mc_por_region <- resultados_entidad |>
  group_by(region) |>
  summarise(
    n_entidades   = n(),
    pct_simple    = mean(pct_mc),
    pct_ponderado = 100 * sum(votos_mc) / sum(total_votos)
  ) |>
  mutate(diferencia = pct_simple - pct_ponderado) |>
  arrange(desc(pct_ponderado))

resumen_mc_por_region

# La diferencia entre el promedio simple y el ponderado, por región, es:
# Occidente y Bajío -0.54, Noreste -1.19, Centro +0.87, Noroeste -0.19,
# Sur-sureste +1.09 (en puntos porcentuales; el signo indica de qué lado
# queda el promedio simple respecto al ponderado).
#
# Si tu intuición fue "va a ser más chica que con pct_shh" en algunas
# regiones acertaste (Noroeste, con apenas 0.19 puntos de diferencia) y en
# otras no (Sur-sureste, con más de un punto). No hay una regla que diga
# "el partido chico siempre tiene diferencias chicas": depende de qué tan
# repartido o concentrado esté su voto dentro de cada región, no de cuánto
# saque en total. Esa es la respuesta honesta, y es mejor que una regla
# que suena bien pero no está en los datos.


# ---- Nivel 2 · De verdad ----

# (a) La columna tamano.

resultados_municipio <- resultados_municipio |>
  mutate(
    tamano = case_when(
      lista_nominal < 5000                          ~ "chico",
      lista_nominal >= 5000 & lista_nominal < 50000  ~ "mediano",
      lista_nominal >= 50000                         ~ "grande"
    )
  )

resultados_municipio |> filter(is.na(tamano))   # cero filas: nadie se quedó sin clasificar

# (b) El resumen por tamaño.

resumen_por_tamano <- resultados_municipio |>
  group_by(tamano) |>
  summarise(
    n_municipios  = n(),
    pct_simple    = mean(participacion, na.rm = TRUE),
    pct_ponderado = 100 * sum(total_votos) / sum(lista_nominal)
  )

resumen_por_tamano

# n_municipios: 781 chicos, 1,343 medianos, 351 grandes. La participación
# simple y la ponderada son: chico 61.96/63.80, mediano 64.62/63.59,
# grande 59.95/60.13.

# (c) La interpretación.
#
# Los municipios medianos son, en promedio, los que más participan; los
# grandes (donde vive la mayoría de la población del país) son los que
# menos. Eso ya es un dato interesante por sí solo: "más grande" no es
# "más participativo".
#
# Sobre la pregunta de si la brecha simple/ponderada cambia con el
# tamaño: en los municipios chicos el promedio simple SUBESTIMA la
# participación ponderada (61.96 contra 63.80): dentro del grupo "chico"
# hay unos poquísimos municipios enormes en votos relativos a los demás
# de su categoría que jalan el número ponderado hacia arriba. En los
# municipios grandes pasa casi lo mismo pero al revés y más leve (59.95
# contra 60.13). Es la misma lección de toda la sesión, aplicada a un
# corte distinto: agrupar por tamaño no elimina el problema del promedio
# simple, solo lo mueve a una escala más chica.

# (d) La entidad con más claves distintas entre INE e INEGI.

claves_distintas_por_entidad <- puente |>
  filter(clave_municipio_inegi != clave_municipio_ife) |>
  count(entidad, sort = TRUE)

claves_distintas_por_entidad

# Oaxaca encabeza, y por mucho: 459 de sus 570 municipios —el 80.5%—
# tienen clave distinta entre INE e INEGI. No es casualidad que sea la
# misma entidad que en la sesión encabezó el conteo de municipios totales
# (más de 500). Oaxaca tiene, con diferencia, la geografía municipal más
# fragmentada del país —muchos municipios pequeños, varios regidos por
# usos y costumbres— y esa fragmentación es exactamente el terreno donde
# la numeración de INE y la de INEGI tienen más oportunidades de
# divergir. El patrón que vimos en clase con Colima (una diferencia
# puntual, un municipio) en Oaxaca es la norma, no la excepción.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) pivot_wider(), la operación inversa.

resultados_largo <- resultados_entidad |>
  select(entidad, pct_shh, pct_fcm, pct_mc) |>
  pivot_longer(cols = c(pct_shh, pct_fcm, pct_mc),
               names_to = "coalicion", values_to = "pct")

resultados_ancho_de_nuevo <- resultados_largo |>
  pivot_wider(names_from = coalicion, values_from = pct)

resultados_ancho_de_nuevo

# Es casi idéntico a las columnas originales de resultados_entidad —"casi"
# porque pivot_wider() no te devuelve las demás columnas (lista_nominal,
# region, etc.) que sí tenía la tabla ancha original: pivot_longer() solo
# guardó las que le pediste con select() antes de aplanar. Si le hubieras
# pasado la tabla completa a pivot_longer(), pivot_wider() sí te la habría
# devuelto completa. Es un buen ejemplo de que pivot_longer()/
# pivot_wider() son inversas exactas SOLO si no perdiste información en
# el camino de ida.
#
# Si le preguntaste esto a una IA, lo más probable es que te haya dado
# esta misma respuesta —names_from/values_from son argumentos estables y
# documentados desde hace años—. Donde hay que tener más cuidado es si te
# sugiere pivot_wider() para "deshacer" un left_join(): eso NO es lo que
# hace, y es un error que una IA puede cometer con confianza total.
# Verificar corriendo el código, otra vez, es lo que separa una pista útil
# de un error que se copia sin darse cuenta.

# (b) El argumento relationship.

intento_permitido <- resultados_municipio |>
  left_join(puente, by = "municipio", relationship = "many-to-many")

nrow(intento_permitido)          # 2,943 — exactamente lo mismo que sin el argumento
# La diferencia NO es el resultado: relationship = "many-to-many" no
# arregla nada, solo le dice a R "sé que esto va a multiplicar filas y
# lo hago a propósito, no me avises". Es útil cuando de verdad quieres un
# cruce de muchos-a-muchos (por ejemplo, todas las combinaciones posibles
# entre dos listas); no es una manera de "silenciar" un error real. Usarlo
# aquí sin corregir el cruce sería quedarte con el problema y además
# apagarle la alarma.

# (c) El momento de más desconfianza.
#
# Para la mayoría, va a ser el mismo: ver que nrow() creció después de un
# left_join(). Un curso entero de estadística enseña a temer los NA;
# casi nadie enseña a temer las filas de más, y sin embargo pasa todo el
# tiempo en trabajo real con datos administrativos mexicanos —padrones,
# censos, resultados electorales—. Guárdalo: la próxima vez que un
# left_join() "funcione sin errores", igual compara nrow() antes y
# después. Es gratis y evita el peor tipo de error: el que no avisa.


# ==============================================================
# Sobre las dos bases que escribiste al final del ejercicio:
#
# Guarda esa respuesta. La sesión 11 va a pedirte, otra vez, que definas
# con precisión qué columna identifica de forma única cada fila de tus
# datos —es la pregunta que hoy aprendiste a hacerte ANTES de escribir
# left_join(), no después de que R te sorprenda.
# ==============================================================
