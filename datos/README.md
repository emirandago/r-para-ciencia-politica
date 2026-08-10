# Catálogo de datos — Laboratorio de R para Ciencia Política, ITAM

Este documento describe cada archivo de `datos/limpios/` y `datos/geo/`: qué es una fila, qué significa cada columna, de dónde salió, cuándo se descargó, bajo qué licencia y qué límites tiene. El script que produjo cada archivo vive en `datos/scripts_de_preparacion/`, con el mismo nombre y el prefijo `prep_`. Si algo de este catálogo no cuadra con lo que ves al abrir un archivo, confía en el script antes que en este texto: el script es el que realmente corrió.

Todos los archivos limpios están en `snake_case`, sin acentos ni eñes en los **nombres de columna** (los **valores** de texto, como nombres de entidad o de municipio, sí llevan acentos: son datos, no identificadores de columna). Ninguno pesa más de 20 MB.

---

## 1. `presidencial_2024_entidad.csv` / `.rds`

**Una fila = una entidad federativa** (32 filas: 31 estados + Ciudad de México).

| Columna | Unidad / tipo | Qué es |
|---|---|---|
| `clave_entidad` | texto, 2 dígitos | Clave INEGI de la entidad, con cero a la izquierda (`01`…`32`). Coincide con la clave que usa el INE: la numeración de entidades es la misma en ambas instituciones (el problema INE-INEGI aparece hasta el nivel de municipio, ver §6). |
| `entidad` | texto | Nombre de la entidad, en formato "Título". |
| `lista_nominal` | entero | Personas con credencial vigente y derecho a votar en esa entidad, según el corte del INE. |
| `total_votos` | entero | Total de votos válidos y nulos sumados de todas las actas computadas de esa entidad. |
| `participacion` | decimal, % | `100 * total_votos / lista_nominal`. |
| `votos_shh` | entero | Coalición **Sigamos Haciendo Historia**: Morena + PT + PVEM, sumando también las combinaciones parciales de logotipos (ver abajo). |
| `votos_fcm` | entero | Coalición **Fuerza y Corazón por México**: PAN + PRI + PRD, mismo criterio. |
| `votos_mc` | entero | Movimiento Ciudadano, que compitió en solitario. |
| `votos_otros` | entero | Candidaturas no registradas + votos nulos. |
| `pct_shh`, `pct_fcm`, `pct_mc` | decimal, % | Cada bloque sobre `total_votos`. |

**Fuente:** INE, Base de Datos de los Cómputos Distritales 2024, elección de Presidencia. Descargada de `https://computos2024.ine.mx/20240608_2030_COMPUTOS.zip` (corte 08/06/2024 20:30, hora del centro; 170,766 actas, 100% computadas). Esa URL no está en ningún botón visible del sitio: `computos2024.ine.mx` es una aplicación de una sola página, y hubo que inspeccionar su paquete de JavaScript para encontrar el patrón real de descarga (documentado dentro del propio script `prep_presidencial_2024_entidad.R`).

**Descargado el:** 2026-08-05. **Licencia:** no declarada explícitamente en el portal del INE (dato abierto de una institución pública; no se encontró un aviso de tipo Creative Commons en el sitio). **Peso:** `.csv` 2.8 KB, `.rds` 2.4 KB.

**Cómo se construyó `votos_shh` y `votos_fcm`:** el archivo del INE no trae una sola columna con el total de cada coalición. Trae una columna por cada combinación de logotipos que pudo marcar la persona que votó (un partido, dos, o los tres). Sumamos Morena + PT + PVEM + todas sus combinaciones para SHH, y PAN + PRI + PRD + todas sus combinaciones para FCM. La composición de las coaliciones está verificada contra los registros de coalición del proceso electoral federal 2023-2024 del INE.

**Qué NO se puede hacer con este archivo:** no sirve para calcular la participación nacional promediando `participacion` de las 32 filas (un promedio simple de porcentajes trata igual a Colima que al Estado de México). Para la cifra nacional real hay que sumar `total_votos` y `lista_nominal` primero y dividir después — así lo hace el script, y así se enseña en la sesión 1.

---

## 2. `presidencial_2024_municipio.csv` / `.rds`

**Una fila = un municipio** (2,475 filas de los 2,477-2,478 municipios del país; ver más abajo por qué no son todos).

Mismas columnas que la base por entidad, más:

| Columna | Unidad / tipo | Qué es |
|---|---|---|
| `clave_municipio` | texto, 5 dígitos | Clave INEGI de entidad + municipio (`01001`…). |
| `municipio` | texto | Nombre del municipio, en formato "Título". |
| `ventaja_shh` | decimal, puntos porcentuales | `pct_shh` menos el mayor de `pct_fcm` y `pct_mc` (el segundo lugar). Puede ser negativo. |

**Fuente:** el mismo ZIP de la base por entidad (§1), pero agregado por municipio cruzando la columna `SECCION` del archivo del INE contra el catálogo de secciones de `emagar/mxDistritos` (ver §6). **Descargado el:** 2026-08-05.

**Decisiones documentadas:**

