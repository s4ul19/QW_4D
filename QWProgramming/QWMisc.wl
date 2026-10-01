(* ::Package:: *)

(* ::Package:: *)
(**)


BeginPackage[
  "QuantumWalks`QWMisc`",
  {"QuantumWalks`", "QuantumWalks`Billiards`", "MaTeX`", "QMB`"}
];


<<ForScience`;

(* ========================================================================= *)
(* PUBLIC DEFINITIONS & USAGE MESSAGES                                       *)
(* ========================================================================= *)

Quiet[
  LocalizedState::usage = FormatUsage[
    "LocalizedState[GridData, Position, CoinState] yields a sparse vector representing \
    a highly localized state at ```Position``` with internal coin state ```CoinState```. \
    ```GridData``` must be a valid grid association."
  ];

  RandomDelocalizedState::usage = FormatUsage[
    "RandomDelocalizedState[spaceDim, coinDim, \"RandomSeed\" -> Automatic] returns \
    Flatten[KroneckerProduct[HaarRandomState[spaceDim], HaarRandomState[coinDim]]]. \
    The two Haar-random factors are independent. Set \"RandomSeed\" -> integer for \
    reproducible results without changing the session's random state."
  ];

 QWEigenphases::usage = FormatUsage[
    "QWEigenphases[GridData_,coin_] retorna las eigenfases del operador evoluci\[OAcute]n de la DTQW"
  ];

QWPs::usage = FormatUsage[
    "QWPs[eigenphases, opts] devuelve la gráfica de P(s) para las fases desplegadas con UnfoldCircular. Incluye el espaciamiento que cierra el círculo. ReturnData -> True devuelve una asociación con los espaciamientos y las barras del histograma (BinEdges y PDF)."
  ];

QWSFF::usage = FormatUsage[
    "QWSFF[eigenphases, tauMax:2, windowSize:Automatic, opts] devuelve la gráfica del SFF de las fases desplegadas con UnfoldCircular. El tiempo se escala como tau=t/N. ReturnData -> True devuelve una asociación con las series {tau, K(tau)} Raw, TimeAverage y RMT, además de WindowSize. PlotRange -> Automatic enfoca el promedio temporal y la curva RMT; PlotRange -> All muestra todos los picos crudos. Acepta PlotLabel y LabelStyle."
  ];

QWPr::usage = FormatUsage[
    "QWPr[eigenphases, opts] devuelve la gráfica de P(r) para cocientes restringidos de espaciamientos consecutivos de las fases originales en el círculo, incluido el espaciamiento de cierre. No requiere unfolding. ReturnData -> True devuelve una asociación con los cocientes y las barras del histograma (BinEdges y PDF)."
  ];

ReturnData::usage = "ReturnData -> True hace que QWPs, QWPr y QWSFF devuelvan datos numéricos en lugar de la gráfica. El valor predeterminado es False.";

QuantumWalks`QWMisc`EjecutarEnNodo::usage = "EjecutarEnNodo[nodo, cantidad, proceso, entradas, preparacion] aplica la funcion pura proceso a cada entrada en cantidad kernels temporales del nodo indicado de Mazinger. preparacion es una funcion pura sin argumentos que se ejecuta en cada kernel y debe devolver True; si se omite, no se requiere inicializacion. Los resultados regresan en el orden de entradas al kernel local. Los nodos admitidos son nodo1, nodo2, nodo3 y nodo4; la conexion usa el alias SSH robot.";

QWSpectralData::usage = FormatUsage[
    "QWSpectralData[GridData, coin] retorna DoS, P(s), SFF y P(r)."
  ];

QWDynamicsData::usage = FormatUsage[
    "QWPs[GridData_,coin_] retorna IPR y temporal Average Distribution."
  ];

EntropiaMoneda::usage = FormatUsage[
    "EntropiaMoneda[psi, dimEspacio] calcula -Tr[rhoMoneda Log[rhoMoneda]] para un estado puro con orden posición x moneda. Normaliza psi internamente, infiere la dimensión de la moneda como Length[psi]/dimEspacio y usa logaritmos naturales (nats)."
  ];

ExtraerRatiosR::usage = FormatUsage[
    "ExtraerRatiosR[fases] calcula los cocientes restringidos entre espaciamientos consecutivos."
  ];


  GaussianState::usage = FormatUsage[
    "GaussianState[GridData, Position, CoinState, Sigma] yields a dense state vector \
    representing a Gaussian wavepacket centered at ```Position``` with standard deviation \
    ```Sigma``` and internal coin state ```CoinState```."
  ];

  VisualizeWalkerState::usage = FormatUsage[
    "VisualizeWalkerState[GridData, StateVector, ScalingMap, ScaleUpperBound] is a compatibility wrapper for DiscreteProbabilityPlot with InputType -> State."
  ];

  QWAnimation::usage = FormatUsage[
    "QWAnimation[GridData, evolution, initialState, steps, opts] precomputes spatial probability frames and returns ListAnimate. FrameStride defaults to 1; the initial and final states are always included. Only the current state is retained during evolution. DiscreteProbabilityPlot and ListAnimate options are supported. The default PlotLabel displays the physical step t."
  ];

  ComputeSurvivalProbability::usage = FormatUsage[
    "ComputeSurvivalProbability[InitState, FinalState] computes the survival probability \
    (fidelity) between the initial and final state. \
    ComputeSurvivalProbability[InitState, AllStates] computes the survival probability \
    across an entire time-evolution matrix."
  ];

  ComputeSpatialIPR::usage = FormatUsage[
    "ComputeSpatialIPR[StateVector, CoinDim] returns the position-space IPR, Total[ComputeSpatialIPRDensity[StateVector, CoinDim]]. Coin probabilities are summed before squaring. The state is normalized internally; CoinDim defaults to 4."
  ];

  ComputeSpatialIPRDensity::usage = FormatUsage[
    "ComputeSpatialIPRDensity[StateVector, CoinDim] returns the local IPR density I_n(x,y) = P_n(x,y)^2, with P_n(x,y) = Sum[Abs[psi_alpha(x,y)]^2, alpha] for the internally normalized state. CoinDim defaults to 4. Consecutive CoinDim amplitudes belong to one site; the result follows GridData[\"Coords\"] ordering and can be passed to DiscreteProbabilityPlot. Its sum equals ComputeSpatialIPR. This position-space density is not the Husimi phase-space distribution."
  ];

  QuantumWalks`QWMisc`AnalyzeBoundaryEigenstates::usage = FormatUsage[
    "AnalyzeBoundaryEigenstates[grid, eigenvals, eigenvecs, opts] returns boundary weights, spatial IPR and candidate energies from corresponding eigenpairs. Supports finite integer-coordinate grids, including Rectangle and Sinai. BoundaryWidth defaults to 2 graph layers and BoundaryThreshold to 0.6. The string option CoinDimension defaults to 4. Energy is -Arg[eigenvalue], consistent with U psi = Exp[-I epsilon] psi. CornerWidth defaults to 3 and applies only to complete rectangles; corner metrics are Missing for other geometries. Original eigenvector indices are preserved."
  ];

  QuantumWalks`QWMisc`PlotBoundarySpectrum::usage = FormatUsage[
    "PlotBoundarySpectrum[analysis] plots boundary probability versus quasienergy from AnalyzeBoundaryEigenstates, highlighting the selected candidates and the uniform reference."
  ];

  QuantumWalks`QWMisc`EigenstateAtEnergy::usage = FormatUsage[
    "EigenstateAtEnergy[epsilon, eigenvals, eigenvecs, opts] returns the normalized eigenstate whose quasienergy -Arg[eigenvalue] is closest to the real target epsilon using circular angular distance. Returns Index, Energy, Distance, State and spatial IPR. Eigenvalues and eigenvectors must be supplied in matching order; no global spectrum variables are used. The string option CoinDimension defaults to 4. Ties return the first matching index."
  ];

  ComputeSpatialIPREvolution::usage = FormatUsage[
    "ComputeSpatialIPREvolution[evolution, initialState, steps, opts] returns {{0, IPR[0]}, ..., {steps, IPR[steps]}}. CoinDimension defaults to 4. Only the current state is retained during evolution; each IPR uses normalized spatial probabilities."
  ];

  ComputeEntanglementEntropyEvolution::usage = FormatUsage[
    "ComputeEntanglementEntropyEvolution[evolution, initialState, tmax, opts] returns {{0, S[0]}, ..., {tmax, S[tmax]}} for the pure state evolved by evolution. S is the position-coin entanglement entropy in nats, computed with EntropiaMoneda. CoinDimension defaults to 4; consecutive coin amplitudes belong to one position. Only the current state is retained during evolution."
  ];

  SpatialIPREvolutionPlot::usage = FormatUsage[
    "SpatialIPREvolutionPlot[evolution, initialState, steps, opts] computes and plots the spatial IPR from t = 0 through steps. CoinDimension defaults to 4. The default vertical scale is logarithmic, with a dashed uniform reference 1/N, where N is the number of spatial sites. Set the string option \"ShowUniformReference\" -> False to hide it. ListLinePlot options are supported, including ScalingFunctions -> None for a linear scale."
  ];
  
  LimitDistribution::usage = FormatUsage[
  "LimitDistribution[GridData, evolution, initialState, tmax, opts] computes the mean spatial probabilities while retaining only the current state and a running sum. Stride defaults to 1 and CoinDimension to 4. Samples are taken at t = 0, Stride, 2 Stride, ... <= tmax; the final time is included only when it is a multiple of Stride. A stride larger than 1 averages only the sampled times. LimitDistribution[TimeStatesList, CoinDim] preserves the interface for a stored list of states. The result is a finite-time average, not an assertion of asymptotic convergence."
 ];
 
 DiscreteProbabilityPlot::usage= FormatUsage[
 "DiscreteProbabilityPlot[GridData, data, opts] plots spatial probabilities on the physical grid. InputType defaults to Probabilities; use State for a state vector and CoinDimension for its coin dimension (default 4). ProbabilityScale supports Linear, Sqrt, CubeRoot, Squared and Log. ProbabilityRange is Automatic or {pmin, pmax} in original probability units. LogFloor defaults to 10^-12. The default ColorFunction is GrayLevel[1 - #] &, mapping low probabilities to white and high probabilities to black; supply a named color scheme or a custom function to override it. Standard ArrayPlot styling options are supported; the coordinate and color ranges are managed by this function."
 ];
, {FrontEndObject::notavail, First::normal}];

(* Error Messages *)
LocalizedState::invalidPos = "Position `1` is not present in the given grid.";
LocalizedState::invalidCoin = "Coin dimension must be 2 or 4.";
RandomDelocalizedState::dim = "Spatial and coin dimensions must be positive integers; received `1` and `2`.";
RandomDelocalizedState::seed = "RandomSeed must be Automatic or an integer; received `1`.";
QuantumWalks`QWMisc`EjecutarEnNodo::args = "Usa EjecutarEnNodo[nodo, cantidad, funcionPura, lista, preparacionOpcional]. El nodo debe ser nodo1, nodo2, nodo3 o nodo4; cantidad debe ser un entero positivo.";

(* ========================================================================= *)
(* PRIVATE DEFINITIONS                                                       *)
(* ========================================================================= *)

Begin["`Private`"];

(* --- Trabajos independientes en kernels temporales de Mazinger --- *)
QuantumWalks`QWMisc`EjecutarEnNodo[nodo_String, cantidad_Integer?Positive, proceso_Function,
    entradas_List, preparacion_Function : Function[True]] /;
    MemberQ[{"nodo1", "nodo2", "nodo3", "nodo4"}, nodo] :=
  (* Conserva los nombres completos durante el envio SSH, incluso cuando
     QuantumWalks ya esta cargado en el kernel local. *)
  Block[{$Context = "Global`", $ContextPath = {"System`"}},
  RemoteEvaluate["ssh://robot",
    Module[{kernels = {}, estado},
      WithCleanup[
        kernels = LaunchKernels[
          KernelConfiguration["ssh://" <> nodo, "KernelCount" -> cantidad]],
        If[! ListQ[kernels] || Length[kernels] =!= cantidad,
          Failure["KernelsNoDisponibles", <|
            "MessageTemplate" -> "No se pudieron abrir todos los kernels solicitados.",
            "Nodo" -> nodo, "Solicitados" -> cantidad,
            "Abiertos" -> If[ListQ[kernels], Length[kernels], 0]|>],
          estado = With[{iniciar = preparacion},
            ParallelEvaluate[iniciar[], kernels, DistributedContexts -> None]];
          If[! AllTrue[estado, TrueQ],
            Failure["PreparacionFallida", <|
              "MessageTemplate" -> "La preparacion no devolvio True en todos los kernels.",
              "Nodo" -> nodo, "EstadoPorKernel" -> estado|>],
            ParallelMap[proceso, entradas, Method -> "FinestGrained",
              DistributedContexts -> None]
          ]
        ],
        If[ListQ[kernels], CloseKernels[kernels]]
      ]
    ],
    IncludeDefinitions -> False
  ]];

QuantumWalks`QWMisc`EjecutarEnNodo[___] :=
  (Message[QuantumWalks`QWMisc`EjecutarEnNodo::args]; $Failed);

Options[RandomDelocalizedState] = {"RandomSeed" -> Automatic};

RandomDelocalizedState[spaceDim_, coinDim_, opts : OptionsPattern[]] := Module[
  {seed = OptionValue["RandomSeed"], makeState},
  If[!IntegerQ[spaceDim] || spaceDim <= 0 ||
     !IntegerQ[coinDim] || coinDim <= 0,
    Message[RandomDelocalizedState::dim, spaceDim, coinDim];
    Return[$Failed]
  ];
  If[seed =!= Automatic && !IntegerQ[seed],
    Message[RandomDelocalizedState::seed, seed];
    Return[$Failed]
  ];
  makeState[] := Flatten[KroneckerProduct[
    HaarRandomState[spaceDim], HaarRandomState[coinDim]]];
  If[seed === Automatic, makeState[],
    BlockRandom[SeedRandom[seed]; makeState[]]]
];

(* --- Localized State --- *)
LocalizedState[GridData_Association, Position_List, CoinState_List] := 
  Module[{PositionIndex, CoinDim, GridDim, StateRules, NormalizedCoin},
    
    PositionIndex = GridData["Mapping"][Position];
    
    If[MissingQ[PositionIndex], 
      Message[LocalizedState::invalidPos, Position];
      Return[$Failed]
    ];
    
    CoinDim = Length[CoinState];
    If[CoinDim != 2 && CoinDim != 4, 
      Message[LocalizedState::invalidCoin];
      Return[$Failed]
    ];
    
    GridDim = GridData["Dimension"];
    NormalizedCoin = Normalize[CoinState];
    
    (* Map local coin amplitudes to the global sparse vector space *)
    StateRules = MapIndexed[
      {CoinDim * (PositionIndex - 1) + First[#2]} -> #1 &, 
      NormalizedCoin
    ];
    
    SparseArray[StateRules, {CoinDim * GridDim}]
  ];


QWEigenphases[GridData_,coin_]:=Module[{dim,S,CoinOp,EvolOp,eigenphases},
dim=GridData["Dimension"];
S=BuildShiftOperators[GridData, CoinDimension->4];
CoinOp=KroneckerProduct[IdentityMatrix[dim,SparseArray],coin//SparseArray];
EvolOp=S . CoinOp;
eigenphases = Sort[Arg[Eigenvalues[Normal[EvolOp]]]]
];


QWPs::invalidPhases = "Se requiere una lista de al menos tres fases reales finitas.";
QWPs::badUnfold = "UnfoldCircular no produjo niveles circulares válidos; revisa las fases y el ajuste de Fourier.";
QWPr::invalidPhases = "Se requiere una lista de al menos tres fases reales finitas.";
QWPr::badSpacings = "Las fases deben ser distintas módulo 2 Pi para calcular los cocientes de espaciamientos circulares.";
QWSFF::invalidTau = "tauMax debe ser positivo y producir al menos un tiempo de muestreo.";
QWSFF::invalidWindow = "windowSize debe ser Automatic o un entero positivo.";

qwCircularUnfold[eigenphases_List] := Module[{data, levels},
  If[Length[eigenphases] < 3 || !VectorQ[eigenphases, NumericQ] ||
     !AllTrue[N[eigenphases], NumberQ[#] && Im[#] == 0 &],
    Message[QWPs::invalidPhases];
    Return[$Failed]
  ];
  data = UnfoldCircular[eigenphases];
  If[!AssociationQ[data] || !KeyExistsQ[data, "UnfoldedLevels"],
    Message[QWPs::badUnfold];
    Return[$Failed]
  ];
  levels = N[data["UnfoldedLevels"]];
  If[!VectorQ[levels, NumberQ] || Length[levels] != Length[eigenphases] ||
     !AllTrue[levels, Im[#] == 0 &],
    Message[QWPs::badUnfold];
    Return[$Failed]
  ];
  data
];

qwCircularSpacings[unfoldDat_Association] := Module[{angles, levels, spacings},
  angles = Mod[N[unfoldDat["OriginalLevels"]] + Pi, 2 Pi] - Pi;
  levels = N[unfoldDat["UnfoldedLevels"]][[Ordering[angles]]];
  spacings = Differences[Append[levels, First[levels] + Length[levels]]];
  If[!AllTrue[spacings, TrueQ[# > 0] &],
    Message[QWPs::badUnfold];
    Return[$Failed]
  ];
  spacings
];

qwCircularPhaseSpacings[eigenphases_List] := Module[{angles, spacings},
  If[Length[eigenphases] < 3 || !VectorQ[eigenphases, NumericQ] ||
     !AllTrue[N[eigenphases], NumberQ[#] && Im[#] == 0 &],
    Message[QWPr::invalidPhases];
    Return[$Failed]
  ];
  angles = Sort[Mod[N[eigenphases] + Pi, 2 Pi]];
  spacings = Differences[Append[angles, First[angles] + 2 Pi]];
  If[!AllTrue[spacings, TrueQ[# > 0] &],
    Message[QWPr::badSpacings];
    Return[$Failed]
  ];
  spacings
];

qwPsPlot[unfoldDat_Association, plotLabel_: None,
  labelStyle_: Automatic, returnData_: False] := Module[
  {spacings, edges, pdf, dataStyle, styles, histogram, curves, s},
  spacings = qwCircularSpacings[unfoldDat];
  If[spacings === $Failed, Return[$Failed]];
  If[TrueQ[returnData],
    {edges, pdf} = HistogramList[spacings, "FreedmanDiaconis", "PDF"];
    Return[<|"Spacings" -> spacings,
      "Histogram" -> <|"BinEdges" -> edges, "PDF" -> pdf|>|>]
  ];
  dataStyle = Directive[RGBColor[0.93, 0.63, 0.19], Opacity[0.85]];
  styles = {Directive[Black, Dashed, Thick],
    Directive[Red, Thick], Directive[Blue, Thick]};
  histogram = Histogram[spacings, "FreedmanDiaconis", "PDF",
    ChartStyle -> dataStyle];
  curves = Plot[
    Evaluate[LevelSpacingDistribution[s, #] & /@ {0, 1, 2}],
    {s, 0, 4}, PlotStyle -> styles
  ];
  Legended[
    Show[histogram, curves, Frame -> True, Axes -> False,
      FrameLabel -> {"s", "P(s)"}, PlotLabel -> plotLabel,
      LabelStyle -> labelStyle,
      PlotRange -> {{0, 4}, All},
      ImageSize -> Large],
    Placed[Column[{
      SwatchLegend[{dataStyle}, {"Datos"}],
      LineLegend[styles, {"Poisson", "GOE/COE", "GUE/CUE"}]
    }], Right]
  ]
];

qwPrPlot[eigenphases_List, plotLabel_: None,
  labelStyle_: Automatic, returnData_: False] := Module[
  {spacings, ratios, edges, pdf, histStyle, styles, histogram, curves, r},
  spacings = qwCircularPhaseSpacings[eigenphases];
  If[spacings === $Failed, Return[$Failed]];
  ratios = MapThread[Min[#1, #2]/Max[#1, #2] &,
    {spacings, RotateLeft[spacings]}];
  If[TrueQ[returnData],
    {edges, pdf} = HistogramList[ratios, "FreedmanDiaconis", "PDF"];
    Return[<|"Ratios" -> ratios,
      "Histogram" -> <|"BinEdges" -> edges, "PDF" -> pdf|>|>]
  ];
  histStyle = Directive[GrayLevel[0.7], Opacity[0.6]];
  styles = {Directive[Black, Dashed, Thick], Directive[Blue, Thick],
    Directive[Red, Thick], Directive[Purple, Thick]};
  histogram = Histogram[ratios, "FreedmanDiaconis", "PDF",
    ChartStyle -> histStyle];
  curves = Plot[
    {2/(1 + r)^2,
     (27/4) (r + r^2)/(1 + r + r^2)^(5/2),
     (81 Sqrt[3]/(2 Pi)) (r + r^2)^2/(1 + r + r^2)^4,
     (729 Sqrt[3]/(2 Pi)) (r + r^2)^4/(1 + r + r^2)^7},
    {r, 0, 1}, PlotStyle -> styles
  ];
  Legended[
    Show[histogram, curves, Frame -> True, Axes -> False,
      FrameLabel -> {"r restringido", "P(r)"}, PlotLabel -> plotLabel,
      LabelStyle -> labelStyle,
      PlotRange -> {{0, 1}, All}, ImageSize -> Large],
    Placed[Column[{
      SwatchLegend[{histStyle}, {"Datos"}],
      LineLegend[styles, {"Poisson", "GOE/COE", "GUE/CUE", "GSE/CSE"}]
    }], Right]
  ]
];

qwSffPlot[unfoldDat_Association, tauMax_, windowSize_,
  plotLabel_: None, labelStyle_: Automatic,
  requestedPlotRange_: Automatic, returnData_: False] := Module[
  {levels, dim, tau, kRaw, kAverage, kRMT, window, plotRange},
  levels = N[unfoldDat["UnfoldedLevels"]];
  dim = Length[levels];
  If[!NumericQ[tauMax] || !TrueQ[tauMax > 0],
    Message[QWSFF::invalidTau];
    Return[$Failed]
  ];
  If[Floor[tauMax dim] < 1,
    Message[QWSFF::invalidTau];
    Return[$Failed]
  ];
  If[windowSize =!= Automatic &&
     !(IntegerQ[windowSize] && windowSize > 0),
    Message[QWSFF::invalidWindow];
    Return[$Failed]
  ];
  tau = N[Range[Floor[tauMax dim]]/dim];
  kRaw = CompileSFF[levels, tau];
  window = If[windowSize === Automatic,
    Min[Length[tau], Max[5, Round[0.02 dim]]],
    Min[Length[tau], windowSize]
  ];
  kAverage = TimeAveragedSFF[tau, kRaw, window];
  kRMT = Transpose[{tau, SpectralFormFactorRMT[tau, 1]}];
  If[TrueQ[returnData],
    Return[<|"Raw" -> Transpose[{tau, kRaw}],
      "TimeAverage" -> kAverage, "RMT" -> kRMT,
      "WindowSize" -> window|>]
  ];
  plotRange = If[requestedPlotRange === Automatic,
    {{0, tauMax},
     {0, 1.15 Max[1, Max[kAverage[[All, 2]]], Max[kRMT[[All, 2]]]]}},
    requestedPlotRange
  ];
  ListPlot[
    {Transpose[{tau, kRaw}], kAverage, kRMT},
    Joined -> {False, True, True},
    PlotStyle -> {
      Directive[GrayLevel[0.6], Opacity[0.25], PointSize[0.003]],
      Directive[Blue, Thick], Directive[Black, Dashed, Thick]
    },
    PlotLegends -> {"SFF crudo", "promedio temporal", "COE (RMT)"},
    Frame -> True, Axes -> False,
    FrameLabel -> {"\[Tau] = t/N", "K(\[Tau])"},
    PlotLabel -> plotLabel,
    LabelStyle -> labelStyle,
    PlotRange -> plotRange, ImageSize -> Large
  ]
];

Options[QWPs] = {PlotLabel -> None, LabelStyle -> Automatic,
  ReturnData -> False};
Options[QWPr] = {PlotLabel -> None, LabelStyle -> Automatic,
  ReturnData -> False};
Options[QWSFF] = {PlotLabel -> None, LabelStyle -> Automatic,
  PlotRange -> Automatic, ReturnData -> False};

QWPs[eigenphases_List, opts: OptionsPattern[]] :=
  Module[{data = qwCircularUnfold[eigenphases]},
    If[data === $Failed, $Failed,
      qwPsPlot[data, OptionValue[PlotLabel], OptionValue[LabelStyle],
        OptionValue[ReturnData]]]
  ];

QWPr[eigenphases_List, opts: OptionsPattern[]] :=
  qwPrPlot[eigenphases, OptionValue[PlotLabel], OptionValue[LabelStyle],
    OptionValue[ReturnData]];

qwSffFromPhases[eigenphases_List, tauMax_, windowSize_,
  plotLabel_, labelStyle_, plotRange_, returnData_] :=
  Module[{data = qwCircularUnfold[eigenphases]},
    If[data === $Failed, $Failed,
      qwSffPlot[data, tauMax, windowSize, plotLabel, labelStyle,
        plotRange, returnData]]
  ];

QWSFF[eigenphases_List, opts: OptionsPattern[]] :=
  qwSffFromPhases[eigenphases, 2, Automatic,
    OptionValue[PlotLabel], OptionValue[LabelStyle],
    OptionValue[PlotRange], OptionValue[ReturnData]];

QWSFF[eigenphases_List, tauMax_ /;
    !MatchQ[tauMax, _Rule | _RuleDelayed], opts: OptionsPattern[]] :=
  qwSffFromPhases[eigenphases, tauMax, Automatic,
    OptionValue[PlotLabel], OptionValue[LabelStyle],
    OptionValue[PlotRange], OptionValue[ReturnData]];

QWSFF[eigenphases_List, tauMax_ /;
    !MatchQ[tauMax, _Rule | _RuleDelayed],
    windowSize_ /; !MatchQ[windowSize, _Rule | _RuleDelayed],
    opts: OptionsPattern[]] :=
  qwSffFromPhases[eigenphases, tauMax, windowSize,
    OptionValue[PlotLabel], OptionValue[LabelStyle],
    OptionValue[PlotRange], OptionValue[ReturnData]];

ExtraerRatiosR[fases_List] := Module[{spacings},
  spacings = Differences[Sort[fases]];
  spacings = Select[spacings, NumericQ[#] && Abs[#] > 10^-12 &];
  If[Length[spacings] < 2, Return[{}]];
  MapThread[Min[#1, #2]/Max[#1, #2] &,
    {Most[spacings], Rest[spacings]}]
];

QWSpectralData[GridData_, coin_] := Module[
  {eigenphases, unfoldDat, originalDOS, unfoldedDOS, phi},
  eigenphases = QWEigenphases[GridData, coin];
  unfoldDat = qwCircularUnfold[eigenphases];
  If[unfoldDat === $Failed, Return[$Failed]];
  If[qwCircularSpacings[unfoldDat] === $Failed, Return[$Failed]];
  originalDOS = Show[
    Histogram[Mod[eigenphases + Pi, 2 Pi] - Pi,
      {Subdivide[-Pi, Pi, unfoldDat["nBins"]]}, "PDF"],
    Plot[unfoldDat["SmoothPDF"][phi], {phi, -Pi, Pi},
      PlotStyle -> Red],
    Frame -> True, Axes -> False,
    FrameLabel -> {"\[Phi]", "DoS"}, ImageSize -> Large
  ];
  unfoldedDOS = Histogram[unfoldDat["UnfoldedLevels"], Automatic,
    "Count", Frame -> True,
    FrameLabel -> {"Nivel desplegado", "Conteo"}];
  {GraphicsRow[{originalDOS, unfoldedDOS}], qwPsPlot[unfoldDat],
    qwSffPlot[unfoldDat, 2, Automatic], qwPrPlot[eigenphases]}
];


EntropiaMoneda::dim = "dimEspacio (`1`) debe ser un entero positivo.";
EntropiaMoneda::state = "psi debe ser un vector numérico finito y no vacío cuya longitud sea múltiplo de dimEspacio (`1`).";
EntropiaMoneda::zero = "El vector cero no define un estado puro normalizado.";

EntropiaMoneda[psi_, dimEspacio_] := Module[
  {amplitudes, escala, matrizBipartita, valoresSchmidt, probabilidades},
  If[!IntegerQ[dimEspacio] || dimEspacio <= 0,
    Message[EntropiaMoneda::dim, dimEspacio]; Return[$Failed]];
  If[!VectorQ[psi, NumericQ] || Length[psi] == 0 ||
      Mod[Length[psi], dimEspacio] != 0 ||
      !FreeQ[psi, _DirectedInfinity | Indeterminate | ComplexInfinity],
    Message[EntropiaMoneda::state, dimEspacio]; Return[$Failed]];

  amplitudes = Normal[psi];
  escala = Max[Abs[amplitudes]];
  If[TrueQ[escala == 0], Message[EntropiaMoneda::zero]; Return[$Failed]];

  (* En psi = Sum_{x,c} M_{x,c} |x> |c>, los cuadrados de los
     valores singulares de M son los autovalores de ambas reducciones. *)
  matrizBipartita = ArrayReshape[
    N[amplitudes/escala], {dimEspacio, Length[amplitudes]/dimEspacio}];
  valoresSchmidt = SingularValueList[matrizBipartita, Tolerance -> 0];
  probabilidades = valoresSchmidt^2;
  probabilidades = probabilidades/Total[probabilidades];

  (* 0 Log[0] se define por continuidad; no se eliminan valores positivos. *)
  probabilidades = Select[probabilidades, # > 0 &];
  -Total[probabilidades*Log[probabilidades]]
]


QWDynamicsData[GridData_, coin_, initState_: Automatic] :=
 Module[
  {
   dim, coords, mapping, evolution, interior, position,
   initialState, state, step,
   stepsIPR = 2500, stepsEntropy = 3500, stepsTemp = 7000,
   iprData, entropyData, siteProbabilities, probabilitySum,
   limitCasesDat, iprImg, entropyImg, limitImg
  },

  dim = GridData["Dimension"];
  coords = GridData["Coords"];
  mapping = GridData["Mapping"];
  evolution =
   BuildShiftOperators[GridData, CoinDimension -> 4] .
    KroneckerProduct[
     IdentityMatrix[dim, SparseArray],
     SparseArray[coin]
    ];

  If[initState === Automatic,
   interior = Select[
     coords,
     Function[pos,
      With[{x = pos[[1]], y = pos[[2]]},
       And[
        ! MissingQ[mapping[{x + 1, y}]],
        ! MissingQ[mapping[{x - 1, y}]],
        ! MissingQ[mapping[{x, y + 1}]],
        ! MissingQ[mapping[{x, y - 1}]]
       ]
      ]
     ]
    ];
   position = RandomChoice[interior];
   initialState =
    LocalizedState[GridData, position, Normalize[HaarRandomState[4]]],
   initialState = initState
  ];

  (* LocalizedState returns a SparseArray; use dense vectors for entropy. *)
  state = Normal[initialState];

  iprData = ConstantArray[0., stepsIPR + 1];
  iprData[[1]] = ComputeSpatialIPR[state, 4];
  entropyData = ConstantArray[0., stepsEntropy + 1];
  entropyData[[1]] = EntropiaMoneda[state, dim];

  siteProbabilities = Total[Partition[Abs[state]^2, 4], {2}];
  probabilitySum = siteProbabilities;

  Do[
   state = Normal[evolution . state];
   siteProbabilities = Total[Partition[Abs[state]^2, 4], {2}];
   probabilitySum += siteProbabilities;

   If[step <= stepsIPR,
    iprData[[step + 1]] = ComputeSpatialIPR[state, 4]
   ];
   If[step <= stepsEntropy,
    entropyData[[step + 1]] = EntropiaMoneda[state, dim]
   ],
   {step, 1, stepsTemp}
  ];

  limitCasesDat = probabilitySum/(stepsTemp + 1);

  iprImg = ListLinePlot[
    iprData,
    Frame -> True,
    FrameLabel -> {
      Style["Tiempo (pasos)", 13, Black],
      Style["IPR", 13, Black]
    },
    PlotLabel -> Style["Evolución de la IPR", 14, Bold],
    LabelStyle -> Directive[Black, 11],
    FrameStyle -> GrayLevel[0.35],
    PlotStyle -> Directive[RGBColor[0.12, 0.47, 0.71], AbsoluteThickness[2.4]],
    ImageSize -> {600, 380},
    PlotRange -> {All, Automatic},
    PlotRangePadding -> Scaled[0.04],
    ScalingFunctions -> {"Log10", "Log10"}
  ];

  entropyImg = ListLinePlot[
    Transpose[{Range[1, stepsEntropy], Rest[entropyData]}],
    Frame -> True,
    FrameLabel -> {
      Style["Tiempo (pasos)", 13, Black],
      Style["Entropía de entrelazamiento", 13, Black]
    },
    PlotLabel -> Style["Entropía de entrelazamiento", 14, Bold],
    LabelStyle -> Directive[Black, 11],
    FrameStyle -> GrayLevel[0.35],
    PlotStyle -> Directive[RGBColor[0.85, 0.33, 0.10], AbsoluteThickness[2.4]],
    ImageSize -> {600, 380},
    PlotRange -> {All, Automatic},
    PlotRangePadding -> Scaled[0.04],
    ScalingFunctions -> {"Log10", "Log10"}
  ];

  limitImg = DiscreteProbabilityPlot[
    GridData,
    limitCasesDat,
    "ProbabilityScale" -> "Linear",
    PlotLabel -> "Distribución espacial promedio",
    FrameLabel -> {"x", "y"},
    LabelStyle -> Directive[Black, 11],
    ImageSize -> {1100, 420},
    Mesh -> False,
    PlotLegends -> Placed[Automatic, Right]
  ];

  GraphicsGrid[
   {
    {iprImg, entropyImg},
    {limitImg, SpanFromLeft}
   },
   Alignment -> Center,
   Spacings -> {0.35, 0.45},
   ImageSize -> 1300
  ]
 ]


(* --- Gaussian State --- *)
GaussianState[GridData_Association, Position_List, CoinState_List, Sigma_?NumericQ] := 
  Module[{XCoord, YCoord, SpatialAmplitudes, StateVector},
    
    {XCoord, YCoord} = Position;
    
    (* Fully vectorized C-level distance evaluation *)
    SpatialAmplitudes = Exp[
      -( (GridData["Coords"][[All, 1]] - XCoord)^2 + 
         (GridData["Coords"][[All, 2]] - YCoord)^2 ) / (2.0 * Sigma^2)
    ];
    
    StateVector = Flatten[KroneckerProduct[SpatialAmplitudes, CoinState]];
    StateVector / Norm[StateVector]
  ];


(* --- Visualization compatibility: rendering is implemented only once. --- *)
VisualizeWalkerState[grid_Association, state_?VectorQ,
    scale_String : "Linear", upper_ : Automatic] :=
  DiscreteProbabilityPlot[grid, state,
    "InputType" -> "State",
    CoinDimension -> If[Length[Lookup[grid, "Coords", {}]] > 0,
      Length[state]/Length[grid["Coords"]], 4],
    "ProbabilityScale" -> scale,
    "ProbabilityRange" -> If[upper === Automatic, Automatic, {0, upper}]
  ];


LimitDistribution[TimeStatesList_List, CoinDim_Integer : 4] := Module[{MeanProbabilities},
  MeanProbabilities = Mean[Abs[TimeStatesList]^2];
  Total[Partition[MeanProbabilities, CoinDim], {2}]
];

LimitDistribution::time = "The maximum time `1` must be a nonnegative integer.";
LimitDistribution::stride = "Stride `1` must be a positive integer.";
LimitDistribution::grid = "The grid must contain a nonempty list of coordinate pairs and a matching positive integer Dimension.";
LimitDistribution::coin = "CoinDimension `1` must be a positive integer.";
LimitDistribution::state = "The initial state must be a finite numeric vector with `1` entries.";
LimitDistribution::operator = "The evolution operator must be a square matrix with dimensions `1`.";
LimitDistribution::numeric = "Evolution produced nonnumeric or nonfinite probabilities at time `1`.";

Options[LimitDistribution] = {"Stride" -> 1, CoinDimension -> 4};

LimitDistribution[grid_Association, evolution_, initialState_, tmax_,
    opts : OptionsPattern[]] := Module[
  {stride, coinDim, coords, n, dimension, state, sum, probabilities,
   sampleCount = 0, lastTime, failed = False},
  If[!IntegerQ[tmax] || tmax < 0,
   Message[LimitDistribution::time, tmax]; Return[$Failed]];
  stride = OptionValue["Stride"];
  If[!IntegerQ[stride] || stride <= 0,
   Message[LimitDistribution::stride, stride]; Return[$Failed]];
  coinDim = OptionValue[CoinDimension];
  If[!IntegerQ[coinDim] || coinDim <= 0,
   Message[LimitDistribution::coin, coinDim]; Return[$Failed]];
  coords = Lookup[grid, "Coords", {}];
  n = Lookup[grid, "Dimension", Missing["Dimension"]];
  If[!IntegerQ[n] || n <= 0 || !MatrixQ[coords] || Dimensions[coords] =!= {n, 2},
   Message[LimitDistribution::grid]; Return[$Failed]];
  dimension = n coinDim;
  If[!VectorQ[initialState, NumberQ[N[#]] &] || Length[initialState] != dimension,
   Message[LimitDistribution::state, dimension]; Return[$Failed]];
  If[!MatrixQ[evolution] || Dimensions[evolution] =!= {dimension, dimension},
   Message[LimitDistribution::operator, {dimension, dimension}]; Return[$Failed]];
  state = Developer`ToPackedArray[N[Normal[initialState]]];
  sum = ConstantArray[0., n];
  lastTime = Quotient[tmax, stride] stride;
  Do[
   If[Mod[t, stride] == 0,
    probabilities = Total[Partition[Abs[state]^2, coinDim], {2}];
    If[!VectorQ[probabilities, NumberQ],
     Message[LimitDistribution::numeric, t]; failed = True; Break[]];
    sum += probabilities;
    sampleCount++
   ];
   If[t < lastTime, state = evolution . state],
   {t, 0, lastTime}
  ];
  If[failed, Return[$Failed]];
  sum/sampleCount
];


