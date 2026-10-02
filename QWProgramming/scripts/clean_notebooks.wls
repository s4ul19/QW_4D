(* Get from a notebook, or run with wolframscript -file. No kernel exit. *)
Module[{root = DirectoryName[DirectoryName[$InputFileName]], files, notebook},
  files = Join[{FileNameJoin[{root, "FunctionsTester.nb"}]},
    FileNames["*.nb", FileNameJoin[{root, "MazingerTests"}]]];
  Do[
    notebook = Get[file];
    If[Head[notebook] =!= Notebook, Print["Invalid notebook: ", file]; Return[$Failed]];
    notebook = DeleteCases[notebook, Cell[_, "Output" | "Message" | "Print", ___], Infinity];
    notebook = notebook /. HoldPattern[CellLabel -> _] :> Sequence[];
    Put[notebook, file], {file, files}];
  Print["Cleaned notebooks: ", Length[files]]
];