- **Voto en el extranjero excluido.** 127 de 170,766 actas (0.07%) son voto de mexicanas y mexicanos en el extranjero (tipo de casilla `M` o `V`), registradas por el INE bajo la sección de plantilla `4074` dentro de cada entidad — no tienen municipio real. Se excluyen de esta base municipal (si sumas `total_votos` de este archivo y lo comparas contra la base por entidad, la diferencia es exactamente esos votos). Si tu pregunta necesita el voto en el extranjero, úsalo desde `presidencial_2024_entidad.csv`.
- **Dos municipios con `pct_shh`, `pct_fcm`, `pct_mc` y `ventaja_shh` en `NA`:** Reforma (La), Oaxaca (`20076`) y Capulálpam de Méndez, Oaxaca (`20247`). En ambos, **todas** las casillas aparecen con el estatus oficial "Casilla no instalada": no es un error de este pipeline, es un hecho real de la elección de 2024 (fenómeno documentado en municipios de "usos y costumbres" de Oaxaca). Dividir votos entre cero no tiene sentido, así que se deja `NA` en vez de inventar un `0`.
- **El corte temporal del cruce sección→municipio.** La geografía municipal de México cambia con el tiempo (nuevos municipios, secciones reasignadas). Para esta base usamos la adscripción municipal *vigente el día de la elección de 2024*, no la de hoy — ver la discusión completa en §6.

**Qué NO se puede hacer con este archivo:** no intentes sumarlo para reconstruir el total nacional exacto de `presidencial_2024_entidad.csv`: por el punto anterior, va a faltar el voto en el extranjero.

---

## 3. `puente_claves_ine_inegi.csv` / `.rds`

**Una fila = un municipio** (2,477 filas).

| Columna | Unidad / tipo | Qué es |
|---|---|---|
| `clave_entidad` | texto, 2 dígitos | Clave INEGI de la entidad. |
| `entidad` | texto | Nombre de la entidad. |
| `clave_municipio_inegi` | texto, 5 dígitos | Clave de municipio según INEGI (Área Geoestadística Municipal). Es la que trae el Marco Geoestadístico y el Censo. |
| `clave_municipio_ife` | texto, 5 dígitos | Clave de municipio según el INE (heredada del IFE). Es la que se puede reconstruir a partir de la `SECCION` de una base electoral del INE. |
| `municipio` | texto | Nombre del municipio, en formato "Título". |

**Fuente:** `github.com/emagar/mxDistritos`, de Eric Magar (ITAM), licencia **MIT**, archivo `equivSecc/tablaEquivalenciasSeccionalesDesde1994.csv` (última revisión visible del repositorio: 2026-04-11). Ese archivo es un catálogo histórico de las ~76,000 secciones electorales del país desde 1994, con la clave INEGI y la clave INE del municipio en el mismo registro. **Descargado el:** 2026-08-05. **Peso:** `.csv` 92 KB, `.rds` 26 KB.

**En 1,369 de los 2,477 municipios (55%), la clave INE y la clave INEGI son distintas.** Ese es exactamente el problema que resuelve esta tabla — ver §6 para la explicación completa.

**Qué NO se puede hacer con este archivo:** no asumas que es válido para años anteriores a 1994 ni que la asociación clave-municipio es inmutable en el tiempo: unos pocos municipios (Pesquería, NL; Juan José Ríos, Sinaloa; entre otros) se crearon separándose de un municipio más grande, y su clave solo tiene sentido a partir de su año de creación.

---

## 4. `municipios_simplificado.rds` y `entidades_simplificado.rds` (en `datos/geo/`)

**Una fila = un municipio** (2,478 filas) / **una fila = una entidad** (32 filas). Objetos `sf` (paquete `sf`), en coordenadas geográficas WGS84 (EPSG:4326).

| Columna (municipios) | Qué es |
|---|---|
| `clave_municipio` | Clave INEGI de 5 dígitos (entidad + municipio). |
| `clave_entidad` | Clave INEGI de entidad, 2 dígitos. |
| `clave_municipio_corta` | Los 3 dígitos de municipio solos, tal como los trae INEGI. |
| `municipio` | Nombre oficial del municipio, según INEGI. |
| `geometry` | El polígono (o multipolígono) simplificado. |

**Fuente:** INEGI, Marco Geoestadístico 2025, producto **"Marco Geoestadístico Integrado 2025"** (`mg_2025_integrado.zip`, 245 MB), ficha `https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=794551163061`. Cobertura temporal declarada por INEGI: 2024-11-01 a 2025-07-31. **Descargado el:** 2026-08-05.

**Por qué el producto "Integrado" y no el "Nacional" completo.** El shapefile nacional completo del Marco Geoestadístico pesa 2.7 GB porque incluye manzanas y AGEB. El producto "Integrado" (245 MB) trae exactamente las capas de entidad (`00ent.*`) y municipio (`00mun.*`) que necesitamos, sin la desagregación a manzana. Extraer solo esas dos capas del "Nacional" completo habría significado descargar los mismos 2.7 GB para terminar usando una fracción.

**Criterio de simplificación.** `rmapshaper::ms_simplify(keep = 0.05, keep_shapes = TRUE)`: conserva 5% de los vértices originales de cada polígono. `keep_shapes = TRUE` evita que desaparezcan del mapa los municipios pequeños (varios de Oaxaca son minúsculos). Se reproyectó de la proyección cónica de Lambert de INEGI a WGS84 (lon/lat) porque es el estándar para mapas web y para `geom_sf()`.

**ADVERTENCIA — léela antes de usar este archivo:** la simplificación deforma los polígonos lo suficiente como para que **cualquier cálculo de área (`st_area()`) o de distancia (`st_distance()`) hecho sobre estos archivos dé un número incorrecto.** Sirven únicamente para **dibujar** mapas (coropletas, por ejemplo), nunca para medirlos. Si alguna sesión necesita medir área o distancia, hay que volver a la fuente original de INEGI sin simplificar.

