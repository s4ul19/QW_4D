(* Validate notebook structure and compatibility entry points without running experiments. *)
integrityRoot = DirectoryName[DirectoryName[$InputFileName]];
integrityFiles = Join[{FileNameJoin[{integrityRoot, "FunctionsTester.nb"}]},
  FileNames["*.nb", FileNameJoin[{integrityRoot, "MazingerTests"}]]];
integrityNotebooks = Get /@ integrityFiles;

VerificationTest[AllTrue[integrityNotebooks, Head[#] === Notebook &], True,
  TestID -> "All project notebooks parse as Notebook"]

VerificationTest[Cases[integrityNotebooks,
  CellGroupData[c_List, ___] /; !AllTrue[c, MatchQ[#, _Cell] &], Infinity], {},
  TestID -> "Notebook groups contain only cells"]

VerificationTest[Cases[integrityNotebooks, Cell[_, "Output" | "Message" | "Print", ___], Infinity], {},
  TestID -> "Notebooks have no saved outputs"]

VerificationTest[Cases[integrityNotebooks, HoldPattern[Return[_Cell]], Infinity], {},
  TestID -> "Notebooks have no expression wrappers around cells"]

VerificationTest[FreeQ[Cases[integrityNotebooks, Cell[b_, "Input", ___] :> b, Infinity],
  s_String /; StringContainsQ[s, "/Users/saul/" | "/home/saul/" | "dependencyDirectosry"]],
  True, TestID -> "Notebook inputs use portable paths"]

VerificationTest[Block[{NotebookDirectory = Function[integrityRoot]},
  Module[{input, expression},
    input = First[Cases[First[integrityNotebooks], Cell[b_BoxData, "Input", ___] :> b, Infinity]];
    expression = ToExpression[input, StandardForm, HoldComplete];
    ReleaseHold[expression];
    Length[DownValues[QWEvolutionOperator]] == 1]], True,
  TestID -> "Main notebook loading cell works without installed ForScience"]

VerificationTest[Module[{before}, before = Names["Global`AnalyzeBoundaryEigenstates"];
  Get[FileNameJoin[{integrityRoot, "QWMisc", "BoundarySpectrum.wl"}]];
  before === Names["Global`AnalyzeBoundaryEigenstates"] &&
    Context[AnalyzeBoundaryEigenstates] === "QuantumWalks`QWMisc`" &&
    Length[DownValues[AnalyzeBoundaryEigenstates]] == 1], True,
  TestID -> "Standalone boundary loader preserves package context"]

VerificationTest[Module[{before = $Context},
  Get[FileNameJoin[{integrityRoot, "analisis", "estados_borde", "analizar_borde.wl"}]];
  $Context === before && Context[EigenstateAtEnergy] === "QuantumWalks`QWMisc`"], True,
  TestID -> "Legacy analysis loader preserves context"]
