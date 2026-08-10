# Tabla de referencia — anti-patrones y stack canónico

Este archivo es la versión larga de lo que `SKILL.md` resume. Consúltalo
cuando el problema que tengas enfrente no esté en la lámina corta, o
cuando dudes si un paquete o una técnica cabe en el nivel de un
laboratorio introductorio (once sesiones, sin Estadística I) o si es de
posgrado.

Fuente de esta tabla: síntesis de `mejores_practicas_r_cpol.md` (documento
normativo del curso) filtrada por `16_mejores_practicas.md` (auditoría que
separa lo introductorio de lo avanzado) y actualizada con
`17c_stack_y_color.md` (verificación de versiones vigentes en fuentes
primarias, agosto de 2026). Donde una cifra o fecha no se pudo confirmar
en fuente primaria, se marca `[VERIFICAR]` tal como aparece en esos
documentos — no la repitas como un hecho firme sin decir que viene con esa
etiqueta.

## Anti-patrones dentro del camino crítico de un curso introductorio

Estos son los que de verdad puede escribir sin querer alguien de primeros
semestres — dplyr básico, ggplot2, mapas, regresión simple. Prioriza
detectarlos.

| # | Anti-patrón | Por qué está mal | Alternativa | Cómo detectarlo si te pasan un script |
|---|---|---|---|---|
| 1 | `library(sp)`, `library(rgdal)`, `library(rgeos)` | Retirados de CRAN el 16 de octubre de 2023; el script no se instala limpio en una máquina nueva | `sf::st_read()`, objetos `sf`, `st_transform()` | Busca `library(sp` / `rgdal` / `rgeos`, o `readOGR(`, `spTransform(`, `Spatial*DataFrame` |
| 2 | `filter(x > 60 \| 50)` en vez de `filter(x %in% c(60, 50))` | `50` se evalúa como lógico (`TRUE`); la condición completa siempre es verdadera; el filtro no filtra nada y no truena | `%in%` para pertenencia a un conjunto de valores; condiciones completas repetidas (`x > 60 | x > 50`) si son dos comparaciones distintas | Busca un número suelto después de `|` o `&` dentro de `filter()` |
| 3 | `filter(var = valor)` (un solo `=`) | Confunde asignación con comparación; produce error o comportamiento no deseado | `filter(var == valor)` | Busca `filter(` seguido de un solo `=` sin duplicar |
| 4 | Gráficos 3D, pie charts, ejes duales, `geom_bar()`/`geom_col()` sin que el eje Y arranque en cero | Distorsionan la lectura visual del dato | `geom_col()` con eje Y desde cero; `facet_wrap()` en vez de doble eje; `patchwork` en vez de 3D | Busca `coord_polar(`, `plot3d(`, `scatterplot3d(`, `persp(`, `sec_axis(` |
| 5 | Reportar `summary(lm())` con errores estándar clásicos como resultado final de un análisis observacional | Los SE clásicos asumen homoscedasticidad, que rara vez se sostiene en datos observacionales de ciencia política | Mostrar `lm()` como puente pedagógico está bien (es lo que se ve en Estadística I); lo que se **reporta** como resultado final es `feols(..., vcov = "hetero")` | No es gregable de forma mecánica: revisa si un `summary(lm())` aparece como la tabla final de un análisis, no como paso intermedio explicado |
| 6 | No verificar `st_crs()` antes de graficar una capa espacial; calcular áreas sin proyección equal-area | Capas con CRS distinto no coinciden en el mapa sin que `sf` avise con un error; los datos mexicanos suelen venir en ITRF2008 (EPSG:6372), no WGS84 | `st_crs(objeto)` antes de graficar; `st_transform(crs = 4326)` para mapas web; comparar `st_crs(a) == st_crs(b)` antes de sobreponer capas | Si el script usa `st_read()` o carga un objeto espacial y nunca aparece `st_crs(`, marca la ausencia |

## Anti-patrones que solo aparecen en trabajo de posgrado (fuera del alcance de este curso)

Estos existen en el documento normativo porque fue escrito para un curso
de metodología política avanzada (posgrado). En un laboratorio
introductorio no se enseñan ni siquiera "para que se familiaricen" —
efectos fijos, interacciones con inferencia formal, DiD escalonado, RDD.
Si alguien de este curso pregunta por ellos, la respuesta correcta no es
enseñarlos a fondo: es explicar la intuición sin fórmulas y decir dónde se
aprenden después (ver la skill hermana `econometria-para-primer-semestre`
para la frontera exacta). Lista breve, por si necesitas reconocerlos:

- Interpretar coeficientes de efectos fijos como si tuvieran lectura
  causal directa.