**Pesos:** `municipios_simplificado.rds` 2.73 MB, `entidades_simplificado.rds` 1.02 MB.

**Discrepancia menor documentada:** 3 de los 2,478 municipios del shapefile (Chicomuselo y Pantelhó, Chiapas; Villa de Pozos, San Luis Potosí) no tienen fila correspondiente en `presidencial_2024_municipio.csv`. Villa de Pozos es un municipio de creación reciente (separado de la capital de San Luis Potosí); es razonable que sus secciones, en 2024, todavía se contaran bajo el municipio del que se separó. La causa exacta para Chicomuselo y Pantelhó no se investigó a fondo — **[VERIFICAR]** si hace falta usarlos.

---

## 5. `judicial_2025_scjn_municipio.csv` / `.rds`

**Formato largo: una fila = un municipio × una candidatura a ministra/o de la SCJN** (158,528 filas: ~2,477 municipios × 64 candidaturas).

| Columna | Unidad / tipo | Qué es |
|---|---|---|
| `clave_municipio` | texto, 5 dígitos | Clave INEGI del municipio. |
| `clave_entidad`, `entidad`, `municipio` | texto | Igual que en las demás bases. |
| `lista_nominal_2025` | entero | Lista nominal del municipio en la elección judicial (repetida en cada fila del mismo municipio). |
| `personas_votaron_2025` | entero | Personas que votaron en el municipio (NO es lo mismo que la suma de votos por candidatura: ver más abajo). |
| `participacion_judicial` | decimal, % | `100 * personas_votaron_2025 / lista_nominal_2025`. |
| `no_candidato` | texto | Identificador de la candidatura tal como aparece en el archivo del INE (`CAND01`…`CAND64`). Es la clave para unir con tu propia codificación. |
| `nombre_candidato` | texto | Apellido paterno, materno y nombre, en ese orden (formato oficial del INE). |
| `genero` | texto | `H` o `M`, tal como lo reporta el INE. |
| `poder_postulante` | texto | Quién postuló a la candidatura: `PE` (Poder Ejecutivo), `PJ` (Poder Judicial), `PL` (Poder Legislativo), `EF` (una entidad federativa), o combinaciones cuando más de un poder coincidió en la misma persona. |
| `estatus_cancelado` | texto | `Sí`/`No`. Una candidatura fue cancelada durante el proceso (incompatibilidad o renuncia); sus votos, si los tiene, siguen en la base tal como los reporta el INE. |
| `votos` | entero | Votos (marcas) que recibió esa candidatura en ese municipio. |
| `votos_nulos_2025`, `recuadros_no_utilizados_2025` | entero | Totales del municipio, repetidos en cada fila (ver §5.2). |

**Fuente:** INE, Base de Datos de los Cómputos Distritales Judiciales 2025, cargo "Ministra/o de la Suprema Corte de Justicia de la Nación". Descargada de `https://computospj2025.ine.mx/assets/20250609_2050_COMPUTOS.zip` (corte 09/06/2025 20:50, hora del centro; 84,266 actas, 100% computadas — este fue el corte final). **Descargado el:** 2026-08-05. **Peso:** `.csv` 15.9 MB, `.rds` 0.48 MB.

**Por qué NO trae una columna `votos_bloque_a`.** Ninguna base oficial etiqueta qué candidaturas son "abiertamente morenistas". Esa es una decisión de codificación política, no un dato: le corresponde a EMG construirla y publicarla caso por caso, con su fuente hemerográfica (ver `proyecto_final_morena_ministras.md`, sección 3). Este archivo deja el voto por candidatura en formato largo exactamente para que esa codificación se pueda aplicar después con un `filter()` + `group_by()` sobre `no_candidato`, sin tener que reconstruir nada desde cero.

### 5.1 — ¿La geografía de la elección judicial coincide con la de 2024? **No.**

El archivo trae, en el mismo registro, dos geografías distintas: `DISTRITO_JUDICIAL_ELECTORAL` (creada específicamente para esta elección, por acuerdo del Consejo General del INE publicado en el DOF el 22 de enero de 2025) y `ID_DISTRITO_FEDERAL` (el distrito electoral ordinario, el mismo que usa la base presidencial de 2024). Se comprobó, no se supuso: **los dos números numéricamente coinciden en solo 11.4% de las actas**, y a nivel nacional hay **93 distritos judiciales distintos contra 300 distritos electorales federales**. No son la misma unidad geográfica.

Por eso, tanto esta base como `presidencial_2024_municipio.csv` se cruzan por **SECCIÓN**, que sí parece ser el mismo catálogo seccional en ambos años (aparece con el mismo campo `SECCION` en los dos archivos del INE), y no por distrito.

### 5.2 — ¿Cómo se cuentan las boletas con menos de 9 candidaturas marcadas?

La Suprema Corte elige 9 cargos, así que cada boleta tenía 9 recuadros disponibles. Se verificó, sumando el archivo completo, que:

`suma de votos por candidatura + votos nulos + recuadros no utilizados = total_votos_casilla`, **exactamente**, y que `total_votos_casilla / personas_votaron ≈ 9.00` a nivel nacional.

