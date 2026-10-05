ClearAll[orientationSummarize];
orientationSummarize[rows_List] := Module[{groups},
  groups = GatherBy[rows, {#["Name"], #["Lambda"]} &];
  SortBy[Map[Function[group, Module[{means, valid},
    means = Lookup[group, "MeanR"]; valid = Select[means, NumericQ];
    <|"Name" -> First[group]["Name"], "Lambda" -> First[group]["Lambda"],
      "MeanR" -> If[valid === {}, Missing["Undefined"], Mean[valid]],
      "SE" -> If[Length[valid] < 2, Missing["TooFewRealizations"], StandardDeviation[valid]/Sqrt[Length[valid]]],
      "ValidRealizations" -> Length[valid], "Realizations" -> Length[group],
      "MeanZeroFraction" -> Mean[(#["ZeroSpacingCount"]/#["D"]) & /@ group],
      "MeanUndefinedFraction" -> Mean[(#["UndefinedRatioCount"]/#["D"]) & /@ group]|>
    ]], groups], {#["Name"], #["Lambda"]} &]
];
orientationSummary = orientationSummarize[orientationResults];
Dataset[orientationSummary]
