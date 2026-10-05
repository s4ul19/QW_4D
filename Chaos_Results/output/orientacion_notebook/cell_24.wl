orientationPhasePlot = ListPlot[Flatten[Table[
  ({row["Lambda"], #} & /@ Select[row["Phases"],
    orientationPhaseWindow[[1]] <= # <= orientationPhaseWindow[[2]] &]),
  {row, orientationSelected}], 1],
  Frame -> True, FrameLabel -> {"lambda", "epsilon"},
  PlotRange -> {{0, 1}, orientationPhaseWindow}, PlotStyle -> PointSize[0.003],
  PlotLabel -> "Eigenfases: puntos sin seguimiento de eigenvectores", ImageSize -> Large];
orientationPhasePlot