Es decir: si alguien marcó menos de 9 candidaturas, los recuadros que dejó en blanco **no se le restan a nadie ni anulan su boleta**: se cuentan aparte, en `RECUADROS_NO_UTILIZADOS` (aquí, `recuadros_no_utilizados_2025`). El voto de cada candidatura (columna `votos`) no se ve afectado por cuántas marcas hizo cada persona en el resto de su boleta.

**Consecuencia práctica: el denominador correcto de la participación es `personas_votaron_2025`, nunca la suma de la columna `votos`.** Sumar `votos` de todas las candidaturas de un municipio no te da "cuánta gente votó": te da hasta 9 veces esa cifra.

### 5.3 — La cifra de participación

**13.0184%** a nivel nacional (12,965,574 personas votaron de una lista nominal de 99,594,010), recalculada de manera independiente sumando el detalle por acta y coincide, dígito por dígito, con el resumen que trae el propio archivo del INE y con lo que muestra en vivo el sitio `computospj2025.ine.mx` bajo "Participación ciudadana". Esta cifra **reemplaza** el rango 12.57%-13.32% que el INE dio la noche de la jornada (comunicado 192, con base en un muestreo) y la cifra de 12.86% que circuló en prensa sin fuente primaria confirmada — ambas mencionadas como pendientes de verificar en `reconocimiento/17d_datos.md`. Este dato queda ya verificado contra la fuente primaria y puede usarse con confianza.

**Verificación cruzada de la lista de electos.** Sumando esta misma base municipal, las 9 candidaturas con más votos a nivel nacional son, en orden: Hugo Aguilar Ortiz, Lenia Batres Guadarrama, Yasmín Esquivel Mossa, Loreta Ortiz Ahlf, María Estela Ríos González, Giovanni Azael Figueroa Mejía, Irving Espinosa Betanzo, Arístides Rodrigo Guerrero García y Sara Irene Herrerías Guerra — la misma lista que reportó la cobertura periodística y que `reconocimiento/17d_datos.md` había marcado `[VERIFICAR]`. Con esto, esa lista queda verificada contra el dato primario del INE, no solo contra prensa.

**Decisiones documentadas:**

- **292 actas sin municipio (0.35%), casi todas "voto anticipado".** El tipo de casilla `A` (voto anticipado) se registra bajo `SECCION = 0`, un valor de plantilla sin territorio real, repetido en las 32 entidades. Representan apenas el 0.04% de la participación nacional (5,041 de 12,965,574 personas). Se excluyen de esta base municipal por la misma razón que el voto en el extranjero se excluyó de la base presidencial: no tienen un municipio real.
- **El corte temporal del cruce sección→municipio para 2025** usa la misma lógica que el de 2024 (§6), pero con año de corte 2025.

**Qué NO se puede hacer con este archivo:**

- No construyas ninguna cifra de "voto morenista" sumando candidaturas por tu cuenta sin documentar tu criterio caso por caso: esa es la parte que, según el diseño del proyecto final, no debe automatizarse.
- No sumes la columna `votos` esperando obtener el número de personas que votaron (ver §5.2).
- No asumas que `no_candidato` (`CAND01`…) identifica siempre a la misma persona entre elecciones judiciales futuras: es un identificador de esta elección, no una clave permanente de la candidata o candidato.

---

## 6. `vdem_americas.csv` / `.rds`

**Una fila = un país-año** (972 filas: 27 países de América × 36 años, 1990-2025).

| Columna | Unidad / tipo | Qué es |
|---|---|---|
| `iso3` | texto, 3 letras | Código ISO 3166-1 alpha-3 del país (`country_text_id` de V-Dem). |
| `pais` | texto | Nombre del país en español, vía `countrycode()` con fuente CLDR (Unicode). |
| `pais_en` | texto | Nombre del país tal como lo trae V-Dem (`country_name`, en inglés). |
| `subregion_vdem` | texto | `"America Latina y el Caribe"` o `"America del Norte"`, tomado de la variable oficial de región de V-Dem (`e_regionpol_6C`) una vez ya filtrado a América. |
| `anio` | entero | Año (1990-2025). |
| `indice_democracia_electoral` | decimal, 0-1 | `v2x_polyarchy`: qué tanto se cumple el ideal de que gobernantes respondan a la ciudadanía a través de elecciones limpias y competidas. |
| `indice_democracia_liberal` | decimal, 0-1 | `v2x_libdem`: además de lo anterior, qué tanto están protegidos los derechos individuales y de las minorías frente al Estado y frente a la mayoría. |
| `indice_corrupcion_politica` | decimal, 0-1 | `v2x_corr`: qué tan extendida está la corrupción. **Corre al revés que los otros cuatro índices de esta base: aquí MÁS alto significa MÁS corrupción.** |
| `indice_libertades_civiles` | decimal, 0-1 | `v2x_civlib`: ausencia de violencia física por parte de agentes del Estado y de restricciones a las libertades privadas y políticas. |
| `indice_empoderamiento_politico_mujeres` | decimal, 0-1 | `v2x_gender`: qué tanta capacidad, voz y participación tienen las mujeres en la toma de decisiones políticas del país. |

**Fuente:** V-Dem Institute, paquete oficial de R `vdemdata` (github.com/vdeminstitute/vdemdata), que trae empacada la versión más reciente del dataset "Country-Year: V-Dem Full+Others" sin pasar por el formulario con correo electrónico que exige v-dem.net para la descarga directa — verificado abriendo esa página: el formulario existe de verdad, y `vdemdata` es la vía alterna que el propio sitio de V-Dem recomienda para usuarios de R. **Descargado el:** 2026-08-05. **Peso:** `.csv` 79.85 KB, `.rds` 10.09 KB.

