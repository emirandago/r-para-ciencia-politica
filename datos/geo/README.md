# datos/geo/

Los dos objetos espaciales del curso, en formato `.rds` (paquete `sf`):

| Archivo | Qué es |
|---|---|
| `municipios_simplificado.rds` | Polígonos de los 2,478 municipios del país. |
| `entidades_simplificado.rds` | Polígonos de las 32 entidades federativas. |

El detalle completo —fuente (INEGI, Marco Geoestadístico 2025), fecha de
descarga, criterio de simplificación y la advertencia de que **no sirven
para medir área ni distancia**, solo para dibujar mapas— está en
[`datos/README.md`](../README.md), §4.

El script que los produjo es
[`datos/scripts_de_preparacion/prep_geografia_simplificada.R`](../scripts_de_preparacion/prep_geografia_simplificada.R).
Se usan sobre todo en la [sesión 7](../../sesiones/07-el-mapa-de-mexico/).
