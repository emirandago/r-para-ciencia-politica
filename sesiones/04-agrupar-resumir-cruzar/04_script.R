# ==============================================================
# Laboratorio de R para Ciencia Política — ITAM
# Sesión 04 · Agrupar, resumir, cruzar
# ---------------------------------------------------------------
# Qué vamos a hacer hoy:
#   Resumir muchas filas en una por grupo con group_by() y summarise(),
#   contar rápido con count(), cruzar dos bases con left_join() —viendo a
#   propósito cómo se rompe y cómo se arregla— y acomodar columnas con
#   pivot_longer(). De paso, cerramos la trampa que dejamos pendiente en
#   la sesión 1.
#
# Qué necesitas antes de empezar:
#   Las sesiones 2 y 3: leer una base con read_csv(), y el pipe |> con
#   filter(), select(), arrange() y mutate(). Hoy no se vuelven a explicar.
#
# Datos: INE, cómputos distritales de la elección presidencial de 2024, por
#        entidad y por municipio; y el puente de claves INE-INEGI, construido
#        a partir de emagar/mxDistritos. Ver datos/README.md, sección 6, para
#        el problema completo de las claves.
# Autor: Emiliano Miranda González
# ==============================================================

# ─────────────────────────────────────────────────────────────
# ESTE ARCHIVO TIENE HUECOS Y NO CORRE DE CORRIDO. Es a propósito.
# Los huecos están marcados con  ← COMPLETA  y se llenan en clase.
# Si intentas correrlo entero antes de llenarlos, va a marcar error.
# La versión resuelta (04_script_completo.R) se publica al terminar la sesión.
# ─────────────────────────────────────────────────────────────


# ---- 0. Los paquetes ----

library(tidyverse)
library(here)


# ---- 1. La trampa de la sesión 1, resuelta ----

# En la sesión 1 abrimos esta misma base y calculamos dos números que
# salieron distintos, sin tener todavía cómo explicar bien la diferencia:

resultados_entidad <- read_csv(here("datos", "limpios", "presidencial_2024_entidad.csv"))

mean(resultados_entidad$pct_shh)                                            # promedio simple
sum(resultados_entidad$votos_shh) / sum(resultados_entidad$total_votos) * 100  # promedio ponderado

# Quedamos con la desconfianza, no con la herramienta. Hoy sí la tenemos:
# group_by() + summarise() es exactamente la manera de repetir esa cuenta
# por grupos, cuantos grupos hagan falta, sin escribir sum()/sum() a mano
# cada vez.

# Antes de poder agrupar por región necesitamos que exista una columna
# "region". No viene en los datos del INE: la construimos nosotros con
# mutate() + case_when(). Y hay que decirlo con todas sus letras: esta es
# UNA división posible de México en cinco regiones, no LA división
# oficial. Hay varias regionalizaciones razonables y ninguna es neutral;
# se documenta aquí, en el código, para que quede claro que es una
# decisión nuestra y no un dato que trajo el INE.

resultados_entidad <- resultados_entidad |>
  mutate(
    region = case_when(
      entidad %in% c("Baja California", "Baja California Sur", "Chihuahua",
                      "Durango", "Sinaloa", "Sonora")                   ~ "Noroeste",
      entidad %in% c("Coahuila", "Nuevo León", "Tamaulipas")            ~ "Noreste",
      entidad %in% c("Aguascalientes", "Colima", "Guanajuato", "Jalisco",
                      "Michoacán", "Nayarit", "Querétaro",
                      "San Luis Potosí", "Zacatecas")                   ~ "Occidente y Bajío",
      entidad %in% c("Ciudad de México", "México", "Hidalgo",
                      "Morelos", "Puebla", "Tlaxcala")                  ~ "Centro",
      entidad %in% c("Campeche", "Chiapas", "Guerrero", "Oaxaca",
                      "Quintana Roo", "Tabasco", "Veracruz", "Yucatán") ~ "Sur-sureste"
    )
  )

# case_when() se lee como una serie de preguntas con su respuesta: "si la
# entidad está en este vector, pon esto; si está en este otro, pon esto
# otro". Es la versión ordenada de encadenar muchos ifelse() uno dentro
# de otro, que se vuelve ilegible después del segundo nivel.

# Si algo salió NA en la columna region, es que alguna entidad se quedó
# fuera de los cinco vectores de arriba. Compruébalo siempre que uses
# case_when(), antes de confiar en el resultado:

