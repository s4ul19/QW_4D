(* Small independent fixtures for the original notebook assertions. *)
Get[FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]], "scripts", "load_project.wl"}]];

iprGrid = GenerateRectangleBasis[8, 5];
iprCoin = Normalize[{1, I, -1, 0}];
iprN = iprGrid["Dimension"];
iprLocalized = LocalizedState[iprGrid, {2, 3}, iprCoin];
iprUniform = Flatten[KroneckerProduct[ConstantArray[1/Sqrt[iprN], iprN], iprCoin]];
iprGaussian = GaussianState[iprGrid, {2, 3}, iprCoin, 1.2];
iprStates = {iprLocalized, iprUniform, iprGaussian};
iprProbabilities = Total[Partition[Abs[Normal[#]/Norm[#]]^2, 4], {2}] & /@ iprStates;
iprDensities = ComputeSpatialIPRDensity /@ iprStates;
iprTotals = ComputeSpatialIPR /@ iprStates;
iprEigenGrid = GenerateRectangleBasis[4, 3];
iprEvolution = QWEvolutionOperator[iprEigenGrid, N[FourierMatrix[4]]];
{iprEigenvalues, iprEigenvectors} = Eigensystem[N[Normal[iprEvolution]]];
iprEigenOrder = Ordering[-Arg[iprEigenvalues]];
iprEigenIndex = iprEigenOrder[[Ceiling[Length[iprEigenOrder]/2]]];
iprEigenstate = Normalize[iprEigenvectors[[iprEigenIndex]]];
iprEigenDensity = ComputeSpatialIPRDensity[iprEigenstate];
iprEigenTotal = ComputeSpatialIPR[iprEigenstate];

grid = iprGrid; coin = iprCoin; psi = iprGaussian;
probabilities = Total[Partition[Abs[Normal[psi]]^2, 4], {2}];
statePlot = DiscreteProbabilityPlot[grid, psi, "InputType" -> "State", PlotLegends -> None];
probabilityPlot = DiscreteProbabilityPlot[grid, probabilities, PlotLegends -> None];
rasterData[plot_] := First[Cases[plot, Raster[values_, ___] :> values, Infinity]];
legendData[plot_] := First[Cases[plot, BarLegend[{f_, bounds_}, ___] :> {f, bounds}, Infinity]];
graphicsRange[plot_] := PlotRange /. AbsoluteOptions[plot, PlotRange];
probeGrid = <|"Coords" -> {{0, 0}, {1, 0}, {0, 1}}, "Dimension" -> 3|>;
probeState = Flatten[Outer[Times, Sqrt[{0.1, 0.2, 0.7}], {1, 0, 0, 0}]];
fixedA = DiscreteProbabilityPlot[probeGrid, {0.1, 0.2, 0.7}, "ProbabilityRange" -> {0, 1}, PlotLegends -> None];
fixedB = DiscreteProbabilityPlot[probeGrid, {0.1, 0.4, 0.5}, "ProbabilityRange" -> {0, 1}, PlotLegends -> None];
irregularGrid = <|"Coords" -> {{-2, 3}, {-2, 4}, {-1, 4}}, "Dimension" -> 3|>;
irregularProbabilities = {0, 0.2, 0.8};
irregularPlot = DiscreteProbabilityPlot[irregularGrid, irregularProbabilities,
  "ProbabilityRange" -> {0, 1}, ColorFunction -> "SunsetColors", PlotLegends -> None];
states = NestList[QWEvolutionOperator[grid, N[FourierMatrix[4]]] . # &, Normal[psi], 4];
averageProbabilities = LimitDistribution[states];
scales = {"Linear", "Sqrt", "CubeRoot", "Squared", "Log"};
