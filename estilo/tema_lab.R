# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# estilo/tema_lab.R · La paleta del curso, para ggplot2
# ---------------------------------------------------------------
# Qué hace este archivo:
#   Define theme_lab(), el tema visual del laboratorio, y las escalas de
#   color que combinan con las láminas y con el sitio. Así, cuando exportes
#   un gráfico y lo pegues en una presentación, no van a pelearse los verdes.
#
# Cómo se usa:
#   source(here::here("estilo", "tema_lab.R"))
#   ggplot(...) + geom_col() + theme_lab()
#
# Los hexes NO se editan aquí. Viven en estilo/paleta-itam.tex, que es
# el único archivo normativo. Si cambian allá, se copian acá y en estilo.scss.
#
# Autor: Emiliano Miranda González
# ==============================================================


# ---- 1. Los cuatro colores del curso ----

# Son los mismos hexes de estilo/paleta-itam.tex, ni uno más.
# Si alguna vez necesitas un tono intermedio, dilúyelo con colorRampPalette()
# a partir de estos; no inventes uno nuevo.

lab_colores <- c(
  verde_itam       = "#006847",  # acento principal: barras, líneas, puntos
  verde_profundo   = "#00402C",  # títulos y texto enfático
  verde_claro      = "#A8D5BE",  # fondos suaves, la categoría de contraste
  gris_texto       = "#3D3D3D"   # cuerpo de texto, ejes, etiquetas
)

# Derivados: diluciones sobre blanco. Mismo criterio que en LaTeX.
lab_gris_velo  <- "#F3F3F3"  # gris_texto al 8% sobre blanco
lab_gris_tenue <- "#A5A5A5"  # gris_texto al 45% sobre blanco


# ---- 2. theme_lab(): el tema visual ----

# Un tema de ggplot2 es una lista de decisiones sobre todo lo que NO son los
# datos: qué tan gruesa es la línea del eje, dónde va la leyenda, si hay
# cuadrícula. ggplot2 trae varios (theme_minimal(), theme_bw()); este es el
# nuestro, y hereda de theme_minimal() para no reinventar lo que ya está bien.

theme_lab <- function(base_size = 12, base_family = "") {

  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(

      # El título es lo primero que se lee. Va en verde profundo y en negritas,
      # y se alinea a la izquierda porque centrado se lee peor.
      plot.title = ggplot2::element_text(
        colour = lab_colores[["verde_profundo"]],
        face   = "bold",
        size   = ggplot2::rel(1.25),
        hjust  = 0,
        margin = ggplot2::margin(b = 6)
      ),

      # El subtítulo es donde va la pregunta politológica, no un adorno.
      plot.subtitle = ggplot2::element_text(
        colour = lab_colores[["gris_texto"]],
        size   = ggplot2::rel(1),
        hjust  = 0,
        margin = ggplot2::margin(b = 12)
      ),

      # La fuente del dato SIEMPRE va aquí. Un gráfico sin fuente no se entrega.
      plot.caption = ggplot2::element_text(
        colour = lab_gris_tenue,
        size   = ggplot2::rel(0.8),
        hjust  = 0,
        margin = ggplot2::margin(t = 10)
      ),

      plot.title.position   = "plot",   # el título se alinea con el borde,
      plot.caption.position = "plot",   # no con el panel: se ve más limpio

      axis.title = ggplot2::element_text(
        colour = lab_colores[["gris_texto"]],
        size   = ggplot2::rel(0.95)
      ),
      axis.text = ggplot2::element_text(
        colour = lab_colores[["gris_texto"]],
        size   = ggplot2::rel(0.9)
      ),

      # Cuadrícula tenue y solo en un eje. La cuadrícula sirve para leer
      # magnitudes; si compite con los datos, estorba.
      panel.grid.major = ggplot2::element_line(colour = lab_gris_velo, linewidth = 0.4),
      panel.grid.minor = ggplot2::element_blank(),

      # Encabezado de faceta: fondo verde velo, texto verde profundo.
      strip.background = ggplot2::element_rect(fill = "#E9F4EF", colour = NA),
      strip.text = ggplot2::element_text(
        colour = lab_colores[["verde_profundo"]],
        face   = "bold",
        size   = ggplot2::rel(0.9),
        margin = ggplot2::margin(4, 4, 4, 4)
      ),

      legend.position  = "top",
      legend.title     = ggplot2::element_text(
        colour = lab_colores[["gris_texto"]],
        size   = ggplot2::rel(0.9)
      ),
      legend.text = ggplot2::element_text(
        colour = lab_colores[["gris_texto"]],
        size   = ggplot2::rel(0.85)
      ),

      plot.margin = ggplot2::margin(12, 14, 10, 12)
    )
}