DiscreteProbabilityPlot::grid = "The grid must contain distinct integer coordinate pairs and a matching Dimension.";
DiscreteProbabilityPlot::input = "InputType `1` is invalid. Use Probabilities or State.";
DiscreteProbabilityPlot::dim = "Expected `1` entries, received `2`. CoinDimension must be a positive integer for state input.";
DiscreteProbabilityPlot::data = "Probabilities must be finite, real and nonnegative; state amplitudes must be finite numeric values.";
DiscreteProbabilityPlot::scale = "ProbabilityScale `1` is invalid. Use Linear, Sqrt, CubeRoot, Squared or Log.";
DiscreteProbabilityPlot::range = "ProbabilityRange must be Automatic or a finite real pair {pmin, pmax} with 0 <= pmin < pmax.";
DiscreteProbabilityPlot::floor = "LogFloor must be a finite positive real number smaller than the upper probability bound.";
DiscreteProbabilityPlot::color = "ColorFunction must be a named color scheme or a function accepting a value between 0 and 1.";

(* Clear definitions/options on reload, including the previous List-only implementation. *)
DownValues[DiscreteProbabilityPlot] = {};
Options[DiscreteProbabilityPlot] = Join[
  {"InputType" -> "Probabilities", CoinDimension -> 4,
   "ProbabilityScale" -> "Linear", "ProbabilityRange" -> Automatic,
   "LogFloor" -> 10^-12, ColorFunction -> (GrayLevel[1 - #] &),
   PlotLegends -> Automatic, Frame -> True, FrameLabel -> {"x", "y"},
   FrameTicks -> Automatic, Mesh -> False, ImageSize -> Large,
   ColorRules -> {Indeterminate -> LightGray}},
  DeleteCases[Options[ArrayPlot],
    HoldPattern[(ColorFunction | PlotLegends | Frame | FrameLabel |
      FrameTicks | Mesh | ImageSize | ColorRules) -> _]]
];

(* At most seven integer labels, using familiar steps such as 1, 2, 5, 10, 20.
   Explicit FrameTicks supplied by the caller remain unchanged. *)
spatialAxisTicks[minimum_Integer, maximum_Integer] := Module[
  {requiredStep, magnitude, step, positions},
  If[minimum == maximum, Return[{{minimum, minimum}}]];
  requiredStep = Max[1, Ceiling[(maximum - minimum)/6]];
  magnitude = 10^Floor[Log10[requiredStep]];
  step = First[Select[magnitude {1, 2, 5, 10}, # >= requiredStep &]];
  positions = Range[Ceiling[minimum/step] step, maximum, step];
  {#, #} & /@ positions
];

DiscreteProbabilityPlot[grid_Association, data_?VectorQ, opts : OptionsPattern[]] :=
 Module[{coords, n, coinDim, inputType, values, probabilities, scale,
   probabilityRange, floor, transform, colorRange, processed,
   xmin, xmax, ymin, ymax, rules, matrix, colorSpec, colorMap,
   legend, label, plotOptions, realNonnegativeQ, graphic, ticks},

  coords = Lookup[grid, "Coords", {}];
  n = Length[coords];
  If[n == 0 || !MatrixQ[coords, IntegerQ] ||
     Dimensions[coords] =!= {n, 2} || Length[DeleteDuplicates[coords]] != n ||
     Lookup[grid, "Dimension", n] =!= n,
   Message[DiscreteProbabilityPlot::grid]; Return[$Failed]];

  values = N[Normal[data]];
  inputType = OptionValue["InputType"];
  coinDim = OptionValue[CoinDimension];
  Switch[inputType,
   "State",
    If[!IntegerQ[coinDim] || coinDim <= 0,
     Message[DiscreteProbabilityPlot::dim, "N times a positive integer", Length[values]];
     Return[$Failed]];
    If[Length[values] != n coinDim,
     Message[DiscreteProbabilityPlot::dim, n coinDim, Length[values]]; Return[$Failed]];
    If[!VectorQ[values, NumberQ], Message[DiscreteProbabilityPlot::data]; Return[$Failed]];
    probabilities = Total[Partition[Abs[values]^2, coinDim], {2}],
   "Probabilities",
    If[Length[values] != n,
     Message[DiscreteProbabilityPlot::dim, n, Length[values]]; Return[$Failed]];
    probabilities = values,
   _, Message[DiscreteProbabilityPlot::input, inputType]; Return[$Failed]
  ];
  realNonnegativeQ = Function[v, NumberQ[v] && TrueQ[Im[v] == 0] && TrueQ[v >= 0]];
  If[!VectorQ[probabilities, realNonnegativeQ],
   Message[DiscreteProbabilityPlot::data]; Return[$Failed]];
  probabilities = Re[probabilities];

  scale = OptionValue["ProbabilityScale"];
  If[!MemberQ[{"Linear", "Sqrt", "CubeRoot", "Squared", "Log"}, scale],
   Message[DiscreteProbabilityPlot::scale, scale]; Return[$Failed]];
  probabilityRange = OptionValue["ProbabilityRange"];
  If[probabilityRange === Automatic,
   probabilityRange = {0., If[Max[probabilities] > 0, Max[probabilities], 1.]}];
  If[!MatchQ[probabilityRange, {_, _}] ||
     !VectorQ[N[probabilityRange], realNonnegativeQ] ||
     !TrueQ[probabilityRange[[1]] < probabilityRange[[2]]],
   Message[DiscreteProbabilityPlot::range]; Return[$Failed]];
  probabilityRange = N[Re[probabilityRange]];

  If[scale === "Log",
   floor = N[OptionValue["LogFloor"]];
   If[!realNonnegativeQ[floor] || !TrueQ[0 < floor < probabilityRange[[2]]],
    Message[DiscreteProbabilityPlot::floor]; Return[$Failed]];
   probabilityRange[[1]] = Max[probabilityRange[[1]], Re[floor]]];
  transform = Switch[scale,
   "Linear", Identity, "Sqrt", Sqrt, "CubeRoot", (#^(1/3) &),
   "Squared", (#^2 &), "Log", Log10];
  label = Switch[scale, "Linear", "P", "Sqrt", "Sqrt(P)",
    "CubeRoot", "P^(1/3)", "Squared", "P^2", "Log", "Log10(P)"];
  colorRange = transform /@ probabilityRange;
  processed = transform /@ Clip[probabilities, probabilityRange];

  {xmin, xmax} = MinMax[coords[[All, 1]]];
  {ymin, ymax} = MinMax[coords[[All, 2]]];
  rules = MapThread[
    {#1[[2]] - ymin + 1, #1[[1]] - xmin + 1} -> #2 &,
    {coords, processed}];
  matrix = Normal[SparseArray[rules, {ymax - ymin + 1, xmax - xmin + 1}, Indeterminate]];

  colorSpec = OptionValue[ColorFunction];
  colorMap = If[StringQ[colorSpec], Quiet[Check[ColorData[colorSpec], $Failed]], colorSpec];
  If[colorMap === $Failed || !MatchQ[colorMap, _ColorDataFunction | _Function] ||
     !ColorQ[Quiet[Check[colorMap[0.5], $Failed]]],
   Message[DiscreteProbabilityPlot::color]; Return[$Failed]];
  legend = Replace[OptionValue[PlotLegends], Automatic :>
    Placed[BarLegend[{
      With[{map = colorMap, range = colorRange},
        Function[v, map[Clip[Rescale[v, range], {0, 1}]]]],
      colorRange}, LegendLabel -> label,
      LabelStyle -> OptionValue[LabelStyle]], Right]];
  (* Use the same explicit range for colors and the legend, including across frames. *)
  plotOptions = DeleteCases[FilterRules[{opts}, Options[ArrayPlot]],
    HoldPattern[(ColorFunction | ColorFunctionScaling | PlotRange | DataRange |
      DataReversed | ColorRules | PlotLegends) -> _]];
  ticks = Replace[OptionValue[FrameTicks], Automatic :>
    {{spatialAxisTicks[ymin, ymax], None},
     {spatialAxisTicks[xmin, xmax], None}}];
  graphic = ArrayPlot[matrix,
   Evaluate[Sequence @@ plotOptions],
   DataReversed -> True, DataRange -> {{xmin, xmax}, {ymin, ymax}},
   ColorFunction -> Function[v, colorMap[Clip[Rescale[v, colorRange], {0, 1}]]],
   ColorFunctionScaling -> False, PlotRange -> colorRange,
   ColorRules -> Prepend[DeleteCases[OptionValue[ColorRules],
      HoldPattern[Indeterminate -> _]], Indeterminate -> LightGray],
   PlotLegends -> None, Frame -> OptionValue[Frame],
   FrameLabel -> OptionValue[FrameLabel], FrameTicks -> ticks,
   Mesh -> OptionValue[Mesh], ImageSize -> OptionValue[ImageSize]
  ];
  (* ArrayPlot's default spatial range clips half of the boundary cells.
     Keep lattice coordinates at cell centers and include the entire cells. *)
  graphic = Show[graphic,
    PlotRange -> {{xmin - 0.5, xmax + 0.5}, {ymin - 0.5, ymax + 0.5}},
    FrameTicks -> ticks, FrameLabel -> OptionValue[FrameLabel]];
  If[legend === None, graphic, Legended[graphic, legend]]
 ];


(* --- Animation: retain frames and one state, rather than all time states. --- *)
QWAnimation::steps = "The number of steps `1` must be a nonnegative integer.";
QWAnimation::stride = "FrameStride `1` must be a positive integer.";
QWAnimation::operator = "The evolution operator must be a square matrix with dimensions `1`.";
QWAnimation::state = "The initial state must be a nonempty finite numeric vector.";

DownValues[QWAnimation] = {};
Options[QWAnimation] = DeleteDuplicatesBy[
  Join[{"FrameStride" -> 1, AnimationRunning -> True, PlotLabel -> Automatic},
    Options[DiscreteProbabilityPlot], Options[ListAnimate]], First];

QWAnimation[grid_Association, evolution_, initialState_, steps_,
    opts : OptionsPattern[]] := Module[
  {stride, state, dimension, plotOptions, animationOptions, label,
   frames, frame, result, tag = Unique["QWAnimationFailure"]},
  If[!IntegerQ[steps] || steps < 0,
   Message[QWAnimation::steps, steps]; Return[$Failed]];
  stride = OptionValue["FrameStride"];
  If[!IntegerQ[stride] || stride <= 0,
   Message[QWAnimation::stride, stride]; Return[$Failed]];
  If[!VectorQ[initialState, NumberQ[N[#]] &] || Length[initialState] == 0,
   Message[QWAnimation::state]; Return[$Failed]];
  dimension = Length[initialState];
  If[!MatrixQ[evolution] || Dimensions[evolution] =!= {dimension, dimension},
   Message[QWAnimation::operator, {dimension, dimension}]; Return[$Failed]];
  state = Developer`ToPackedArray[N[Normal[initialState]]];
  plotOptions = DeleteCases[FilterRules[{opts}, Options[DiscreteProbabilityPlot]],
    HoldPattern[("InputType" | PlotLabel) -> _]];
  animationOptions = DeleteCases[FilterRules[{opts}, Options[ListAnimate]],
    HoldPattern[(PlotLabel | AnimationRunning | ImageSize) -> _]];
  label = OptionValue[PlotLabel];
  result = Catch[
    Reap[
      Do[
       If[Mod[t, stride] == 0 || t == steps,
        frame = DiscreteProbabilityPlot[grid, state,
          "InputType" -> "State",
          PlotLabel -> If[label === Automatic, Row[{"t = ", t}], label],
          Sequence @@ plotOptions];
        If[frame === $Failed, Throw[$Failed, tag]];
        Sow[frame]
       ];
       If[t < steps, state = evolution . state],
       {t, 0, steps}
      ]
    ], tag];
  If[result === $Failed, Return[$Failed]];
  frames = result[[2, 1]];
  (* ImageSize controls each plot; the player must also fit its external legend. *)
  ListAnimate[frames, Sequence @@ animationOptions, ImageSize -> All,
    AnimationRunning -> OptionValue[AnimationRunning]]
];

(* --- Overlap and Statistics --- *)
ComputeSurvivalProbability[InitState_?VectorQ, FinalState_?VectorQ] :=
  Abs[Conjugate[InitState] . FinalState]^2;

ComputeSurvivalProbability[InitState_?VectorQ, AllStates_?MatrixQ] := 
  Abs[AllStates . Conjugate[InitState]]^2;

(* Spatial IPR traces out the coin BEFORE squaring the probabilities.
   It differs from Total[Abs[Normalize[state]]^4] in the position-coin basis. *)
ComputeSpatialIPR::coin = ComputeSpatialIPRDensity::coin =
  "CoinDim `1` must be a positive integer.";
ComputeSpatialIPR::state = ComputeSpatialIPRDensity::state =
  "The state must be a nonempty finite numeric vector whose length is divisible by CoinDim (`1`).";
ComputeSpatialIPR::zero = ComputeSpatialIPRDensity::zero =
  "The zero vector cannot be normalized to compute a spatial IPR.";

(* Remove the previous more-specific VectorQ definition when reloading. *)
DownValues[ComputeSpatialIPR] = {};
DownValues[ComputeSpatialIPRDensity] = {};

spatialIPRDensity[state_, coinDim_, caller_] := Module[
  {amplitudes, scale, probabilities},
  If[!IntegerQ[coinDim] || coinDim <= 0,
    Message[caller::coin, coinDim]; Return[$Failed]];
  If[!VectorQ[state, NumberQ[N[#]] &] || Length[state] == 0 ||
      Mod[Length[state], coinDim] != 0,
    Message[caller::state, coinDim]; Return[$Failed]];
  amplitudes = Normal[state];
  scale = Max[Abs[amplitudes]];
  If[TrueQ[scale == 0], Message[caller::zero]; Return[$Failed]];
  (* Scale first to avoid overflow/underflow for rescaled numeric states,
     while retaining exact arithmetic for exact inputs. *)
  probabilities = Total[Partition[Abs[amplitudes/scale]^2, coinDim], {2}];
  (probabilities/Total[probabilities])^2
];

ComputeSpatialIPRDensity[state_, coinDim_ : 4] :=
  spatialIPRDensity[state, coinDim, ComputeSpatialIPRDensity];

ComputeSpatialIPR[state_, coinDim_ : 4] := Module[{density},
  density = spatialIPRDensity[state, coinDim, ComputeSpatialIPR];
  If[density === $Failed, $Failed, Total[density]]
];

(* --- Boundary eigenstates and quasienergy selection from explicit eigenpairs. --- *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "QWMisc", "BoundarySpectrum.wl"}]];

EigenstateAtEnergy::energy = "epsilon must be a finite real numeric quasienergy.";
EigenstateAtEnergy::pairs = "Supply a nonempty list of finite nonzero eigenvalues and a matching rectangular list of eigenvectors with length divisible by CoinDimension.";
EigenstateAtEnergy::coin = "The string option CoinDimension (`1`) must be a positive integer.";
EigenstateAtEnergy::state = "The selected eigenvector must be a finite numeric nonzero vector.";
EigenstateAtEnergy::args = "Use EigenstateAtEnergy[epsilon, eigenvals, eigenvecs, opts] with matching eigenpairs and a real numeric target.";

Options[EigenstateAtEnergy] = {"CoinDimension" -> 4};
DownValues[EigenstateAtEnergy] = {};
EigenstateAtEnergy[epsilon_?NumericQ, eigenvalues_List, eigenvectors_List,
    OptionsPattern[]] := Module[
  {coinDim, dimensions, energies, distances, index, state, scale, ipr},
  coinDim = OptionValue["CoinDimension"];
  If[!IntegerQ[coinDim] || coinDim <= 0,
    Message[EigenstateAtEnergy::coin, coinDim]; Return[$Failed]];
  If[!NumberQ[N[epsilon]] || !TrueQ[Im[N[epsilon]] == 0],
    Message[EigenstateAtEnergy::energy]; Return[$Failed]];
  dimensions = Dimensions[eigenvectors];
  If[eigenvalues === {} || !VectorQ[eigenvalues, NumberQ[N[#]] &] ||
     AnyTrue[eigenvalues, TrueQ[# == 0] &] || Length[dimensions] != 2 ||
     dimensions[[1]] != Length[eigenvalues] || dimensions[[2]] < 1 ||
     Mod[dimensions[[2]], coinDim] != 0,
    Message[EigenstateAtEnergy::pairs]; Return[$Failed]];
  energies = -Arg[N[eigenvalues]];
  (* Circular distance identifies -Pi and Pi, also for targets outside the branch. *)
  distances = Abs[Arg[Exp[I (energies - N[epsilon])]]];
  index = First[Ordering[distances, 1]];
  state = Normal[eigenvectors[[index]]];
  If[!VectorQ[state, NumberQ[N[#]] &],
    Message[EigenstateAtEnergy::state]; Return[$Failed]];
  scale = Max[Abs[state]];
  If[!TrueQ[scale > 0],
    Message[EigenstateAtEnergy::state]; Return[$Failed]];
  state = Normalize[state/scale];
  ipr = ComputeSpatialIPR[state, coinDim];
  If[ipr === $Failed, Return[$Failed]];
  <|"Index" -> index, "Energy" -> energies[[index]],
    "Distance" -> distances[[index]], "State" -> state, "IPR" -> ipr|>
];
EigenstateAtEnergy[___] := (Message[EigenstateAtEnergy::args]; $Failed);

(* --- Spatial IPR evolution: O(state dimension + steps) storage. --- *)
ComputeSpatialIPREvolution::steps = "Steps `1` must be a nonnegative integer.";
ComputeSpatialIPREvolution::coin = "CoinDimension `1` must be a positive integer.";
ComputeSpatialIPREvolution::state = "The initial state must be a nonzero finite numeric vector with length divisible by CoinDimension (`1`).";
ComputeSpatialIPREvolution::operator = "The evolution operator must be a finite numeric square matrix with dimensions `1`.";
ComputeSpatialIPREvolution::numeric = "Evolution produced an invalid or zero state at time `1`; its spatial IPR cannot be computed.";

Options[ComputeSpatialIPREvolution] = {CoinDimension -> 4};
DownValues[ComputeSpatialIPREvolution] = {};
ComputeSpatialIPREvolution[evolution_, initialState_, steps_,
    opts : OptionsPattern[]] := Module[{coinDim, dimension, state, data, ipr, scale, failed = False},
  If[!IntegerQ[steps] || steps < 0,
    Message[ComputeSpatialIPREvolution::steps, steps]; Return[$Failed]];
  coinDim = OptionValue[CoinDimension];
  If[!IntegerQ[coinDim] || coinDim <= 0,
    Message[ComputeSpatialIPREvolution::coin, coinDim]; Return[$Failed]];
  If[!VectorQ[initialState, NumberQ[N[#]] &] || Length[initialState] == 0 ||
      Mod[Length[initialState], coinDim] != 0,
    Message[ComputeSpatialIPREvolution::state, coinDim]; Return[$Failed]];
  scale = Max[Abs[initialState]];
  If[TrueQ[scale == 0],
    Message[ComputeSpatialIPREvolution::state, coinDim]; Return[$Failed]];
  dimension = Length[initialState];
  If[!MatrixQ[evolution, NumberQ[N[#]] &] ||
      Dimensions[evolution] =!= {dimension, dimension},
    Message[ComputeSpatialIPREvolution::operator, {dimension, dimension}]; Return[$Failed]];
  state = Developer`ToPackedArray[N[Normal[initialState/scale]]];
  state = state/Norm[state];
  data = ConstantArray[0., {steps + 1, 2}];
  Do[
    ipr = Quiet[ComputeSpatialIPR[state, coinDim]];
    If[ipr === $Failed,
      Message[ComputeSpatialIPREvolution::numeric, t]; failed = True; Break[]];
    data[[t + 1]] = {t, ipr};
    If[t < steps, state = evolution . state],
    {t, 0, steps}
  ];
  If[failed, $Failed, data]
];

(* --- Position-coin entanglement entropy from t = 0 through tmax. --- *)
ComputeEntanglementEntropyEvolution::time = "tmax (`1`) must be a nonnegative integer.";
ComputeEntanglementEntropyEvolution::coin = "CoinDimension (`1`) must be a positive integer.";
ComputeEntanglementEntropyEvolution::state = "The initial state must be a nonzero finite numeric vector with length divisible by CoinDimension (`1`).";
ComputeEntanglementEntropyEvolution::operator = "The evolution operator must be a finite numeric square matrix with dimensions `1`.";
ComputeEntanglementEntropyEvolution::numeric = "Evolution produced an invalid or zero state at time `1`; its entanglement entropy cannot be computed.";

Options[ComputeEntanglementEntropyEvolution] = {CoinDimension -> 4};
ComputeEntanglementEntropyEvolution[evolution_, initialState_, tmax_,
    opts : OptionsPattern[]] := Module[
  {coinDim, dimension, dimEspacio, state, data, entropy, scale, failed = False},
  If[!IntegerQ[tmax] || tmax < 0,
    Message[ComputeEntanglementEntropyEvolution::time, tmax]; Return[$Failed]];
  coinDim = OptionValue[CoinDimension];
  If[!IntegerQ[coinDim] || coinDim <= 0,
    Message[ComputeEntanglementEntropyEvolution::coin, coinDim]; Return[$Failed]];
  If[!VectorQ[initialState, NumericQ] || Length[initialState] == 0 ||
      Mod[Length[initialState], coinDim] != 0 ||
      !FreeQ[initialState, _DirectedInfinity | Indeterminate | ComplexInfinity],
    Message[ComputeEntanglementEntropyEvolution::state, coinDim]; Return[$Failed]];
  scale = Max[Abs[initialState]];
  If[TrueQ[scale == 0],
    Message[ComputeEntanglementEntropyEvolution::state, coinDim]; Return[$Failed]];
  dimension = Length[initialState];
  If[!MatrixQ[evolution, NumericQ] ||
      Dimensions[evolution] =!= {dimension, dimension} ||
      !FreeQ[evolution, _DirectedInfinity | Indeterminate | ComplexInfinity],
    Message[ComputeEntanglementEntropyEvolution::operator,
      {dimension, dimension}]; Return[$Failed]];

  dimEspacio = dimension/coinDim;
  state = Developer`ToPackedArray[N[Normal[initialState/scale]]];
  state = state/Norm[state];
  data = ConstantArray[0., {tmax + 1, 2}];
  Do[
    entropy = Quiet[EntropiaMoneda[state, dimEspacio]];
    If[entropy === $Failed || !NumericQ[entropy],
      Message[ComputeEntanglementEntropyEvolution::numeric, t];
      failed = True; Break[]];
    data[[t + 1]] = {t, entropy};
    If[t < tmax, state = evolution . state],
    {t, 0, tmax}
  ];
  If[failed, $Failed, data]
];

SpatialIPREvolutionPlot::reference = "ShowUniformReference must be True or False.";
DownValues[SpatialIPREvolutionPlot] = {};
Options[SpatialIPREvolutionPlot] = Join[
  {CoinDimension -> 4, "ShowUniformReference" -> True,
   ScalingFunctions -> {None, "Log"},
   PlotStyle -> {Directive[Blue, Thick], Directive[Gray, Dashed]},
   PlotLegends -> Automatic, Frame -> True, Axes -> False,
   FrameLabel -> {"Paso t", "IPR espacial"},
   PlotLabel -> "Evoluci\[OAcute]n de la localizaci\[OAcute]n espacial",
   GridLines -> Automatic, PlotRange -> All, ImageSize -> 700},
  DeleteCases[Options[ListLinePlot],
    HoldPattern[(ScalingFunctions | PlotStyle | PlotLegends | Frame | Axes |
      FrameLabel | PlotLabel | GridLines | PlotRange | ImageSize) -> _]]
];

SpatialIPREvolutionPlot[evolution_, initialState_, steps_,
    opts : OptionsPattern[]] := Module[{data, showReference, nSites, curves, legends, plotOptions},
  showReference = OptionValue["ShowUniformReference"];
  If[!MemberQ[{True, False}, showReference],
    Message[SpatialIPREvolutionPlot::reference]; Return[$Failed]];
  data = ComputeSpatialIPREvolution[evolution, initialState, steps,
    CoinDimension -> OptionValue[CoinDimension]];
  If[data === $Failed, Return[$Failed]];
  nSites = Length[initialState]/OptionValue[CoinDimension];
  curves = If[showReference,
    {data, {{0, 1/nSites}, {steps, 1/nSites}}}, {data}];
  legends = Replace[OptionValue[PlotLegends], Automatic :>
    Placed[If[showReference,
      {"IPR espacial", "Distribuci\[OAcute]n uniforme: 1/N"}, {"IPR espacial"}], Below]];
  plotOptions = DeleteCases[FilterRules[{opts}, Options[ListLinePlot]],
    HoldPattern[PlotLegends -> _]];
  ListLinePlot[curves, Sequence @@ plotOptions, PlotLegends -> legends,
    Sequence @@ DeleteCases[FilterRules[Options[SpatialIPREvolutionPlot], Options[ListLinePlot]],
      HoldPattern[PlotLegends -> _]]]
];

End[];

EndPackage[];