**Cita obligatoria** (verificada en `v-dem.net/about/faq/`, sección "How do I cite the V-Dem data?"):

> Coppedge, Michael, John Gerring, Carl Henrik Knutsen, Staffan I. Lindberg, Jan Teorell, David Altman, Fabio Angiolillo, Michael Bernhard, Agnes Cornell, M. Steven Fish, Linnea Fox, Lisa Gastaldi, Haakon Gjerløw, Adam Glynn, Ana Good God, Allen Hicken, Katrin Kinzelbach, Joshua Krusell, Kyle L. Marquardt, Kelly McMann, Valeriya Mechkova, Juraj Medzihorsky, Anja Neundorf, Pamela Paxton, Daniel Pemstein, Josefine Pernes, Johannes von Römer, Brigitte Seim, Rachel Sigman, Svend-Erik Skaaning, Jeffrey Staton, Aksel Sundström, Marcus Tannenberg, Eitan Tzelgov, Yi-ting Wang, Tore Wig, Steven Wilson and Daniel Ziblatt. 2026. "V-Dem Country-Year Dataset v16" Varieties of Democracy (V-Dem) Project. https://doi.org/10.23696/vdemds26

Si usas el paquete `vdemdata` en un trabajo, cita también: Maerz, Seraphine F., Amanda B. Edgell, Sebastian Hellemeier, Nina Illchenko, and Linnea Fox. 2026. *vdemdata: An R package to load, explore and work with the most recent V-Dem (Varieties of Democracy) dataset.* https://github.com/vdeminstitute/vdemdata

**Licencia:** el sitio de V-Dem declara los datos "open source and free for anyone to use... you do not need to seek permission to use the data, but we kindly ask you to cite the data" (`v-dem.net/about/faq/`). No se localizó, dentro de lo verificado en esta ola de trabajo, un texto de licencia tipo Creative Commons explícito en esa misma página — `reconocimiento/17d_datos.md` había reportado CC-BY-SA sin abrir la página de licencia directamente, así que esa etiqueta específica queda `[VERIFICAR]`.

**Decisiones documentadas** (ver también `prep_vdem_americas.R`):

- **"América" = COWcode 2-165** (Correlates of War), no la variable de región propia de V-Dem (que junta Norteamérica con Europa Occidental). Con este filtro, V-Dem **no cubre 8 microestados del Caribe** (Bahamas, Antigua y Barbuda, Santa Lucía, Granada, San Vicente y las Granadinas, San Cristóbal y Nieves, Dominica, Belice): sencillamente no aparecen en el objeto `vdem` con ese rango. `qog_basico.csv` (§7) sí los cubre — las dos bases se complementan por eso.
- **Arranca en 1990**, no antes: los cinco indicadores elegidos no tienen ni un solo `NA` para los 27 países de América entre 1990 y 2025, así que no se pierde cobertura por ese arranque.

**Qué NO se puede hacer con este archivo:** no promedies `indice_corrupcion_politica` junto con los otros cuatro índices esperando que "más alto" signifique lo mismo en los cinco — ese índice corre al revés. No compares valores absolutos de este archivo contra una versión distinta de V-Dem (v15, v14...): el propio proyecto advierte que los cambios de metodología entre versiones hacen esa comparación engañosa: solo son comparables los rangos y órdenes dentro de una misma versión.

---

## 7. `qog_basico.csv` / `.rds`

**Una fila = un país** (35 países de América; corte transversal, NO panel — ver la nota de años más abajo).

| Columna | Unidad / tipo | Qué es |
|---|---|---|
| `iso3` | texto, 3 letras | Código ISO 3166-1 alpha-3 (`ccodealp` de QoG). |
| `pais` | texto | Nombre del país en español, vía `countrycode()` (fuente CLDR). |
| `indice_control_corrupcion` | decimal, ≈ -2.5 a 2.5 | `wbgi_cce` (Banco Mundial, *Worldwide Governance Indicators*/WGI): qué tanto el poder público se ejerce para beneficio privado y qué tanto el Estado logra contenerlo. **MÁS alto es MEJOR** (menos corrupción) — al revés que `indice_corrupcion_politica` de V-Dem. |
| `indice_efectividad_gubernamental` | decimal, ≈ -2.5 a 2.5 | `wbgi_gee` (WGI): calidad del servicio civil, de la formulación de políticas públicas y de su implementación, e independencia de la burocracia frente a presiones políticas. Más alto es mejor. |
| `indice_estado_derecho` | decimal, ≈ -2.5 a 2.5 | `wbgi_rle` (WGI): qué tanto confían los actores en las reglas de la sociedad y las cumplen — contratos, propiedad, policía y tribunales. Más alto es mejor. |
| `indice_estabilidad_politica` | decimal, ≈ -2.5 a 2.5 | `wbgi_pve` (WGI): qué tan probable es que el gobierno sea desestabilizado por medios inconstitucionales o violentos, incluido el terrorismo. Más alto es mejor. |
| `indice_percepcion_corrupcion_ti` | entero, 0-100 | `ti_cpi` (Transparencia Internacional, *Corruption Perceptions Index*): percepción de corrupción del sector público entre empresarios, analistas de riesgo y población en general. 0 = percepción de máxima corrupción, 100 = percepción de mínima corrupción. **Escala distinta a las cuatro anteriores: no las promedies juntas sin estandarizar.** |
| `indice_desarrollo_humano` | decimal, 0-1 | `undp_hdi` (PNUD, *Human Development Index*): promedio geométrico de esperanza de vida, escolaridad e ingreso por persona. No es un indicador de "gobierno" en sentido estricto — se incluye como contexto de desarrollo. |
| `gasto_publico_educacion_pib` | decimal, % del PIB | `wdi_expedu` (Banco Mundial, *World Development Indicators*): gasto público en educación como porcentaje del PIB del país. Es el único indicador de "gasto público" de esta base. |

