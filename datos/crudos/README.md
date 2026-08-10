# datos/crudos/

Aquí vive el original tal como se descargó de cada fuente, antes de
cualquier limpieza. **Esta carpeta está vacía en GitHub a propósito.**

Los datos crudos de este curso pesan, juntos, más de 600 MB —el Marco
Geoestadístico completo de INEGI, los cómputos del INE, el microdato de
Latinobarómetro—, muy por encima de lo razonable para un repositorio de
material didáctico. Por eso `.gitignore` excluye todo el contenido de esta
carpeta (`datos/crudos/**`, con `!datos/crudos/.gitkeep` para que la
carpeta exista aunque esté vacía).

Nada se pierde con eso: **cada script de
[`datos/scripts_de_preparacion/`](../scripts_de_preparacion/) con el
prefijo `prep_` reconstruye por su cuenta lo que necesita de esta
carpeta**, descargando directo de la fuente original (INE, INEGI, V-Dem,
Quality of Government, Latinobarómetro, `emagar/mxDistritos`) la primera
vez que se corre. No hace falta conseguir estos archivos por separado ni
pedírselos a nadie: correr el `prep_*.R` correspondiente es suficiente.

El detalle de cada fuente —URL exacta, fecha de descarga, licencia— está
en [`datos/README.md`](../README.md), no aquí: esta carpeta no tiene
contenido que documentar mientras está vacía.
