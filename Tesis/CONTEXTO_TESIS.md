# Contexto esencial de la tesis

Actualizado: 2026-11-25. Resumen persistente de la conversación y comprobación del `main.tex` actual. Leer junto con `AGENTS.md` y `GUIA_ESCRITURA.md`.

## Proyecto y fuentes

- Autor: Saúl Estuardo Nájera Allara, licenciatura en Física Aplicada, USAC/ECFM.
- Tema: caminatas cuánticas discretas en el tiempo (DTQW) en billares, con moneda de dimensión cuatro. Investigación principalmente mediante simulaciones en Wolfram Mathematica.
- Proyecto: `/Users/saul/Desktop/EPS_QW/Tesis`; fuente `main.tex`, bibliografía `ref.bib`, figuras `Imgs/`, PDF `main.pdf`.
- Asesores: José Alfredo de León (JA, `\janote`), Carlos Francisco Pineda Zorrilla (CP, `\cpnote`), Rodolfo Samayoa. Las notas `\snnote` son de Saúl.
- Investigación: `/Users/saul/Desktop/EPS_QW/Chaos_Results/main.tex` y PDF correspondiente. La sección I contiene el modelo.
- Derivación analítica provisional, actualizable por el usuario: `/Users/saul/Desktop/ChatGPT/QWProgramming/analítica1D/derivacion.tex` y `derivacion.pdf`.
- Presentación previa: `/Users/saul/Desktop/ChatGPT/QWProgramming/presentaciones/espectro_bloques.pdf`. Las figuras de intervalos de L1 están en el subdirectorio `Imgs` de esa carpeta.
- Referencia de escritura indicada originalmente: `/Users/saul/Desktop/Libros/QM/schimel-2012-writing_science-whole-book.pdf`. La existencia con ese nombre exacto no se confirmó en la revisión de 2026-11-17; buscar el nombre actual si hace falta.
- Artículo ya añadido a `ref.bib`: Aharonov, Ambainis, Kempe y Vazirani, *Quantum walks on graphs*, STOC 2001, pp. 50–59, DOI `10.1145/380752.380758`. Clave `aharonov2001quantum`; versión consultada https://arxiv.org/abs/quant-ph/0012090v2 (revisión de 2002). Su sección 3.1 sirve de fundamento para moneda + desplazamiento.

## Historia científica y estructura

Pregunta actual de la tesis: cómo emerge el caos cuántico en DTQW sobre billares con moneda 4D. La comparación muestra que la elección de moneda influye fuertemente en las firmas espectrales; la geometría por sí sola no determina los resultados de los casos estudiados. Las monedas que conservan sectores horizontal y vertical permiten una solución espectral por caminatas 1D para cualquier geometría dentro del modelo reflectante.

Capítulos actuales, comprobados en `main.tex` (títulos aprobados; no cambiar por iniciativa propia):

1. Introducción.
2. Caminatas cuánticas discretas en billares.
3. Caos cuántico e indicadores espectrales.
4. Integrabilidad con monedas diagonales por bloques.
5. Huellas de caos cuántico en billares (título actual; antes fue «Firmas…»).
6. Poder coherente L1 de la moneda y firmas espectrales.
7. Conclusiones.

Capítulo 4: 4.1 «Descomposición de la caminata bidimensional en caminatas unidimensionales»; 4.2 «Derivación del espectro 1D y ausencia de firmas caóticas»; 4.3 «Análisis espectral», centrada en las eigenfases distintas de una caminata en Sinaí.

## Modelo y convenciones

- Sitios accesibles `Omega` subconjunto finito de Z², N sitios. Espacio total Hc tensor Hp, dimensión 4N; kets en orden moneda–posición: `|c,v>`.
- Orden interno `{R,L,U,D}`. Coin homogénea y constante en el tiempo. Un paso: `U = S(C tensor I_p)`.
- Convención tipográfica aprobada: etiquetas de dirección R, L, U y D en letra recta (`\mathrm`), al igual que los subíndices abreviados h y v de las monedas y estados. El operador U, la coordenada v y los coeficientes siguen en cursiva.
- En el interior, S cambia la posición un sitio conservando dirección. Si el vecino está fuera de Omega, permanece en el mismo sitio e invierte dirección (`R <-> L`, `U <-> D`) sin fase adicional. No es una reflexión especular continua sobre una tangente curva.
- Moneda por bloques en esa base: `C = C_h directsum C_v`, ambos en U(2). No intercambia sectores horizontal y vertical.
- En 4.1 se usa `H_y^{horizontal}`, `H_x^{vertical}`, y bases B correspondientes, con coordenadas fijadas explícitamente (`y=y_0`, `x=x_0`). La base completa concatena las bases de todas las filas horizontales y luego de todas las columnas verticales.
- Los estados de cada base se ordenan por coordenada espacial creciente y luego por dirección en cada sitio: R,L en filas; U,D en columnas. Cada estado total aparece una vez.
- La invariancia se escribe mediante estados: `psi en H -> U psi en H`, porque al asesor le resulta incómoda la notación `U H subset H`.
- Invariancia + ortogonalidad implican `⟨b'|U|b⟩=0` para estados de distintos subespacios; eso justifica los ceros de la matriz por bloques. La ortogonalidad por sí sola no basta para anular elementos de U.
- Se aceptó una aclaración breve: «Si la fila o columna no es conexa, cada una de sus componentes conexas evoluciona de forma independiente, debido a la reflexión en sus extremos». La separación por filas/columnas sigue siendo válida; al usar el espectro de un intervalo reflectante, resolver cada componente conexa por separado. No centrar toda la sección en este detalle ni reintroducir una maquinaria formal de «tramos».
- La sección 4.1 ya incluye el miniresumen y la figura de la geometría de Sinaí solicitados por CP. La figura muestra una fila y una columna destacadas.

