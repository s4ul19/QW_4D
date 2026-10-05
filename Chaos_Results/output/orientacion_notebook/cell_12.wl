ClearAll[orientationPoint, orientationSave, orientationRun];
orientationPoint[path_Association, lambda_, cfg_Association, shift_] := Module[
  {c, errors, n, u, vals, phases, data, elapsed, modulusError},
  c = orientationCoin[path, lambda, cfg["Alpha"]];
  errors = orientationCoinErrors[path, lambda, cfg["Alpha"]];
  If[Max[Values[errors]] >= cfg["NumericalTolerance"],
    Return[Failure["CoinInvariant", <|"Errors" -> errors|>]]];
  n = Length[shift]/4;
  {elapsed, vals} = AbsoluteTiming[
    u = N[shift . KroneckerProduct[IdentityMatrix[n, SparseArray], SparseArray[c]]];
    Eigenvalues[Normal[u]]];
  If[!VectorQ[vals, NumericQ], Return[Failure["Eigensystem", <||>]]];
  modulusError = Max[Abs[Abs[vals] - 1]];
  If[modulusError >= cfg["NumericalTolerance"],
    Return[Failure["UnitCircle", <|"Error" -> modulusError|>]]];
  phases = Sort[-Arg[vals]];
  data = QuantumWalks`QWMisc`QWPr[phases, "ReturnData" -> True,
    "AllowDegeneracies" -> True, "DegeneracyTolerance" -> cfg["Tolerance"]];
  If[!AssociationQ[data], Return[Failure["Ratios", <||>]]];
  Join[KeyTake[path, {"Name", "Seed", "RotationSeed"}],
    <|"Lambda" -> lambda, "D" -> Length[vals], "Coin" -> c,
      "Phases" -> phases, "Ratios" -> data["Ratios"],
      "MeanR" -> If[data["Ratios"] === {}, Missing["Undefined"], Mean[data["Ratios"]]],
      "ZeroSpacingCount" -> data["ZeroSpacingCount"],
      "UndefinedRatioCount" -> data["UndefinedRatioCount"],
      "EigenvalueModulusError" -> modulusError, "Seconds" -> elapsed|>, errors]
];
orientationSave[file_String, value_] := Module[{temporary = file <> ".partial", saved},
  saved = Export[temporary, value, "WXF"];
  If[!StringQ[saved], Return[Failure["Export", <|"File" -> file|>]]];
  RenameFile[temporary, file, OverwriteTarget -> True]
];
orientationRun[cfg_Association, paths_List, directory_String] := Catch[Module[
  {grid, shift, rows = {}, file, row, count = 0, total},
  grid = QuantumWalks`Billiards`GenerateRectangleBasis[cfg["Lx"], cfg["Ly"]];
  shift = QuantumWalks`QWMisc`QWEvolutionOperator[grid, IdentityMatrix[4]];
  If[shift === $Failed, Throw[Failure["Shift", <||>], "orientation"]];
  total = Length[paths] Length[cfg["Lambdas"]];
  Do[
    file = FileNameJoin[{directory, path["Name"] <> "-seed" <> ToString[path["Seed"]] <>
      "-point" <> IntegerString[j, 10, 4] <> ".wxf"}];
    row = If[FileExistsQ[file], Import[file, "WXF"],
      orientationPoint[path, cfg["Lambdas"][[j]], cfg, shift]];
    If[!AssociationQ[row] || !(And @@ (KeyExistsQ[row, #] & /@
      {"Name", "Seed", "Lambda", "Phases", "Ratios", "MeanR", "ZeroSpacingCount", "UndefinedRatioCount", "D"})),
      Throw[Failure["Point", <|"File" -> file, "Result" -> row|>], "orientation"]];
    If[row["Name"] =!= path["Name"] || row["Seed"] =!= path["Seed"] ||
      row["Lambda"] =!= cfg["Lambdas"][[j]] || row["D"] =!= 4 grid["Dimension"],
      Throw[Failure["CheckpointMismatch", <|"File" -> file|>], "orientation"]];
    If[!FileExistsQ[file] && !StringQ[orientationSave[file, row]],
      Throw[Failure["Save", <|"File" -> file|>], "orientation"]];
    AppendTo[rows, row]; count++;
    Print[count, "/", total, "  ", path["Name"], " seed=", path["Seed"],
      " lambda=", row["Lambda"], "  <r>=", row["MeanR"],
      "  ceros=", row["ZeroSpacingCount"], "  0/0=", row["UndefinedRatioCount"]],
    {path, paths}, {j, Length[cfg["Lambdas"]]}];
  rows
], "orientation"];
