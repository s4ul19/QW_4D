(* Regression tests for portable loading, conventions and shared dynamics. *)
Get[FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]], "scripts", "load_project.wl"}]];
testGrid = GenerateRectangleBasis[2, 2];
probeGrid = <|"Coords" -> {{0, 0}, {1, 0}, {0, 1}}, "Dimension" -> 3|>;
testCoin = N[FourierMatrix[4]];
testInitial = LocalizedState[testGrid, {1, 1}, {1, 0, 0, 0}];
testOperator = QWEvolutionOperator[testGrid, testCoin];

testClose[a_, b_] := Max[Abs[Flatten[N[a - b]]]] < 10^-10;

VerificationTest[Norm[Normal[testOperator . ConjugateTranspose[testOperator]] - IdentityMatrix[36]], 0.,
  SameTest -> (Abs[#1 - #2] < 10^-10 &), TestID -> "Unitary four-state walk"]

VerificationTest[Module[{grid = GenerateRectangleBasis[1, 1], coin = N[FourierMatrix[2]], s, c},
  s = BuildShiftOperators[grid, CoinDimension -> 2];
  c = KroneckerProduct[IdentityMatrix[4, SparseArray], SparseArray[coin]];
  testClose[Normal[QWEvolutionOperator[grid, coin]], Normal[s[[2]] . c . s[[1]] . c]]],
  True, TestID -> "Documented two-state split-step order"]

VerificationTest[QWEigenphases[GenerateRectangleBasis[0, 0], Exp[-I/5] IdentityMatrix[4]],
  Sort[{1/5 - Pi, 1/5 - Pi, 1/5, 1/5}], SameTest -> testClose,
  TestID -> "Quasienergy minus Arg convention"]

VerificationTest[Quiet[QWEvolutionOperator[<|"Coords" -> {{0, 0}}, "Dimension" -> 2|>, testCoin]],
  $Failed, TestID -> "Invalid grid"]

VerificationTest[Quiet[QWEigenphases[testGrid, IdentityMatrix[3]]], $Failed,
  TestID -> "Unsupported coin dimension"]

VerificationTest[Quiet[QWEvolutionOperator[testGrid, testCoin, CoinDimension -> 2]], $Failed,
  TestID -> "Coin dimension mismatch"]

VerificationTest[And @@ Table[With[{c = N[RandomMatrix[name, RandomSeed -> 9]]},
  Dimensions[c] === {4, 4} && testClose[c . ConjugateTranspose[c], IdentityMatrix[4]]],
  {name, RandomMatrixNames[]}], True, TestID -> "All nine project coins are unitary"]

VerificationTest[RandomMatrix["upu", RandomSeed -> 31] === RandomMatrix["upu", "RandomSeed" -> 31],
  True, TestID -> "Coin seed and legacy alias"]

VerificationTest[BlockRandom[SeedRandom[4]; Module[{expected, actual},
  expected = RandomReal[]; SeedRandom[4]; RandomMatrix["o", RandomSeed -> 71]; actual = RandomReal[];
  actual === expected]], True, TestID -> "Coin seed preserves random stream"]

VerificationTest[Quiet[RandomMatrix["unknown"]], $Failed, TestID -> "Invalid coin name"]

VerificationTest[Quiet[RandomMatrix["p", RandomSeed -> "bad"]], $Failed, TestID -> "Invalid seed"]

VerificationTest[RandomDelocalizedState[2, 2, RandomSeed -> 8] ===
  RandomDelocalizedState[2, 2, "RandomSeed" -> 8], True, TestID -> "State seed alias"]

VerificationTest[Quiet[GaussianState[testGrid, {1, 1}, {1, 0, 0, 0}, 0]], $Failed,
  TestID -> "Gaussian zero width rejected"]

VerificationTest[Quiet[LocalizedState[testGrid, {1, 1}, {0, 0, 0, 0}]], $Failed,
  TestID -> "Localized zero coin rejected"]

VerificationTest[Norm[GaussianState[testGrid, {100, 100}, {1, 0, 0, 0}, 10^-5]], 1.,
  SameTest -> (Abs[#1 - #2] < 10^-12 &), TestID -> "Narrow off-grid Gaussian remains normalized"]

VerificationTest[ComputeSurvivalProbability[{2, 0}, {{3, 0}, {0, 4}}], {1., 0.},
  TestID -> "Survival normalizes both states"]

VerificationTest[Quiet[ComputeSurvivalProbability[{1, 0}, {0, 0}]], $Failed,
  TestID -> "Survival zero state rejected"]

VerificationTest[Quiet[ComputeSurvivalProbability[{1, 0}, {1, 0, 0}]], $Failed,
  TestID -> "Survival incompatible states rejected"]

VerificationTest[CoinEntanglementEntropy[{1, 0, 0, 1}, 2], Log[2],
  SameTest -> (Abs[#1 - #2] < 10^-12 &), TestID -> "Bell entropy in nats"]

VerificationTest[CoinEntanglementEntropy[{1, I, 0, 2}, 2] === EntropiaMoneda[{1, I, 0, 2}, 2],
  True, TestID -> "Entropy compatibility alias"]

VerificationTest[Quiet[ComputeEntanglementEntropyEvolution[IdentityMatrix[4], {1, 0, 0, 0}, -1]],
  $Failed, TestID -> "Entropy negative horizon"]

VerificationTest[Quiet[ComputeSpatialIPREvolution[{{1, Infinity}, {0, 1}}, {1, 0}, 1, CoinDimension -> 1]],
  $Failed, TestID -> "Nonfinite operator rejected"]

VerificationTest[Quiet[LimitDistribution[testGrid, testOperator, ConstantArray[0, 36], 1]],
  $Failed, TestID -> "Limit distribution zero state rejected"]

VerificationTest[Module[{states, streamed},
  states = NestList[testOperator . # &, Normal[testInitial], 5];
  streamed = LimitDistribution[testGrid, testOperator, 7 testInitial, 5, Stride -> 2];
  testClose[streamed, LimitDistribution[states[[{1, 3, 5}]]]]], True,
  TestID -> "Stride samples physical times 0 2 4 and normalizes state"]

VerificationTest[LimitDistribution[testGrid, testOperator, testInitial, 4, Stride -> 2] ===
  LimitDistribution[testGrid, testOperator, testInitial, 4, "Stride" -> 2], True,
  TestID -> "Distribution stride legacy alias"]

VerificationTest[Module[{data},
  data = QWDynamicsData[testGrid, testCoin, testInitial,
    IPRSteps -> 2, EntropySteps -> 3, DistributionSteps -> 4, ReturnData -> True];
  data["IPR"][[All, 1]] == Range[0, 2] && data["Entropy"][[All, 1]] == Range[0, 3] &&
    testClose[data["LimitDistribution"], LimitDistribution[
      NestList[testOperator . # &, Normal[testInitial], 4]]]], True,
  TestID -> "Dynamics horizons include physical zero and correct average"]

VerificationTest[Module[{a, b},
  a = QWDynamicsData[testGrid, testCoin, RandomSeed -> 8,
    IPRSteps -> 0, EntropySteps -> 0, DistributionSteps -> 0, ReturnData -> True];
  b = QWDynamicsData[testGrid, testCoin, "RandomSeed" -> 8,
    IPRSteps -> 0, EntropySteps -> 0, DistributionSteps -> 0, ReturnData -> True];
  a === b], True, TestID -> "Dynamics automatic state reproducible"]

VerificationTest[Quiet[QWDynamicsData[GenerateRectangleBasis[0, 0], IdentityMatrix[4],
  IPRSteps -> 0, EntropySteps -> 0, DistributionSteps -> 0]], $Failed,
  TestID -> "No interior requires explicit state"]

VerificationTest[Quiet[QWDynamicsData[testGrid, testCoin, IPRSteps -> -1]], $Failed,
  TestID -> "Dynamics invalid horizon"]

VerificationTest[Length[QWPr[{0, Pi/2, Pi}, ReturnData -> True]["Ratios"]], 3,
  TestID -> "Circular r includes closing spacing"]

VerificationTest[Sort[QWPr[{0, Pi/2, Pi}, ReturnData -> True]["Ratios"]], {0.5, 0.5, 1.},
  SameTest -> testClose, TestID -> "Circular r ratios"]

VerificationTest[Quiet[QWPr[{0, 0, Pi}, ReturnData -> True]], $Failed,
  TestID -> "Duplicate circular phases rejected"]

VerificationTest[Module[{data, cue},
  data = QWSFF[N[Subdivide[-3, 3, 31]], ReturnData -> True];
  cue = data["RMTReferences"]["CUE"];
  Keys[data["RMTReferences"]] === {"COE", "CUE"} &&
    testClose[cue[[All, 2]], Min[#, 1] & /@ cue[[All, 1]]]], True,
  TestID -> "SFF provides COE and CUE with correct unitary reference"]

VerificationTest[Quiet[QWSFF[N[Subdivide[-3, 3, 31]], RMTEnsembles -> {3}, ReturnData -> True]],
  $Failed, TestID -> "Unsupported SFF ensemble rejected"]

VerificationTest[EigenstateAtEnergy[.2, Exp[-I {.2, -.6}], IdentityMatrix[2], CoinDimension -> 1]["Index"],
  1, TestID -> "Energy selection sign"]

VerificationTest[EigenstateAtEnergy[-Pi + .01, Exp[-I {Pi - .01, 0}], IdentityMatrix[2], CoinDimension -> 1]["Index"],
  1, TestID -> "Energy selection across branch cut"]

VerificationTest[EigenstateAtEnergy[.2, Exp[-I {.2, -.6}], IdentityMatrix[2], CoinDimension -> 1] ===
  EigenstateAtEnergy[.2, Exp[-I {.2, -.6}], IdentityMatrix[2], "CoinDimension" -> 1],
  True, TestID -> "Energy selection coin alias"]

VerificationTest[Module[{analysis}, analysis = AnalyzeBoundaryEigenstates[testGrid,
  Exp[-I {.2}], {Normal[testInitial]}, CoinDimension -> 4];
  analysis["BoundarySiteIndices"] === {1, 2, 3, 4, 6, 7, 8, 9} &&
    Abs[First[analysis["Data"]]["Energy"] - .2] < 10^-12], True,
  TestID -> "Boundary neighbors and quasienergy sign"]

VerificationTest[Module[{before}, before = QWEigenphases[testGrid, testCoin];
  Get[FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]], "QWMisc.wl"}]];
  before === QWEigenphases[testGrid, testCoin] && Length[DownValues[QWEigenphases]] == 1],
  True, TestID -> "Package reload resets definitions consistently"]

VerificationTest[DiscreteProbabilityPlot[probeGrid, {0.1, 0.2, 0.7},
  ProbabilityScale -> "Log", ProbabilityRange -> {0.001, 1}, LogFloor -> 0.001,
  InputType -> "Probabilities", PlotLegends -> None] ===
  DiscreteProbabilityPlot[probeGrid, {0.1, 0.2, 0.7},
  "ProbabilityScale" -> "Log", "ProbabilityRange" -> {0.001, 1}, "LogFloor" -> 0.001,
  "InputType" -> "Probabilities", PlotLegends -> None], True,
  TestID -> "Symbolic plot options preserve legacy behavior"]

VerificationTest[AnalyzeBoundaryEigenstates[testGrid, {1.}, {Normal[testInitial]},
  BoundaryWidth -> 1, BoundaryThreshold -> .5, CornerWidth -> 1] ===
  AnalyzeBoundaryEigenstates[testGrid, {1.}, {Normal[testInitial]},
  "BoundaryWidth" -> 1, "BoundaryThreshold" -> .5, "CornerWidth" -> 1], True,
  TestID -> "Symbolic boundary options preserve legacy behavior"]
