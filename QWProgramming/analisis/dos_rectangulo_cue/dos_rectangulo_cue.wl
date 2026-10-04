(* Densidad espectral del caminante 2D (moneda 4x4) en el billar rectangular,
   con moneda homogenea tomada de CUE(4).
   Uso: wolframscript -file dos_rectangulo_cue.wl  (desde esta carpeta) *)

raiz = DirectoryName[DirectoryName[DirectoryName[$InputFileName]]];
Get[FileNameJoin[{raiz, "JA_libs", "QMB", "Kernel", "init.m"}]];
Get[FileNameJoin[{raiz, "JA_libs", "QuantumWalks", "Kernel", "init.m"}]];
Get[FileNameJoin[{raiz, "QWMisc.wl"}]];
SetDirectory[DirectoryName[$InputFileName]];

{Lx, Ly} = {10, 6};           (* sitios: (Lx+1)(Ly+1) *)
nMonedas = 40;
nBins = 32;
SeedRandom[20261001];

grid = GenerateRectangleBasis[Lx, Ly];
dimTotal = 4 grid["Dimension"];
monedas = RandomVariate[CircularUnitaryMatrixDistribution[4], nMonedas];
fases = QWEigenphases[grid, #] & /@ monedas;   (* en (-Pi, Pi] *)

bordes = Subdivide[-Pi, Pi, nBins];
centros = MovingAverage[bordes, 2];
densidad[f_] := BinCounts[f, {bordes}]/(Length[f] (2 Pi/nBins));

(* Densidad de bandas del bulto: U(k) = S(k).C, S(k) = diag(e^-iky, e^iky, e^-ikx, e^ikx) *)
densidadBulto[c_, nk_: 60] := Module[{ks, f},
  ks = Most[Subdivide[-Pi, Pi, nk]];
  f = Flatten@Table[Arg[Eigenvalues[
        DiagonalMatrix[{Exp[-I ky], Exp[I ky], Exp[-I kx], Exp[I kx]}] . c]],
      {kx, ks}, {ky, ks}];
  densidad[f]];

(* Realizaciones individuales *)
ejemplos = Table[<|"n" -> n, "billar" -> densidad[fases[[n]]],
    "bulto" -> densidadBulto[monedas[[n]]]|>, {n, 3}];

(* Promedio sobre el ensamble *)
dProm = Mean[densidad /@ fases];
dErr = StandardDeviation[densidad /@ fases]/Sqrt[nMonedas];
chi2 = Total[((dProm - 1/(2 Pi))/dErr)^2];

Print["Sitios: ", grid["Dimension"], "   dim U: ", dimTotal, "   monedas: ", nMonedas];
Print["Promedio: max|rho - 1/2pi|/(1/2pi) = ", Max[Abs[dProm - 1/(2 Pi)]] 2 Pi // N];
Print["chi2 contra 1/2pi = ", N[chi2], " con ", nBins, " bins"];
Do[Print["Moneda ", e["n"], ": distancia L1 billar-bulto = ",
   N[Total[Abs[e["billar"] - e["bulto"]]] 2 Pi/nBins]], {e, ejemplos}];

escalon[d_] := Transpose[{bordes, Append[d, Last[d]]}];
estilo = {Frame -> True, Axes -> False, ImageSize -> 360,
   InterpolationOrder -> 0, PlotRange -> {{-Pi, Pi}, {0, Automatic}},
   FrameTicks -> {{Automatic, None}, {{-Pi, -Pi/2, 0, Pi/2, Pi}, None}}};
panelEjemplo[e_] := ListLinePlot[{escalon[e["billar"]], escalon[e["bulto"]]},
   Evaluate[estilo], PlotStyle -> {Black, {Red, Dashed}},
   FrameLabel -> {"\[Phi]", "\[Rho](\[Phi])"},
   PlotLabel -> "Moneda CUE #" <> ToString[e["n"]],
   PlotLegends -> If[e["n"] == 1, Placed[{"billar", "bulto"}, {Right, Top}], None]];
panelProm = Show[
   ListLinePlot[escalon[dProm], Evaluate[estilo], PlotStyle -> Black,
     FrameLabel -> {"\[Phi]", "\[LeftAngleBracket]\[Rho](\[Phi])\[RightAngleBracket]"},
     PlotLabel -> "Promedio, " <> ToString[nMonedas] <> " monedas",
     PlotRange -> {{-Pi, Pi}, {0, 0.3}}],
   Plot[1/(2 Pi), {x, -Pi, Pi}, PlotStyle -> {Red, Dashed}]];
fig = GraphicsGrid[{{panelEjemplo[ejemplos[[1]]], panelEjemplo[ejemplos[[2]]]},
    {panelEjemplo[ejemplos[[3]]], panelProm}}, ImageSize -> 760];
Export["dos_rectangulo_cue.png", fig, ImageResolution -> 150];
Export["dos_rectangulo_cue.svg", fig];

Export["fases.csv", Transpose[fases]];   (* columna n = moneda n *)
Export["densidad.csv", Prepend[Transpose[{centros, dProm, dErr,
     ejemplos[[1, "billar"]], ejemplos[[1, "bulto"]]}],
   {"phi", "rho_promedio", "error", "rho_moneda1", "rho_bulto_moneda1"}]];
