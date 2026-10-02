(* ::Package:: *)

(* All definitions are reset together so Get is safe on reload. *)
ClearAll["QuantumWalks`QWMisc`*", "QuantumWalks`QWMisc`Private`*"];


BeginPackage[
  "QuantumWalks`QWMisc`",
  {"ForScience`", "QuantumWalks`", "QuantumWalks`Billiards`", "QMB`"}
];


(* ========================================================================= *)
(* PUBLIC DEFINITIONS & USAGE MESSAGES                                       *)
(* ========================================================================= *)

  LocalizedState::usage = "LocalizedState[GridData, Position, CoinState] yields a sparse vector representing \
    a highly localized state at ```Position``` with internal coin state ```CoinState```. \
    ```GridData``` must be a valid grid association.";

  RandomDelocalizedState::usage = "RandomDelocalizedState[spaceDim, coinDim, RandomSeed -> Automatic] returns \
    Flatten[KroneckerProduct[HaarRandomState[spaceDim], HaarRandomState[coinDim]]]. \
    The two Haar-random factors are independent. Set RandomSeed -> integer for \
    reproducible results without changing the session's random state.";

 QWEigenphases::usage = "QWEigenphases[grid, coin, opts] returns sorted quasienergies epsilon = -Arg[lambda], with U psi = Exp[-I epsilon] psi. CoinDimension defaults to Automatic (inferred from coin).";

QWPs::usage = "QWPs[eigenphases, opts] plots circular unfolded spacing density P(s), including the closing spacing. ReturnData -> True returns Spacings and Histogram (BinEdges, PDF).";

QWSFF::usage = "QWSFF[eigenphases, tauMax:2, windowSize:Automatic, opts] plots the SFF at tau=t/N. RMTEnsembles -> {1, 2} shows COE and CUE references. ReturnData -> True returns Raw, TimeAverage, WindowSize and RMTReferences; RMT retains the COE series for compatibility. PlotRange -> All includes every raw peak.";

QWPr::usage = "QWPr[eigenphases, opts] plots restricted adjacent spacing ratios on the original phase circle, including closure, without unfolding or discarding small spacings. ReturnData -> True returns Ratios and Histogram.";

ReturnData::usage = "ReturnData -> True returns numeric associations from QWPs, QWPr, QWSFF and QWDynamicsData. The default is False.";

QuantumWalks`QWMisc`EjecutarEnNodo::usage = "EjecutarEnNodo[node, count, process, inputs, preparation:Function[True]] runs a pure process function on inputs using temporary kernels on nodo1, nodo2, nodo3 or nodo4 via SSH alias robot. Preparation runs in each worker and must return True. Kernels open sequentially with a 120-second connection limit and always close after work. EvaluateOnNode is the English API name.";

QWSpectralData::usage = "QWSpectralData[grid, coin, opts] returns density of states, P(s), SFF and P(r) plots. CoinDimension is inferred from coin by default.";

QWDynamicsData::usage = "QWDynamicsData[grid, coin, initialState:Automatic, opts] plots spatial IPR, coin entanglement entropy and finite-time mean probabilities. ReturnData -> True returns the initial state, operator and numeric series. IPRSteps, EntropySteps and DistributionSteps default to 2500, 3500 and 7000. RandomSeed makes the automatic localized initial state reproducible. All time series include t = 0.";

