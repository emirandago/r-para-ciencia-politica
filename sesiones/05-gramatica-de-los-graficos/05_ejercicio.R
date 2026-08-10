# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 05 · Ejercicio para llevar
# ---------------------------------------------------------------
# Tres niveles. Haz el primero siempre; el segundo si puedes; el tercero
# si te sobra tiempo o si te dio curiosidad. Nadie los revisa: son tuyos.
#
# Ninguno se resuelve copiando y pegando, y ninguno necesita una función
# que no hayamos visto hoy. Si sientes que te falta una herramienta, no
# te falta: te falta acordarte de cuál.
#
# La solución comentada se publica después de la sesión, en 05_solucion.R.
# Intenta primero. El punto no es tener la respuesta, es haber peleado
# diez minutos con ella.
# ==============================================================

library(tidyverse)
library(here)

resultados_entidad   <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))
resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))


# ---- Nivel 1 · Calentamiento ----

# Reproduce el gráfico secuencial de la sesión (participación por entidad,
# con fill = participacion y scale_fill_viridis_c()), pero cambia la
# variable: usa pct_shh en vez de participacion, tanto en el eje como en
# el fill.
#
# Antes de correrlo, contesta mentalmente: ¿esperas que el orden de las
# barras sea el mismo que con participacion? ¿Por qué sí o por qué no?
#
# Escribe tu código aquí abajo:




# ---- Nivel 2 · De verdad ----

# Una pregunta nueva, con la base de municipios: ¿dónde estuvo más reñida
# la elección entre las ciudades grandes del país, y en cuántas de ellas
# le ganó el bloque contrario a Sigamos Haciendo Historia?
#
# (a) Filtra resultados_municipio con filter() para quedarte solo con los
#     municipios con lista_nominal mayor a 300,000 personas.
#
# (b) Con ese filtro, haz un gráfico de barras horizontal: municipio en el
#     eje y (ordenado por ventaja_shh), ventaja_shh en el eje x, fill
#     mapeado a ventaja_shh, con una escala DIVERGENTE y midpoint = 0
#     explícito. Ponle título en forma de pregunta, ejes con unidad y
#     fuente.
#
# (c) En un comentario de dos o tres líneas: ¿por qué una escala divergente
#     es la elección correcta para ventaja_shh, y por qué NO lo sería para
#     participacion? Usa tus propias palabras, no copies la sesión.
#
# (d) Cuenta cuántos de esos municipios grandes tuvieron ventaja_shh
#     negativa —es decir, dónde le ganó el bloque contrario— con filter()
#     y nrow(). Interpreta el número en un comentario: ¿te sorprende que
#     sean muchos o pocos, dado lo que sabes de la elección de 2024?
#
# Escribe tu código aquí abajo:




# ---- Nivel 3 · Si te sobra tiempo ----

# (a) Toma el filtro de municipios grandes del nivel 2 y colorea cada
#     barra por el nombre del municipio (fill = municipio) usando
#     rainbow() con scale_fill_manual(). Corre el gráfico y descríbelo en
#     un comentario: ¿a partir de cuántas barras deja de servir?
#
# (b) Investiga el paquete ggokabeito (la paleta Okabe-Ito, la que usa R
#     por defecto desde la versión 4.0.0 para gráficos base) o la función
#     colorBlindness::cvdPlot(). Tienes tres caminos, y los tres son
#     legítimos: la documentación del paquete en CRAN, una búsqueda en
#     línea, o preguntarle a una IA. Si usas la IA, pídele además que te
#     explique la diferencia entre una paleta "colorblind-safe" y una
#     paleta "perceptualmente uniforme" — no son lo mismo, y es fácil
#     confundirlas. Después VERIFICA instalando el paquete y corriendo el
#     ejemplo que te haya dado. La sesión 11 trata precisamente de esto:
#     verificar antes de confiar.
#
# (c) Escribe en un comentario, en una sola oración, cuál fue el error o
#     la advertencia que más veces te salió hoy y qué significaba.
#
# Escribe tu código aquí abajo:




# ==============================================================
# Y una última, que no tiene código:
#
# Vuelve a la pregunta que escribiste en la sesión 1. Si tuvieras que
# graficarla hoy, ¿qué tipo de escala de color necesitaría —secuencial,
# divergente o cualitativa—? Y si no necesita color en absoluto, ¿por qué
# no?
#
# Escribe tu respuesta aquí:
#
# ==============================================================
