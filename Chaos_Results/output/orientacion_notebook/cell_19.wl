orientationRPlot = ListPlot[
  Table[Cases[Select[orientationSummary, #["Name"] == name &],
    a_Association /; NumericQ[a["MeanR"]] :>
      {a["Lambda"], If[NumericQ[a["SE"]], Around[a["MeanR"], a["SE"]], a["MeanR"]]}],
    {name, orientationConfig["Names"]}],
  Joined -> True, PlotMarkers -> Automatic, IntervalMarkers -> "Bars",
  PlotLegends -> orientationConfig["Names"], Frame -> True,
  FrameLabel -> {"lambda", "<r> (media entre realizaciones)"},
  GridLines -> {None, {2 Log[2] - 1, 0.5307, 0.5996}},
  PlotRange -> {{0, 1}, {0, 0.7}}, ImageSize -> Large,
  PlotLabel -> "Referencias: Poisson 0.3863; ortogonal 0.5307; unitaria 0.5996"];
orientationDegeneracyPlot = ListLinePlot[
  Flatten[Table[{
    ({#["Lambda"], #["MeanZeroFraction"]} & /@ Select[orientationSummary, #["Name"] == name &]),
    ({#["Lambda"], #["MeanUndefinedFraction"]} & /@ Select[orientationSummary, #["Name"] == name &])},
    {name, orientationConfig["Names"]}], 1],
  PlotLegends -> Flatten[({# <> " gaps cero", # <> " pares 0/0"} & /@ orientationConfig["Names"])],
  Frame -> True, FrameLabel -> {"lambda", "fraccion"}, PlotRange -> All, ImageSize -> Large];
Column[{orientationRPlot, orientationDegeneracyPlot}]
