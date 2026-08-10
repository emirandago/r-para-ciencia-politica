# Laboratorio de R para Ciencia Política — ITAM

Material completo de un curso de once sesiones de una hora que enseña R a
estudiantes de Ciencia Política y Relaciones Internacionales del ITAM que
nunca han programado. Lo imparte Emiliano Miranda González por encargo del
Departamento Académico de Ciencia Política.

**La forma recomendada de consumir este material es el sitio publicado, no
este repositorio directamente:**
[emirandago.github.io/r-para-politologos](https://emirandago.github.io/r-para-politologos/).
El sitio tiene navegación, botones de descarga para cada sesión y las
páginas en prosa navegable; este repositorio es el código fuente que lo
produce.

## Para quién es

Para estudiantes de primeros semestres que no han tomado Estadística I ni
Estadística II, que no saben qué es un directorio de trabajo ni han usado
GitHub, y que quieren dejar de tenerle miedo a los datos. También es
material reutilizable para cualquier profesor que quiera enseñar R aplicado
a ciencia política partiendo de cero.

## Cómo empezar, en tres pasos

1. **Instala R y después RStudio.** Sigue la página
   [Empieza aquí](https://emirandago.github.io/r-para-politologos/empieza-aqui.html)
   del sitio publicado: instalación paso a paso sin suponer conocimiento
   previo, para Windows y para macOS por separado.
2. **Descarga este repositorio sin usar `git`.** Botón verde **"Code"** →
   **"Download ZIP"**, arriba de la lista de archivos de esta página.
   Descomprime el ZIP y abre el archivo `r-para-politologos.Rproj`.
3. **Instala los paquetes del curso con una sola instrucción**, corrida una
   vez en la consola de RStudio:

   ```r
   install.packages(c("tidyverse", "here", "janitor", "sf", "viridis", "modelsummary", "fixest"))
   ```

   Los detalles completos, con qué hacer si algo de esto falla, están en la
   página [Empieza aquí](https://emirandago.github.io/r-para-politologos/empieza-aqui.html).

## Las once sesiones

| # | Título | Pregunta que responde | Entregable de la hora |
|---|---|---|---|
| 1 | Tu primera hora en R | ¿Por qué un politólogo programa? | Un gráfico de barras de la elección 2024 hecho por ellos |
| 2 | Los datos son tablas | ¿Cómo se ve una base de datos por dentro? | Cargar y describir una base electoral real |
| 3 | Pedirle cosas a los datos | ¿Dónde ganó Morena por más de veinte puntos? | Una tabla filtrada que contesta una pregunta propia |
| 4 | Agrupar, resumir, cruzar | ¿Cómo comparo estados entre sí? | Cruzar dos bases y resumir por entidad |
| 5 | La gramática de los gráficos | ¿Por qué unos gráficos convencen y otros no? | Un gráfico con título, fuente y paleta defendible |
| 6 | Gráficos que se publican | ¿Cómo hago una figura de paper? | Una figura en PDF lista para un trabajo final |
| 7 | El mapa de México | ¿Cómo se ve el voto en el territorio? | Un mapa coroplético de resultados 2024 |
| 8 | Describir sin mentir | ¿Qué significa que dos cosas "van juntas"? | Un scatter con línea de tendencia e interpretación escrita |
| 9 | La regresión como instrumento politológico | ¿Cuánto explica X a Y? | Una tabla de regresión con lectura en prosa |
| 10 | Que otro pueda repetirlo | ¿Cómo entrego trabajo serio? | Un reporte reproducible propio, publicado |
| 11 | La IA como copiloto, no como piloto | ¿Cómo uso Claude sin dejar de aprender? | El proyecto Morena × ministras, hecho en pareja con la IA |

Once horas no alcanzan para cubrir todo lo que vale la pena enseñar. La
carpeta [`extras/`](extras/) reúne módulos autoestudiables, completos y con
el mismo estándar de calidad, sobre funciones e iteración, probabilidad y
simulación, modelos logit y GLM, datos de panel y efectos fijos, un primer
vistazo a inferencia causal, y una guía Stata→R.

## Estructura de carpetas

```
repo/
├── README.md                # este archivo
├── _quarto.yml               # configuración del sitio Quarto
├── index.qmd                 # portada del sitio publicado
├── empieza-aqui.qmd           # instalación paso a paso
├── LICENSE                    # CC BY 4.0 para el material didáctico
├── r-para-politologos.Rproj  # proyecto de RStudio — ábrelo desde aquí
│
├── sesiones/                  # una carpeta por sesión, siete archivos cada una:
│   └── 01-primer-contacto/    #   guion (.qmd), láminas (.tex y .pdf),
│       ...                    #   script con huecos, script resuelto,
│                               #   ejercicio y solución
│
├── datos/
│   ├── README.md               # catálogo: qué es cada archivo, fuente, licencia
│   ├── limpios/                 # lo que usan las sesiones: .csv y .rds listos
│   ├── crudos/                  # el original tal como se descargó
│   ├── geo/                     # shapefiles y geopackages
│   └── scripts_de_preparacion/  # cómo se pasó de crudo a limpio
│
├── extras/                    # módulos autoestudiables (ver arriba)
├── recursos/                  # glosario, errores comunes, acordeón de R
├── ia/                         # uso responsable de IA, skills, prompts
└── estilo/                     # paleta y tipografía del curso (Beamer, ggplot2, sitio)
```

Cada carpeta de sesión es descargable por separado desde el sitio publicado,
en menos de tres clics, sin que quien la descarga necesite entender qué es
un repositorio.

## Cómo se cita este material

Ver [`LICENSE`](LICENSE) para el texto completo de la licencia CC BY 4.0 y
su alcance exacto (qué cubre y qué no, como los datos de terceros). La cita
sugerida es:

> Miranda González, Emiliano (2026). *Laboratorio de R para Ciencia
> Política*. Instituto Tecnológico Autónomo de México, Departamento
> Académico de Ciencia Política.
> https://github.com/emirandago/r-para-politologos. Licencia CC BY 4.0.

## Agradecimientos

Este curso no parte de cero. Reúne y actualiza al stack de R de 2026 el
contenido de tres cursos que se impartieron antes en el ITAM: el curso de
**Paula Cortina** (nueve sesiones, de la progresión aritmética a los mapas),
el curso de **Aldo Gómez** (ocho clases, con versión para alumnos y versión
completa, y trabajo detallado con datos electorales y shapefiles de la
Ciudad de México), y el curso de **Álvaro Pérez**
([`Introduccion_a_R`](https://github.com/AlvaroPLZ/Introduccion_a_R), ocho
clases publicadas sobre datos ordenados, relaciones entre bases, iteración,
funciones, probabilidad y simulación). Ninguna de las tres herencias
desaparece: su contenido está repartido entre `sesiones/` y `extras/`.

Como referencia general en español para quien quiera profundizar más allá
de este laboratorio, el curso reconoce a *AnalizaR Datos Políticos*, de
**Andrés Cruz** y **Francisco Urdinez**
([arcruz0.github.io/libroadp](https://arcruz0.github.io/libroadp/)): el
libro de referencia más completo de R aplicado a ciencia política que existe
en español.
