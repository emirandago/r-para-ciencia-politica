# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Verificación integral del repositorio
# ---------------------------------------------------------------
# Qué hace este script:
#   Corre, uno por uno y en un entorno limpio, todos los scripts que el
#   camino crítico del curso promete que corren de arriba abajo: los
#   "_script_completo.R" y "_solucion.R" de las diez sesiones, y los
#   "_script.R" y "_solucion.R" de los seis extras autoestudiables.
#   Además revisa —solo con parse(), sin ejecutarlos, porque bajan
#   cientos de megabytes de internet— los ocho scripts de preparación
#   de datos. Y antes de todo eso, confirma que here::here() apunte a
#   la raíz del proyecto y que los paquetes que el curso necesita estén
#   instalados.
#
# Por qué existe este script: el §10 de las instrucciones del proyecto
# lo dice sin rodeos —"todo script del repositorio se ejecuta antes de
# publicarse. Un script que no corre en una instalación limpia es un
# fracaso del laboratorio, no un detalle: la primera vez que a alguien
# de primer semestre le truena el código del profesor, deja de venir"—.
# Este script es la manera de repetir esa verificación cada vez que se
# agregue o se cambie un archivo, sin tener que correr cada .R a mano,
# uno por uno, en la consola.
#
# Qué NO hace este script, a propósito:
#   No corre los "_script.R" DE SESIÓN (los de extras sí, porque esos
#   son autoestudiables y no tienen huecos) ni los "_ejercicio.R": esos
#   traen huecos marcados <hueco>...</hueco>, a propósito, para
#   completarse en clase, y DEBEN marcar error si se corren tal cual.
#   Que fallen no es un bug del curso: sería un bug que NO fallaran.
#
#   No descarga ningún dato: los "prep_*.R" solo se revisan con
#   parse(), que detecta errores de sintaxis sin bajar un solo
#   megabyte de internet. Correrlos completos es trabajo aparte,
#   deliberado y ocasional, no algo que este script deba repetir cada
#   vez.
#
# Cómo leer el resultado: la tabla final tiene una fila por archivo.
# "corre" en TRUE quiere decir que el script llegó de la primera a la
# última línea sin lanzar un error; NO promete que el contenido sea
# correcto, solo que no truena. Las advertencias se cuentan aparte:
# varias son pedagógicas y están puestas a propósito (se explican en
# reconocimiento/41_verificacion_scripts.md); otras, si aparecen, vale
# la pena leerlas con cuidado antes de decidir si importan.
#
# Autor: Emiliano Miranda González (con el subagente de verificación)
# ==============================================================

library(tidyverse)
library(here)


# ---- 0. ¿Dónde está parado R? ----

# Si esto truena, ninguno de los scripts que siguen va a poder
# encontrar los datos: abre r-para-ciencia-politica.Rproj desde RStudio
# (Archivo > Abrir proyecto) y vuelve a correr este script.

if (!file.exists(here("r-para-ciencia-politica.Rproj"))) {
  stop(
    "here::here() no está parado en la raíz del proyecto (se esperaba\n",
    "encontrar r-para-ciencia-politica.Rproj ahí). Ruta actual: ", here(),
    "\nAbre el .Rproj desde RStudio y vuelve a correr este script."
  )
}

cat("here::here() ->", here(), "\n\n")


# ---- 1. Los paquetes que el curso necesita ----

# Construida recorriendo todos los library() de sesiones/, extras/,
# estilo/ y datos/scripts_de_preparacion/. Si agregas un paquete nuevo
# en algún script del curso, agrégalo aquí también -- esta lista no se
# genera sola a partir del código.

paquetes_del_curso <- c(
  "tidyverse", "here", "sf", "janitor", "viridis", "modelsummary", "fixest",
  "haven", "readxl", "rmapshaper", "data.table", "quarto", "knitr", "tinytable",
  "patchwork", "marginaleffects", "countrycode", "curl", "vdemdata", "zip"
)

disponibilidad <- vapply(
  paquetes_del_curso,
  function(pkg) requireNamespace(pkg, quietly = TRUE),
  logical(1)
)

faltantes <- names(disponibilidad)[!disponibilidad]

if (length(faltantes) > 0) {
  cat("PAQUETES FALTANTES (instálalos con install.packages() antes de seguir):\n")
  cat(" -", paste(faltantes, collapse = ", "), "\n\n")
} else {
  cat("Los", length(paquetes_del_curso), "paquetes del curso están instalados.\n\n")
}


# ---- 2. La función que corre un script en un entorno limpio ----

# new.env() evita que un script le herede objetos a otro: cada archivo
# se corre como si alguien abriera RStudio por primera vez. Los
# gráficos se mandan a un dispositivo nulo -- si no, correr treinta y
# tantos scripts seguidos llena la pantalla de ventanas de gráficos que
# nadie va a mirar una por una.

verificar_script <- function(ruta_relativa) {
  ruta <- here(ruta_relativa)
  advertencias <- character(0)

  grDevices::pdf(file = nullfile())
  on.exit(grDevices::dev.off(), add = TRUE)

  resultado <- try(
    withCallingHandlers(
      source(ruta, local = new.env(), echo = FALSE),
      warning = function(w) {
        advertencias[[length(advertencias) + 1]] <<- conditionMessage(w)
        invokeRestart("muffleWarning")
      }
    ),
    silent = TRUE
  )

  tibble(
    archivo        = ruta_relativa,
    corre          = !inherits(resultado, "try-error"),
    error          = if (inherits(resultado, "try-error")) conditionMessage(attr(resultado, "condition")) else NA_character_,
    n_advertencias = length(advertencias),
    advertencias   = paste(advertencias, collapse = " | ")
  )
}

