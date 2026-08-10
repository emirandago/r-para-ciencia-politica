# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Extra 4 · Datos de panel y efectos fijos
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Construir un panel de datos con dos elecciones mexicanas reales
#   (presidencial 2024, judicial 2025), calcular la variación BETWEEN
#   municipios y la variación WITHIN cada municipio, ajustar un modelo
#   con feols() y un efecto fijo, y usar lag()/lead()/cumsum().
#
# Qué necesitas antes de empezar:
#   La sesión 4 (group_by, summarise, left_join) y la sesión 9
#   (feols(), modelsummary()).
#
# Sin prueba de Hausman, sin efectos aleatorios, sin álgebra de
# matrices de varianza-covarianza: ese aparato es de un curso de
# métodos de posgrado, no de este laboratorio.
#
# Este es un módulo AUTOESTUDIABLE. Este script corre completo, de
# arriba abajo, SIN huecos.
#
# Datos: INE, cómputos distritales de la elección presidencial de
#        2024 y de la elección judicial de 2025, por municipio. Ver
#        datos/README.md, secciones 2 y 5.
# Autor: Emiliano Miranda González
# ==============================================================


# ---- 0. Los paquetes ----

# Un paquete nuevo: fixest, para feols(). Ya lo instalaste en la
# sesión 9.
#
#   install.packages(c("fixest"))

library(tidyverse)
library(here)
library(fixest)


# ---- 1. Construir el panel: dos elecciones, un mismo municipio ----

presidencial_2024 <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv")) |>
  select(clave_municipio, entidad, municipio, participacion)

judicial_2025 <- read_csv(here("datos", "limpios", "judicial_2025_scjn_municipio.csv")) |>
  distinct(clave_municipio, .keep_all = TRUE) |>          # una fila por municipio, no una por candidatura
  select(clave_municipio, participacion_judicial)

# judicial_2025_scjn_municipio.csv viene en formato LARGO: una fila
# por municipio POR candidatura (ver datos/README.md, sección 5). La
# columna participacion_judicial se repite igual en las 64 filas de un
# mismo municipio, así que distinct(clave_municipio, .keep_all = TRUE)
# se queda con una sola fila por municipio sin perder información.

panel_ancho <- presidencial_2024 |>
  inner_join(judicial_2025, by = "clave_municipio") |>
  rename(participacion_2024 = participacion)

nrow(panel_ancho)   # 2,475 municipios con las dos elecciones


# ---- 2. De ancho a largo: pivot_longer(), de la sesión 4 ----

panel_largo <- panel_ancho |>
  pivot_longer(
    cols      = c(participacion_2024, participacion_judicial),
    names_to  = "eleccion",
    values_to = "participacion_pct"
  ) |>
  mutate(
    anio    = if_else(eleccion == "participacion_2024", 2024, 2025),
    es_2025 = as.numeric(anio == 2025)
  )

# 2,475 municipios x 2 elecciones = 4,950 filas. Cada municipio
# aparece dos veces: una fila para 2024, una para 2025.
nrow(panel_largo)


# ---- 3. La pregunta BETWEEN: comparar municipios entre sí ----

media_por_municipio <- panel_largo |>
  group_by(clave_municipio) |>
  summarise(media = mean(participacion_pct))

sd_between <- sd(media_por_municipio$media)
sd_between   # alrededor de 8 puntos porcentuales

# summarise() colapsa cada municipio en UNA fila con su promedio entre
# las dos elecciones, y sd() mide qué tan distintos son esos 2,475
# promedios ENTRE SÍ.


# ---- 4. La pregunta WITHIN: comparar un municipio consigo mismo ----

panel_largo <- panel_largo |>
  group_by(clave_municipio) |>
  mutate(
    media_municipio   = mean(participacion_pct),
    desviacion_within = participacion_pct - media_municipio
  ) |>
  ungroup()

sd_within <- sd(panel_largo$desviacion_within)
sd_within   # más de 24 puntos porcentuales

# mutate() —a diferencia de summarise()— conserva las 4,950 filas y le
# pega a cada una la media de SU municipio. La resta que sigue mide
# cuánto se aleja cada elección de "lo normal" para ese municipio
# específico.

sd_between
sd_within
sd_within / sd_between   # la variación within es varias veces más grande


# ---- 5. Lo que ese contraste dice de México ----

panel_largo |>
  group_by(anio) |>
  summarise(participacion_promedio = mean(participacion_pct))

# La participación promedio SIMPLE cae de alrededor de 63.1% en 2024 a
# alrededor de 15.8% en 2025. Ojo con la misma trampa de siempre —la
# sesión 1 la plantó y la sesión 4 la resolvió—: esto es un promedio
# simple entre 2,475 municipios, no el dato nacional ponderado. El
# dato oficial y verificado, documentado en datos/README.md, es
# 13.02% para la elección judicial de 2025. La caída real, ponderada
# por votos, es todavía más grande que la que ves aquí.
#
# Esa caída de casi 50 puntos, ocurrida más o menos por igual en casi
# todos los municipios del país, es exactamente lo que produce mucha
# variación WITHIN (cada municipio se movió mucho respecto a sí mismo)
# y relativamente poca variación BETWEEN (los municipios no se movieron
# tan distinto UNOS DE OTROS: casi todos cayeron juntos).


# ---- 6. feols() con un efecto fijo ----

modelo_fe <- feols(
  participacion_pct ~ es_2025 | clave_municipio,
  data = panel_largo,
  vcov = ~clave_municipio
)

