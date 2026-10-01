(* Gráfica de la entropía moneda-posición para las monedas de FunctionsTester.nb.
   Cargar con Get[".../plot_entropia_monedas.wl"] después de calcular EntropyDat. *)

ClearAll[PlotEntropiaMonedas];

PlotEntropiaMonedas::data =
  "Se esperan una serie {{0,S(0)},...,{tmax,S(tmax)}} por cada nombre de moneda.";
PlotEntropiaMonedas::names =
  "La lista de nombres debe contener gpg, seguida de al menos una moneda caótica.";
PlotEntropiaMonedas::bounds =
  "La entropía debe estar entre 0 y Log[4] (salvo errores numéricos pequeños).";

PlotEntropiaMonedas[datos_List, nombres_List, inicioZoom_Integer : 20] := Module[
  {corte, tmax, maximo = Log[4], valores, tZoom, valoresTardios,
   margen, rangoZoom, paleta, coloresRegulares, coloresCaoticos,
   estilosRegulares, estilosCaoticos, estilos, graficaCompleta,
   panelZoom, graficaRegular, graficaCaotica},

  corte = FirstPosition[nombres, "gpg", Missing["NoEncontrado"]];
  If[MissingQ[corte] || corte[[1]] >= Length[nombres],
    Message[PlotEntropiaMonedas::names]; Return[$Failed]];
  corte = corte[[1]];

  If[Length[datos] != Length[nombres] || datos === {} ||
     !AllTrue[datos, MatrixQ[#, NumericQ] &&
       MatchQ[Dimensions[#], {_, 2}] &] ||
     Length[Union[Length /@ datos]] != 1,
    Message[PlotEntropiaMonedas::data]; Return[$Failed]];
  tmax = Length[First[datos]] - 1;
  If[tmax < 1 || !AllTrue[datos,
      TrueQ[#[[All, 1]] == Range[0, tmax]] &],
    Message[PlotEntropiaMonedas::data]; Return[$Failed]];

  valores = Flatten[datos[[All, All, 2]]];
  If[!AllTrue[valores, -10^-9 <= # <= maximo + 10^-9 &],
    Message[PlotEntropiaMonedas::bounds]; Return[$Failed]];

  paleta[extremos_List, n_Integer] :=
    Blend[extremos, #] & /@
      If[n == 1, {0.5}, Subdivide[0, 1, n - 1]];
  coloresRegulares = paleta[
    {RGBColor[0.22, 0.67, 0.83], RGBColor[0.06, 0.22, 0.53]}, corte];
  coloresCaoticos = paleta[
    {RGBColor[0.96, 0.57, 0.13], RGBColor[0.68, 0.12, 0.13]},
    Length[nombres] - corte];
  estilosRegulares = Directive[#, AbsoluteThickness[2]] & /@
    coloresRegulares;
  estilosCaoticos = Directive[#, AbsoluteThickness[2], Dashed] & /@
    coloresCaoticos;
  estilos = Join[estilosRegulares, estilosCaoticos];

  graficaCompleta = ListLinePlot[datos,
    PlotStyle -> estilos,
    ScalingFunctions -> None,
    PlotLegends -> Placed[
      LineLegend[estilos, nombres, LegendLabel -> "Moneda"], Right],
    Frame -> True, Axes -> False,
    FrameLabel -> {"Paso t", "S(t) [nats]"},
    PlotLabel -> "Entropía de entrelazamiento moneda-posición",
    PlotRange -> {{0, tmax}, {0, 1.05 maximo}},
    GridLines -> {Automatic, {Log[2]}},
    GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
    Epilog -> {
      Directive[GrayLevel[0.4], Dotted, AbsoluteThickness[1.5]],
      Line[{{0, maximo}, {tmax, maximo}}],
      Inset[Style["máximo = ln 4", 12, GrayLevel[0.35]],
        {0.98 tmax, maximo}, {Right, Bottom}]
    },
    ImageSize -> 950, LabelStyle -> Directive[14]
  ];

  (* Una escala común en ambos paneles permite comparar las fluctuaciones. *)
  tZoom = Min[Max[0, inicioZoom], tmax - 1];
  valoresTardios = Flatten[datos[[All, tZoom + 1 ;;, 2]]];
  margen = Max[0.02 maximo,
    0.12 (Max[valoresTardios] - Min[valoresTardios])];
  rangoZoom = {Max[0, Min[valoresTardios] - margen],
    Min[1.05 maximo, Max[valoresTardios] + margen]};

  panelZoom[series_, estilosPanel_, etiquetas_, titulo_] :=
    ListLinePlot[series,
      PlotStyle -> estilosPanel,
      ScalingFunctions -> None,
      PlotLegends -> Placed[
        LineLegend[estilosPanel, etiquetas, LegendLayout -> "Row"], Below],
      Frame -> True, Axes -> False,
      FrameLabel -> {"Paso t", "S(t) [nats]"},
      PlotLabel -> titulo,
      PlotRange -> {{tZoom, tmax}, rangoZoom},
      GridLines -> Automatic,
      GridLinesStyle -> Directive[GrayLevel[0.88]],
      ImageSize -> 460, LabelStyle -> Directive[12]
    ];

  graficaRegular = panelZoom[
    Take[datos, corte], estilosRegulares, Take[nombres, corte],
    "Integrables: detalle desde t = " <> ToString[tZoom]];
  graficaCaotica = panelZoom[
    Drop[datos, corte], estilosCaoticos, Drop[nombres, corte],
    "Caóticas: detalle desde t = " <> ToString[tZoom]];

  Column[{graficaCompleta,
    GraphicsRow[{graficaRegular, graficaCaotica}, Spacings -> 15]},
    Center, 2]
];