EntropiaMoneda::usage = "EntropiaMoneda[psi, spaceDimension] is the compatibility name for CoinEntanglementEntropy; entropy uses natural logarithms (nats).";



  GaussianState::usage = "GaussianState[GridData, Position, CoinState, Sigma] yields a dense state vector \
    representing a Gaussian wavepacket centered at ```Position``` with standard deviation \
    ```Sigma``` and internal coin state ```CoinState```.";

  VisualizeWalkerState::usage = "VisualizeWalkerState[GridData, StateVector, ScalingMap, ScaleUpperBound] is a compatibility wrapper for DiscreteProbabilityPlot with InputType -> State.";

  QWAnimation::usage = "QWAnimation[GridData, evolution, initialState, steps, opts] precomputes spatial probability frames and returns ListAnimate. Stride defaults to 1 (the legacy string FrameStride is also accepted); the initial and final states are always included. Only the current state is retained during evolution. DiscreteProbabilityPlot and ListAnimate options are supported. The default PlotLabel displays the physical step t.";

  ComputeSurvivalProbability::usage = "ComputeSurvivalProbability[initialState, finalState] computes normalized fidelity between finite nonzero numeric states. \
    ComputeSurvivalProbability[InitState, AllStates] computes the survival probability \
    across an entire time-evolution matrix.";

  ComputeSpatialIPR::usage = "ComputeSpatialIPR[StateVector, CoinDim] returns the position-space IPR, Total[ComputeSpatialIPRDensity[StateVector, CoinDim]]. Coin probabilities are summed before squaring. The state is normalized internally; CoinDim defaults to 4.";

  ComputeSpatialIPRDensity::usage = "ComputeSpatialIPRDensity[StateVector, CoinDim] returns the local IPR density I_n(x,y) = P_n(x,y)^2, with P_n(x,y) = Sum[Abs[psi_alpha(x,y)]^2, alpha] for the internally normalized state. CoinDim defaults to 4. Consecutive CoinDim amplitudes belong to one site; the result follows GridData[\"Coords\"] ordering and can be passed to DiscreteProbabilityPlot. Its sum equals ComputeSpatialIPR. This position-space density is not the Husimi phase-space distribution.";

  AnalyzeBoundaryEigenstates::usage = "AnalyzeBoundaryEigenstates[grid, eigenvals, eigenvecs, opts] returns boundary weights, spatial IPR and candidate energies from corresponding eigenpairs. Supports finite integer-coordinate grids, including Rectangle and Sinai. BoundaryWidth defaults to 2 graph layers and BoundaryThreshold to 0.6. CoinDimension defaults to 4. Energy is -Arg[eigenvalue], consistent with U psi = Exp[-I epsilon] psi. CornerWidth defaults to 3 and applies only to complete rectangles; corner metrics are Missing for other geometries. Original eigenvector indices are preserved.";

  PlotBoundarySpectrum::usage = "PlotBoundarySpectrum[analysis] plots boundary probability versus quasienergy from AnalyzeBoundaryEigenstates, highlighting the selected candidates and the uniform reference.";

  EigenstateAtEnergy::usage = "EigenstateAtEnergy[epsilon, eigenvals, eigenvecs, opts] returns the normalized eigenstate whose quasienergy -Arg[eigenvalue] is closest to the real target epsilon using circular angular distance. Returns Index, Energy, Distance, State and spatial IPR. Eigenvalues and eigenvectors must be supplied in matching order; no global spectrum variables are used. CoinDimension defaults to 4. Ties return the first matching index.";

  ComputeSpatialIPREvolution::usage = "ComputeSpatialIPREvolution[evolution, initialState, steps, opts] returns {{0, IPR[0]}, ..., {steps, IPR[steps]}}. CoinDimension defaults to 4. Only the current state is retained during evolution; each IPR uses normalized spatial probabilities.";

  ComputeEntanglementEntropyEvolution::usage = "ComputeEntanglementEntropyEvolution[evolution, initialState, tmax, opts] returns {{0, S[0]}, ..., {tmax, S[tmax]}} for the pure state evolved by evolution. S is the position-coin entanglement entropy in nats, computed with EntropiaMoneda. CoinDimension defaults to 4; consecutive coin amplitudes belong to one position. Only the current state is retained during evolution.";

  SpatialIPREvolutionPlot::usage = "SpatialIPREvolutionPlot[evolution, initialState, steps, opts] computes and plots the spatial IPR from t = 0 through steps. CoinDimension defaults to 4. The default vertical scale is logarithmic, with a dashed uniform reference 1/N, where N is the number of spatial sites. Set ShowUniformReference -> False to hide it. ListLinePlot options are supported, including ScalingFunctions -> None for a linear scale.";
  
  LimitDistribution::usage = "LimitDistribution[GridData, evolution, initialState, tmax, opts] computes the mean spatial probabilities while retaining only the current state and a running sum. Stride defaults to 1 and CoinDimension to 4. Samples are taken at t = 0, Stride, 2 Stride, ... <= tmax; the final time is included only when it is a multiple of Stride. A stride larger than 1 averages only the sampled times. LimitDistribution[TimeStatesList, CoinDim] preserves the interface for a stored list of states. The result is a finite-time average, not an assertion of asymptotic convergence.";
 
 DiscreteProbabilityPlot::usage= "DiscreteProbabilityPlot[GridData, data, opts] plots spatial probabilities on the physical grid. InputType defaults to Probabilities; use State for a state vector and CoinDimension for its coin dimension (default 4). ProbabilityScale supports Linear, Sqrt, CubeRoot, Squared and Log. ProbabilityRange is Automatic or {pmin, pmax} in original probability units. LogFloor defaults to 10^-12. The default ColorFunction is GrayLevel[1 - #] &, mapping low probabilities to white and high probabilities to black; supply a named color scheme or a custom function to override it. Standard ArrayPlot styling options are supported; the coordinate and color ranges are managed by this function.";



QWEvolutionOperator::usage = "QWEvolutionOperator[grid, coin, opts] builds the sparse quantum walk operator. CoinDimension -> Automatic infers 2 or 4 from coin. Four-state walks use S.C; two-state split-step walks use Sy.C.Sx.C, with C = IdentityMatrix[N] KroneckerProduct coin.";
RandomMatrix::usage = "RandomMatrix[name, opts] returns one of the project's 4 x 4 unitary coins. RandomSeed -> integer gives reproducible results without changing the session random stream. RandomMatrixNames[] lists the names.";
RandomMatrixNames::usage = "RandomMatrixNames[] returns {p, oo, b, gpg, o, uoou, ubu, u, upu} as strings, in the plotting order.";
CoinEntanglementEntropy::usage = "CoinEntanglementEntropy[psi, spaceDimension] returns position-coin entanglement entropy in nats, normalizing the finite nonzero pure state internally. EntropiaMoneda is a compatibility alias.";
EvaluateOnNode::usage = "EvaluateOnNode[node, count, process, inputs, preparation] runs independent work on temporary Mazinger kernels. EjecutarEnNodo is a compatibility alias; see its usage for SSH configuration.";
Stride::usage = "Stride -> positive integer selects physical sampling steps for LimitDistribution and QWAnimation.";
IPRSteps::usage = "IPRSteps -> nonnegative integer sets the last IPR time in QWDynamicsData.";
EntropySteps::usage = "EntropySteps -> nonnegative integer sets the last entropy time in QWDynamicsData.";
DistributionSteps::usage = "DistributionSteps -> nonnegative integer sets the averaging horizon in QWDynamicsData.";
RMTEnsembles::usage = "RMTEnsembles -> {1, 2} chooses SFF reference Dyson indices (0, 1, 2). The default shows COE and CUE without assigning a symmetry class to a coin.";

InputType::usage = "Selects State or Probabilities input for spatial plots.";
ProbabilityScale::usage = "Selects Linear, Sqrt, CubeRoot, Squared or Log probability colors.";
ProbabilityRange::usage = "Specifies Automatic or a pair in original probability units.";
LogFloor::usage = "Sets a positive probability floor for logarithmic colors.";
ShowUniformReference::usage = "Controls the uniform 1/N reference in SpatialIPREvolutionPlot.";
BoundaryWidth::usage = "Sets the number of boundary graph layers.";
CornerWidth::usage = "Sets the number of corner layers in complete rectangles.";
BoundaryThreshold::usage = "Sets the minimum boundary probability for candidate eigenstates.";

