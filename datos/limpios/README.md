# datos/limpios/

Los archivos que usan las sesiones y los extras: `.csv` (para abrir en
Excel sin miedo) y `.rds` (para cargar rápido en R conservando tipos).
Ninguno pesa más de 20 MB.

El catálogo completo —qué es cada fila, qué significa cada columna, de
dónde salió, cuándo se descargó y bajo qué licencia— vive en
[`datos/README.md`](../README.md). Este archivo no repite ese detalle:
remite a él.

| Archivo | Detalle en `datos/README.md` |
|---|---|
| `presidencial_2024_entidad.csv` / `.rds` | §1 |
| `presidencial_2024_municipio.csv` / `.rds` | §2 |
| `puente_claves_ine_inegi.csv` / `.rds` | §3 |
| `judicial_2025_scjn_municipio.csv` / `.rds` | §5 |
| `vdem_americas.csv` / `.rds` | §6 |
| `qog_basico.csv` / `.rds` | §7 |
| `latinobarometro_reciente.csv` / `.rds` | §8 |

El script que produjo cada archivo vive en
[`datos/scripts_de_preparacion/`](../scripts_de_preparacion/), con el
mismo nombre y el prefijo `prep_`.