**Fuente:** QoG Institute (Universidad de Gotemburgo), *The Quality of Government Basic Dataset, Version Jan26*, corte transversal (`qog_bas_cs_jan26.csv`), descargado directo de `qogdata.pol.gu.se` con `curl::curl_download()` — **sin paquete de R**: se verificó que QoG no distribuye ningún paquete de R en CRAN ni en GitHub para el dataset Basic completo. **Descargado el:** 2026-08-05. **Peso:** `.csv` 3.26 KB, `.rds` 2.41 KB.

**Cita obligatoria** (verificada en `gu.se/en/quality-government/qog-data/data-downloads/basic-dataset`):

> Dahlberg, Stefan, Aksel Sundström, Sören Holmberg, Bo Rothstein, Natalia Alvarado Pachon, Victor Saidi Phiri, Chuwei Chen & Zhen Liu 2026. *The Quality of Government Basic Dataset, Version Jan26.* University of Gothenburg: The Quality of Government Institute, https://www.gu.se/en/quality-government. https://doi.org/10.18157/qogbasjan26

QoG pide, además, citar la fuente original de cada variable que uses. Verificado para las que trae esta base:

- `ti_cpi`: Transparency International. (2025). *Corruption perception index 2024* [Licensed under CC-BY-ND 4.0]. http://www.transparency.org/cpi
- `wbgi_*` (las cuatro variables del Banco Mundial): *Worldwide Governance Indicators*, 2025 Revision, World Bank (www.govindicators.org). El WGI recalculó su serie histórica completa con esta revisión de 2025.
- `undp_hdi` y `wdi_expedu`: PNUD (*Human Development Report*) y Banco Mundial (*World Development Indicators*) respectivamente — se confirmó que son las fuentes originales de QoG para estas columnas, pero el texto exacto de cita que pide cada institución para estas dos variables específicas queda `[VERIFICAR]` (no se abrió la sección correspondiente del codebook completo de QoG, que supera las 300 páginas).

**Licencia:** QoG lo declara explícito en la misma página: *"The QoG datasets are open and available, free of charge and without a need to register your data. You can use them for your analysis, graphs, teaching, and other academic-related and non-commercial purposes... We do not allow other uses of these data including but not limited to redistribution, commercialization and other for-profit usage."* — uso académico y docente sí, redistribuir o usar con fines comerciales no. Se verificó abriendo esa página en vivo: **no exige registro**, a diferencia de lo que un formulario de correo (como el de V-Dem) habría exigido.

**Decisiones documentadas** (ver también `prep_qog_basico.R`):

- **Corte transversal (país), no panel (país-año).** QoG también publica una versión *Basic TS* (país-año, 1946-2025); se eligió la CS porque V-Dem ya cubre la dimensión temporal para democracia, y porque un país-por-fila es más directo de explicar en una sesión de once minutos.
- **El "corte transversal" no es un año único de verdad.** La propia página de descarga de QoG lo advierte, textual: *"data from and around 2022 is included. Data from 2022 is prioritized; however, if no data is available for a country for 2022, data for 2023 is included... up to a maximum of +/- 3 years."* No asumas que cada celda es literalmente 2022: puede venir de un año distinto según el país y la variable.
- **Mismo filtro de "América" que V-Dem** (COWcode 2-165), para que las dos bases se puedan cruzar por `iso3` sin sorpresas de cobertura. A diferencia de V-Dem, QoG **sí cubre** a los 8 microestados del Caribe que V-Dem no codifica — por eso esta base trae 35 países y `vdem_americas.csv` trae 27.
- **Se descartaron dos variables candidatas:** `wdi_gdpcapcon2015` (PIB per cápita) por no ser un indicador de calidad institucional, corrupción o gasto público (es desarrollo económico), y `wdi_expmil` (gasto militar) por tener 12 de 35 países en `NA` (34%), demasiado hueco para un ejercicio introductorio.
- **`NA` esperados y explicados:** `indice_percepcion_corrupcion_ti` tiene 3 `NA` (Antigua y Barbuda, Belice, San Cristóbal y Nieves — Transparencia Internacional no encuesta a esos microestados); `gasto_publico_educacion_pib` tiene 1 `NA` (Guyana — el Banco Mundial no tiene ese dato para el país en el rango de años cubierto). No se rellenaron con promedios: serían datos inventados.

**Qué NO se puede hacer con este archivo:** no promedies `indice_percepcion_corrupcion_ti` (escala 0-100) junto con los cuatro indicadores `wbgi_*` (escala ≈ -2.5 a 2.5) sin estandarizar ambos primero. No redistribuyas este archivo fuera de un uso académico o de docencia — es justo lo que prohíbe la licencia de QoG. No asumas que todas las filas describen el mismo año calendario.

---

## 8. `latinobarometro_reciente.csv` / `.rds`