# La misma idea, pero solo de sintaxis: para los scripts de preparación
# de datos, que aquí NO se corren completos porque bajan cientos de
# megabytes cada uno.

verificar_sintaxis <- function(ruta_relativa) {
  ruta <- here(ruta_relativa)
  resultado <- try(parse(file = ruta), silent = TRUE)

  tibble(
    archivo        = ruta_relativa,
    corre          = !inherits(resultado, "try-error"),
    error          = if (inherits(resultado, "try-error")) conditionMessage(attr(resultado, "condition")) else NA_character_,
    n_advertencias = NA_integer_,
    advertencias   = NA_character_
  )
}


# ---- 3. Los archivos del camino crítico: las diez sesiones ----

sesiones_num      <- sprintf("%02d", 1:10)   # 01 a 10; la sesión 11 no trae .R
carpetas_sesiones <- list.dirs(here("sesiones"), full.names = FALSE, recursive = FALSE)

carpeta_de <- function(numero, carpetas) {
  encontrada <- carpetas[startsWith(carpetas, numero)]
  if (length(encontrada) != 1) {
    stop("No encontré (o encontré más de una) carpeta para el número '", numero, "'")
  }
  encontrada
}

carpetas_sesiones_ordenadas <- map_chr(sesiones_num, carpeta_de, carpetas = carpetas_sesiones)

scripts_sesiones <- c(
  file.path("sesiones", carpetas_sesiones_ordenadas, paste0(sesiones_num, "_script_completo.R")),
  file.path("sesiones", carpetas_sesiones_ordenadas, paste0(sesiones_num, "_solucion.R"))
)


# ---- 4. Los archivos de los seis extras autoestudiables ----

extras_num      <- sprintf("%02d", 1:6)
carpetas_extras <- list.dirs(here("extras"), full.names = FALSE, recursive = FALSE)
carpetas_extras_ordenadas <- map_chr(extras_num, carpeta_de, carpetas = carpetas_extras)

scripts_extras <- c(
  file.path("extras", carpetas_extras_ordenadas, paste0(extras_num, "_script.R")),
  file.path("extras", carpetas_extras_ordenadas, paste0(extras_num, "_solucion.R"))
)


# ---- 5. Los scripts de preparación de datos: solo sintaxis ----

scripts_prep <- file.path(
  "datos", "scripts_de_preparacion",
  list.files(here("datos", "scripts_de_preparacion"), pattern = "^prep_.*\\.R$")
)


# ---- 6. Correr todo y armar la tabla ----

cat(
  "Corriendo", length(scripts_sesiones) + length(scripts_extras),
  "scripts completos (sesiones + extras) y revisando la sintaxis de",
  length(scripts_prep), "scripts de preparación de datos...\n\n"
)

resultados_sesiones <- map_dfr(scripts_sesiones, verificar_script)
resultados_extras   <- map_dfr(scripts_extras, verificar_script)
resultados_prep     <- map_dfr(scripts_prep, verificar_sintaxis)

tabla_resultados <- bind_rows(
  mutate(resultados_sesiones, categoria = "sesión (completo/solución)"),
  mutate(resultados_extras,   categoria = "extra (autoestudiable)"),
  mutate(resultados_prep,     categoria = "prep (solo sintaxis)")
) |>
  relocate(categoria, .before = archivo)


# ---- 7. El reporte en consola ----

cat("\n==================== RESULTADO ====================\n\n")

print(select(tabla_resultados, categoria, archivo, corre, n_advertencias), n = Inf)

n_fallas <- sum(!tabla_resultados$corre)

if (n_fallas == 0) {
  cat("\nLos", nrow(tabla_resultados), "archivos revisados corrieron (o parsearon) sin error.\n")
} else {
  cat("\n", n_fallas, "de", nrow(tabla_resultados), "archivos NO corrieron. Detalle:\n\n")
  tabla_resultados |>
    filter(!corre) |>
    select(archivo, error) |>
    print(n = Inf, width = Inf)
}

n_con_advertencias <- sum(tabla_resultados$n_advertencias > 0, na.rm = TRUE)
if (n_con_advertencias > 0) {
  cat("\n", n_con_advertencias, "archivos corrieron con al menos una advertencia.",
      "Revísalas con tabla_resultados |> filter(n_advertencias > 0) |> View(),",
      "y compáralas contra la lista de advertencias esperadas de",
      "reconocimiento/41_verificacion_scripts.md.\n")
}

cat("\nRecuerda: los \"_script.R\" DE SESIÓN y los \"_ejercicio.R\" no se corrieron\n")
cat("aquí, a propósito -- tienen huecos y deben completarse en clase, no correr\n")
cat("solos. Los \"prep_*.R\" solo se revisaron por sintaxis, no se ejecutaron.\n")

# tabla_resultados queda disponible en el entorno para inspeccionarla
# a mano después de correr este script, por ejemplo con
# View(tabla_resultados) o tabla_resultados |> filter(!corre).