summary(modelo_fe)

# clave_municipio, después de la barra, se absorbe como efecto fijo:
# el modelo elimina todo lo que es constante en cada municipio a
# través de las dos elecciones y deja solo es_2025 para explicar lo
# que sí cambió.

diferencia_manual <- panel_largo |>
  group_by(anio) |>
  summarise(media = mean(participacion_pct)) |>
  summarise(diferencia = diff(media))

diferencia_manual

# Compara el coeficiente de es_2025 en modelo_fe contra diferencia_manual.
# Deberían coincidir casi hasta el último decimal: con exactamente dos
# periodos por unidad, una regresión de efectos fijos sobre una sola
# variable de periodo reproduce, matemáticamente, la diferencia
# promedio pareada que ya calculaste a mano. No es casualidad ni un
# error de redondeo a tu favor: es una propiedad de los datos de panel
# de dos periodos.


# ---- 7. lag(), lead() y cumsum(): un ejemplo con datos INVENTADOS ----

# Con solo dos periodos por municipio, estas funciones se ven un poco
# recortadas. Para que la sintaxis quede clara con MÁS de dos
# momentos, un panel de juguete: tres estados ficticios, cinco años,
# un indicador cualquiera. INVENTADO, para el ejemplo, igual que los
# votos_ficticios de la sesión 1.

set.seed(2026)
panel_de_juguete <- expand_grid(
  estado = c("Estado A", "Estado B", "Estado C"),
  anio   = 2020:2024
) |>
  mutate(valor = round(runif(n(), min = 30, max = 70), 1))

panel_de_juguete <- panel_de_juguete |>
  group_by(estado) |>
  arrange(anio) |>
  mutate(
    valor_anterior  = lag(valor),            # el valor del año pasado, del MISMO estado
    valor_siguiente = lead(valor),           # el valor del año que viene
    cambio          = valor - lag(valor),    # cuánto cambió respecto al año pasado
    acumulado       = cumsum(valor),         # la suma corrida hasta ese año
    minimo_a_la_fecha = cummin(valor),       # el valor MÁS CHICO visto hasta ese año, del mismo estado
    maximo_a_la_fecha = cummax(valor)        # el valor MÁS GRANDE visto hasta ese año, del mismo estado
  ) |>
  ungroup()

panel_de_juguete

# group_by(estado) ANTES de arrange() y mutate() no es opcional: sin
# él, lag() te traería el valor del ÚLTIMO año de OTRO estado al
# cambiar de grupo, un error silencioso que R no te avisa. cummin() y
# cummax() son primas de cumsum(): en vez de ir sumando, van guardando
# el mínimo o el máximo visto hasta cada fila, dentro del mismo grupo
# —útiles para preguntas como "¿ya se había visto una participación
# tan baja como esta en este municipio?"—.


# ---- 8. lag() sobre el panel real ----

panel_largo <- panel_largo |>
  group_by(clave_municipio) |>
  arrange(anio) |>
  mutate(participacion_anterior = lag(participacion_pct)) |>
  ungroup()

# Para las filas de 2025, participacion_anterior ahora trae la
# participación de 2024 del MISMO municipio, en la misma fila: lista
# para restar sin un segundo left_join().

panel_largo |>
  filter(anio == 2025) |>
  mutate(cambio = participacion_pct - participacion_anterior) |>
  summarise(cambio_promedio = mean(cambio))

# Ese cambio_promedio debe coincidir, otra vez, con diferencia_manual
# de la sección 6: tres caminos distintos —resta directa de promedios,
# feols() con efecto fijo, y lag() fila por fila— y los tres llegan al
# mismo número. Eso, más que cualquier función suelta, es la lección
# de este módulo.


# ---- 9. Cámbiale algo ----

# Repite las secciones 3 y 4, pero filtrando primero panel_largo a
# solo las entidades de la región "Sur-sureste" que definiste en la
# sesión 4 (Campeche, Chiapas, Guerrero, Oaxaca, Quintana Roo,
# Tabasco, Veracruz, Yucatán). ¿La razón sd_within / sd_between de esa
# región se parece a la del país completo, o es distinta?

panel_sursureste <- panel_largo |>
  filter(entidad %in% c("Campeche", "Chiapas", "Guerrero", "Oaxaca",
                          "Quintana Roo", "Tabasco", "Veracruz", "Yucatán"))

media_sursureste <- panel_sursureste |>
  group_by(clave_municipio) |>
  summarise(media = mean(participacion_pct))

sd(media_sursureste$media)   # between, solo Sur-sureste

panel_sursureste_within <- panel_sursureste |>
  group_by(clave_municipio) |>
  mutate(desviacion = participacion_pct - mean(participacion_pct)) |>
  ungroup()

sd(panel_sursureste_within$desviacion)   # within, solo Sur-sureste


# ==============================================================
# La pregunta abierta del cierre.
#
# El extra 4 comparó a México consigo mismo en dos momentos. Para que
# ese "antes y después" se convierta en una diferencia-en-diferencias
# de verdad, ¿qué le tendrías que agregar? Piensa en la palabra que ya
# se usó varias veces en este script —"grupo de comparación"— y en
# qué parte de México NO vivió el mismo colapso de participación entre
# 2024 y 2025 que el resto del país. No lo contestes con código
# todavía: esa herramienta es, literalmente, el extra 5.
# ==============================================================
