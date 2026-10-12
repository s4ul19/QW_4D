<< TheoreticalRMT`

n = 200;        (* tamano de las matrices *)
reals = 20000;  (* matrices por ensamble; la figura del texto usa 200000 (~2.5 min en 64 nucleos) *)
w = 0.1;        (* ancho de los bins *)

(* E|H_ij|^2 = 1/2 fuera de la diagonal en GOE y GUE: semicirculo de radio r = Sqrt[2 n] *)
r = Sqrt[2. n];
nCount[x_] := n (1/2 + x Sqrt[r^2 - x^2]/(Pi r^2) + ArcSin[x/r]/Pi);

matrix[1] := With[{a = RandomVariate[NormalDistribution[], {n, n}]}, (a + Transpose[a])/2];
matrix[2] := With[{a = RandomVariate[NormalDistribution[0, 1/Sqrt[2.]], {n, n, 2}] . {1, I}},
   (a + ConjugateTranspose[a])/2];

(* espaciamientos desplegados de la mitad central del espectro *)
spacings[beta_] := Differences[nCount /@ Sort[Eigenvalues[matrix[beta]]][[n/4 ;; 3 n/4]]];

s[1] = Flatten[ParallelTable[spacings[1], {reals}]];
s[2] = Flatten[ParallelTable[spacings[2], {reals}]];

histPlot[beta_] := Show[
   Histogram[s[beta], {0, 4, w}, "PDF", ChartStyle -> LightGray],
   Plot[{ExactPs[beta, x], P[x, beta]}, {x, 0, 3.6}, PlotStyle -> {{Thick, Blue}, {Thick, Dashed, Red}}],
   Frame -> True, FrameLabel -> {None, "P(s)"}, PlotRange -> {{0, 3.6}, All},
   PlotLabel -> Row[{If[beta == 1, "GOE, ", "GUE, "], Length[s[beta]], " espaciamientos"}]];

(* histograma menos el promedio de P en cada bin, con error de Poisson *)
diffPlot[beta_] := Module[{m = Length[s[beta]], c = BinCounts[s[beta], {0, 4, w}], x0 = Range[w/2, 4 - w/2, w]},
   Show[
    Plot[ExactPs[beta, x] - P[x, beta], {x, 0, 3.6}, PlotStyle -> {Thick, Blue}],
    ListPlot[Transpose[{x0, (Around[#, Sqrt[#]] & /@ c)/(m w) -
        (NIntegrate[P[x, beta], {x, # - w/2, # + w/2}]/w & /@ x0)}], PlotStyle -> Black],
    Plot[0, {x, 0, 3.6}, PlotStyle -> {Thick, Dashed, Red}],
    Frame -> True, FrameLabel -> {"s", "P(s) \[Minus] P_Wigner(s)"}, PlotRange -> {{0, 3.6}, All}]];

fig = Labeled[GraphicsGrid[{{histPlot[1], histPlot[2]}, {diffPlot[1], diffPlot[2]}}, ImageSize -> 900],
  SwatchLegend[{LightGray, Blue, Red, Black},
   {"histograma", "ExactPs", "P (Wigner surmise)", "histograma \[Minus] P"}, LegendLayout -> "Row"], Bottom]