resultados_entidad |> filter(is.na(region))

# Debe devolver cero filas. Si no, falta clasificar alguna entidad en
# alguno de los cinco bloques de arriba.

# Ahora sí: comparamos por región. Dentro de summarise(), n() cuenta
# cuántas filas cayeron en cada grupo, y podemos pedir el promedio simple
# Y el ponderado en la misma tabla, para verlos uno al lado del otro.

resumen_por_region <- resultados_entidad |>
  group_by(region) |>
  summarise(
    n_entidades   = n(),
    pct_simple    = mean(pct_shh),
    pct_ponderado = 100 * sum(votos_shh) / sum(total_votos)
  ) |>
  arrange(desc(pct_ponderado))

resumen_por_region

# Fíjate en la fila "Centro": ahí la diferencia entre las dos columnas es
# más grande que en cualquier otra región. Ciudad de México y México
# concentran ellos solos casi 20 millones de votos, y Tlaxcala unos
# cientos de miles: el promedio simple los trata como iguales, el
# ponderado no.

# ← COMPLETA: repite el mismo cálculo pero sin agrupar por nada —es
#   decir, para las 32 entidades juntas—, y compáralo contra los dos
#   números con los que abrimos esta sección.
resumen_nacional <-


resumen_nacional

# EL SALTO: de "siento que el país votó más o menos 60 y tantos por
# ciento por Sigamos Haciendo Historia" a "puedo decir que el número
# ponderado real es 59.76%, que el promedio simple de las 32 entidades es
# 60.66%, y que la diferencia de casi un punto es exactamente el peso que
# el promedio simple le da de más a los estados chicos". La sesión 1 dejó
# plantada la desconfianza; hoy la resolvemos con una herramienta que se
# repite igual de bien con 5 grupos, con 32 o con 2,475.

# Una nota que vale para el resto de tu vida politóloga: group_by() +
# summarise() siempre contesta una pregunta ENTRE grupos —¿cómo se
# compara esta región con esa otra?—. El día que tengas datos de varias
# elecciones y quieras comparar un mismo estado consigo mismo a través
# del tiempo, esa es una pregunta distinta —se llama comparación "within"
# en la jerga de datos de panel, contra la comparación "between" que
# hicimos aquí— y usa las mismas funciones con un giro adicional. Queda
# para el extra de panel y efectos fijos.


# ---- 2. count(): el atajo de group_by() + summarise(n = n()) ----

# Muchísimas veces lo único que quieres saber es "cuántas filas hay por
# grupo". Se puede escribir con group_by()+summarise(n=n()), pero es tan
# común que dplyr trae un atajo que hace lo mismo en una sola línea.

resultados_municipio <- read_csv(here("datos", "limpios", "presidencial_2024_municipio.csv"))

# ← COMPLETA: usa count() sobre resultados_municipio para saber cuántos
#   municipios tiene cada entidad. Pídele que ordene de mayor a menor
#   con sort = TRUE.
municipios_por_entidad <-


municipios_por_entidad

# Fíjate quién queda hasta arriba: Oaxaca, con más de 500 municipios —
# casi una cuarta parte de todos los municipios del país están en un
# solo estado—. Eso no es un capricho de los datos: es la razón por la
# que cualquier mapa de México "por número de algo", sin ajustar por
# población, suele parecer que Oaxaca domina el mapa entero. Lo vamos a
# ver otra vez, y peor, en la sesión 7.

nrow(resultados_municipio)   # el total de filas, para comparar contra el resumen de arriba


# ---- 3. Cruzar dos bases: el left_join() que se rompe a propósito ----

# La pregunta de hoy es: ¿podemos pegarle a cada municipio la clave que
# usa el puente, usando el NOMBRE del municipio? Es la primera idea que
# se le ocurre a cualquiera, y la vamos a intentar tal cual, a propósito,
# para ver por qué no basta.

puente <- read_csv(here("datos", "limpios", "puente_claves_ine_inegi.csv"))

intento_por_nombre <- resultados_municipio |>
  left_join(puente, by = "municipio")

