(* Ejecutar desde un cuaderno de Wolfram con la interfaz gráfica abierta.
   Recupera las salidas guardadas de FunctionsTester.nb y las exporta a PDF. *)

Module[
  {base, notebook, sections, stadiums, coins, statistics, exported = 0,
   missing = {}, section, groups, outputs, plots, name, prefix, stadium,
   coin, file, result, i},

  base = DirectoryName[$InputFileName];
  notebook = Get[FileNameJoin[{DirectoryName[base], "FunctionsTester.nb"}]];
  sections = Cases[
    notebook,
    CellGroupData[cells_List, ___] /;
      MatchQ[First[cells], Cell[_String, "Section", ___]] :> cells,
    Infinity
  ];

  stadiums = {{"Rectángulo", "Rect"}, {"Sinaí", "Sinai"}};
  coins = {"p", "oo", "b", "gpg", "o", "uoou", "ubu", "u", "upu"};
  statistics = {{"P(s)", "Ps"}, {"P(r)", "Pr"}, {"SFF", "SFF"}};

  Do[
    stadium = stadiumSpec[[2]];
    section = SelectFirst[sections,
      MatchQ[First[#], Cell[title_, "Section", ___] /; title === stadiumSpec[[1]]] &,
      Missing["Section"]];
    If[MissingQ[section],
      Print["Falta la sección: ", stadiumSpec[[1]], ". Evalúa y guarda el notebook antes de exportar."];
      Return[$Failed]];

    Do[
      name = statisticSpec[[1]];
      prefix = statisticSpec[[2]];
      groups = Cases[
        section,
        CellGroupData[cells_List, ___] /;
          MatchQ[First[cells], Cell[name, "Subsubsection", ___]] :> cells,
        Infinity
      ];
      If[Length[groups] != 1,
        Print["No se encontró una subsección única: ", stadium, " ", name];
        Continue[]
      ];
      outputs = Cases[
        First[groups],
        Cell[BoxData[boxes_], "Output", ___] :> boxes,
        Infinity
      ];
      If[Length[outputs] != 1,
        Print["No se encontró una salida única: ", stadium, " ", name];
        Continue[]
      ];
      plots = ReleaseHold[
        ToExpression[BoxData[First[outputs]], StandardForm, HoldComplete]
      ];
      If[!ListQ[plots] || Length[plots] != Length[coins],
        Print["Lista de figuras inesperada: ", stadium, " ", name];
        Continue[]
      ];

      Do[
        coin = coins[[i]];
        file = FileNameJoin[{base, "Imgs",
          prefix <> "_" <> stadium <> "_" <> coin <> ".pdf"}];
        If[!MatchQ[plots[[i]], _Legended | _Graphics],
          AppendTo[missing, prefix <> "_" <> stadium <> "_" <> coin];
          Continue[]
        ];
        result = Export[file, plots[[i]], "PDF"];
        If[result === $Failed,
          AppendTo[missing, prefix <> "_" <> stadium <> "_" <> coin],
          exported++
        ],
        {i, Length[coins]}
      ],
      {statisticSpec, statistics}
    ],
    {stadiumSpec, stadiums}
  ];

  Print["Figuras exportadas: ", exported];
  Print["Sin figura guardada: ", missing];
];
