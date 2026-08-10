# .github

Contiene [`workflows/publish.yml`](workflows/publish.yml), la GitHub
Action que publica el sitio del laboratorio.

Corre automáticamente cada vez que se sube un cambio a la rama `main`, y
también se puede disparar a mano desde la pestaña "Actions" del
repositorio. En dos pasos: instala Quarto en una máquina temporal de
GitHub y corre `quarto render` para construir el sitio a partir de los
archivos `.qmd` del repositorio; después publica el resultado en la rama
`gh-pages`, que es de donde GitHub Pages sirve
[emirandago.github.io/r-para-ciencia-politica](https://emirandago.github.io/r-para-ciencia-politica/).
El token que necesita para escribir en esa rama (`GITHUB_TOKEN`) lo genera
GitHub automáticamente en cada ejecución: no hay que crear ningún secreto
a mano.

El workflow **no instala R**. `_quarto.yml` construye el sitio con
`execute: eval: false`: los `.qmd` de las sesiones son guiones en prosa
para leer antes o después de la clase, no reportes que recalculan datos al
hacer build —el código que citan ya se verificó por separado, corriendo
los scripts de `sesiones/` en una instalación limpia—. Por eso la Action
compila en segundos y no depende de que el stack completo de paquetes de R
se instale en la nube cada vez que alguien sube un cambio.
