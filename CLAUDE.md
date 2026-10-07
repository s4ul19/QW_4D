# QW_4D: caminatas cuánticas con moneda 4D en billares

Tesis de licenciatura de Saúl Nájera (USAC, Física Aplicada). Asesor: JA de León (IF-UNAM).
Cotutores: Carlos Pineda (líder; investiga, escribe y corrige) y Rodolfo Samayoa.
Entrega de la tesis ~noviembre 2026; después, un artículo. Repo: github.com/s4ul19/QW_4D.
Este archivo es para Carlos.

## Pregunta científica
DTQW 2D, U = S·C, C = 𝟙ₚ ⊗ M, M ∈ U(4), moneda homogénea. Billares: rectángulo
(integrable) y Sinaí (caótico). ¿Basta la geometría de la frontera para decidir caos o
integrabilidad? Antecedente: Alonso-Lobo 2025 (moneda qubit).
**Objetivo actual:** clasificar la estadística espectral, moneda por moneda y geometría
por geometría: dónde hay caos y en qué clase (Poisson, COE, CUE).
Hipótesis de trabajo (no probada): la compatibilidad moneda/shift con reflexión controla
la estadística (ver `Chaos_Results/output/analisis_caos/analisis_y_pruebas.md`).

## Convenciones (fuente: el código)
- Tensor: posición ⊗ moneda. Índice = 4(sitio−1) + c.
- Orden de la moneda en el código: {U, D, R, L} = {y+1, y−1, x+1, x−1}. Algunas notas usan
  {L, U, R, D}. Al escribir una moneda fija (p. ej. `b`) o una condición matricial,
  decir qué orden se usa.
- Reflexión: si x+δ_c ∉ Ω, S|x,c⟩ = |x, c̄⟩ (se queda y se invierte la dirección).
- Cuasienergía: U ψ = e^{−iε} ψ, ε = −arg λ ∈ [−π, π].
- Rectángulo: `GenerateRectangleBasis[a,b]` incluye de 0 a a, o sea (a+1)(b+1) sitios.
- Sinaí: `GenerateSinaiBasis[L,R]` = 1/8 del cuadrado: 0 ≤ y ≤ x ≤ L, x²+y² ≥ R².
  Es el Sinaí del proyecto. Cuidado: `SFF_CUE/` usa otros dominios (cuadrado completo).
- Monedas (`RandomMatrix` en `QWProgramming/QWMisc.wl`):
  `u` CUE(4); `o` COE(4); `oo` COE(2)⊗COE(2); `p` diagonal de fases aleatorias;
  `b` matriz fija; `gpg` = G·p·G† con G = Grover; `uoou`, `ubu`, `upu` = V·X·V† con V ∈ CUE(4).

## Estructura (todo activo)
- `AnteProyecto/`: protocolo de tesis.
- `Chaos_Results/`: notas principales (revtex), figuras en `Imgs/`, presentación
  `presentacionFrancois/`, análisis en `output/`.
- `SFF_CUE/`, `QWProgramming/analisis/sff_cue_2d/`: SFF con moneda CUE(4), parte analítica y Python.
- `problema_unidimensional/`: modelo 1D con paredes, espectro exacto.
- `4DAnalysis/`, `IPR_Desv_Results/`, `NBs/`: notas y notebooks anteriores.
- `QWProgramming/`: código del proyecto (Mathematica). `QWMisc.wl` encima de JA_libs
  (`QuantumWalks`, `QMB`; clon aparte, en .gitignore). Tests: `wolframscript -file tests/run.wls`.
  Notebook principal: `FunctionsTester.nb`.
- Cálculos grandes en mazinger: ver `QWProgramming/MazingerTests/Recursos-Mazinger.md`
  (memoria ≈ 0.5 GiB + 96 N² bytes por diagonalización densa).

## Reglas
- No modificar código (QWProgramming, JA_libs, scripts) salvo que Carlos lo pida
  expresamente. Para cálculos exploratorios, escribir scripts en el scratchpad.
- No editar ningún .tex salvo que se pida. Las notas dentro de un .tex van como `\cpnote{}`
  o `\clnote{}` (Claude). Revisar que la macro exista: `fixme` no es compatible con revtex.
- No hacer commits. Los hace Carlos.
- La implementación de referencia es QuantumWalks/QWMisc. Si se reimplementa en Python,
  replicar exactamente la base y la reflexión del código, y decirlo.
- En análisis: separar lo derivado de lo supuesto ([supuesto], [estimado]). No asignar clase
  de simetría por la etiqueta "integrable/caótica" de una figura. Indicar si un SFF/P(s)
  es con o sin unfolding y cuál es D (niveles realmente usados).