(* Error Messages *)
LocalizedState::invalidPos = "Position `1` is not present in the given grid.";
LocalizedState::invalidCoin = "Coin dimension must be 2 or 4.";
RandomDelocalizedState::dim = "Spatial and coin dimensions must be positive integers; received `1` and `2`.";
RandomDelocalizedState::seed = "RandomSeed must be Automatic or an integer; received `1`.";
QuantumWalks`QWMisc`EjecutarEnNodo::args = "Use EvaluateOnNode[node, positiveKernelCount, pureFunction, inputsList, optionalPreparation] with node nodo1, nodo2, nodo3 or nodo4.";

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
  RemoteEvaluate[
    KernelConfiguration["ssh://robot", "Method" -> "Launch",
      "TimeConstraint" -> 120],
    Module[{kernels = {}, nuevos, estado, cargarBiblioteca},
      (* La actualizacion del usuario apunta a un .mx inexistente. Cada
         proceso necesita cargar su propia copia incluida antes de preparar
         QuantumWalks; cargarla solo en robot no inicializa los subkernels. *)
      cargarBiblioteca = Function[
        Module[{archivo},
          archivo = FileNameJoin[{$InstallationDirectory, "SystemFiles",
            "Components", "GeneralUtilities", "GeneralUtilitiesLoader.m"}];
          If[!FileExistsQ[archivo], Return[False]];
          Check[
            Get[archivo];
            BeginPackage["GeneralUtilities`"];
            EndPackage[];
            StringTemplate["`1`"][1] === "1",
            False
          ]
        ]
      ];
      If[!TrueQ[cargarBiblioteca[]],
        Return[Failure["BibliotecaNoDisponible", <|
          "MessageTemplate" -> "No se pudo cargar GeneralUtilities en robot.",
          "Nodo" -> nodo|>]]];
      WithCleanup[
        Do[
          nuevos = LaunchKernels[KernelConfiguration[
            "ssh://" <> nodo, "KernelCount" -> 1,
            "Method" -> "Launch", "TimeConstraint" -> 120]];
          If[!ListQ[nuevos] || Length[nuevos] =!= 1, Break[]];
          kernels = Join[kernels, nuevos],
          {cantidad}
        ],
        If[! ListQ[kernels] || Length[kernels] =!= cantidad,
          Failure["KernelsNoDisponibles", <|
            "MessageTemplate" -> "No se pudieron abrir todos los kernels solicitados.",
            "Nodo" -> nodo, "Solicitados" -> cantidad,
            "Abiertos" -> If[ListQ[kernels], Length[kernels], 0]|>],
          estado = With[{iniciar = preparacion, cargar = cargarBiblioteca},
            ParallelEvaluate[
              If[TrueQ[cargar[]], iniciar[], False],
              kernels, DistributedContexts -> None]];
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

Options[RandomDelocalizedState] = {RandomSeed -> Automatic, "RandomSeed" -> Automatic};

RandomDelocalizedState[spaceDim_, coinDim_, opts : OptionsPattern[]] := Module[
  {seed = qwOptionValue[{opts}, RandomSeed, {"RandomSeed"}, OptionValue[RandomSeed]], makeState},
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

(* --- Shared validation and canonical/legacy option lookup. --- *)
qwOptionValue[rules_List, key_, aliases_List, default_] := Module[{matches},
  matches = Cases[rules, HoldPattern[(k_ -> v_)] /; k === key :> v];
  If[matches =!= {}, Return[Last[matches]]];
  matches = Cases[rules, HoldPattern[(k_ -> v_)] /; MemberQ[aliases, k] :> v];
  If[matches === {}, default, Last[matches]]
];
qwFiniteNumberQ[x_] := NumberQ[N[x]];
qwGridQ[grid_] := AssociationQ[grid] && With[
  {coords = Lookup[grid, "Coords", {}], n = Lookup[grid, "Dimension", 0]},
  IntegerQ[n] && n > 0 && MatrixQ[coords, IntegerQ] &&
  Dimensions[coords] === {n, 2} && Length[DeleteDuplicates[coords]] == n];
qwNeighbors[coords_List] := Module[{mapping = AssociationThread[coords -> Range[Length[coords]]]},
  Table[DeleteMissing[mapping /@ (coords[[i]] + # & /@
    {{1, 0}, {-1, 0}, {0, 1}, {0, -1}})], {i, Length[coords]}]
];
qwStateQ[state_, coinDim_] := IntegerQ[coinDim] && coinDim > 0 &&
  VectorQ[state, qwFiniteNumberQ] && Length[state] > 0 &&
  Mod[Length[state], coinDim] == 0 && TrueQ[Max[Abs[state]] > 0];
qwNormalizedState[state_] := Module[{v = N[Normal[state/Max[Abs[state]]]]},
  Developer`ToPackedArray[v/Norm[v]]];
qwPrepareEvolution[evolution_, initialState_, coinDim_, caller_] := Module[{dimension},
  If[!IntegerQ[coinDim] || coinDim <= 0,
    Message[caller::coin, coinDim]; Return[$Failed]];
  If[!qwStateQ[initialState, coinDim],
    Message[caller::state, coinDim]; Return[$Failed]];
  dimension = Length[initialState];
  If[!MatrixQ[evolution, qwFiniteNumberQ] ||
      Dimensions[evolution] =!= {dimension, dimension},
    Message[caller::operator, {dimension, dimension}]; Return[$Failed]];
  qwNormalizedState[initialState]
];

LocalizedState::grid = GaussianState::grid = QWEvolutionOperator::grid =
  "The grid must have distinct integer coordinate pairs and a matching positive Dimension.";
LocalizedState::invalidCoin = GaussianState::coin =
  "The coin state must be a finite nonzero numeric vector of length 2 or 4.";
LocalizedState[grid_, position_, coinState_] := Module[{index, coinDim, coords, normalizedCoin},
  If[!qwGridQ[grid], Message[LocalizedState::grid]; Return[$Failed]];
  coords = grid["Coords"];
  index = FirstPosition[coords, position, Missing["Position"]];
  If[MissingQ[index], Message[LocalizedState::invalidPos, position]; Return[$Failed]];
  If[!qwStateQ[coinState, 1] || !MemberQ[{2, 4}, Length[coinState]],
    Message[LocalizedState::invalidCoin]; Return[$Failed]];
  index = First[index]; coinDim = Length[coinState];
  normalizedCoin = Normalize[coinState/Max[Abs[coinState]]];
  SparseArray[MapIndexed[{coinDim (index - 1) + First[#2]} -> #1 &, normalizedCoin],
    {coinDim grid["Dimension"]}]
];

QWEvolutionOperator::coin = "CoinDimension must be 2 or 4 and match a finite numeric square coin matrix.";
QWEvolutionOperator::shift = "BuildShiftOperators did not return shift operators with dimensions `1`.";
Options[QWEvolutionOperator] = {CoinDimension -> Automatic};
QWEvolutionOperator[grid_, coin_, opts : OptionsPattern[]] := Module[
  {coinDim = OptionValue[CoinDimension], n, shift, coinOperator, shifts},
  If[!qwGridQ[grid], Message[QWEvolutionOperator::grid]; Return[$Failed]];
  If[coinDim === Automatic, coinDim = Length[coin]];
  If[!MemberQ[{2, 4}, coinDim] || !MatrixQ[coin, qwFiniteNumberQ] ||
      Dimensions[coin] =!= {coinDim, coinDim},
    Message[QWEvolutionOperator::coin]; Return[$Failed]];
  n = grid["Dimension"];
  (* Rebuild Mapping rather than trust an inconsistent association. *)
  shift = BuildShiftOperators[Join[grid,
    <|"Mapping" -> AssociationThread[grid["Coords"] -> Range[n]]|>], CoinDimension -> coinDim];
  shifts = If[coinDim == 2, shift, {shift}];
  If[!ListQ[shifts] || Length[shifts] != If[coinDim == 2, 2, 1] ||
      !AllTrue[shifts, MatrixQ[#, qwFiniteNumberQ] && Dimensions[#] === {n coinDim, n coinDim} &],
    Message[QWEvolutionOperator::shift, {n coinDim, n coinDim}]; Return[$Failed]];
  coinOperator = KroneckerProduct[IdentityMatrix[n, SparseArray], SparseArray[coin]];
  Fold[#2 . coinOperator . #1 &, IdentityMatrix[n coinDim, SparseArray], shifts]
];

Options[QWEigenphases] = Options[QWEvolutionOperator];
QWEigenphases[grid_, coin_, opts : OptionsPattern[]] := Module[{evolution},
  evolution = QWEvolutionOperator[grid, coin, opts];
  If[evolution === $Failed, $Failed, Sort[-Arg[Eigenvalues[Normal[evolution]]]]]
];

Options[RandomMatrix] = Options[RandomDelocalizedState];
RandomMatrix::name = "Unknown coin name `1`. Use a name from RandomMatrixNames[].";
RandomMatrix::seed = RandomDelocalizedState::seed;
RandomMatrixNames[] := {"p", "oo", "b", "gpg", "o", "uoou", "ubu", "u", "upu"};
RandomMatrix[name_, opts : OptionsPattern[]] := Module[{seed, makeCoin, u, c},
  If[!StringQ[name] || !MemberQ[RandomMatrixNames[], ToLowerCase[name]],
    Message[RandomMatrix::name, name]; Return[$Failed]];
  seed = qwOptionValue[{opts}, RandomSeed, {"RandomSeed"}, OptionValue[RandomSeed]];
  If[seed =!= Automatic && !IntegerQ[seed], Message[RandomMatrix::seed, seed]; Return[$Failed]];
  makeCoin[] := Switch[ToLowerCase[name],
    "o", RandomVariate[CircularOrthogonalMatrixDistribution[4]],
    "oo", KroneckerProduct[RandomVariate[CircularOrthogonalMatrixDistribution[2]],
      RandomVariate[CircularOrthogonalMatrixDistribution[2]]],
    "u", RandomVariate[CircularUnitaryMatrixDistribution[4]],
    "p", DiagonalMatrix[Exp[I RandomReal[{0, 2 Pi}, 4]]],
    "b", {{1, 1, 0, 0}, {0, 0, 1, 1}, {0, 0, 1, -1}, {1, -1, 0, 0}}/Sqrt[2],
    "gpg", c = GeneralizedGroverCoin[Pi/4.]; c . RandomMatrix["p"] . ConjugateTranspose[c],
    "uoou" | "ubu" | "upu",
      u = RandomVariate[CircularUnitaryMatrixDistribution[4]];
      c = RandomMatrix[Switch[ToLowerCase[name], "uoou", "oo", "ubu", "b", "upu", "p"]];
      u . c . ConjugateTranspose[u]];
  If[seed === Automatic, makeCoin[], BlockRandom[SeedRandom[seed]; makeCoin[]]]
];

QWPs::invalidPhases = "Supply at least three finite real phases.";
QWPs::badUnfold = "UnfoldCircular did not produce valid circular levels; check the phases and Fourier fit.";
QWPr::invalidPhases = "Supply at least three finite real phases.";
QWPr::badSpacings = "Phases must be distinct modulo 2 Pi to compute circular spacing ratios.";
QWSFF::ensembles = "RMTEnsembles must be a nonempty list of distinct Dyson indices from {0, 1, 2}.";
QWSFF::invalidTau = "tauMax must be finite, real, positive and produce at least one sample.";
QWSFF::invalidWindow = "windowSize must be Automatic or a positive integer.";

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
      SwatchLegend[{dataStyle}, {"Data"}],
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
      FrameLabel -> {"Restricted r", "P(r)"}, PlotLabel -> plotLabel,
      LabelStyle -> labelStyle,
      PlotRange -> {{0, 1}, All}, ImageSize -> Large],
    Placed[Column[{
      SwatchLegend[{histStyle}, {"Data"}],
      LineLegend[styles, {"Poisson", "GOE/COE", "GUE/CUE", "GSE/CSE"}]
    }], Right]
  ]
];

qwSffPlot[unfoldDat_Association, tauMax_, windowSize_,
  plotLabel_: None, labelStyle_: Automatic,
  requestedPlotRange_: Automatic, returnData_: False, ensembles_: {1, 2}] := Module[
  {levels, dim, tau, kRaw, kAverage, kRMT, references, names, styles, window, plotRange},
  If[!ListQ[ensembles] || ensembles === {} || !DuplicateFreeQ[ensembles] ||
      !AllTrue[ensembles, MemberQ[{0, 1, 2}, #] &],
    Message[QWSFF::ensembles]; Return[$Failed]];
  levels = N[unfoldDat["UnfoldedLevels"]];
  dim = Length[levels];
  If[!qwFiniteNumberQ[tauMax] || !TrueQ[Im[N[tauMax]] == 0 && tauMax > 0],
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
  names = Lookup[<|0 -> "Poisson", 1 -> "COE", 2 -> "CUE"|>, ensembles];
  references = AssociationThread[names ->
    (Transpose[{tau, SpectralFormFactorRMT[tau, #]}] & /@ ensembles)];
  styles = Lookup[<|0 -> Directive[Gray, Dotted, Thick],
    1 -> Directive[Black, Dashed, Thick], 2 -> Directive[Red, Thick]|>, ensembles];
  If[TrueQ[returnData],
    Return[<|"Raw" -> Transpose[{tau, kRaw}],
      "TimeAverage" -> kAverage, "RMT" -> kRMT, "RMTReferences" -> references,
      "WindowSize" -> window|>]
  ];
  plotRange = If[requestedPlotRange === Automatic,
    {{0, tauMax},
     {0, 1.15 Max[1, Max[kAverage[[All, 2]]], Max[Flatten[Values[references][[All, All, 2]]]]]}},
    requestedPlotRange
  ];
  ListPlot[
    Join[{Transpose[{tau, kRaw}], kAverage}, Values[references]],
    Joined -> Join[{False, True}, ConstantArray[True, Length[ensembles]]],
    PlotStyle -> Join[{
      Directive[GrayLevel[0.6], Opacity[0.25], PointSize[0.003]],
      Directive[Blue, Thick]}, styles],
    PlotLegends -> Join[{"Raw SFF", "Time average"}, (# <> " (RMT)" & /@ names)],
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
  PlotRange -> Automatic, ReturnData -> False, RMTEnsembles -> {1, 2}};

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
  plotLabel_, labelStyle_, plotRange_, returnData_, ensembles_] :=
  Module[{data = qwCircularUnfold[eigenphases]},
    If[data === $Failed, $Failed,
      qwSffPlot[data, tauMax, windowSize, plotLabel, labelStyle,
        plotRange, returnData, ensembles]]
  ];

QWSFF[eigenphases_List, opts: OptionsPattern[]] :=
  qwSffFromPhases[eigenphases, 2, Automatic,
    OptionValue[PlotLabel], OptionValue[LabelStyle],
    OptionValue[PlotRange], OptionValue[ReturnData], OptionValue[RMTEnsembles]];

QWSFF[eigenphases_List, tauMax_ /;
    !MatchQ[tauMax, _Rule | _RuleDelayed], opts: OptionsPattern[]] :=
  qwSffFromPhases[eigenphases, tauMax, Automatic,
    OptionValue[PlotLabel], OptionValue[LabelStyle],
    OptionValue[PlotRange], OptionValue[ReturnData], OptionValue[RMTEnsembles]];

QWSFF[eigenphases_List, tauMax_ /;
    !MatchQ[tauMax, _Rule | _RuleDelayed],
    windowSize_ /; !MatchQ[windowSize, _Rule | _RuleDelayed],
    opts: OptionsPattern[]] :=
  qwSffFromPhases[eigenphases, tauMax, windowSize,
    OptionValue[PlotLabel], OptionValue[LabelStyle],
    OptionValue[PlotRange], OptionValue[ReturnData], OptionValue[RMTEnsembles]];

Options[QWSpectralData] = Options[QWEigenphases];
QWSpectralData[grid_, coin_, opts : OptionsPattern[]] := Module[
  {eigenphases, unfoldDat, originalDOS, unfoldedDOS, phi},
  eigenphases = QWEigenphases[grid, coin, opts];
  If[eigenphases === $Failed, Return[$Failed]];
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
    FrameLabel -> {"Unfolded level", "Count"}];
  {GraphicsRow[{originalDOS, unfoldedDOS}], qwPsPlot[unfoldDat],
    qwSffPlot[unfoldDat, 2, Automatic], qwPrPlot[eigenphases]}
];


EntropiaMoneda::dim = "spaceDimension (`1`) must be a positive integer.";
EntropiaMoneda::state = "Supply a finite nonempty numeric vector with length divisible by spaceDimension (`1`).";
EntropiaMoneda::zero = "The zero vector does not define a normalized pure state.";

CoinEntanglementEntropy[psi_, dimEspacio_] := Module[
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


Options[QWDynamicsData] = {CoinDimension -> Automatic, RandomSeed -> Automatic,
  "RandomSeed" -> Automatic, IPRSteps -> 2500, EntropySteps -> 3500,
  DistributionSteps -> 7000, Stride -> 1, ReturnData -> False};
QWDynamicsData::steps = "IPRSteps, EntropySteps and DistributionSteps must be nonnegative integers; Stride must be positive.";
QWDynamicsData::seed = RandomDelocalizedState::seed;
QWDynamicsData::interior = "The grid has no interior site with four cardinal neighbors; supply an explicit initial state.";
QWDynamicsData[grid_, coin_, opts : OptionsPattern[]] :=
  qwDynamicsData[grid, coin, Automatic, {opts}];
QWDynamicsData[grid_, coin_, initialState_ /; !MatchQ[initialState, _Rule | _RuleDelayed],
    opts : OptionsPattern[]] := qwDynamicsData[grid, coin, initialState, {opts}];
qwDynamicsData[grid_, coin_, initialState_, opts_List] := Module[
  {coinDim, evolution, seed, steps, stride, state, interior, initialize,
   ipr, entropy, distribution, data, iprPlot, entropyPlot, distributionPlot},
  {coinDim, seed} = {qwOptionValue[opts, CoinDimension, {}, Automatic],
    qwOptionValue[opts, RandomSeed, {"RandomSeed"}, Automatic]};
  steps = qwOptionValue[opts, #, {}, # /. Options[QWDynamicsData]] & /@
    {IPRSteps, EntropySteps, DistributionSteps};
  stride = qwOptionValue[opts, Stride, {}, 1];
  If[!AllTrue[steps, IntegerQ[#] && # >= 0 &] || !IntegerQ[stride] || stride < 1,
    Message[QWDynamicsData::steps]; Return[$Failed]];
  If[seed =!= Automatic && !IntegerQ[seed], Message[QWDynamicsData::seed, seed]; Return[$Failed]];
  evolution = QWEvolutionOperator[grid, coin, CoinDimension -> coinDim];
  If[evolution === $Failed, Return[$Failed]];
  coinDim = Length[coin];
  state = initialState;
  If[state === Automatic,
    interior = Pick[grid["Coords"], Length /@ qwNeighbors[grid["Coords"]], 4];
    If[interior === {}, Message[QWDynamicsData::interior]; Return[$Failed]];
    initialize[] := LocalizedState[grid, RandomChoice[interior], HaarRandomState[coinDim]];
    state = If[seed === Automatic, initialize[], BlockRandom[SeedRandom[seed]; initialize[]]]];
  ipr = ComputeSpatialIPREvolution[evolution, state, steps[[1]], CoinDimension -> coinDim];
  If[ipr === $Failed, Return[$Failed]];
  entropy = ComputeEntanglementEntropyEvolution[evolution, state, steps[[2]], CoinDimension -> coinDim];
  If[entropy === $Failed, Return[$Failed]];
  distribution = LimitDistribution[grid, evolution, state, steps[[3]],
    CoinDimension -> coinDim, Stride -> stride];
  If[distribution === $Failed, Return[$Failed]];
  data = <|"InitialState" -> qwNormalizedState[state], "EvolutionOperator" -> evolution,
    "IPR" -> ipr, "Entropy" -> entropy, "LimitDistribution" -> distribution|>;
  If[TrueQ[qwOptionValue[opts, ReturnData, {}, False]], Return[data]];
  iprPlot = ListLinePlot[ipr, Frame -> True, Axes -> False,
    FrameLabel -> {"Step t", "Spatial IPR"}, PlotRange -> All,
    ScalingFunctions -> {None, "Log"}, ImageSize -> {600, 380}];
  entropyPlot = ListLinePlot[entropy, Frame -> True, Axes -> False,
    FrameLabel -> {"Step t", "Coin entanglement entropy [nats]"},
    PlotRange -> All, ImageSize -> {600, 380}];
  distributionPlot = DiscreteProbabilityPlot[grid, distribution,
    PlotLabel -> "Mean spatial probability", ImageSize -> {1100, 420}];
  GraphicsGrid[{{iprPlot, entropyPlot}, {distributionPlot, SpanFromLeft}}, ImageSize -> 1300]
];

GaussianState::position = "The center must be a finite real coordinate pair.";
GaussianState::sigma = "Sigma must be a finite positive real number.";
GaussianState[grid_, position_, coinState_, sigma_] := Module[{distances, amplitudes, state},
  If[!qwGridQ[grid], Message[GaussianState::grid]; Return[$Failed]];
  If[!VectorQ[position, qwFiniteNumberQ] || Length[position] != 2 ||
      !AllTrue[position, TrueQ[Im[N[#]] == 0] &],
    Message[GaussianState::position]; Return[$Failed]];
  If[!qwFiniteNumberQ[sigma] || !TrueQ[Im[N[sigma]] == 0 && sigma > 0],
    Message[GaussianState::sigma]; Return[$Failed]];
  If[!qwStateQ[coinState, 1] || !MemberQ[{2, 4}, Length[coinState]],
    Message[GaussianState::coin]; Return[$Failed]];
  distances = Total[(# - position)^2] & /@ grid["Coords"];
  (* Subtract the minimum exponent to retain very narrow/off-grid packets. *)
  amplitudes = If[# < Log[$MinMachineNumber], 0., Exp[#]] & /@
    (-N[(distances - Min[distances])/(2 sigma^2)]);
  state = Flatten[KroneckerProduct[amplitudes, Normalize[coinState/Max[Abs[coinState]]]]];
  Normalize[state]
];

(* --- Visualization compatibility: rendering is implemented only once. --- *)
VisualizeWalkerState[grid_Association, state_?VectorQ,
    scale_String : "Linear", upper_ : Automatic] :=
  DiscreteProbabilityPlot[grid, state,
    InputType -> "State",
    CoinDimension -> If[Length[Lookup[grid, "Coords", {}]] > 0,
      Length[state]/Length[grid["Coords"]], 4],
    ProbabilityScale -> scale,
    ProbabilityRange -> If[upper === Automatic, Automatic, {0, upper}]
  ];


LimitDistribution[states_List, coinDim_Integer : 4] := Module[{densities},
  If[states === {} || !MatrixQ[states, qwFiniteNumberQ] ||
      !AllTrue[states, qwStateQ[#, coinDim] &],
    Message[LimitDistribution::state, coinDim]; Return[$Failed]];
  densities = ComputeSpatialIPRDensity[#, coinDim] & /@ states;
  Mean[Sqrt[densities]]
];

LimitDistribution::time = "The maximum time `1` must be a nonnegative integer.";
LimitDistribution::stride = "Stride `1` must be a positive integer.";
LimitDistribution::grid = "The grid must contain a nonempty list of coordinate pairs and a matching positive integer Dimension.";
LimitDistribution::coin = "CoinDimension `1` must be a positive integer.";
LimitDistribution::state = "The initial state must be a finite numeric vector with `1` entries.";
LimitDistribution::operator = "The evolution operator must be a square matrix with dimensions `1`.";
LimitDistribution::numeric = "Evolution produced nonnumeric or nonfinite probabilities at time `1`.";

Options[LimitDistribution] = {Stride -> 1, "Stride" -> Automatic, CoinDimension -> 4};

LimitDistribution[grid_Association, evolution_, initialState_, tmax_,
    opts : OptionsPattern[]] := Module[
  {stride, coinDim, coords, n, dimension, state, sum, probabilities,
   sampleCount = 0, lastTime, failed = False},
  If[!IntegerQ[tmax] || tmax < 0,
   Message[LimitDistribution::time, tmax]; Return[$Failed]];
  stride = qwOptionValue[{opts}, Stride, {"Stride"}, OptionValue[Stride]];
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
  If[Length[initialState] != dimension,
   Message[LimitDistribution::state, dimension]; Return[$Failed]];
  state = qwPrepareEvolution[evolution, initialState, coinDim, LimitDistribution];
  If[state === $Failed, Return[$Failed]];
  sum = ConstantArray[0., n];
  lastTime = Quotient[tmax, stride] stride;
  Do[
   If[Mod[t, stride] == 0,
    probabilities = Quiet[ComputeSpatialIPRDensity[state, coinDim]];
    If[probabilities === $Failed,
     Message[LimitDistribution::numeric, t]; failed = True; Break[]];
    sum += Sqrt[probabilities];
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

(* Symbolic options are canonical; string spellings remain compatibility aliases. *)
Options[DiscreteProbabilityPlot] = Join[
  {InputType -> "Probabilities", "InputType" -> Automatic, CoinDimension -> 4,
   ProbabilityScale -> "Linear", "ProbabilityScale" -> Automatic,
   ProbabilityRange -> Automatic, "ProbabilityRange" -> Automatic,
   LogFloor -> 10^-12, "LogFloor" -> Automatic, ColorFunction -> (GrayLevel[1 - #] &),
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
  inputType = qwOptionValue[{opts}, InputType, {"InputType"}, OptionValue[InputType]];
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

  scale = qwOptionValue[{opts}, ProbabilityScale, {"ProbabilityScale"}, OptionValue[ProbabilityScale]];
  If[!MemberQ[{"Linear", "Sqrt", "CubeRoot", "Squared", "Log"}, scale],
   Message[DiscreteProbabilityPlot::scale, scale]; Return[$Failed]];
  probabilityRange = qwOptionValue[{opts}, ProbabilityRange, {"ProbabilityRange"}, OptionValue[ProbabilityRange]];
  If[probabilityRange === Automatic,
   probabilityRange = {0., If[Max[probabilities] > 0, Max[probabilities], 1.]}];
  If[!MatchQ[probabilityRange, {_, _}] ||
     !VectorQ[N[probabilityRange], realNonnegativeQ] ||
     !TrueQ[probabilityRange[[1]] < probabilityRange[[2]]],
   Message[DiscreteProbabilityPlot::range]; Return[$Failed]];
  probabilityRange = N[Re[probabilityRange]];

  If[scale === "Log",
   floor = N[qwOptionValue[{opts}, LogFloor, {"LogFloor"}, OptionValue[LogFloor]]];
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
QWAnimation::stride = "Stride `1` must be a positive integer.";
QWAnimation::operator = "The evolution operator must be a square matrix with dimensions `1`.";
QWAnimation::coin = "CoinDimension must be a positive integer; received `1`.";
QWAnimation::state = "The initial state must be a nonempty finite numeric vector.";

Options[QWAnimation] = DeleteDuplicatesBy[
  Join[{Stride -> 1, "Stride" -> Automatic, "FrameStride" -> Automatic, AnimationRunning -> True, PlotLabel -> Automatic},
    Options[DiscreteProbabilityPlot], Options[ListAnimate]], First];

QWAnimation[grid_Association, evolution_, initialState_, steps_,
    opts : OptionsPattern[]] := Module[
  {stride, state, plotOptions, animationOptions, label,
   frames, frame, result, tag = Unique["QWAnimationFailure"]},
  If[!IntegerQ[steps] || steps < 0,
   Message[QWAnimation::steps, steps]; Return[$Failed]];
  stride = qwOptionValue[{opts}, Stride, {"Stride", "FrameStride"}, OptionValue[Stride]];
  If[!IntegerQ[stride] || stride <= 0,
   Message[QWAnimation::stride, stride]; Return[$Failed]];
  If[!qwGridQ[grid] || Length[initialState] != grid["Dimension"] OptionValue[CoinDimension],
    Message[QWAnimation::state]; Return[$Failed]];
  state = qwPrepareEvolution[evolution, initialState, OptionValue[CoinDimension], QWAnimation];
  If[state === $Failed, Return[$Failed]];
  plotOptions = DeleteCases[FilterRules[{opts}, Options[DiscreteProbabilityPlot]],
    HoldPattern[(InputType | "InputType" | PlotLabel) -> _]];
  animationOptions = DeleteCases[FilterRules[{opts}, Options[ListAnimate]],
    HoldPattern[(PlotLabel | AnimationRunning | ImageSize) -> _]];
  label = OptionValue[PlotLabel];
  result = Catch[
    Reap[
      Do[
       If[Mod[t, stride] == 0 || t == steps,
        frame = DiscreteProbabilityPlot[grid, state,
          InputType -> "State",
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
ComputeSurvivalProbability::state = "Supply finite nonzero numeric states of matching lengths (or a matrix of final-state rows).";
ComputeSurvivalProbability[initialState_, final_] := Module[{initial, states, probabilities},
  states = If[VectorQ[final], {final}, final];
  If[!qwStateQ[initialState, 1] || !MatrixQ[states, qwFiniteNumberQ] ||
      Length[states] == 0 || Last[Dimensions[states]] != Length[initialState] ||
      !AllTrue[states, qwStateQ[#, 1] &],
    Message[ComputeSurvivalProbability::state]; Return[$Failed]];
  initial = qwNormalizedState[initialState];
  probabilities = Abs[(qwNormalizedState /@ states) . Conjugate[initial]]^2;
  If[VectorQ[final], First[probabilities], probabilities]
];

(* Spatial IPR traces out the coin BEFORE squaring the probabilities.
   It differs from Total[Abs[Normalize[state]]^4] in the position-coin basis. *)
ComputeSpatialIPR::coin = ComputeSpatialIPRDensity::coin =
  "CoinDim `1` must be a positive integer.";
ComputeSpatialIPR::state = ComputeSpatialIPRDensity::state =
  "The state must be a nonempty finite numeric vector whose length is divisible by CoinDim (`1`).";
ComputeSpatialIPR::zero = ComputeSpatialIPRDensity::zero =
  "The zero vector cannot be normalized to compute a spatial IPR.";


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
Get[FileNameJoin[{DirectoryName[$InputFileName], "QWMisc", "Private", "BoundarySpectrum.wl"}]];

EigenstateAtEnergy::energy = "epsilon must be a finite real numeric quasienergy.";
EigenstateAtEnergy::pairs = "Supply a nonempty list of finite nonzero eigenvalues and a matching rectangular list of eigenvectors with length divisible by CoinDimension.";
EigenstateAtEnergy::coin = "CoinDimension (`1`) must be a positive integer.";
EigenstateAtEnergy::state = "The selected eigenvector must be a finite numeric nonzero vector.";
EigenstateAtEnergy::args = "Use EigenstateAtEnergy[epsilon, eigenvals, eigenvecs, opts] with matching eigenpairs and a real numeric target.";

Options[EigenstateAtEnergy] = {CoinDimension -> 4, "CoinDimension" -> Automatic};
EigenstateAtEnergy[epsilon_?NumericQ, eigenvalues_List, eigenvectors_List,
    opts : OptionsPattern[]] := Module[
  {coinDim, dimensions, energies, distances, index, state, scale, ipr},
  coinDim = qwOptionValue[{opts}, CoinDimension, {"CoinDimension"}, OptionValue[CoinDimension]];
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
ComputeSpatialIPREvolution[evolution_, initialState_, steps_,
    opts : OptionsPattern[]] := Module[{coinDim, state, data, ipr, failed = False},
  If[!IntegerQ[steps] || steps < 0,
    Message[ComputeSpatialIPREvolution::steps, steps]; Return[$Failed]];
  coinDim = OptionValue[CoinDimension];
  state = qwPrepareEvolution[evolution, initialState, coinDim, ComputeSpatialIPREvolution];
  If[state === $Failed, Return[$Failed]];
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
  {coinDim, dimEspacio, state, data, entropy, failed = False},
  If[!IntegerQ[tmax] || tmax < 0,
    Message[ComputeEntanglementEntropyEvolution::time, tmax]; Return[$Failed]];
  coinDim = OptionValue[CoinDimension];
  state = qwPrepareEvolution[evolution, initialState, coinDim, ComputeEntanglementEntropyEvolution];
  If[state === $Failed, Return[$Failed]];
  dimEspacio = Length[state]/coinDim;
  data = ConstantArray[0., {tmax + 1, 2}];
  Do[
    entropy = Quiet[CoinEntanglementEntropy[state, dimEspacio]];
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
Options[SpatialIPREvolutionPlot] = Join[
  {CoinDimension -> 4, ShowUniformReference -> True, "ShowUniformReference" -> Automatic,
   ScalingFunctions -> {None, "Log"},
   PlotStyle -> {Directive[Blue, Thick], Directive[Gray, Dashed]},
   PlotLegends -> Automatic, Frame -> True, Axes -> False,
   FrameLabel -> {"Step t", "Spatial IPR"},
   PlotLabel -> "Spatial localization over time",
   GridLines -> Automatic, PlotRange -> All, ImageSize -> 700},
  DeleteCases[Options[ListLinePlot],
    HoldPattern[(ScalingFunctions | PlotStyle | PlotLegends | Frame | Axes |
      FrameLabel | PlotLabel | GridLines | PlotRange | ImageSize) -> _]]
];

SpatialIPREvolutionPlot[evolution_, initialState_, steps_,
    opts : OptionsPattern[]] := Module[{data, showReference, nSites, curves, legends, plotOptions},
  showReference = qwOptionValue[{opts}, ShowUniformReference, {"ShowUniformReference"}, OptionValue[ShowUniformReference]];
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
      {"Spatial IPR", "Uniform distribution: 1/N"}, {"Spatial IPR"}], Below]];
  plotOptions = DeleteCases[FilterRules[{opts}, Options[ListLinePlot]],
    HoldPattern[PlotLegends -> _]];
  ListLinePlot[curves, Sequence @@ plotOptions, PlotLegends -> legends,
    Sequence @@ DeleteCases[FilterRules[Options[SpatialIPREvolutionPlot], Options[ListLinePlot]],
      HoldPattern[PlotLegends -> _]]]
];

EntropiaMoneda[args___] := CoinEntanglementEntropy[args];
EvaluateOnNode[args___] := QuantumWalks`QWMisc`EjecutarEnNodo[args];

End[];

EndPackage[];
