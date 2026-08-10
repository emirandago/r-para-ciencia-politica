# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 4 · Ejercicio para practicar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el
# tercero si te sobra tiempo o te dio curiosidad.
#
# La solución comentada está en 04_solucion.R. Intenta primero.
# ==============================================================

library(tidyverse)
library(here)
library(fixest)

presidencial_2024 <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv")) |>
  select(clave_municipio, entidad, municipio, participacion)

judicial_2025 <- read_csv(here("datos", "limpios", "judicial_2025_scjn_municipio.csv")) |>
  distinct(clave_municipio, .keep_all = TRUE) |>
  select(clave_municipio, participacion_judicial)

panel_largo <- presidencial_2024 |>
  inner_join(judicial_2025, by = "clave_municipio") |>
  rename(participacion_2024 = participacion) |>
  pivot_longer(
    cols      = c(participacion_2024, participacion_judicial),
    names_to  = "eleccion",
    values_to = "participacion_pct"
  ) |>
  mutate(
    anio    = if_else(eleccion == "participacion_2024", 2024, 2025),
    es_2025 = as.numeric(anio == 2025)
  )


# ---- Nivel 1 · Calentamiento ----

# El script calculó sd_between y sd_within para todo el país, y como
# "cámbiale algo" las repitió solo para la región Sur-sureste. Ahora
# repítelas tú para la región Noroeste (Baja California, Baja
# California Sur, Chihuahua, Durango, Sinaloa, Sonora).
#
# Antes de correrlo, anticipa: la región Noroeste tiene mucha menos
# población total que el Sur-sureste, pero eso no necesariamente dice
# nada sobre qué tan pareja o dispareja fue la caída de participación
# entre sus municipios. ¿Esperas una razón (within / between) parecida
# a la del país completo, más grande, o más chica?

# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# (a) Calcula, para las 32 entidades, el promedio de participacion_2024
#     y el promedio de participacion_judicial (agrupando por entidad,
#     no por municipio), y la diferencia entre ambos.
#
# (b) Ordena las 32 entidades de la caída MÁS chica a la MÁS grande.
#     ¿Cuál entidad tuvo la caída más pequeña en puntos porcentuales?
#     ¿Cuál tuvo la más grande?
#
# (c) Contesta en un comentario de dos o tres líneas: la entidad con
#     la caída más grande, ¿es alguna con la que ya te habías
#     encontrado en otras sesiones del curso por alguna otra razón
#     (revisa la sesión 1 o la sesión 4)? ¿Se te ocurre alguna
#     hipótesis política de por qué esa entidad en particular cayó
#     tanto más que las demás?

# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Investiga, con documentación o con una IA —y VERIFICA lo que te
#     conteste corriéndolo—, qué produce
#
#       feols(participacion_pct ~ 1 | clave_municipio + anio, data = panel_largo)
#
#     es decir, un modelo SIN ninguna variable explicativa a la
#     derecha del ~, solo dos efectos fijos después de la barra.
#     ¿Qué tiene sentido que reporte un modelo así, si no hay ningún
#     coeficiente que estimar?
#
# (b) Investiga qué significa que un panel esté "balanceado"
#     (balanced panel) contra "desbalanceado" (unbalanced panel).
#     ¿Nuestro panel_largo de este extra es balanceado? (Pista:
#     ¿todos los municipios tienen exactamente dos filas, una por
#     año, sin ninguno de sobra ni de menos?)
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el
#     error que más veces te salió hoy y qué significaba.

# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, sin código:
#
# Este panel tiene N = 2,475 municipios y T = 2 periodos. Si mañana
# apareciera una tercera elección con datos municipales —digamos, la
# elección intermedia de 2027— y la agregaras a este panel, ¿qué de lo
# que hiciste hoy seguiría funcionando sin cambios, y qué tendrías que
# revisar? Piensa específicamente en la sección de lag()/lead().
# ==============================================================
