base = DirectoryName[$InputFileName];
cells = Select[Import[FileNameJoin[{base, "cells.json"}], "RawJSON"], #["style"] === "Input" &];
project = "/Users/saul/Desktop/ChatGPT/QWProgramming";
Block[{NotebookDirectory = Function[project]}, ToExpression[cells[[1]]["text"], InputForm]];
ToExpression[cells[[2]]["text"], InputForm];
orientationConfig = Join[orientationConfig, <|"Lx" -> 3, "Ly" -> 2, "Seeds" -> {23, 47}, "Lambdas" -> {0., 0.5, 1.}|>];
orientationPaths = Flatten[Table[orientationPath[name, seed, orientationConfig["RotationSeedOffset"]],
  {name, orientationConfig["Names"]}, {seed, orientationConfig["Seeds"]}], 1];
ToExpression[cells[[3]]["text"], InputForm];
If[!TrueQ[orientationChecksPassed], Print["FAIL invariants"]; Quit[1]];
ToExpression[cells[[4]]["text"], InputForm];
orientationRoot = FileNameJoin[{base, "smoke"}];
ToExpression[cells[[5]]["text"], InputForm];
If[!ListQ[orientationResults] || Length[orientationResults] =!= 12, Print["FAIL scan: ", Short[orientationResults]]; Quit[2]];
firstRun = orientationResults;
ToExpression[cells[[5]]["text"], InputForm];
If[orientationResults =!= firstRun, Print["FAIL resume"]; Quit[3]];
Do[ToExpression[cells[[j]]["text"], InputForm], {j,6,10}];
If[Length[orientationSummary] =!= 6 || !FreeQ[{orientationRPlot, orientationDegeneracyPlot, orientationPhasePlot}, _ListPlot | _ListLinePlot],
 Print["FAIL plots"]; Quit[4]];
(* Independent baseline: direct public eigenphase function, instead of cached shift. *)
smallGrid = QuantumWalks`Billiards`GenerateRectangleBasis[3,2];
originalPhases = QuantumWalks`QWMisc`QWEigenphases[smallGrid, First[orientationPaths]["C0"]];
If[Max[Abs[originalPhases - First[orientationResults]["Phases"]]] > 10^-10, Print["FAIL lambda zero"]; Quit[5]];
(* Snapshot/checkpoint schema and all numerical bounds. *)
If[!AllTrue[orientationResults, #["EigenvalueModulusError"] < 10^-10 && Length[#["Phases"]] == 48 &], Quit[6]];
Print["PASS: 12 points, 2 families, 2 seeds, invariants, lambda=0 baseline, resume, summary, P(r)/P(s) and plots."];
Print["Max TR residual: ", Max[Lookup[orientationChecks, "TimeReversalError"]]];
Print["Output heads: ", Head /@ {orientationRPlot, orientationDegeneracyPlot, orientationPhasePlot}];
Quit[0];
