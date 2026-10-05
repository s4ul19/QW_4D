base = DirectoryName[$InputFileName];
cells = Import[FileNameJoin[{base, "cells.json"}], "RawJSON"];
makeCell[item_] := Module[{boxes, parsed, roundtrip},
  If[item["style"] =!= "Input", Return[Cell[item["text"], item["style"], ExpressionUUID -> CreateUUID[]]]];
  parsed = ToExpression["(" <> item["text"] <> "\n)", InputForm, HoldComplete];
  If[parsed === $Failed, Print["Parse failed"]; Quit[1]];
  boxes = "(" <> item["text"] <> "\n)";
  roundtrip = ToExpression[boxes, StandardForm, HoldComplete];
  If[roundtrip =!= parsed, Put[parsed, FileNameJoin[{base,"parsed.txt"}]]; Put[roundtrip,FileNameJoin[{base,"roundtrip.txt"}]]; Print["Roundtrip failed"]; Quit[2]];
  Cell[BoxData[boxes], "Input", ExpressionUUID -> CreateUUID[]]
];
section = Cell[CellGroupData[makeCell /@ cells, Open]];
Put[section, FileNameJoin[{base, "section.txt"}]];
Print["Built and roundtripped ", Count[cells, a_Association /; a["style"] === "Input"], " inputs."];
Quit[];
