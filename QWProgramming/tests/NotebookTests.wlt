(* Migrated VerificationTest expressions from FunctionsTester.nb. *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "notebook_setup.wl"}]];

VerificationTest[ComputeSpatialIPR[iprLocalized], 1, TestID -> "IPR localizada"]

VerificationTest[ComputeSpatialIPR[iprUniform], 1/iprN, TestID -> "IPR uniforme"]

VerificationTest[ComputeSpatialIPRDensity[iprUniform], ConstantArray[1/iprN^2, iprN], TestID -> "Densidad uniforme"]

VerificationTest[Max[Abs[iprDensities[[3]] - iprProbabilities[[3]]^2]] < 1/10^12, True, TestID -> "I_n = P_n^2"]

VerificationTest[Abs[Total[iprEigenDensity] - iprEigenTotal] < 1/10^12, True, TestID -> "Suma local = IPR del eigenvector"]

VerificationTest[Norm[iprEvolution . iprEigenstate - iprEigenvalues[[iprEigenIndex]]*iprEigenstate] < 1/10^10, True, TestID -> "Eigenvector válido"]

VerificationTest[And @@ (1/iprN - 1/10^12 <= #1 <= 1 + 1/10^12 & ) /@ iprTotals, True, TestID -> "Cotas 1/N <= IPR <= 1"]

VerificationTest[ComputeSpatialIPRDensity[SparseArray[{2 -> I, 7 -> 2}, {8}]], {1/25, 16/25}, TestID -> "Estado disperso complejo"]

VerificationTest[ComputeSpatialIPRDensity[7*I*{1, I, 0, 2}, 2], {1/9, 4/9}, TestID -> "Invariancia bajo reescalamiento"]

VerificationTest[ComputeSpatialIPRDensity[{1, I, 0, 2}, 1], {1/36, 1/36, 0, 4/9}, TestID -> "Dimensión de moneda 1"]

VerificationTest[{ComputeSpatialIPR[{1, I, 0, 0}/Sqrt[2]], Total[Abs[{1, I, 0, 0}/Sqrt[2]]^4]}, {1, 1/2}, TestID -> "IPR espacial distinta de posición-moneda"]

VerificationTest[Quiet[ComputeSpatialIPR[ConstantArray[0, 8]]], $Failed, TestID -> "Rechazo del vector cero"]

VerificationTest[Quiet[ComputeSpatialIPRDensity[{1, 2, 3}]], $Failed, TestID -> "Rechazo de longitud incompatible"]

VerificationTest[Quiet[ComputeSpatialIPR[{1, 2}, 0]], $Failed, TestID -> "Rechazo de dimensión de moneda inválida"]

VerificationTest[Quiet[ComputeSpatialIPR[{Infinity, 0}, 2]], $Failed, TestID -> "Rechazo de amplitudes no finitas"]

VerificationTest[ComputeSpatialIPREvolution[IdentityMatrix[8, SparseArray], {1, 0, 0, 0, 0, 0, 0, 0}, 3], {{0, 1.}, {1, 1.}, {2, 1.}, {3, 1.}}, TestID -> "Identidad y tiempos desde cero"]

VerificationTest[ComputeSpatialIPREvolution[IdentityMatrix[8, SparseArray], ConstantArray[1, 8], 0], {{0, 0.5}}, TestID -> "Cero pasos y estado no normalizado"]

VerificationTest[Max[Abs[ComputeSpatialIPREvolution[N[FourierMatrix[4]], {1, 0, 0, 0}, 5, CoinDimension -> 2][[All,2]] - (ComputeSpatialIPR[#1, 2] & ) /@ NestList[N[FourierMatrix[4]] . #1 & , {1., 0., 0., 0.}, 5]]] < 1/10^12, True, TestID -> "CoinDimension 2 y comparación con NestList"]

VerificationTest[Quiet[ComputeSpatialIPREvolution[IdentityMatrix[8], ConstantArray[0, 8], 3]], $Failed, TestID -> "Estado cero"]

VerificationTest[Quiet[ComputeSpatialIPREvolution[IdentityMatrix[4], ConstantArray[1, 8], 3]], $Failed, TestID -> "Dimensiones incompatibles"]

VerificationTest[Quiet[ComputeSpatialIPREvolution[IdentityMatrix[8], ConstantArray[1, 8], -1]], $Failed, TestID -> "Pasos negativos"]

VerificationTest[Quiet[ComputeSpatialIPREvolution[ConstantArray[0, {8, 8}], ConstantArray[1, 8], 2]], $Failed, TestID -> "Evolución a estado cero"]

VerificationTest[FrameLabel /. Options[statePlot, FrameLabel], {"x", "y"}, TestID -> "Etiquetas de ejes"]

VerificationTest[With[{legend = legendData[DiscreteProbabilityPlot[grid, probabilities]]}, legend[[1]][legend[[2,2]]]], GrayLevel[0.], TestID -> "Leyenda: máximo"]

VerificationTest[With[{legend = legendData[DiscreteProbabilityPlot[grid, probabilities, "ProbabilityScale" -> "Log"]]}, legend[[1]][legend[[2,1]]]], GrayLevel[1.], TestID -> "Leyenda logarítmica: mínimo"]

VerificationTest[statePlot === probabilityPlot, True, TestID -> "Estado y probabilidades"]

VerificationTest[DiscreteProbabilityPlot[probeGrid, SparseArray[probeState], "InputType" -> "State", PlotLegends -> None] === DiscreteProbabilityPlot[probeGrid, probeState, "InputType" -> "State", PlotLegends -> None], True, TestID -> "Estado disperso"]

VerificationTest[DiscreteProbabilityPlot[probeGrid, SparseArray[{0.1, 0.2, 0.7}], PlotLegends -> None] === DiscreteProbabilityPlot[probeGrid, {0.1, 0.2, 0.7}, PlotLegends -> None], True, TestID -> "Probabilidades dispersas"]

VerificationTest[VisualizeWalkerState[grid, psi] === DiscreteProbabilityPlot[grid, psi, "InputType" -> "State"], True, TestID -> "Compatibilidad"]

VerificationTest[rasterData[fixedA][[1,1]], rasterData[fixedB][[1,1]], TestID -> "Color fijo entre cuadros"]

VerificationTest[rasterData[irregularPlot][[1,1]], List @@ ColorData["SunsetColors"][0.], SameTest -> (Max[Abs[#1 - #2]] < 1/10^10 & ), TestID -> "Sitio nulo en (-2,3)"]

VerificationTest[rasterData[irregularPlot][[2,2]], List @@ ColorData["SunsetColors"][0.8], SameTest -> (Max[Abs[#1 - #2]] < 1/10^10 & ), TestID -> "Máximo en (-1,4)"]

VerificationTest[rasterData[irregularPlot][[1,2]], {0.85, 0.85, 0.85}, TestID -> "Exterior gris"]

VerificationTest[graphicsRange[irregularPlot], {{-2.5, -0.5}, {2.5, 4.5}}, TestID -> "Bordes completos"]

VerificationTest[Head[DiscreteProbabilityPlot[probeGrid, {0, 0, 0}]], Legended, TestID -> "Probabilidades nulas"]

VerificationTest[Head[DiscreteProbabilityPlot[probeGrid, {0, 0, 0}, "ProbabilityScale" -> "Log"]], Legended, TestID -> "Logaritmo de ceros"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, {0.1, 0.9}]], $Failed, TestID -> "Longitud incorrecta"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, {0.1, -0.1, 1.}]], $Failed, TestID -> "Probabilidad negativa"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, {0.1, I, 0.9}]], $Failed, TestID -> "Probabilidad compleja"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, {0.1, Infinity, 0.9}]], $Failed, TestID -> "Probabilidad infinita"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, probeState, "InputType" -> "State", CoinDimension -> 3.5]], $Failed, TestID -> "Moneda no entera"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, probeState, "InputType" -> "State", CoinDimension -> 2]], $Failed, TestID -> "Estado de longitud incorrecta"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, {0.1, 0.2, 0.7}, "InputType" -> "Other"]], $Failed, TestID -> "Tipo de entrada desconocido"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, {0.1, 0.2, 0.7}, "ProbabilityScale" -> "Other"]], $Failed, TestID -> "Escala desconocida"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, {0.1, 0.2, 0.7}, "ProbabilityRange" -> {1, 0}]], $Failed, TestID -> "Intervalo inválido"]

