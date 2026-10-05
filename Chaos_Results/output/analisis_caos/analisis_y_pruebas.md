# Emergencia de caos en la caminata: análisis y pruebas

Revisión del 4 de octubre de 2026. Se consultaron las figuras espectrales y dinámicas de `main.pdf` y `presentacionFrancois/presentacion_breve.pdf`, sus fuentes y la implementación en `/Users/saul/Desktop/ChatGPT/QWProgramming`. Las comprobaciones adicionales se reproducen con `verificar.py`; `verificacion.json` contiene sus resultados. No se modificaron las fuentes ni los resultados originales.

**Conclusión de trabajo:** los datos apuntan a la compatibilidad entre moneda, desplazamiento y reflexión como factor que controla la estadística espectral. La orientación de los eigenvectores de la moneda respecto a las direcciones físicas importa. La pérdida de descomposiciones dinámicas especiales es una hipótesis plausible para la repulsión, pero todavía no hay una condición necesaria y suficiente de caos ni una demostración de integrabilidad para todas las monedas con estadística próxima a Poisson.

## 1. Evidencia revisada

En las comparaciones de P(s), P(r) y SFF:

| Monedas | Rectángulo | Sinaí discretizado |
|---|---|---|
| gpg, oo | Distribuciones próximas a Poisson, con desviaciones | Repulsión visible |
| b | Ausencia de repulsión universal clara; estructura adicional | Repulsión visible |
| uoou, o, ubu, u, upu | Repulsión visible | Repulsión visible |
| p | Degeneraciones masivas; necesita análisis por ciclos | Ciclos de distintas longitudes y degeneraciones; no evidencia de caos |

Es una lectura cualitativa de las figuras, no una nueva clasificación mediante ajustes. Los paneles agregados no permiten reconstruir por sí solos todos los tamaños, monedas y tratamientos usados. Las etiquetas «integrable» y «caótica» de algunas leyendas no constituyen pruebas independientes. Las referencias COE de los SFF originales tampoco asignan la clase de simetría.

Se recalcularon cocientes restringidos de espaciamientos, sin unfolding y con cierre circular, a partir de datos guardados:

| Datos | Dimensión D | Muestras de moneda | Media de r |
|---|---:|---:|---:|
| oo, semilla 23, rectángulo de coordenadas 0..30 en cada eje | 3844 | 1 | 0.37500379 |
| CUE(4), Sinaí L=16, R=12 | 352 | 128 | 0.57800149 ± 0.00189436 |
| CUE(4), Sinaí L=24, R=18 | 736 | 64 | 0.58004355 ± 0.00226582 |

Los errores son errores estándar entre monedas, no entre espaciamientos. El valor rectangular pertenece a una realización, sin error de ensamble estimado. Los resultados de Sinaí coinciden exactamente con las medias guardadas. Poisson da 2 ln(2)-1 ≈ 0.38629; las referencias asintóticas ortogonal y unitaria son aproximadamente 0.531 y 0.600. Las aproximaciones de matrices pequeñas dan valores ligeramente distintos y no deben confundirse con límites exactos.

Los SFF físicos guardados de Sinaí también presentan desviaciones de CUE mayores que los errores estándar. Por ejemplo, para D=736, en 0.6≤t/D≤1 se registra 0.70885±0.00747, frente a 0.80027 de la referencia CUE. Esto no invalida la repulsión local; impide afirmar convergencia universal con esos dos tamaños. El resultado depende además de distinguir SFF físico, SFF desplegado y contribución desconectada de la densidad media.

El ejemplo oo rectangular tiene 44 candidatos de borde de 3844 estados, usando dos capas y peso ≥0.6. Esa selección es exploratoria: su sensibilidad al ancho está documentada. La concentración en borde no prueba origen topológico ni explica por sí sola toda la estadística del espectro.

## 2. Por qué la moneda puede cambiar un rectángulo

La implementación usa posición ⊗ moneda, con orden interno {U,D,R,L}, y

\[
 U(C)=S\mathcal C,\qquad \mathcal C=I_N\otimes C.
\]