## Derivación 1D de 4.2

Se consideran n sitios consecutivos j=1,...,n, dos direcciones internas y la misma reflexión en ambos extremos. Notación acordada recientemente: `U_{1D}` para evolución 1D, `U_0` para moneda sin fase global; se conserva `S_n` para el shift. Evitar `U_n(C)` y `U_{n,0}` en texto nuevo. No usar «tramo» en la prosa; las etiquetas LaTeX antiguas con esa palabra se conservaron para no romper referencias.

Moneda y fase:
`C = exp(i alpha) C_0`, `C_0 = [[a,b],[-b*,a*]]`, `|a|²+|b|²=1`.
`U_{1D}=exp(i alpha) U_0`; resolver `U_0 psi=mu psi` y recuperar `lambda=exp(i alpha) mu`.
Estado: suma_j `R_j|R,j> + L_j|L,j>`.

Recurrencias interiores:
`mu R_{j+1}=a R_j+b L_j`, j=1,...,n-1.
`mu L_{j-1}=-b* R_j+a* L_j`, j=2,...,n.
Bordes: `mu R_1=-b*R_1+a*L_1`; `mu L_n=aR_n+bL_n`.
Amplitudes auxiliares `L_0=R_1`, `R_{n+1}=L_n` incorporan los bordes sin añadir sitios físicos.

Para a distinto de 0:
`w_j=(R_j,L_{j-1})^T`, `w_{j+1}=T(mu)w_j`,
`T=(1/a*) [[mu^{-1},b],[b*,mu]]`.
T propaga un perfil espacial para un eigenvalor propuesto; no es el operador temporal.
Borde izquierdo: `w_1=R_1 e_+`, `e_+=(1,1)^T`.
Borde derecho: `e_-^T T(mu)^n e_+=0`, `e_-=(1,-1)^T`.

Escribir `a=A exp(i phi)`, A=|a|>0, y `T=exp(i phi) Ttilde` da det Ttilde=1. Cayley–Hamilton y los polinomios de Chebyshev de segunda especie (`mathsf U`, distintos del operador U) dan la condición:
`mathsf U_{n-1}((mu+mu^{-1})/(2A)) (mu^{-1}-mu+2i Im(b)) = 0`.

Espectro físico:
- Banda: `lambda_{m,+/-}=exp(i alpha) exp(+/- i arccos(|a| cos(pi m/n)))`, m=1,...,n-1.
- Adicionales: `lambda_{ext,+/-}=exp(i alpha) [i Im(b) +/- sqrt(1-Im(b)^2)]`, independientes de n.
- Llamarlos «adicionales». No llamarlos universalmente «estados de borde»: su localización depende de la moneda.
- Para a distinto de 0 hay 2n valores distintos. El texto actual ya indica la completitud para a distinto de cero y que para n=1 solo quedan los adicionales. El caso a=0 se discutió en el chat mediante resolución directa y sigue pendiente en el documento. No afirmar que la transferencia cubre a=0, pues divide entre a*.
- Para reconstruir el espectro del billar, reunir valores de filas/columnas (o sus componentes conexas) contando multiplicidades. Filas con el mismo bloque comparten su fase; C_h y C_v pueden tener fases distintas. Los valores adicionales se repiten entre componentes aunque cambien las longitudes.
- «Integrabilidad» se usa por acuerdo con los asesores en el sentido de solubilidad espectral exacta. Esto no demuestra por sí solo estadística poissoniana universal. El análisis estadístico corresponde a los resultados que se aporten, incluyendo 4.3.

## Estado comprobado del capítulo 4