VerificationTest[Quiet[DiscreteProbabilityPlot[probeGrid, {0.1, 0.2, 0.7}, "ProbabilityScale" -> "Log", "LogFloor" -> 0]], $Failed, TestID -> "Piso logarítmico inválido"]

VerificationTest[Quiet[DiscreteProbabilityPlot[Association["Coords" -> {{0, 0}, {0, 0}}, "Dimension" -> 2], {0.5, 0.5}]], $Failed, TestID -> "Coordenadas duplicadas"]

VerificationTest[Quiet[DiscreteProbabilityPlot[Association["Coords" -> {{0.5, 0}}, "Dimension" -> 1], {1}]], $Failed, TestID -> "Coordenadas no enteras"]

VerificationTest[Max[Abs[Norm /@ states - 1]] < 1/10^10, True, TestID -> "Norma durante la caminata"]

VerificationTest[Abs[Total[averageProbabilities] - 1] < 1/10^10, True, TestID -> "Promedio normalizado"]

VerificationTest[Head[DiscreteProbabilityPlot[grid, probabilities, "ProbabilityScale" -> "Linear"]], Legended, TestID -> "Escala Linear"]

VerificationTest[Head[DiscreteProbabilityPlot[grid, probabilities, "ProbabilityScale" -> "Sqrt"]], Legended, TestID -> "Escala Sqrt"]

VerificationTest[Head[DiscreteProbabilityPlot[grid, probabilities, "ProbabilityScale" -> "CubeRoot"]], Legended, TestID -> "Escala CubeRoot"]

VerificationTest[Head[DiscreteProbabilityPlot[grid, probabilities, "ProbabilityScale" -> "Squared"]], Legended, TestID -> "Escala Squared"]

VerificationTest[Head[DiscreteProbabilityPlot[grid, probabilities, "ProbabilityScale" -> "Log"]], Legended, TestID -> "Escala Log"]