La moneda es homogénea y permanece fija en el tiempo. Cada paso mezcla direcciones también en el interior. Por ello este operador no tiene garantizada la separabilidad del Hamiltoniano escalar de una partícula libre en un rectángulo.

Para C'=VCV† y W=I⊗V:

\[
 U(C')=SW\mathcal CW^\dagger,\qquad
 WU(C)W^\dagger=WS\mathcal CW^\dagger.
\]

Si [S,W]≠0, la conjugación de la moneda no es ese cambio de base del operador completo. No se garantiza igualdad de sus espectros. Esto explica por qué conservar los eigenvalores de C permite cambiar físicamente la caminata.

Como comprobación, se usó una única moneda diagonal y su conjugada Haar en un rectángulo de 7×5 sitios: el espectro de las monedas coincide con error <5×10^-16, pero |Tr U²| cambia de 0 a 24.81453. Esta comprobación demuestra que los operadores completos no son isoespectrales; no constituye una prueba estadística de caos.

Las familias del código son p=P, gpg=GPG†, oo=O1⊗O2, uoou=V(oo)V†, ubu=VBV† y upu=VPV†, junto a o~COE(4), u~CUE(4) y B fijo. Llamar por separado a dos familias con la misma semilla no asegura reutilizar la misma moneda base: las extracciones aleatorias previas pueden diferir. Las comparaciones controladas deben guardar C0 y construir explícitamente su conjugada.

Una moneda 4×4 extraída de CUE no convierte por definición a U, de dimensión 4N, en una matriz CUE. Tampoco una moneda producto demuestra que U sea producto de dos caminatas espaciales: el desplazamiento cardinal debe factorizarse de manera compatible.

## 3. Caso resoluble: moneda diagonal

La reflexión implementada conserva el eje: una dirección bloqueada se invierte en el mismo sitio. Con C=P diagonal, el caminante no cambia de eje en el interior. U es una permutación con fases, descompuesta en ciclos independientes sobre cada segmento horizontal y vertical del dominio.

En un rectángulo de nx×ny sitios, un ciclo vertical tiene 2ny estados y acumula fase ny(θU+θD). Los eigenvalores son

\[
 z^{(v)}_m=\exp i\left[\frac{\theta_U+\theta_D}{2}+\frac{\pi m}{n_y}\right],
 \quad m=0,\ldots,2n_y-1,
\]

cada uno con multiplicidad nx. Horizontalmente se obtiene la misma fórmula con nx y θR+θL, y multiplicidad ny. La cuasienergía del proyecto es ε=-Arg(z). Para fases genéricas, sin coincidencias adicionales entre ambas familias, hay 2nx+2ny eigenvalores distintos en dimensión 4nxny; la fracción de espaciamientos nulos es 1-1/(2nx)-1/(2ny). La fórmula se verificó en 7×5 sitios con error máximo de fase 2.9×10^-15.

La descomposición por ciclos sigue existiendo en el Sinaí discretizado; cambian las longitudes y multiplicidades. La geometría por sí sola no genera mezcla entre ciclos cuando la moneda es diagonal.

Por eso pModif, que excluye el primer bin (96.74% en rectángulo y 49.61% en Sinaí según las figuras), es una distribución condicionada y no la estadística del espectro completo. El primer bin no equivale necesariamente sólo a degeneraciones exactas. Un ajuste de su remanente no establece caos.

## 4. Una simetría antiunitaria explícita en el rectángulo

Sea R la inversión de posición (x,y)↦(Lx-x,Ly-y), sin permutar moneda. Para el shift reflectivo de este proyecto se cumple RSR=S†. S es real. Si C=Cᵀ es unitaria, el operador antiunitario

\[
 \Theta=\mathcal C^\dagger R\mathsf K
\]

(\mathsf K es conjugación compleja en la base física) satisface

\[
 \Theta^2=I,\qquad \Theta U\Theta^{-1}=U^\dagger.
\]

En efecto, R conmuta con la moneda homogénea, y C*=C† para una matriz simétrica unitaria. Así,

\[
 \mathcal C^\dagger R(S\mathcal C)^*R\mathcal C
 =\mathcal C^\dagger S^\dagger\mathcal C^*\mathcal C
 =U^\dagger.
\]

La comprobación numérica sobre una moneda simétrica aleatoria da residuos de Frobenius de aproximadamente 7×10^-15 para ambas identidades. Es una simetría construida con operaciones físicas del modelo, no una conjugación definida artificialmente a partir de eigenvectores de U.

Esto se aplica a p, gpg, oo y o en el rectángulo. Si además se alcanza un régimen universal dentro de sectores apropiados, es compatible con la clase ortogonal. No demuestra caos. El dominio de un octavo de Sinaí no tiene esa inversión espacial, de modo que esta construcción particular no se traslada: se deben buscar otras simetrías antes de asignar clase unitaria. El nombre COE de la moneda no basta.

## 5. Conjetura y límites

La hipótesis principal es que las monedas especiales preservan estructuras dinámicas compatibles con propagación y reflexión, mientras que orientaciones genéricas hibridan modos antes desacoplados. La geometría de Sinaí puede romper parte de esas estructuras. Queda por identificar los operadores conservados o una descomposición constructiva para oo, gpg y b; sus histogramas no bastan para afirmar integrabilidad exacta.

Un criterio de trabajo para universalidad espectral sería: dentro de cada sector físico irreducible, mezcla coherente de muchos modos antes del tiempo de Heisenberg, sin localización dominante ni descomposiciones adicionales, con correlaciones que se aproximen al ensamble de la simetría correcta al crecer el tamaño. No se presenta como un teorema para esta caminata.

La matriz M_ab=|U_ab|² permite estudiar una dinámica desfasada clásica: conectividad, clases invariantes, periodicidad y relajación. La relación entre esa mezcla y universalidad tiene precedentes rigurosos en ciertas familias de grafos cuánticos, pero sus hipótesis no se transfieren automáticamente a una retícula homogénea. M pierde las fases de interferencia. En 2D, una escala difusiva proporcional a L² puede competir con D∝L²; aumentar el tamaño no asegura por sí mismo una separación creciente de escalas.

Ni una entropía moneda-posición cercana a ln4 ni un IPR pequeño son diagnósticos suficientes. Las figuras con estados inicialmente deslocalizados ya muestran poca separación entre familias espectralmente distintas. Para comparar con estados aleatorios, la referencia debe corresponder al observable: para un vector Haar complejo en C^N⊗C^4, E[IPR espacial]=5/(4N+1), mientras E[IPR total]=2/(4N+1). Las líneas 2/N y 3/N no son automáticamente referencias apropiadas del IPR espacial con cuatro componentes internas.

## 6. Pruebas prioritarias y predicciones

**A. Conjugación isoespectral que conserve la simetría antiunitaria.** Fijar una realización C0 de oo o gpg, elegir A real antisimétrica, Oλ=exp(λA) y Cλ=Oλ C0 Oλᵀ. Conservar el mismo rectángulo y las mismas matrices durante el barrido. Se conservan eigenvalores de moneda, simetría Cλ=Cλᵀ y la reversión temporal anterior. Si aparece repulsión ortogonal y se abren cruces evitados, el espectro de moneda y la ruptura de esa reversión temporal quedan descartados como causas únicas. Repetir con varias C0 y A. Comparar luego con conjugaciones unitarias genéricas para investigar por separado el cambio de clase.

**B. Barrido de acoplamiento entre ejes ya implementado.** COECoinInterpolation usa Cλ=exp[-i Kλ], con Kλ=[KV, λA; λAᵀ, KH], K real simétrica. En λ=0 se conservan líneas individuales; no se espera necesariamente Poisson en la superposición degenerada. Registrar además de la media de r: ZeroSpacingCount, UndefinedRatioCount, dimensiones de bloques, P(r), P(s) y eigenfases. El script COEInterpolation-Barrido.wl actualmente devuelve sólo {λ,media r}: no retiene esos contadores en el resultado final. No se ejecutaron ni consultaron trabajos remotos en esta revisión.

El barrido propuesto debe repetir semillas y tamaños a razón de aspecto fija. En el rectángulo esta interpolación mantiene la simetría antiunitaria demostrada; cambia acoplamiento y también, en general, los eigenvalores de la moneda. Por eso complementa, pero no sustituye, la prueba A.

**C. Separar simetrías antes de interpretar Poisson.** Construir reflexiones y permutaciones de moneda en la base física y medir ||[U,Q]||F/||U||F. Separar sólo simetrías verificadas. Comparar el espectro mezclado con cada bloque. Si los bloques ya muestran repulsión, el aparente comportamiento regular era una superposición de sectores. Buscar también integrales estructuradas de complejidad controlada; el conmutante completo de una matriz finita incluye funciones de U y no diagnostica integrabilidad.

**D. Cambiar únicamente las fronteras.** Usar exactamente la misma moneda en rectángulo reflectivo, cilindro y toro periódico. En el toro homogéneo se conservan ambos momentos, y U se descompone en bloques U(kx,ky)=S(kx,ky)C de dimensión cuatro. Esta descomposición es un control exacto contra «una moneda genérica siempre produce caos». En el cilindro queda un momento conservado. Evaluar los bloques y no interpretar sus superposiciones como un único ensamble universal.

**E. Distinguir transporte de interferencia.** Comparar C con D1 C D2 para fases diagonales: |C_ab|² y por tanto M permanecen idénticos. Si las estadísticas cambian, las probabilidades de transición no bastan. Excluir transformaciones que sean un simple gauge del operador completo; controlar la clase antiunitaria, pues algunas fases pueden cambiarla. Comparar la escala de relajación de M y la de correlaciones cuánticas, sin tratarlas como iguales por definición.

**F. Escalamiento y estados de borde.** Usar al menos cuatro tamaños con razón de aspecto fija, varias monedas independientes y ventanas de cuasienergía con densidad suave. Seguir el peso de borde, IPR de eigenestados, P(r), P(s) y SFF. Estados extendidos en área deberían mostrar IPR espacial de orden L^-2; estados extendidos sólo por borde, L^-1; localizados en una región fija, orden uno. Verificar esos exponentes, no clasificarlos con un único umbral. No eliminar eigenvalores aislados para mejorar un ajuste: reportar el espectro completo y selecciones físicas definidas previamente.

Para SFF distinguir K(t)=E|Tr U^t|²/D del conectado [E|Tr U^t|²-|E Tr U^t|²]/D y del observable tras unfolding. Comparar sólo después del régimen de tiempos cortos no universal, usando la dimensión de cada sector. El plateau aislado tampoco prueba caos.

Una implementación inicial razonable es ejecutar A y C primero, aprovechar B después y emplear D como control. Se debe conservar la moneda fija en cada realización: renovarla en cada paso define otro problema, sin un único U cuyo espectro se está estudiando.

## Fuentes principales

- `../../main.pdf`, figuras 3–6 y secciones de IPR y entrelazamiento.
- `../../presentacionFrancois/presentacion_breve.pdf`, diapositivas 5–23.
- `QWProgramming/QWMisc.wl`, RandomMatrix, COECoinInterpolation, QWPr, QWPs y QWSFF.
- `QWProgramming/JA_libs/QuantumWalks/Billiards/Common.wl`, BuildShiftOperators4State.
- `QWProgramming/analisis/estados_borde/`, CSV y resumen de la realización oo.
- `QWProgramming/analisis/sff_cue_2d/`, fases NPZ, resúmenes y diagnóstico de unfolding.
- Atas et al., distribución de razones de espaciamientos: https://arxiv.org/abs/1212.5611
- Gnutzmann y Altland, universalidad y dinámica clásica en grafos cuánticos: https://arxiv.org/abs/nlin/0402029
- Omanakuttan y Lakshminarayan, monedas con límite clásico caótico y dependencia del régimen moneda/caminante: https://arxiv.org/abs/2008.11318. Es un antecedente conceptual, no una demostración para monedas fijas de dimensión cuatro.