**Una fila = un país** (17 países; agregado de la ola 2024 de la encuesta Latinobarómetro, construido a partir de 19,214 personas entrevistadas).

| Columna | Unidad / tipo | Qué es |
|---|---|---|
| `iso3` | texto, 3 letras | Código ISO 3166-1 alpha-3, construido con `countrycode()` a partir de `IDENPA` (código numérico de país del archivo original). |
| `pais` | texto | Nombre del país en español. |
| `n_encuestados` | entero | Número de personas entrevistadas en ese país en la ola 2024 (sin ponderar). |
| `apoyo_democracia_pct` | decimal, % | Pregunta `P11STGBS`: porcentaje (ponderado por `WT`) que eligió *"La democracia es preferible a cualquier otra forma de gobierno"*, frente a que un gobierno autoritario puede ser preferible o que da lo mismo un régimen u otro. |
| `satisfaccion_democracia_pct` | decimal, % | Pregunta `P12STGBS.A`: porcentaje (ponderado) *"Muy satisfecho"* o *"Más bien satisfecho"* con el funcionamiento de la democracia en su país, sobre una escala de 4 categorías. |
| `confianza_interpersonal_pct` | decimal, % | Pregunta `P10STGBS`: porcentaje (ponderado) que dice que *"se puede confiar en la mayoría de las personas"*, frente a *"uno nunca es lo suficientemente cuidadoso"*. |
| `confianza_gobierno_pct` | decimal, % | Pregunta `P14ST.E`: porcentaje (ponderado) con *"mucha"* o *"algo de"* confianza en el gobierno, sobre una escala de 4 categorías. |
| `confianza_poder_judicial_pct` | decimal, % | Pregunta `P14ST.F`: mismo criterio que la anterior, para el Poder Judicial. |
| `percepcion_corrupcion_prom` | decimal, 0-10 | Pregunta `P54N`: promedio (ponderado) de qué tan corrupto se percibe al país, en una escala de 0 (*"para nada corrupto"*) a 10 (*"totalmente corrupto"*). **No es un porcentaje: más alto significa más corrupción percibida.** |

**Fuente:** Corporación Latinobarómetro, *Estudio Latinobarómetro 2024*, versión agregada v2024.1, archivo Stata (`latinobarometro-2024-stata-v20250817.zip`), descargado directo de `latinobarometro.org/latinobarometro-2024` con `curl::curl_download()`. **Descargado el:** 2026-08-05. **Peso del archivo limpio:** `.csv` 0.95 KB, `.rds` 0.85 KB (el microdato crudo, `.dta`, pesa 12.73 MB y vive solo en `datos/crudos/latinobarometro/`, excluido de git).

**Verificación de que no hace falta registro:** se comprobó, abriendo en vivo `latinobarometro.org/documentacion-datos`, `.../agregados` y `.../latinobarometro-2024`, que el sitio actual **no exige correo, contraseña ni formulario** antes de mostrar el enlace de descarga — se buscó explícitamente "registr", "login", "formulario" en el HTML de esas páginas y no aparece ninguno. `reconocimiento/17d_datos.md` había marcado esto `[VERIFICAR]` sobre una versión anterior del sitio; queda resuelto: hoy la descarga es directa.

**Cita obligatoria** (tomada literal de `latinobarometro.org/latinobarometro-2024`, sección "Cómo citar"):

> Estudio Latinobarómetro 2024. Corporación Latinobarómetro: Oleada 2024 - Versión agregada: https://www.latinobarometro.org/latinobarometro-2024. Madrid: JD Systems Institute.

**Licencia** (tomada literal de `latinobarometro.org/agregados`, sección "Uso, citación y apoyo"):

> Política de uso de datos: Los conjuntos (SPSS, Stata, SAS, R, CSV) son aptos para investigación no comercial, docencia y publicaciones. Se prohíbe la redistribución: volver a publicar datos del Latinobarómetro en otros sitios web infringe el derecho de propiedad de Latinobarómetro.

**Decisiones documentadas** (ver también `prep_latinobarometro.R`):

- **Ponderación con `WT`.** Los seis indicadores se calcularon con `weighted.mean(..., w = WT)`, no con un promedio simple: el archivo trae un peso muestral por persona y promediar sin ponderar habría cometido el mismo error que promediar `participacion` sin ponderar por lista nominal en la sesión 1.
- **17 de los 18 países/territorios que anuncia el sitio para la ola 2024.** Falta Nicaragua. No se encontró, ni en el archivo ni en la página pública, una nota oficial que explique la ausencia — es consistente con reportes periodísticos sobre restricciones del gobierno nicaragüense a la investigación de opinión pública en el país, pero esa explicación puntual queda `[VERIFICAR]`.
- **`percepcion_corrupcion_prom` es un promedio 0-10, no un porcentaje** — a propósito distinto en forma de los otros cinco indicadores de esta base, para que quede claro que mide algo distinto (intensidad percibida, no proporción de personas).

**Qué NO se puede hacer con este archivo:** no redistribuyas ni el archivo limpio ni, sobre todo, el microdato crudo (`datos/crudos/latinobarometro/`) fuera de este curso — la licencia de Latinobarómetro lo prohíbe explícitamente. No trates `percepcion_corrupcion_prom` como si fuera un porcentaje. No asumas que los 17 países son los mismos 17 en todas las olas de Latinobarómetro: la cobertura cambia de año en año (ver el punto de Nicaragua arriba).

