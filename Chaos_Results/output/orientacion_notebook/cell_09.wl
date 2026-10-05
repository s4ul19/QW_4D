ClearAll[orientationTRCheck];
orientationTRCheck[path_Association, lambda_, alpha_] := Module[
  {grid, coords, n, d, r, c, cbig, s, u, q, targets},
  grid = QuantumWalks`Billiards`GenerateRectangleBasis[3, 2];
  coords = grid["Coords"]; n = grid["Dimension"]; d = 4 n;
  targets = Flatten[Table[
    4 (First[FirstPosition[coords, {3, 2} - pos]] - 1) + Range[4], {pos, coords}]];
  r = SparseArray[Thread[Transpose[{targets, Range[d]}] -> 1.], {d, d}];
  c = orientationCoin[path, lambda, alpha];
  cbig = KroneckerProduct[IdentityMatrix[n, SparseArray], SparseArray[c]];
  s = QuantumWalks`QWMisc`QWEvolutionOperator[grid, IdentityMatrix[4]];
  u = s . cbig; q = ConjugateTranspose[cbig] . r;
  <|"ShiftReversalError" -> Norm[Normal[r . s . r - ConjugateTranspose[s]], "Frobenius"],
    "ThetaSquaredError" -> Norm[Normal[q . Conjugate[q] - IdentityMatrix[d]], "Frobenius"],
    "TimeReversalError" -> Norm[Normal[q . Conjugate[u] . ConjugateTranspose[q] - ConjugateTranspose[u]], "Frobenius"]|>
];
orientationChecks = Flatten[Table[Join[
  KeyTake[path, {"Name", "Seed"}], <|"Lambda" -> lambda|>,
  orientationCoinErrors[path, lambda, orientationConfig["Alpha"]],
  orientationTRCheck[path, lambda, orientationConfig["Alpha"]]],
  {path, orientationPaths}, {lambda, {0., 0.5, 1.}}], 1];
orientationChecksPassed = AllTrue[orientationChecks,
  Max[Values[KeyDrop[#, {"Name", "Seed", "Lambda"}]]] < orientationConfig["NumericalTolerance"] &];
Print["Invariantes correctas: ", orientationChecksPassed];
Dataset[orientationChecks]
