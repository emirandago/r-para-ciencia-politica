# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 06 · Solución comentada del ejercicio
# ---------------------------------------------------------------
# Se publica después de la sesión. Si llegaste aquí sin haber peleado
# con el ejercicio, regrésate: la solución solo enseña algo a quien ya
# se atoró. Leer código correcto sin haberlo intentado se siente como
# aprender y no lo es.
#
# Autor: Emiliano Miranda González
# ==============================================================

# [PENDIENTE: sustituir por base comparada cuando exista]
# Esta solución sigue usando datos mexicanos por la misma razón que el
# ejercicio: todavía no hay ninguna base comparada en datos/limpios/.

library(tidyverse)
library(here)
library(patchwork)

source(here("estilo", "tema_lab.R"))

resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

municipios_participacion <- resultados_municipio |>
  filter(!is.na(participacion)) |>
  arrange(participacion) |>
  mutate(posicion = row_number())

ggplot(municipios_participacion, aes(x = posicion, y = participacion, fill = participacion)) +
  geom_col(width = 1) +
  scale_fill_viridis_c(option = "viridis") +
  theme_lab() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(
    title = "Participación municipal en 2024, ordenada de menor a mayor",
    x     = "Municipios, ordenados de menor a mayor participación",
    y     = "Participación (%)"
  )

# Sobre la pregunta previa: NO tiene sentido una escala divergente aquí, y
# es un error de codificación visual usarla, no solo de gusto. Una escala
# divergente le dice a quien lee "hay un punto de referencia sustantivo a
# la mitad, y lo que importa es de qué lado y qué tan lejos estás de él".
# Eso es exactamente lo que pasa con ventaja_shh: cero es el empate entre
# SHH y el segundo lugar, un punto con significado político real.
# Participación no tiene ese punto medio: 0% no es un "empate", es
# simplemente el mínimo posible de la escala, y 50% no significa nada
# especial tampoco. Ahí lo que corresponde es una escala SECUENCIAL
# (gradient() o viridis_c(), que es lo que usamos arriba): solo importa
# la magnitud, de menos a más, sin un punto de quiebre al centro.


# ---- Nivel 2 · De verdad ----

# (a) La clasificación ad hoc.

region_municipio <- resultados_municipio |>
  mutate(
    region_norte_sur = case_when(
      entidad %in% c("Baja California", "Baja California Sur", "Chihuahua",
                      "Coahuila", "Durango", "Nuevo León", "Sinaloa",
                      "Sonora", "Tamaulipas") ~ "Norte",
      TRUE ~ "Sur"
    )
  ) |>
  filter(!is.na(ventaja_shh))

# (b) El gráfico de paneles. Reutilizamos el mismo esqueleto de "skyline"
# del script de hoy: ordenar y darle una posición a cada municipio, pero
# ahora calculando esa posición POR REGIÓN, para que cada panel se lea de
# menor a mayor por sí solo.

region_municipio <- region_municipio |>
  arrange(region_norte_sur, ventaja_shh) |>
  group_by(region_norte_sur) |>      # la posición se reinicia en cada región
  mutate(posicion = row_number()) |>
  ungroup()

ggplot(region_municipio, aes(x = posicion, y = ventaja_shh, fill = ventaja_shh)) +
  geom_col(width = 1) +
  scale_fill_gradient2(low = "#7B1113", mid = "white", high = "#006847", midpoint = 0) +
  facet_wrap(~ region_norte_sur, ncol = 1, scales = "free_x") +
  theme_lab() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(
    title   = "¿Dónde se concentra la ventaja de SHH?",
    x       = "Municipios de cada región, ordenados de menor a mayor ventaja",
    y       = "Ventaja de SHH sobre el segundo lugar (pp)",
    caption = "Fuente: INE, cómputos distritales 2024."
  )

