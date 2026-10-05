orientationConfig = <|
  "Lx" -> 12, "Ly" -> 8,
  "Names" -> {"oo", "gpg"}, "Seeds" -> {23, 47, 83},
  "RotationSeedOffset" -> 100000,
  "Lambdas" -> N[Subdivide[0, 1, 20]],
  "Alpha" -> N[Pi/2], "Tolerance" -> 1/10^10,
  "NumericalTolerance" -> 1/10^8, "CodeVersion" -> 1
|>;
ClearAll[orientationPath, orientationCoin, orientationCoinErrors];
orientationPath[name_String, seed_Integer, offset_Integer] := Module[{c0, a},
  c0 = N[QuantumWalks`QWMisc`RandomMatrix[name, "RandomSeed" -> seed]];
  a = BlockRandom[SeedRandom[seed + offset];
    RandomVariate[NormalDistribution[], {4, 4}]];
  a = a - Transpose[a];
  a = a/Norm[a, 2];
  <|"Name" -> name, "Seed" -> seed, "RotationSeed" -> seed + offset,
    "C0" -> c0, "A" -> a|>
];
orientationCoin[path_Association, lambda_?NumericQ, alpha_?NumericQ] :=
  With[{o = MatrixExp[lambda alpha path["A"]]},
    o . path["C0"] . Transpose[o]];
orientationCoinErrors[path_Association, lambda_, alpha_] := Module[{o, c, ev0, ev, match},
  o = MatrixExp[lambda alpha path["A"]];
  c = orientationCoin[path, lambda, alpha];
  ev0 = Eigenvalues[path["C0"]]; ev = Eigenvalues[c];
  match = Min[Max[Abs[ev - #]] & /@ Permutations[ev0]];
  <|"OrthogonalityError" -> Norm[Transpose[o] . o - IdentityMatrix[4], "Frobenius"],
    "RealityError" -> Norm[Im[o], "Frobenius"],
    "CoinSymmetryError" -> Norm[c - Transpose[c], "Frobenius"],
    "CoinUnitarityError" -> Norm[ConjugateTranspose[c] . c - IdentityMatrix[4], "Frobenius"],
    "CoinSpectrumError" -> match|>
];
orientationPaths = Flatten[Table[
  orientationPath[name, seed, orientationConfig["RotationSeedOffset"]],
  {name, orientationConfig["Names"]}, {seed, orientationConfig["Seeds"]}], 1];
Dataset[KeyTake[#, {"Name", "Seed", "RotationSeed"}] & /@ orientationPaths]
