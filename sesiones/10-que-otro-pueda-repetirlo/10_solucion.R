# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 10 · Solución comentada del ejercicio
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

resultados <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

pct_ponderado <- function(parte, total) {
  sum(parte) / sum(total) * 100
}


# ---- Nivel 1 · Calentamiento ----

pct_ponderado(resultados$votos_mc, resultados$total_votos)
mean(resultados$pct_mc)

# La diferencia entre las dos cifras existe pero es más chica que la que
# viste con Sigamos Haciendo Historia en la sesión 1. Tiene sentido: el
# promedio ponderado se aleja del simple cuando el partido saca resultados
# muy distintos según el tamaño de la entidad —fuerte en estados grandes,
# débil en chicos, o al revés—. Movimiento Ciudadano tuvo un resultado más
# parejo en términos relativos entre estados grandes y chicos que las
# otras dos coaliciones, así que ponderar por tamaño lo mueve menos.
#
# La lección no es sobre Movimiento Ciudadano: es que la función te deja
# hacer la misma pregunta sobre cualquier columna sin volver a escribir la
# cuenta, y eso te permite comparar entre coaliciones con el mismo criterio.


# ---- Nivel 2 · De verdad — comparado ----

judicial <- read_csv(here("datos", "limpios", "judicial_2025_scjn_municipio.csv"))

judicial_municipio <- judicial |>
  distinct(clave_municipio, .keep_all = TRUE) |>
  select(clave_municipio, entidad, lista_nominal_2025, personas_votaron_2025)

# (a) Participación ponderada de la elección judicial 2025:

pct_ponderado(judicial_municipio$personas_votaron_2025, judicial_municipio$lista_nominal_2025)

# Debe salir cerca de 13.02 — el dato ya verificado en datos/README.md,
# recalculado de forma independiente y comprobado contra la fuente
# primaria del INE. Si tu número está lejos de ahí, algo se rompió en el
# distinct() de arriba: probablemente sigues arrastrando filas repetidas.

# (b) Participación ponderada de la elección presidencial 2024:

pct_ponderado(resultados$total_votos, resultados$lista_nominal)

# (c) La comparación.
#
# La participación en la elección judicial de 2025 fue muchísimo menor que
# en la presidencial de 2024 —del orden de una quinta parte, no de un
# ajuste pequeño—. Es un hallazgo ampliamente documentado en la cobertura
# de esa elección, y aquí lo estás recalculando tú mismo, de forma
# independiente, con datos primarios.
#
# Una explicación defendible con lo que tenemos: una elección judicial era
# un tipo de proceso inédito en México, con una boleta de decenas de
# candidaturas que la mayoría de las personas no conocía, y sin la
# cobertura mediática ni la costumbre cívica que sí tiene una elección
# presidencial. Eso es una intuición razonable, pero conviene decirlo con
# honestidad: estos datos por sí solos no prueban esa explicación —solo
# muestran QUE la participación fue menor, no POR QUÉ—. Para sostener el
# "por qué" haría falta otra fuente: encuestas de salida, cobertura de
# prensa contemporánea, o los datos de participación de otra elección
# judicial en otro país para comparar. Esa distinción entre "lo que el
# dato muestra" y "lo que el dato no prueba" es, en el fondo, la misma
# honestidad que es el argumento completo de la sesión de hoy.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) No hay una única respuesta correcta de código aquí: el resultado es
#     tu propia URL publicada. Si seguiste el mismo procedimiento de la
#     sección 5 a la 7 de 10_script_completo.R con estos dos números en
#     vez de uno, ya lo resolviste.
#
# (b) Respuesta esperable, y verificada en 10_guion.qmd: casi siempre no
#     es un error real. La primera vez que se activa GitHub Pages, GitHub
#     tarda uno o dos minutos en construir el sitio, y durante ese rato
#     la URL puede mostrar un 404. La respuesta correcta —"espera y
#     refresca"— es también la más aburrida, y por eso es fácil que una
#     IA te sugiera algo más complicado primero. Verificar antes de actuar
#     es exactamente el reflejo que la sesión 11 va a insistir en instalar.
#
# (c) Sin código: es tuya. El paso que más cuesta confiar suele ser el
#     mismo para casi todo el grupo —el YAML, por lo sensible que es a un
#     espacio de más—, y vale la pena saber que no te pasó solo a ti.


# ==============================================================
# Sobre a quién le mandaste el link:
#
# Si esa persona vio primero tu texto y tu número, y no una pantalla en
# blanco ni un mensaje de error, tu reporte cumplió lo que esta sesión
# pedía. Guarda esa URL: es el primer artefacto público de tu trabajo en
# este laboratorio, y va a seguir existiendo después de que termine el
# curso.
#
# Una pregunta para cerrar: dentro de un año, sin haber abierto esta
# carpeta desde entonces, ¿tu documento Quarto seguiría renderizando los
# mismos números? Si tienes dudas, ¿qué parte de hoy fue la que te las dejó?
# ==============================================================