# (c) La interpretación, que es la parte que de verdad importa.
#
# El patrón se confirma, pero con dos matices que valen más que la
# respuesta binaria. Primero, la magnitud: el promedio de ventaja_shh es
# 24.2 puntos en los 342 municipios del norte contra 47.6 puntos en los
# 2,131 del sur —una diferencia real, no un empate—. Se puede reproducir
# con lo que ya sabes:
#
#   region_municipio |>
#     group_by(region_norte_sur) |>
#     summarise(margen_promedio = mean(ventaja_shh), n = n())
#
# Segundo, y esto es lo que un gráfico de paneles deja ver y un solo
# número no: el patrón se rompe visiblemente en el Bajío. Guanajuato
# (14.8 puntos en promedio), Jalisco (11.5) y Querétaro (25.8) caen del
# lado "Sur" con esta clasificación puramente geográfica, pero se
# comportan políticamente mucho más parecido al norte conservador que al
# resto del sur. Esto es evidencia de que una regionalización ad hoc por
# geografía puede ocultar tanto como revela: para contestar bien la
# pregunta necesitarías una clasificación por historia político-electoral
# —el tipo de trabajo que hace un politólogo, no una función de R—, no
# solo un mapa.
#
# Nota también la trampa de la sesión 1, otra vez: el promedio de 24.2 y
# 47.6 es un promedio SIN PONDERAR de miles de municipios chicos, así que
# le da el mismo peso a un municipio de 300 personas que a uno de
# 300,000. Es una pregunta legítima —"¿en cuántos municipios ganó SHH por
# mucho?"— pero es una pregunta distinta de "¿cuántos votos de ventaja
# tuvo SHH en total en el norte contra el sur?", que necesitaría sumar
# votos, no promediar porcentajes.


# ---- Nivel 3 · Si te sobra tiempo ----

# (a) La comparación viridis vs. magma.

skyline <- resultados_municipio |>
  filter(!is.na(ventaja_shh)) |>
  arrange(ventaja_shh) |>
  mutate(posicion = row_number())

base <- ggplot(skyline, aes(x = posicion, y = ventaja_shh, fill = ventaja_shh)) +
  geom_col(width = 1) +
  theme_lab() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(x = NULL, y = "Ventaja de SHH (pp)")

(base + scale_fill_viridis_c(option = "viridis") + labs(title = "option = \"viridis\"")) /
  (base + scale_fill_viridis_c(option = "magma")   + labs(title = "option = \"magma\""))

# Una IA consultada sobre esto típicamente contesta bien la parte
# descriptiva: "viridis" va de morado oscuro a amarillo, "magma" va de
# negro a un amarillo más cálido pasando por magenta, y las dos mantienen
# el mismo orden de luminosidad de un extremo al otro (por eso ambas
# siguen siendo seguras para daltonismo y para escala de grises). Donde
# conviene desconfiar es si la IA afirma con demasiada seguridad CUÁL de
# las dos "se ve mejor" para tus datos en particular: eso es un juicio de
# diseño, no un hecho verificable, y la única forma de decidirlo es
# corriendo las dos y mirando, como acabas de hacer.
#
# (b) La pregunta con trampa.
#
# Si una IA te contesta que alguna paleta de la familia viridis (viridis,
# magma, inferno, plasma, cividis, mako, rocket, turbo) no es segura para
# daltonismo, está equivocada o te está confundiendo con otra familia de
# paletas: el diseño perceptualmente uniforme y seguro para las formas
# comunes de daltonismo es precisamente la razón por la que existe toda la
# familia. Donde sí hay que tener cuidado es con paletas AJENAS a viridis
# que alguien arma a mano con scale_fill_manual() —esas no vienen con
# ninguna garantía, y hay que verificarlas con una herramienta como
# colorBlindness::cvdPlot() antes de darlas por buenas—. Ese es el tipo de
# afirmación que sí conviene pedirle la fuente a la IA, y que aquí no
# hace falta pedirla porque ya está verificada en el material del curso.


# ==============================================================
# Cierre: la figura de paneles con la que cerraste el Nivel 2 —dos
# distribuciones, una para el norte y una para el sur, con la misma
# escala— es exactamente el tipo de comparación que en la sesión 11 vas a
# necesitar entre el poder electoral de Morena y el voto judicial: no un
# solo número para "México", sino una comparación entre grupos, hecha de
# forma que las dos mitades se puedan leer una junto a la otra. Guarda
# este script: vas a volver a este patrón.
# ==============================================================