# R sí te devuelve un resultado, pero antes te avienta un mensaje en
# amarillo o naranja que empieza con "Warning message" y menciona
# "many-to-many relationship". Traducido: "detecté que una fila tuya hizo
# pareja con MÁS de una fila de la otra base, y eso casi siempre es un
# error, así que te aviso antes de que sigas trabajando con esto". No es
# un error que detiene el código —el resultado sí se produce—, pero es
# una alarma que hay que leer, no cerrar de un clic.

nrow(resultados_municipio)    # con la que empezamos: 2,475
nrow(intento_por_nombre)      # con la que terminamos: más de 2,475

# Empezaste con 2,475 filas y terminaste con más. Eso, en un left_join(),
# casi siempre significa que la columna que usaste para unir NO
# identifica una sola fila del otro lado: hay nombres de municipio que se
# repiten, y cada repetición multiplicó la fila original.

# Este es exactamente el motivo por el que merge() de R base está
# prohibido en este curso: merge() puede perder filas o multiplicarlas
# igual que left_join(), pero no avisa nunca —ni de esto ni de perder
# observaciones—. Un cruce que falla en silencio es peor que uno que te
# grita que algo salió raro.


# ---- 3.1 Diagnóstico: ¿qué nombres se repiten? ----

# Usamos la herramienta que acabamos de aprender —count()— para
# preguntarle a los datos, con precisión, cuáles nombres de municipio no
# son únicos en el país.

# ← COMPLETA: cuenta cuántas veces aparece cada "municipio" en
#   resultados_municipio y quédate solo con los que aparecen más de una
#   vez (usa filter() sobre la columna que produce count(), que se llama n).
nombres_repetidos <-


nombres_repetidos
nrow(nombres_repetidos)   # 89 nombres de municipio no son únicos en México

# Léelos con calma. "Benito Juarez" —así, tal como está en los datos, sin
# acento: otra inconsistencia real que te vas a encontrar seguido
# trabajando con bases mexicanas— es municipio en siete entidades
# distintas. "Emiliano Zapata" lo es en seis. Son nombres de héroes
# patrios, y México los repartió por el mapa sin que a nadie le importara
# que algún día alguien quisiera cruzar bases por nombre.
#
# El nombre de un municipio, solo, casi nunca es una clave. La
# combinación de entidad + municipio sí lo es casi siempre; la CLAVE
# numérica lo es siempre.


# ---- 3.2 Unir por clave, la correcta ----

# La base electoral (resultados_municipio) ya trae, en clave_municipio,
# la clave de INEGI —lo puedes comprobar tú misma o tú mismo: Colima
# capital aparece con clave "06002", que es exactamente la clave que le
# da INEGI, no la que usa el INE, que es "06001" (ver datos/README.md,
# sección 6). El puente trae esa misma clave de INEGI en su columna
# clave_municipio_inegi.

# ← COMPLETA: une resultados_municipio con puente por clave, emparejando
#   clave_municipio (de resultados_municipio) con clave_municipio_inegi
#   (de puente).
cruce_correcto <-


nrow(cruce_correcto)   # ahora sí: exactamente las mismas 2,475 filas con las que empezamos

# Sin warning, sin filas de más. Cuadró porque una clave numérica sí
# identifica una sola fila; un nombre de texto, en un país con 2,477
# municipios y con héroes patrios repartidos por todos lados, no siempre.
#
# De regalo, el puente te deja también clave_municipio_ife en la misma
# tabla: la clave que usa el INE para ese mismo municipio. La vas a
# necesitar el día que cruces esta base contra una fuente que solo trae
# la numeración del INE —pasa más seguido de lo que parece, y el
# argumento relationship = "many-to-many" existe por si alguna vez de
# verdad quieres permitir que un cruce multiplique filas a propósito;
# casi nunca es lo que quieres, y hoy menos que nunca.


# ---- 3.3 anti_join(): ¿quién se quedó fuera, de verdad? ----

# El cruce por clave ya funcionó, pero eso no significa que absolutamente
# todos los municipios del puente hayan encontrado pareja en la base
# electoral. anti_join() contesta exactamente esa pregunta: devuelve las
# filas de la primera base que NO encontraron pareja en la segunda —y
# ninguna columna más, porque no hubo con qué pegarlas.

sin_pareja <- puente |>
  anti_join(resultados_municipio, by = c("clave_municipio_inegi" = "clave_municipio"))

sin_pareja

