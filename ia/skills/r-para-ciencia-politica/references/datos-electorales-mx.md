# Datos electorales mexicanos: la reconciliación INE–INEGI

## El problema

El INE (antes IFE) y el INEGI son dos instituciones distintas, con dos
sistemas de claves distintos, y **sus códigos de municipio no coinciden**.
Si cruzas una base de resultados electorales del INE con un shapefile o
una base socioeconómica del INEGI usando el nombre del municipio o
asumiendo que las claves numéricas son intercambiables, el cruce puede
"funcionar" — correr sin error — y sin embargo emparejar mal algunas
filas. Es el mismo tipo de falla silenciosa que un `filter()` mal escrito:
no truena, y está mal.

No inventes una regla de conversión entre ambos sistemas de claves. Existe
una fuente ya construida y verificada para esto.

## La tabla puente: `emagar/mxDistritos`

Repositorio de Eric Magar (ITAM), verificado directamente en
`github.com/emagar/mxDistritos` (última revisión del README consultada:
10 de abril de 2026). El propio repositorio confirma, en la sección de
identificadores de observación, dos columnas que son exactamente la
reconciliación que necesitas:

- **`inegi`** = identificador de municipio usado por INEGI.
- **`ife`** = identificador de municipio usado por IFE/INE.
- `edon` = número de entidad (1 a 32); `edo` = abreviatura de entidad;
  `mun` = nombre del municipio; `seccion` = identificador de sección
  electoral (no cruza fronteras municipales).

Es decir: cualquier fila del repositorio trae, lado a lado, el código de
municipio en ambos sistemas — esa es la tabla puente. El repositorio
también documenta el *reseccionamiento* (cambios en los límites de las
secciones electorales a través del tiempo) en
`equivSecc/tablaEquivalenciasSeccionalesDesde1994.csv`, relevante si el
cruce involucra series de tiempo largas.

Cita que el propio repositorio pide usar (ver "About" en la página del
repositorio): Eric Magar (2019) *Recent Mexican electoral geography
repository*, https://github.com/emagar/mxDistritos.

### Patrón de uso

```r
library(tidyverse)
library(here)

# La tabla puente trae inegi e ife como columnas hermanas: úsala para
# traducir de un sistema de claves al otro antes de cualquier cruce.
puente_municipios <- read_csv(here("datos", "crudos", "equivalencias_mxdistritos.csv")) |>
  select(edon, mun, inegi, ife)

# Ahora sí puedes cruzar una base con claves INE contra una con claves
# INEGI, pasando por la tabla puente en vez de asumir que los códigos
# numéricos ya coinciden.
resultados_con_clave_inegi <- resultados_ine |>
  left_join(puente_municipios, by = c("clave_municipio_ine" = "ife"))

# Cuenta antes y después: si nrow() cambió, algo no cruzó como esperabas.
nrow(resultados_ine)
nrow(resultados_con_clave_inegi)
```

Este patrón es un punto de partida, no una receta cerrada: los nombres de
columna exactos de la tabla que descargues del repositorio pueden variar
según el archivo específico (`vhat`, `vraw`, `win`) — revisa la sección
"Variables in the datasets" del README antes de asumir un nombre de
columna que no hayas confirmado.

## `emagar/elecRetrns`: resultados electorales, no solo geografía

Repositorio hermano del mismo autor (Eric Magar, ITAM), confirmado en
`github.com/emagar/elecRetrns` ("Recent Mexican Election Vote Returns").
Mientras que `mxDistritos` resuelve la geografía y la reconciliación de
claves, `elecRetrns` es la fuente de resultados electorales en sí.
`[VERIFICAR]` la estructura exacta de columnas de este segundo repositorio
antes de escribir código contra él: no se auditó con el mismo detalle que
`mxDistritos` para esta skill.

## Regla general para cualquier cruce con datos oficiales mexicanos

1. Nunca asumas que dos claves numéricas de fuentes distintas son la misma
   cosa solo porque tienen el mismo número de dígitos.
2. Si vas a cruzar INE con INEGI (o con cualquier shapefile del Marco
   Geoestadístico), pasa primero por una tabla de reconciliación
   verificada — `mxDistritos` para el caso mexicano — en vez de inventar
   una tabla de equivalencias a mano.
3. Cuenta filas antes y después del cruce (`nrow()`). Un `left_join()`
   nunca debería cambiar el número de filas del lado izquierdo salvo que
   la clave de la derecha tenga duplicados; si el número cambió y no lo
   esperabas, la reconciliación de claves es sospechosa número uno.
4. Si el ejercicio no requiere geografía electoral fina (solo entidad, por
   ejemplo), el riesgo de discrepancia de claves de municipio no aplica —
   no compliques un cruce que no lo necesita.
