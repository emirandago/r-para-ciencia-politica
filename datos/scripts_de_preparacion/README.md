# datos/scripts_de_preparacion/

Cómo se pasó de cada dato crudo a su versión limpia en
[`datos/limpios/`](../limpios/). El curso predica reproducibilidad; esta
carpeta es donde el repositorio la practica: cada script baja su propia
fuente, documenta las decisiones que tomó y deja el resultado listo.

| Script | Produce |
|---|---|
| [`prep_presidencial_2024_entidad.R`](prep_presidencial_2024_entidad.R) | `presidencial_2024_entidad.csv` / `.rds` |
| [`prep_presidencial_2024_municipio.R`](prep_presidencial_2024_municipio.R) | `presidencial_2024_municipio.csv` / `.rds` |
| [`prep_puente_claves_ine_inegi.R`](prep_puente_claves_ine_inegi.R) | `puente_claves_ine_inegi.csv` / `.rds` |
| [`prep_geografia_simplificada.R`](prep_geografia_simplificada.R) | `datos/geo/municipios_simplificado.rds` y `entidades_simplificado.rds` |
| [`prep_judicial_2025_scjn.R`](prep_judicial_2025_scjn.R) | `judicial_2025_scjn_municipio.csv` / `.rds` |
| [`prep_vdem_americas.R`](prep_vdem_americas.R) | `vdem_americas.csv` / `.rds` |
| [`prep_qog_basico.R`](prep_qog_basico.R) | `qog_basico.csv` / `.rds` |
| [`prep_latinobarometro.R`](prep_latinobarometro.R) | `latinobarometro_reciente.csv` / `.rds` |

El detalle de cada fuente, cada decisión de limpieza y cada advertencia de
uso está documentado en [`datos/README.md`](../README.md), no aquí: cada
script referencia la sección correspondiente en su propio encabezado. Cada
`prep_*.R` corre de forma independiente y reconstruye por su cuenta lo que
necesite de [`datos/crudos/`](../crudos/), que en GitHub está vacía.
