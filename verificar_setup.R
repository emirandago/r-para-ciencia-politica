# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# verificar_setup.R · ¿Está todo listo para empezar?
# ---------------------------------------------------------------
# Qué hace:
#   Revisa las cinco cosas que tienen que estar bien antes de correr
#   cualquier script del curso, y te dice exactamente cuál falla y cómo
#   arreglarla. No modifica nada.
#
# Cómo se usa:
#   Abre el proyecto r-para-ciencia-politica.Rproj, y en la consola escribe:
#
#       source("verificar_setup.R")
#
#   Si todo sale con un "OK", ya puedes empezar.
#
# Por qué existe:
#   Porque el error más frustrante del primer día no es un error de código,
#   es que R esté parado en la carpeta equivocada. Cuando eso pasa, el
#   mensaje que R devuelve ("does not exist") no dice la causa real, y
#   quien empieza no tiene cómo adivinarla.
#
# Autor: Emiliano Miranda González
# ==============================================================

cat("\n=== Verificando el laboratorio ===\n\n")

fallas <- 0
ok  <- function(x) cat("  OK    ", x, "\n")
mal <- function(x, arreglo) {
  cat("  FALLA ", x, "\n         -> ", arreglo, "\n", sep = "")
  fallas <<- fallas + 1
}


# ---- 1. ¿Está aquí el paquete que sabe dónde estamos? ----

if (requireNamespace("here", quietly = TRUE)) {
  ok("El paquete 'here' está instalado.")
} else {
  mal("Falta el paquete 'here'.",
      'Corre en la consola: install.packages("here")')
}


# ---- 2. ¿Dónde cree R que está parado? ----

# Esta es LA verificación importante. here() busca hacia arriba, desde la
# carpeta en la que R está trabajando, hasta encontrar un archivo .Rproj (o
# alguna otra señal de raíz de proyecto) y se ancla ahí. Si abriste el .Rproj
# equivocado —o ninguno—, here() se ancla en otro lugar y TODAS las rutas del
# curso quedan mal a la vez.
#
# La prueba no es que la carpeta se llame de cierta forma: es que exista
# datos/limpios/ adentro. Eso funciona igual si descargaste el ZIP (y tu
# carpeta se llama r-para-ciencia-politica-main) que si clonaste el
# repositorio.

if (requireNamespace("here", quietly = TRUE)) {

  raiz <- here::here()
  wd   <- getwd()

  cat("\n  R está trabajando en:\n    ", wd,   "\n", sep = "")
  cat(  "  here() está anclado en:\n    ", raiz, "\n\n", sep = "")

  raiz_ok <- dir.exists(file.path(raiz, "datos", "limpios"))
  wd_ok   <- dir.exists(file.path(wd,   "datos", "limpios"))

  if (raiz_ok) {

    ok("here() apunta a la carpeta del curso: encontré datos/limpios/ adentro.")

  } else if (wd_ok) {

    # Este es el caso traicionero. El paquete 'here' decide su raíz UNA SOLA VEZ,
    # cuando se carga, y después ya no la vuelve a calcular. Si R arrancó en la
    # carpeta equivocada y después se corrigió el directorio, here() se queda
    # anclado donde estaba y ninguna ruta del curso funciona — aunque getwd()
    # ya diga lo correcto. Cambiar de carpeta NO basta: hay que reiniciar R.
    mal("here() se quedó anclado en una carpeta vieja.",
        paste0("Estás en el lugar correcto, pero 'here' se cargó antes de que\n",
               "            lo estuvieras y guardó la raíz equivocada. Reinicia R:\n",
               "            Session -> Restart R  (Ctrl+Shift+F10 / Cmd+Shift+F10)\n",
               "            y vuelve a correr esta verificación."))

  } else {

    mal("R NO está en la carpeta del curso.",
        paste0("Cierra RStudio por completo y vuelve a abrirlo haciendo\n",
               "            doble clic sobre r-para-ciencia-politica.Rproj\n",
               "            (no desde el icono de RStudio). Si el problema sigue,\n",
               "            revisa que no haya OTRO archivo .Rproj en una carpeta\n",
               "            de arriba: si lo hay, here() se ancla en esa y no en esta."))
  }
}


# ---- 3. ¿Están las bases que usan las sesiones? ----

if (requireNamespace("here", quietly = TRUE) &&
    dir.exists(file.path(here::here(), "datos", "limpios"))) {

  esperados <- c(
    "datos/limpios/presidencial_2024_entidad.csv",
    "datos/limpios/presidencial_2024_municipio.csv",
    "datos/limpios/puente_claves_ine_inegi.csv",
    "datos/limpios/judicial_2025_scjn_municipio.csv",
    "datos/geo/entidades_simplificado.rds",
    "datos/geo/municipios_simplificado.rds"
  )

  faltan <- esperados[!file.exists(here::here(esperados))]

  if (length(faltan) == 0) {
    ok(paste0("Están las ", length(esperados), " bases del curso."))
  } else {
    mal(paste0("Faltan ", length(faltan), " base(s): ",
               paste(basename(faltan), collapse = ", ")),
        paste0("Vuelve a descargar el material del sitio del curso, o\n",
               "            revisa que el ZIP se haya descomprimido completo."))
  }
}


# ---- 4. ¿Están los paquetes de las primeras sesiones? ----

# Solo los que hacen falta de la sesión 1 a la 6. Los de mapas y regresión
# se revisan cuando lleguemos ahí, para no alarmar a nadie el primer día.

basicos <- c("tidyverse", "here")
faltantes <- basicos[!vapply(basicos, requireNamespace, logical(1), quietly = TRUE)]

if (length(faltantes) == 0) {
  ok("Están los paquetes de las primeras sesiones.")
} else {
  mal(paste0("Falta(n): ", paste(faltantes, collapse = ", ")),
      paste0('Corre en la consola:\n',
             '            install.packages(c(',
             paste0('"', faltantes, '"', collapse = ", "), '))'))
}


# ---- 5. ¿La sesión está limpia? ----

# No es un error, es una advertencia. Si arrastras objetos de una sesión
# anterior, tu código puede funcionar por razones que no están escritas en
# el script — y el día que se lo pases a alguien más, no va a correr.

n_objetos <- length(ls(envir = globalenv()))
if (n_objetos <= 3) {
  ok("La sesión de R está razonablemente limpia.")
} else {
  cat("  AVISO  Hay ", n_objetos, " objetos en el entorno.\n",
      "         No es un error, pero conviene empezar de cero:\n",
      "         Session -> Restart R (Ctrl+Shift+F10 / Cmd+Shift+F10).\n", sep = "")
}


# ---- Veredicto ----

cat("\n")
if (fallas == 0) {
  cat("=== Todo listo. Puedes empezar. ===\n\n")
} else {
  cat("=== ", fallas, " cosa(s) por arreglar. Sigue las indicaciones de arriba. ===\n\n",
      sep = "")
}

invisible(fallas)
