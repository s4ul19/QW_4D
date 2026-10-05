orientationColumns = {"Name", "Lambda", "MeanR", "SE", "ValidRealizations", "Realizations", "MeanZeroFraction", "MeanUndefinedFraction"};
Export[FileNameJoin[{orientationDirectory, "summary.csv"}],
  Prepend[(Lookup[#, orientationColumns] & /@ orientationSummary), orientationColumns], "CSV"];
Export[FileNameJoin[{orientationDirectory, "mean_r.pdf"}], orientationRPlot];
Export[FileNameJoin[{orientationDirectory, "degeneracies.pdf"}], orientationDegeneracyPlot];
Export[FileNameJoin[{orientationDirectory, "eigenphases.pdf"}], orientationPhasePlot];
orientationDirectory
