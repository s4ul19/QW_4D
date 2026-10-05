orientationSelectedName = "oo";
orientationSelectedSeed = 23;
orientationPhaseWindow = {-0.5, 0.5};
orientationSelected = SortBy[Select[orientationResults,
  #["Name"] == orientationSelectedName && #["Seed"] == orientationSelectedSeed &], #["Lambda"] &];
orientationSlices = DeleteDuplicates[Table[
  First[MinimalBy[orientationSelected, Abs[#["Lambda"] - target] &]], {target, {0., 0.5, 1.}}]];
Column[Table[With[{label = Row[{row["Name"], ", seed=", row["Seed"], ", lambda=", row["Lambda"]}]},
  QuantumWalks`QWMisc`QWPr[row["Phases"], "AllowDegeneracies" -> True,
    "DegeneracyTolerance" -> orientationConfig["Tolerance"], PlotLabel -> label]],
  {row, orientationSlices}]]