# ---- 3. Escalas de color ----

# ggplot2 distingue "color" (el borde o el punto) de "fill" (el relleno).
# Por eso cada escala existe dos veces. Es de las cosas que más confunden al
# principio: si tu gráfico sale gris, casi siempre pusiste una y necesitabas
# la otra.

# --- 3.1 Escala continua: para números (población, porcentaje de voto) ---

# Va del verde claro al verde profundo. Es una escala SECUENCIAL: sirve
# cuando "más color" significa "más cantidad". No la uses para categorías.

scale_fill_lab_c <- function(...) {
  ggplot2::scale_fill_gradient(
    low  = lab_colores[["verde_claro"]],
    high = lab_colores[["verde_profundo"]],
    ...
  )
}

scale_colour_lab_c <- function(...) {
  ggplot2::scale_colour_gradient(
    low  = lab_colores[["verde_claro"]],
    high = lab_colores[["verde_profundo"]],
    ...
  )
}

# Alias con la grafía estadounidense, porque ggplot2 acepta las dos y nadie
# debería tronar por escribir "color" en vez de "colour".
scale_color_lab_c <- scale_colour_lab_c


# --- 3.2 Escala discreta: para categorías (partidos, regiones) ---

# ADVERTENCIA, y es de las importantes del curso: una paleta monocromática
# como esta funciona bien hasta con TRES categorías. Con más, los tonos se
# vuelven indistinguibles y el gráfico miente por omisión.
# Si necesitas más de tres categorías, usa viridis:
#     scale_fill_viridis_d()
# que sí está diseñada para eso y es segura para daltonismo.
# La función te avisa sola si te pasas.

lab_paleta_discreta <- unname(lab_colores[c("verde_itam", "verde_claro", "verde_profundo")])

scale_fill_lab_d <- function(...) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    palette = function(n) {
      if (n > 3) {
        warning(
          "theme_lab: pediste ", n, " categorias y la paleta del curso solo ",
          "distingue bien 3. Usa scale_fill_viridis_d() en su lugar.",
          call. = FALSE
        )
      }
      grDevices::colorRampPalette(lab_paleta_discreta)(n)
    },
    ...
  )
}

scale_colour_lab_d <- function(...) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    palette = function(n) {
      if (n > 3) {
        warning(
          "theme_lab: pediste ", n, " categorias y la paleta del curso solo ",
          "distingue bien 3. Usa scale_colour_viridis_d() en su lugar.",
          call. = FALSE
        )
      }
      grDevices::colorRampPalette(lab_paleta_discreta)(n)
    },
    ...
  )
}

scale_color_lab_d <- scale_colour_lab_d


# ---- 4. Un tema para mapas ----

# Un mapa no necesita ejes: nadie lee "19.4° N" en un mapa de México. Lo que
# theme_lab_mapa() hace es quitar todo lo que en un mapa es ruido, y dejar
# título, subtítulo, fuente y leyenda, que sí informan.

theme_lab_mapa <- function(base_size = 12, base_family = "") {
  theme_lab(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      axis.title  = ggplot2::element_blank(),
      axis.text   = ggplot2::element_blank(),
      axis.ticks  = ggplot2::element_blank(),
      panel.grid  = ggplot2::element_blank(),
      legend.position = "right"
    )
}


# Pregúntate: si cambiaras legend.position de "top" a "right" en theme_lab(),
# ¿qué gráficos del curso se verían mejor y cuáles peor? Cámbialo y averígualo.