# Dos municipios: Chicomuselo y Pantelhó, ambos de Chiapas. Existen en el
# catálogo de INEGI y no tienen fila en la base electoral de 2024. Está
# documentado en datos/README.md y, siendo honestos, no se investigó a
# fondo por qué —queda marcado [VERIFICAR] ahí mismo. Eso también es
# parte del oficio: hay preguntas que un left_join() te deja
# perfectamente planteadas y que tú no vas a poder cerrar hoy.
# Documentar que faltan, con nombre y apellido, es mejor que no darse
# cuenta de que faltan.


# ---- 4. pivot_longer(): varias columnas en una sola ----

# resultados_entidad trae pct_shh, pct_fcm y pct_mc como tres columnas
# separadas: una por coalición. Eso se llama formato ANCHO —cada fila es
# una entidad, y cada coalición vive en su propia columna—. Es cómodo
# para leer en Excel y muy incómodo para graficar tres barras por
# entidad, porque ggplot2 quiere UNA columna que diga de qué coalición se
# trata y OTRA con el número.

resultados_largo <- resultados_entidad |>
  select(entidad, pct_shh, pct_fcm, pct_mc) |>
  pivot_longer(
    cols      = c(pct_shh, pct_fcm, pct_mc),
    names_to  = "coalicion",
    values_to = "pct"
  )

resultados_largo

# 32 entidades × 3 coaliciones = 96 filas. Cada coalición ahora vive en
# su propia fila en vez de en su propia columna: eso es el formato
# LARGO, y es el que vas a usar en la sesión 5 para pedirle a ggplot2 que
# dibuje las tres coaliciones con un solo geom_col() y un color por
# coalición, en vez de tres capas sueltas.
#
# La operación inversa —de largo a ancho— se llama pivot_wider() y hace
# exactamente lo contrario. Existe, la vas a usar mucho menos seguido de
# lo que imaginas, y queda en el acordeón de la página de esta sesión y
# en extras/ para cuando de verdad la necesites.


# ---- 5. El entregable: reconstruir la cifra por entidad desde los municipios ----

# Si el cruce por clave está bien hecho, deberíamos poder reconstruir,
# sumando los 2,475 municipios agrupados por entidad, casi exactamente
# los mismos totales que ya trae presidencial_2024_entidad.csv, armado
# directamente por el INE. "Casi", no "exactamente": ya sabemos por qué
# desde la sesión 1 —el voto en el extranjero no tiene municipio, así que
# presidencial_2024_municipio.csv lo excluye (ver datos/README.md).

reconstruido_por_entidad <- resultados_municipio |>
  group_by(entidad) |>
  summarise(total_votos_reconstruido = sum(total_votos))

comparacion <- resultados_entidad |>
  select(entidad, total_votos) |>
  left_join(reconstruido_por_entidad, by = "entidad") |>
  mutate(diferencia = total_votos - total_votos_reconstruido)

comparacion |> arrange(desc(diferencia))

# La diferencia nunca es cero, y no debería serlo: súmala completa.

sum(comparacion$diferencia)

# Si te da 117,831, es exactamente el voto en el extranjero de toda la
# elección —el mismo número que documenta datos/README.md—. Fíjate
# también en qué entidades concentran la diferencia más grande: Jalisco,
# Puebla, Michoacán, Guanajuato. No es casualidad: son estados que
# históricamente tienen más población viviendo fuera del país. Un
# left_join() bien hecho no solo une datos: te deja ver, en la
# diferencia misma, un hecho real sobre México.
#
# Ese es el entregable de hoy: dos bases cruzadas por clave, sin filas de
# más ni de menos, y un resumen por entidad que cuadra —con una
# diferencia que sabes nombrar en vez de una que te sorprende.


# ---- 6. Cámbiale algo ----

# Repite el resumen por región de la sección 1, pero para pct_fcm en vez
# de pct_shh. ¿La región con más diferencia entre el promedio simple y el
# ponderado sigue siendo la misma?




# ==============================================================
# La pregunta abierta del cierre.
#
# El left_join() por clave funcionó perfecto para la elección de 2024.
# ¿Qué tendría que ser distinto para que ese mismo cruce fallara si
# hicieras esto mismo con datos de 1990, o de 2000? Piensa en lo que dice
# datos/README.md sobre municipios que se crearon separándose de uno más
# grande —Pesquería, en Nuevo León; Juan José Ríos, en Sinaloa— y en qué
# le pasaría a una clave que, en ese año, todavía no existía.
# ==============================================================
