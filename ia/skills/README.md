# Skills

Los archivos de esta carpeta son **instrucciones para un asistente de
IA** (por ejemplo, Claude), no páginas para leer en el navegador. Por eso
`_quarto.yml` excluye explícitamente `ia/skills/` de lo que el sitio
construye: si se dejaran renderizar, aparecerían como páginas sueltas sin
contexto. Quien quiera verlas llega por aquí, no por el sitio publicado.

## Qué hay hoy

| Ruta | Qué es |
|---|---|
| [`r-para-politologos/SKILL.md`](r-para-politologos/SKILL.md) | La única skill que existe hasta ahora. Guía a un asistente de IA para escribir, revisar y depurar código R con el criterio pedagógico de este laboratorio: stack 2026, anti-patrones prohibidos, lenguaje incluyente, verificación antes que invención, y la reconciliación de claves electorales INE-INEGI. |
| [`r-para-politologos/references/anti-patrones-y-stack.md`](r-para-politologos/references/anti-patrones-y-stack.md) | Tabla larga de anti-patrones y del stack canónico del curso, para cuando el resumen de `SKILL.md` no alcanza. |
| [`r-para-politologos/references/datos-electorales-mx.md`](r-para-politologos/references/datos-electorales-mx.md) | Referencia sobre la reconciliación de claves de municipio entre INE e INEGI, con la tabla puente `emagar/mxDistritos`. |

## Cómo se usa

`SKILL.md` describe cuándo debe activarse (básicamente, cualquier pregunta
sobre un script de R, un error de RStudio, o limpiar, cruzar o graficar una
base de datos, aunque no se mencione la palabra "R"). Los archivos de
`references/` no se cargan solos: `SKILL.md` remite a ellos cuando hace
falta el detalle largo.

## Qué falta

El §9 de la arquitectura del proyecto (`INSTRUCCIONES_PROYECTO_Lab_R.md`)
prevé varias skills además de esta, construidas junto con la sesión 11.
Hoy solo existe `r-para-politologos`. Este README se actualiza según se
agreguen las demás.