---

## 9. El problema de las claves municipales INE contra INEGI, y cómo se reconcilió

Este es el contenido central de la sesión 4, y aparece resuelto en `puente_claves_ine_inegi.csv`, pero conviene explicarlo aquí completo porque toca a todas las bases de este catálogo que llegan a nivel de municipio.

**El problema.** El INE identifica municipios con su propia numeración (heredada del IFE, por eso se le llama clave "ife" en la literatura y en las bases de Eric Magar), ligada a su cartografía electoral. INEGI usa la clave de Área Geoestadística Municipal (AGEM), base de su Marco Geoestadístico y del Censo. **Las dos numeraciones no son intercambiables.** En el municipio 1 de Aguascalientes coinciden (`01001` en ambos sistemas), pero en 1,369 de los 2,477 municipios del país — más de la mitad — no coinciden. Ejemplos verificados en este trabajo: Colima capital es `06002` para INEGI pero `06001` para el INE; Campeche capital es `04002` para INEGI pero `04001` para el INE.

**Por qué esto rompe un `left_join()` ingenuo.** Cualquier base electoral del INE (incluidas las dos de este catálogo) llega con la geografía del INE. Cualquier capa de INEGI (el Marco Geoestadístico, el Censo) llega con la clave de INEGI. Si cruzas una contra otra por clave de municipio sin reconciliarlas primero, vas a unir Colima con el municipio equivocado en 1,369 casos, en silencio, sin que R te avise.

**Cómo se resolvió aquí.** Se usó `emagar/mxDistritos` (github.com/emagar/mxDistritos, de Eric Magar, ITAM, licencia MIT), que trae, para cada una de las ~76,000 secciones electorales del país desde 1994, tanto la clave INEGI como la clave INE del municipio al que pertenece, en el mismo registro. Esa tabla, agregada a nivel de municipio, es `puente_claves_ine_inegi.csv`.

**Dos matices que valió la pena documentar, y que pueden ser material de clase:**

1. **El campo `baja` de esa tabla no significa lo que parece.** El primer intento de esta ola de trabajo filtró "secciones vigentes" con `is.na(baja)`, asumiendo que "baja" quiere decir "esta sección ya no existe". Eso excluía por error miles de secciones que sí tuvieron votos reales en la elección de 2024 (por ejemplo, la sección 86 de Aguascalientes, marcada con `baja = 2023`, votó normalmente en junio de 2024). No se encontró documentación pública que explique con precisión qué evento marca esa columna. La solución que se adoptó — y que puede discutirse en clase como ejemplo de "no confíes en una columna solo por su nombre" — fue usar, para cada sección, el registro con el año de `alta` más reciente que no sea posterior a la elección en cuestión, ignorando `baja` por completo.
2. **Cuatro municipios (de 2,477) tenían una ambigüedad real:** la misma clave INEGI aparecía asociada a dos claves INE distintas, correspondientes a dos municipios reales diferentes (típicamente un municipio de creación reciente, separado de uno más grande: Pesquería de Apodaca en Nuevo León, Juan José Ríos de Guasave en Sinaloa, entre otros). Se resolvió por mayoría de secciones — quedándose con la clave que respalda la mayoría — y se documenta aquí en vez de esconderse.

**Recomendación para la sesión 4.** El ejercicio ya está diseñado en `proyecto_final_morena_ministras.md` §2.4: unir primero por *nombre* de municipio a propósito, dejar que falle, diagnosticar con `anti_join()`, y solo entonces unir por clave usando este puente. Esa secuencia de doce minutos es, según el propio diseño del curso, "el contenido más valioso de las once horas".

---

## 10. Resumen de licencias

| Fuente | Licencia declarada | ¿Permite redistribuir? |
|---|---|---|
| INE (cómputos 2024 y cómputos judiciales 2025) | No declarada explícitamente en el portal. Dato público de una institución gubernamental mexicana. | No prohibida explícitamente. |
| INEGI (Marco Geoestadístico) | Términos de Libre Uso de información del sitio de INEGI (no se localizó un aviso tipo Creative Commons dedicado a este producto específico). | No prohibida explícitamente. |
| `emagar/mxDistritos` | **MIT** (declarada explícitamente en el repositorio de GitHub). | Sí. |
| V-Dem (`vdem_americas.csv`) | Datos abiertos, de uso libre, con cita obligatoria (ver §6). Texto de licencia tipo CC no verificado directamente — `[VERIFICAR]`. | Sí, con cita. |
| Quality of Government (`qog_basico.csv`) | Abierta, sin registro, **solo uso académico/docente no comercial** (ver §7). | **No.** Redistribución y uso comercial prohibidos explícitamente. |
| Latinobarómetro (`latinobarometro_reciente.csv`) | Investigación no comercial, docencia y publicaciones (ver §8). | **No.** Redistribución prohibida explícitamente — aplica sobre todo al microdato crudo. |

Las tres fuentes comparadas (V-Dem, QoG, Latinobarómetro) piden cita obligatoria — los textos exactos están en §6, §7 y §8. QoG y Latinobarómetro además **prohíben explícitamente la redistribución**: los archivos de `datos/limpios/` de este repositorio son recortes ya agregados y transformados para uso didáctico dentro de este curso, no una republicación del dato original — aun así, si este repositorio se hace público, vale la pena que EMG confirme con ambas instituciones que este uso agregado/educativo cae dentro de lo permitido antes de publicarlo sin restricciones.
