(* Internal boundary implementation, evaluated only in QWMisc`Private`. *)
(* Analisis de frontera compartido por QWMisc.wl y el cargador anterior. *)


Options[AnalyzeBoundaryEigenstates] = {
  CoinDimension -> 4, "CoinDimension" -> Automatic,
  BoundaryWidth -> 2, "BoundaryWidth" -> Automatic,
  CornerWidth -> 3, "CornerWidth" -> Automatic,
  BoundaryThreshold -> 0.6, "BoundaryThreshold" -> Automatic
};

AnalyzeBoundaryEigenstates::grid = "Supply distinct integer coordinates with matching Coords and Dimension.";
AnalyzeBoundaryEigenstates::opts = "CoinDimension and widths must be positive integers; BoundaryThreshold must be between 0 and 1.";
AnalyzeBoundaryEigenstates::states = "Supply matching finite nonzero eigenvalues and numeric eigenvectors of length CoinDimension times Dimension.";

AnalyzeBoundaryEigenstates[grid_Association, eigenvalues_List,
    eigenvectors_List, opts : OptionsPattern[]] := Module[
  {coords, n, coinDim, width, cornerWidth, threshold, xmin, xmax,
   ymin, ymax, dx, dy, distances, cornerDistances, boundaryIndices,
   cornerIndices, energies, rows, probabilities, amplitudes, scale,
   candidates, isRectangle, neighbors,
   frontier, nextFrontier, layer, boundarySites},

  coinDim = qwOptionValue[{opts}, CoinDimension, {"CoinDimension"}, OptionValue[CoinDimension]];
  width = qwOptionValue[{opts}, BoundaryWidth, {"BoundaryWidth"}, OptionValue[BoundaryWidth]];
  cornerWidth = qwOptionValue[{opts}, CornerWidth, {"CornerWidth"}, OptionValue[CornerWidth]];
  threshold = qwOptionValue[{opts}, BoundaryThreshold, {"BoundaryThreshold"}, OptionValue[BoundaryThreshold]];
  If[!And @@ (IntegerQ[#] && # > 0 & /@ {coinDim, width, cornerWidth}) ||
     !NumericQ[threshold] || !TrueQ[0 <= threshold <= 1],
    Message[AnalyzeBoundaryEigenstates::opts]; Return[$Failed]];

  coords = Lookup[grid, "Coords", {}];
  n = Lookup[grid, "Dimension", 0];
  If[!IntegerQ[n] || n < 1 || Length[coords] != n ||
     !MatrixQ[coords, IntegerQ] || Dimensions[coords] != {n, 2} ||
     Length[DeleteDuplicates[coords]] != n,
    Message[AnalyzeBoundaryEigenstates::grid]; Return[$Failed]];
  {xmin, xmax} = MinMax[coords[[All, 1]]];
  {ymin, ymax} = MinMax[coords[[All, 2]]];
  isRectangle = n == (xmax - xmin + 1) (ymax - ymin + 1);

  If[Length[eigenvalues] == 0 || Length[eigenvalues] != Length[eigenvectors] ||
     !VectorQ[eigenvalues, NumberQ] || AnyTrue[eigenvalues, TrueQ[# == 0] &] ||
     !AllTrue[eigenvectors, Function[v,
       VectorQ[v, NumberQ] && Length[v] == coinDim n &&
       TrueQ[Max[Abs[v]] > 0]]],
    Message[AnalyzeBoundaryEigenstates::states]; Return[$Failed]];

  If[isRectangle,
    (* En un rectangulo esta formula coincide con la distancia en el grafo. *)
    dx = Min[#[[1]] - xmin, xmax - #[[1]]] & /@ coords;
    dy = Min[#[[2]] - ymin, ymax - #[[2]]] & /@ coords;
    distances = MapThread[Min, {dx, dy}];
    cornerDistances = MapThread[Max, {dx, dy}];
    cornerIndices = Flatten[Position[cornerDistances, d_ /; d < cornerWidth]];
    boundarySites = Flatten[Position[distances, 0]],

    (* La misma vecindad utilizada por el shift de cuatro estados.
       Se reconstruye el mapping para seguir exactamente el orden de Coords. *)
    neighbors = qwNeighbors[coords];
    boundarySites = Flatten[Position[Length /@ neighbors, degree_ /; degree < 4]];
    distances = ConstantArray[Infinity, n];
    distances[[boundarySites]] = ConstantArray[0, Length[boundarySites]];
    frontier = boundarySites;
    layer = 0;
    (* Busqueda por capas, iniciada en toda la frontera, tambien en agujeros. *)
    While[frontier =!= {},
      nextFrontier = DeleteDuplicates[Flatten[neighbors[[frontier]]]];
      nextFrontier = Select[nextFrontier, distances[[#]] === Infinity &];
      If[nextFrontier === {}, Break[]];
      layer++;
      distances[[nextFrontier]] = ConstantArray[layer, Length[nextFrontier]];
      frontier = nextFrontier
    ];
    (* Las esquinas de la caja envolvente no definen las de una geometria general. *)
    cornerIndices = {}
  ];
  (* Width = 2 incluye las capas de distancia 0 y 1. *)
  boundaryIndices = Flatten[Position[distances, d_ /; d < width]];
  energies = -Arg[N[eigenvalues]];

  rows = Table[
    amplitudes = Normal[eigenvectors[[i]]];
    scale = Max[Abs[amplitudes]];
    probabilities = Total[Partition[Abs[amplitudes/scale]^2, coinDim], {2}];
    probabilities = probabilities/Total[probabilities];
    <|"Index" -> i, "Energy" -> energies[[i]],
      "BoundaryWeight" -> Total[probabilities[[boundaryIndices]]],
      "CornerWeight" -> If[isRectangle, Total[probabilities[[cornerIndices]]],
        Missing["NotApplicable"]],
      "IPR" -> Total[probabilities^2],
      "MeanBoundaryDistance" -> probabilities . distances|>,
    {i, Length[eigenvalues]}];
  rows = SortBy[rows, #["Energy"] &];
  candidates = Select[rows, #["BoundaryWeight"] >= threshold &];

  <|"Data" -> rows, "Candidates" -> candidates,
    "CandidateIndices" -> Lookup[candidates, "Index", {}],
    "CandidateEnergies" -> Lookup[candidates, "Energy", {}],
    "BoundaryIndices" -> boundaryIndices, "CornerIndices" -> cornerIndices,
    "BoundarySiteIndices" -> boundarySites,
    "BoundaryLayerDistances" -> distances,
    "BoundaryDefinition" -> "MissingCardinalNeighbor",
    "BoundaryDistanceMetric" -> "GraphSteps",
    "RectangleGeometry" -> isRectangle,
    "BoundaryWidth" -> width, "CornerWidth" -> cornerWidth,
    "BoundaryThreshold" -> threshold,
    "UniformBoundaryWeight" -> N[Length[boundaryIndices]/n],
    "UniformCornerWeight" -> If[isRectangle, N[Length[cornerIndices]/n],
      Missing["NotApplicable"]]|>
];

PlotBoundarySpectrum[analysis_Association] := Module[{all, selected},
  all = {#["Energy"], #["BoundaryWeight"]} & /@ analysis["Data"];
  selected = {#["Energy"], #["BoundaryWeight"]} & /@ analysis["Candidates"];
  ListPlot[{all, selected}, Joined -> False, Frame -> True, Axes -> False,
    PlotStyle -> {Directive[Gray, PointSize[0.003]],
      Directive[Red, PointSize[0.007]]},
    PlotLegends -> {"All states", "Boundary candidates"},
    FrameLabel -> {"Quasienergy epsilon", "Boundary probability"},
    GridLines -> {None, {analysis["UniformBoundaryWeight"],
      analysis["BoundaryThreshold"]}},
    PlotRange -> {{-Pi, Pi}, {0, 1}}, ImageSize -> Large]
];