- La sección 4.2 contiene la versión condensada de la derivación, con referencias cruzadas y cierre sobre solubilidad espectral. La reconstrucción del espectro con multiplicidades se explica en palabras.
- Por acuerdo con Saúl y su asesor, la sección 4.3 presenta una sola figura de Sinaí. La figura usa BlockDiagonal_Sinai_Ps_COEs_Analytical.pdf y BlockDiagonal_Sinai_SFF_COEs_Analytical.pdf. La moneda se compone de dos bloques COE de 2 por 2. Ambos indicadores usan una copia por eigenfase coincidente. P(s) se muestra con y sin unfolding, y el SFF promediado se muestra para el espectro desplegado. El resultado descrito es una semejanza parcial con Poisson. La figura está acordada y la redacción queda pendiente de aprobación del asesor.
- En una versión anterior se analizaba el espectro con multiplicidades. Las fracciones de espaciamientos nulos eran 96,1 % en el rectángulo y 48,2 % en Sinaí para aquella configuración. Con la normalización K(t)=|sum_j exp(i t phi_j)|²/N, el promedio a tiempo largo sobre tiempos enteros para las eigenfases originales es sum_j m_j²/N, donde m_j es la multiplicidad de cada eigenfase distinta. K=1 corresponde al espectro sin degeneraciones con esa normalización. Los gráficos muestran un promedio móvil en un intervalo finito.

## Discusión actual sobre estadística de Poisson

Resultados y distinciones establecidos en el chat:

- Si se conservan las multiplicidades, N eigenfases totales y D distintas producen N−D espaciamientos circulares nulos. Una fracción positiva de ceros aporta un átomo en s=0, mientras que la distribución exponencial de media uno P(s)=exp(−s) es continua. Un unfolding que preserve las coincidencias no elimina ese átomo. La solubilidad espectral exacta y la invariancia de los subespacios tampoco implican independencia estadística entre los espectros.
- Para examinar solo las eigenfases distintas, se acordó agrupar las coincidencias en el círculo con tolerancia, conservar una copia por eigenfase, ajustar el unfolding a esa lista y normalizar los espaciamientos circulares a media uno. Como comparación, se pueden normalizar los espaciamientos de esa misma lista sin unfolding. En Mathematica, QWPoissonComparison recibe las eigenfases originales en radianes. Internamente llama a QWPs para hacer unfolding. Si se le pasan niveles previamente devueltos por UnfoldCircular, los interpreta como ángulos módulo 2 Pi, altera el orden y vuelve a aplicar unfolding.
- Prueba con un billar triangular aportada por Saúl: 2120 eigenfases distintas de 3444. El histograma obtenido al introducir las eigenfases originales presenta un déficit de espaciamientos pequeños frente a la exponencial. El histograma visualmente cercano a la exponencial se obtuvo con la entrada ya desplegada y no sirve como evidencia.
- Ejemplo teórico discutido en el chat: en un cuadrado de n por n, asignar a cada caminata 1D de una fila o columna una moneda proporcional a la identidad con fase aleatoria independiente. Cada caminata aporta 2n eigenfases equiespaciadas, con un desplazamiento aleatorio. Al superponer M=2n caminatas, la probabilidad de que un espaciamiento circular normalizado exceda s es (1−s/M)^(M−1) para 0≤s≤M, y tiende a exp(−s). Esto demuestra convergencia para la distribución marginal de espaciamientos. El patrón se repite en cada intervalo de longitud pi/n y el ejemplo requiere un operador moneda dependiente de la posición.

Pregunta abierta para retomar: ¿se puede obtener una ley exponencial de espaciamientos mediante una familia de billares con una misma moneda espacialmente homogénea C_h ⊕ C_v? Especificar si se incluye el espectro con multiplicidades o solo las eigenfases distintas. En el modelo homogéneo, los eigenvalores adicionales se comparten dentro de cada orientación y las eigenfases de banda también coinciden cuando se repiten fracciones m/n para distintos tamaños. Falta determinar si alguna familia de geometrías y monedas permite obtener la ley buscada dentro de ese modelo.

## Otros resultados y figuras

- Cap. 5: se consideran Grover `g` y `upu` (diagonal conjugada por una unitaria). Rectángulo: g próxima a Poisson, upu próxima a COE. Sinaí: g próxima a COE, upu próxima a CUE. Son comparaciones de estadísticas, no pruebas automáticas de una simetría.
- Indicadores usados: DoS, P(s), SFF e IPR. No se empleará el cociente de espaciamientos P(r). Las figuras originales de intervalos L1 lo incluían; se excluyó ese panel al insertarlas.
- IPR: distinguir eigenestados frente a eigenfase de evolución temporal. Los archivos IPR disponibles inicialmente correspondían a eigenestados frente a eigenfase.
- L1: poder coherente en la base de direcciones. No equivale específicamente a acoplamiento horizontal–vertical ni basta para diagnosticar caos; Grover es un ejemplo relevante con L1=1 y comportamiento integrable en el rectángulo.
- Cap. 6 tiene dos figuras: rectángulo y Sinaí, cada una reúne intervalos 0–0.1 y 0.9–1 con un único caption. Archivos copiados en Imgs: `Mixing_Rect_Interval_0_01.pdf`, `Mixing_Rect_Interval_09_10.pdf`, `Mixing_Sinai_Interval_00_01.pdf`, `Mixing_Sinai_Interval_09_10.pdf`. Paneles visibles: distribución de fases, P(s), SFF.
- CP tiene notas recientes sobre sintetizar figuras del cap. 6 y continuar la investigación. No asumir que los paneles provisionales son resultados finales.