- Incluir efectos fijos como variables dummy con `factor()` en `lm()` en
  vez de `feols(y ~ x | grupo)`.
- Omitir términos constitutivos en una interacción (`lm(y ~ x1:x2)` en vez
  de `lm(y ~ x1 * x2)`).
- Usar TWFE estándar con tratamiento escalonado sin correr antes un
  diagnóstico de Goodman-Bacon.
- Elegir manualmente el ancho de banda de una regresión discontinua sin
  justificación, o confundir bandwidth óptimo para estimación puntual con
  el óptimo para intervalos de confianza.

## Stack canónico — qué es de las once sesiones y qué es avanzado

| Paquete | Para qué sirve | ¿Nivel del laboratorio o avanzado? |
|---|---|---|
| `tidyverse` (`dplyr`, `ggplot2`, `tidyr`, `readr`) | Manipulación y visualización de datos, base de todo el curso | **Nivel del laboratorio** |
| `here` | Rutas relativas basadas en el proyecto `.Rproj`, sin `setwd()` | **Nivel del laboratorio** |
| `janitor` | `clean_names()` al importar, `tabyl()` para tablas de frecuencia | **Nivel del laboratorio** |
| `haven` | Importar `.dta` de Stata | **Nivel del laboratorio** (importación básica); el manejo fino de labels/`zap_labels()` es más avanzado |
| `sf` | Todo lo geoespacial: `st_read()`, `st_transform()`, `geom_sf()` | **Nivel del laboratorio** |
| `ggspatial`, `ggrepel` | Escala y flecha de norte en mapas; etiquetas sin traslape | **Nivel del laboratorio** |
| `viridis` (integrado en `ggplot2` ≥ 3.0.0 vía `scale_*_viridis_*()`) | Paletas seguras para daltonismo | **Nivel del laboratorio** |
| `fixest` (`feols()`) | Regresión con error robusto de fábrica, presentado junto a `lm()` | **Nivel del laboratorio**, limitado a regresión simple/múltiple sin efectos fijos avanzados ni IV |
| `modelsummary` | Tablas de regresión y de descriptivos (`datasummary()`) | **Nivel del laboratorio** |
| `plm`, `marginaleffects`, `sandwich`, `lmtest`, `did`, `bacondecomp`, `rdrobust`/`rddensity` | Panel data, efectos marginales de interacciones, SE avanzados, DiD escalonado, RDD | **Avanzado / posgrado** — no corresponde al camino crítico introductorio |
| `sensemakr`, `HonestDiD`, `interflex`, `DeclareDesign` | Análisis de sensibilidad, heterogeneidad no lineal, declaración de diseños | El propio documento normativo los marca como "no en el temario" — ni siquiera son material de auto-estudio para este público |

### Versiones vigentes en CRAN a agosto de 2026 (para saber si un tutorial viejo ya quedó obsoleto)

Verificado en fuentes primarias por el equipo del curso (`17c_stack_y_color.md`); las fechas exactas marcadas `[VERIFICAR]` en la fuente se repiten aquí con la misma etiqueta.

| Paquete | Versión vigente | Nota relevante |
|---|---|---|
| `dplyr` | 1.2.1 (abril 2026) | Verbos con guion bajo son **defunct** desde 1.2.0, no solo deprecados |
| `ggplot2` | 4.0.3 (abril 2026); el salto grande fue 4.0.0 (septiembre 2025) | `aes_string()` muerta desde 2018; `qplot()` y `size` para líneas, deprecados desde 3.4.0 (2022) |
| `sf` | 1.1-1 (mayo 2026) | Ya usa el pipe nativo internamente; exige R ≥ 4.1.0 |
| `sp`/`rgdal`/`rgeos`/`maptools` | — | Retirados de CRAN el 16 de octubre de 2023 |
| `fixest` | 0.14.1 (mayo 2026) | Sin deprecaciones que rompan sintaxis de cursos anteriores |
| `modelsummary` | 2.6.0 (fecha exacta `[VERIFICAR]`, ~febrero 2026) | El motor de salida por defecto es `tinytable`, no `kableExtra`, desde la versión 2.0.0 |
| `janitor` | 2.2.1 (diciembre 2024) | Sin cambios de sintaxis relevantes |
| `here` | 1.0.2 (septiembre 2025) | Detecta automáticamente proyectos de Quarto/VS Code además de `.Rproj` |

No enseñes ni des por buena sintaxis de `modelsummary(..., output = "kableExtra")` como comportamiento por defecto: hay que ser explícito con el argumento `output` si alguien quiere ese motor en vez de `tinytable`.
