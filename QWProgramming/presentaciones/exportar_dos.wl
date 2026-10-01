(* Extrae las barras de las figuras DoS/Unfold ya guardadas en
   FunctionsTester.nb. No recalcula los espectros. *)

Module[{base, notebook, sections, section, groups, outputs, plots, insetPlots,
  bins, names, records = {}, sectionName, stadium, spec, coin, i, j},

  base = DirectoryName[$InputFileName];
  notebook = Get[FileNameJoin[{DirectoryName[base], "FunctionsTester.nb"}]];
  sections = Cases[notebook,
    CellGroupData[cells_List, ___] /;
      MatchQ[First[cells], Cell[_String, "Section", ___]] :> cells,
    Infinity];
  names = {"p", "oo", "b", "gpg", "o", "uoou", "ubu", "u", "upu"};

  Do[
    sectionName = spec[[1]];
    stadium = spec[[2]];
    section = SelectFirst[sections,
      MatchQ[First[#], Cell[title_, "Section", ___] /;
        title === sectionName] &, Missing["Section"]];
    If[MissingQ[section], Print["Falta la sección: ", sectionName]; Exit[1]];
    groups = Cases[section,
      CellGroupData[cells_List, ___] /;
        MatchQ[First[cells], Cell["DoS", "Subsection", ___]] :> cells,
      Infinity];
    If[Length[groups] != 1, Print["Sección DoS inesperada: ", stadium]; Exit[1]];
    outputs = Cases[First[groups],
      Cell[BoxData[boxes_], "Output", ___] :> boxes, Infinity];
    plots = ReleaseHold[
      ToExpression[BoxData[First[outputs]], StandardForm, HoldComplete]];
    If[!ListQ[plots] || Length[plots] != Length[names],
      Print["Lista de figuras inesperada: ", stadium]; Exit[1]];

    Do[
      coin = names[[i]];
      insetPlots = Cases[plots[[i]], Inset[g_Graphics, ___] :> g, Infinity];
      If[Length[insetPlots] != 2,
        Print["No hay par DoS/Unfold: ", stadium, " ", coin]; Exit[1]];
      bins = Table[
        Cases[insetPlots[[j]],
          Rectangle[{x_?NumericQ, 0}, {right_?NumericQ, height_?NumericQ}, ___] :>
            N[{x, right, height}], Infinity], {j, 2}];
      If[AnyTrue[bins, EmptyQ],
        Print["Histograma vacío: ", stadium, " ", coin]; Exit[1]];
      AppendTo[records, <|"stadium" -> stadium, "coin" -> coin,
        "dos" -> bins[[1]], "unfold" -> bins[[2]]|>],
      {i, Length[names]}],
    {spec, {{"Rectángulo", "Rect"}, {"Sinaí", "Sinai"}}}];

  Export[FileNameJoin[{base, "dos_barras.json"}], records, "RawJSON"];
  Print["Pares DoS/Unfold extraídos: ", Length[records]];
];
