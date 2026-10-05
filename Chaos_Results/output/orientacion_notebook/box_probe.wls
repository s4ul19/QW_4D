s = "orientationRoot = NotebookDirectory[];\nGet[FileNameJoin[{orientationRoot, \"scripts\", \"load_project.wl\"}]];";
p=ToExpression[s,InputForm,HoldComplete];
b=ToExpression[s,InputForm,Function[x,ToBoxes[Unevaluated[x],StandardForm],HoldAllComplete]];
b = b /. RowBox[items_List] :> RowBox[Flatten[(If[# === ";", {";", "\[IndentingNewLine]"}, {#}] &) /@ items, 1]];
r=ToExpression[b,StandardForm,HoldComplete];
Print[FullForm /@ {p,b,r}];
Print[p === r];
Quit[];
