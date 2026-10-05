import json, pathlib, hashlib
base=pathlib.Path(__file__).resolve().parent
original=pathlib.Path('/Users/saul/Desktop/ChatGPT/QWProgramming/FunctionsTester.nb').read_bytes()
(base/'original.nb').write_bytes(original)
(base/'original.sha256').write_text(hashlib.sha256(original).hexdigest())
cells=[]
def cell(style,s): cells.append({'style':style,'text':s.strip()})
def code(s): cell('Input',s)
cell('Title','Orientacion ortogonal de la moneda: espectro fijo y simetria antiunitaria')
cell('Text','Objetivo: variar los eigenvectores de oo y gpg sin cambiar los eigenvalores de la moneda ni romper la simetria antiunitaria del rectangulo. C(lambda)=O(lambda).C0.Transpose[O(lambda)], O(lambda)=MatrixExp[lambda alpha A], A real antisimetrica. La moneda es homogenea y fija durante cada evolucion. Ejecuta las secciones 1 a 7 en orden. El barrido se ejecuta localmente en la seccion 5; cargar las definiciones no lo inicia.')
cell('Section','1. Cargar el proyecto')
code('''orientationRoot = NotebookDirectory[];
Get[FileNameJoin[{orientationRoot, "scripts", "load_project.wl"}]];''')
cell('Section','2. Parametros y realizaciones fijas')
cell('Text','Lx y Ly son coordenadas maximas: hay (Lx+1)(Ly+1) sitios y D=4(Lx+1)(Ly+1) niveles. El piloto usa {12,8}, 3 semillas por familia y 21 valores de lambda: 126 diagonalizaciones de dimension 468. Para escalar, cambia Lx,Ly conservando razon de aspecto (por ejemplo {24,16}, {36,24}) y aumenta semillas. alpha=Pi/2 fija la escala angular, con ||A||2=1; lambda=1 es solo el extremo de este camino, no garantiza caos ni una rotacion Haar. La rotacion se genera independientemente de la moneda y no se vuelve a sortear en cada lambda.')
code('''orientationConfig = <|
  "Lx" -> 12, "Ly" -> 8,
  "Names" -> {"oo", "gpg"}, "Seeds" -> {23, 47, 83},
  "RotationSeedOffset" -> 100000,
  "Lambdas" -> N[Subdivide[0, 1, 20]],
  "Alpha" -> N[Pi/2], "Tolerance" -> 1/10^10,
  "NumericalTolerance" -> 1/10^8, "CodeVersion" -> 1
|>;
ClearAll[orientationPath, orientationCoin, orientationCoinErrors];
orientationPath[name_String, seed_Integer, offset_Integer] := Module[{c0, a},
  c0 = N[QuantumWalks`QWMisc`RandomMatrix[name, "RandomSeed" -> seed]];
  a = BlockRandom[SeedRandom[seed + offset];
    RandomVariate[NormalDistribution[], {4, 4}]];
  a = a - Transpose[a];
  a = a/Norm[a, 2];
  <|"Name" -> name, "Seed" -> seed, "RotationSeed" -> seed + offset,
    "C0" -> c0, "A" -> a|>
];
orientationCoin[path_Association, lambda_?NumericQ, alpha_?NumericQ] :=
  With[{o = MatrixExp[lambda alpha path["A"]]},
    o . path["C0"] . Transpose[o]];
orientationCoinErrors[path_Association, lambda_, alpha_] := Module[{o, c, ev0, ev, match},
  o = MatrixExp[lambda alpha path["A"]];
  c = orientationCoin[path, lambda, alpha];
  ev0 = Eigenvalues[path["C0"]]; ev = Eigenvalues[c];
  match = Min[Max[Abs[ev - #]] & /@ Permutations[ev0]];
  <|"OrthogonalityError" -> Norm[Transpose[o] . o - IdentityMatrix[4], "Frobenius"],
    "RealityError" -> Norm[Im[o], "Frobenius"],
    "CoinSymmetryError" -> Norm[c - Transpose[c], "Frobenius"],
    "CoinUnitarityError" -> Norm[ConjugateTranspose[c] . c - IdentityMatrix[4], "Frobenius"],
    "CoinSpectrumError" -> match|>
];
orientationPaths = Flatten[Table[
  orientationPath[name, seed, orientationConfig["RotationSeedOffset"]],
  {name, orientationConfig["Names"]}, {seed, orientationConfig["Seeds"]}], 1];
Dataset[KeyTake[#, {"Name", "Seed", "RotationSeed"}] & /@ orientationPaths]''')
cell('Section','3. Verificar las invariantes antes del barrido')
cell('Text','R invierte solo la posicion respecto al centro del rectangulo. Para este shift, R.S.R=S adjunto. Como C es simetrica, Theta=(I tensor C adjunto).R.K satisface Theta^2=I y Theta.U.Theta^-1=U adjunto. La comprobacion completa se hace en un rectangulo pequeno para evitar multiplicaciones densas costosas en el barrido. Las invariantes 4x4 se revisan en cada punto. Estos controles no prueban caos ni eliminan otras simetrias unitarias.')
code('''ClearAll[orientationTRCheck];
orientationTRCheck[path_Association, lambda_, alpha_] := Module[
  {grid, coords, n, d, r, c, cbig, s, u, q, targets},
  grid = QuantumWalks`Billiards`GenerateRectangleBasis[3, 2];
  coords = grid["Coords"]; n = grid["Dimension"]; d = 4 n;
  targets = Flatten[Table[
    4 (First[FirstPosition[coords, {3, 2} - pos]] - 1) + Range[4], {pos, coords}]];
  r = SparseArray[Thread[Transpose[{targets, Range[d]}] -> 1.], {d, d}];
  c = orientationCoin[path, lambda, alpha];
  cbig = KroneckerProduct[IdentityMatrix[n, SparseArray], SparseArray[c]];
  s = QuantumWalks`QWMisc`QWEvolutionOperator[grid, IdentityMatrix[4]];
  u = s . cbig; q = ConjugateTranspose[cbig] . r;
  <|"ShiftReversalError" -> Norm[Normal[r . s . r - ConjugateTranspose[s]], "Frobenius"],
    "ThetaSquaredError" -> Norm[Normal[q . Conjugate[q] - IdentityMatrix[d]], "Frobenius"],
    "TimeReversalError" -> Norm[Normal[q . Conjugate[u] . ConjugateTranspose[q] - ConjugateTranspose[u]], "Frobenius"]|>
];
orientationChecks = Flatten[Table[Join[
  KeyTake[path, {"Name", "Seed"}], <|"Lambda" -> lambda|>,
  orientationCoinErrors[path, lambda, orientationConfig["Alpha"]],
  orientationTRCheck[path, lambda, orientationConfig["Alpha"]]],
  {path, orientationPaths}, {lambda, {0., 0.5, 1.}}], 1];
orientationChecksPassed = AllTrue[orientationChecks,
  Max[Values[KeyDrop[#, {"Name", "Seed", "Lambda"}]]] < orientationConfig["NumericalTolerance"] &];
Print["Invariantes correctas: ", orientationChecksPassed];
Dataset[orientationChecks]''')
cell('Section','4. Definir el calculo de cada punto y el guardado')
cell('Text','Se conserva todo el espectro, sin unfolding para r y sin eliminar niveles repetidos. QWPr conserva ratios cero y omite solamente pares 0/0; los dos contadores se guardan. Las fases, moneda y errores numericos permiten revisar cada punto. Los espectros pertenecen al operador completo: cualquier simetria unitaria adicional debe separarse antes de atribuir universalidad a un sector. Cada punto terminado se guarda en WXF mediante reemplazo atomico. Reevaluar la seccion 5 con los mismos parametros y realizaciones reutiliza los archivos completos; el punto interrumpido se recalcula.')
code('''ClearAll[orientationPoint, orientationSave, orientationRun];
orientationPoint[path_Association, lambda_, cfg_Association, shift_] := Module[
  {c, errors, n, u, vals, phases, data, elapsed, modulusError},
  c = orientationCoin[path, lambda, cfg["Alpha"]];
  errors = orientationCoinErrors[path, lambda, cfg["Alpha"]];
  If[Max[Values[errors]] >= cfg["NumericalTolerance"],
    Return[Failure["CoinInvariant", <|"Errors" -> errors|>]]];
  n = Length[shift]/4;
  {elapsed, vals} = AbsoluteTiming[
    u = N[shift . KroneckerProduct[IdentityMatrix[n, SparseArray], SparseArray[c]]];
    Eigenvalues[Normal[u]]];
  If[!VectorQ[vals, NumericQ], Return[Failure["Eigensystem", <||>]]];
  modulusError = Max[Abs[Abs[vals] - 1]];
  If[modulusError >= cfg["NumericalTolerance"],
    Return[Failure["UnitCircle", <|"Error" -> modulusError|>]]];
  phases = Sort[-Arg[vals]];
  data = QuantumWalks`QWMisc`QWPr[phases, "ReturnData" -> True,
    "AllowDegeneracies" -> True, "DegeneracyTolerance" -> cfg["Tolerance"]];
  If[!AssociationQ[data], Return[Failure["Ratios", <||>]]];
  Join[KeyTake[path, {"Name", "Seed", "RotationSeed"}],
    <|"Lambda" -> lambda, "D" -> Length[vals], "Coin" -> c,
      "Phases" -> phases, "Ratios" -> data["Ratios"],
      "MeanR" -> If[data["Ratios"] === {}, Missing["Undefined"], Mean[data["Ratios"]]],
      "ZeroSpacingCount" -> data["ZeroSpacingCount"],
      "UndefinedRatioCount" -> data["UndefinedRatioCount"],
      "EigenvalueModulusError" -> modulusError, "Seconds" -> elapsed|>, errors]
];
orientationSave[file_String, value_] := Module[{temporary = file <> ".partial", saved},
  saved = Export[temporary, value, "WXF"];
  If[!StringQ[saved], Return[Failure["Export", <|"File" -> file|>]]];
  RenameFile[temporary, file, OverwriteTarget -> True]
];
orientationRun[cfg_Association, paths_List, directory_String] := Catch[Module[
  {grid, shift, rows = {}, file, row, count = 0, total},
  grid = QuantumWalks`Billiards`GenerateRectangleBasis[cfg["Lx"], cfg["Ly"]];
  shift = QuantumWalks`QWMisc`QWEvolutionOperator[grid, IdentityMatrix[4]];
  If[shift === $Failed, Throw[Failure["Shift", <||>], "orientation"]];
  total = Length[paths] Length[cfg["Lambdas"]];
  Do[
    file = FileNameJoin[{directory, path["Name"] <> "-seed" <> ToString[path["Seed"]] <>
      "-point" <> IntegerString[j, 10, 4] <> ".wxf"}];
    row = If[FileExistsQ[file], Import[file, "WXF"],
      orientationPoint[path, cfg["Lambdas"][[j]], cfg, shift]];
    If[!AssociationQ[row] || !(And @@ (KeyExistsQ[row, #] & /@
      {"Name", "Seed", "Lambda", "Phases", "Ratios", "MeanR", "ZeroSpacingCount", "UndefinedRatioCount", "D"})),
      Throw[Failure["Point", <|"File" -> file, "Result" -> row|>], "orientation"]];
    If[row["Name"] =!= path["Name"] || row["Seed"] =!= path["Seed"] ||
      row["Lambda"] =!= cfg["Lambdas"][[j]] || row["D"] =!= 4 grid["Dimension"],
      Throw[Failure["CheckpointMismatch", <|"File" -> file|>], "orientation"]];
    If[!FileExistsQ[file] && !StringQ[orientationSave[file, row]],
      Throw[Failure["Save", <|"File" -> file|>], "orientation"]];
    AppendTo[rows, row]; count++;
    Print[count, "/", total, "  ", path["Name"], " seed=", path["Seed"],
      " lambda=", row["Lambda"], "  <r>=", row["MeanR"],
      "  ceros=", row["ZeroSpacingCount"], "  0/0=", row["UndefinedRatioCount"]],
    {path, paths}, {j, Length[cfg["Lambdas"]]}];
  rows
], "orientation"];''')
cell('Section','5. Ejecutar o reanudar el barrido local')
cell('Text','Esta celda inicia las diagonalizaciones. La carpeta se identifica por un hash de parametros, matrices fijas y version de Wolfram. Puedes abortar y reevaluar: los puntos terminados se conservan. Para leer resultados de otra sesion sin calcular, importa metadata.wxf y los archivos *-point*.wxf de la carpeta impresa. No se envia ningun trabajo a Mazinger.')
code('''If[!TrueQ[orientationChecksPassed],
  Print["Ejecuta la seccion 3 y revisa los controles antes de continuar."],
  orientationMetadata = <|"Config" -> orientationConfig, "Paths" -> orientationPaths,
    "WolframVersion" -> $Version,
    "EnergyConvention" -> "U psi = Exp[-I epsilon] psi; epsilon = -Arg[eigenvalue]",
    "Sector" -> "Full operator; no unitary symmetry resolution"|>;
  orientationDirectory = FileNameJoin[{orientationRoot, "results", "OrthogonalOrientation",
    IntegerString[Hash[orientationMetadata, "SHA256"], 16, 64]}];
  If[!DirectoryQ[orientationDirectory],
    CreateDirectory[orientationDirectory, CreateIntermediateDirectories -> True]];
  If[!StringQ[orientationSave[FileNameJoin[{orientationDirectory, "metadata.wxf"}], orientationMetadata]],
    Print["No se pudo guardar metadata.wxf; no se inicia el barrido."],
    Print["Resultados: ", orientationDirectory];
    orientationResults = orientationRun[orientationConfig, orientationPaths, orientationDirectory];
    If[ListQ[orientationResults],
      Print["Puntos disponibles: ", Length[orientationResults]], orientationResults]
  ]
]''')
cell('Section','6. Resumen y graficas de r y degeneraciones')
cell('Text','La media asigna el mismo peso a cada realizacion; el error estandar se estima entre las medias de las realizaciones, nunca tratando todos los gaps como independientes. El piloto de tres realizaciones solo orienta. Un promedio con menos realizaciones validas se marca por ValidRealizations. Las referencias son aproximadamente 0.3863 (Poisson), 0.5307 (ortogonal) y 0.5996 (unitaria); la simetria conservada apunta a la ortogonal si se alcanza universalidad y se resuelven los sectores adicionales.')
code('''ClearAll[orientationSummarize];
orientationSummarize[rows_List] := Module[{groups},
  groups = GatherBy[rows, {#["Name"], #["Lambda"]} &];
  SortBy[Map[Function[group, Module[{means, valid},
    means = Lookup[group, "MeanR"]; valid = Select[means, NumericQ];
    <|"Name" -> First[group]["Name"], "Lambda" -> First[group]["Lambda"],
      "MeanR" -> If[valid === {}, Missing["Undefined"], Mean[valid]],
      "SE" -> If[Length[valid] < 2, Missing["TooFewRealizations"], StandardDeviation[valid]/Sqrt[Length[valid]]],
      "ValidRealizations" -> Length[valid], "Realizations" -> Length[group],
      "MeanZeroFraction" -> Mean[(#["ZeroSpacingCount"]/#["D"]) & /@ group],
      "MeanUndefinedFraction" -> Mean[(#["UndefinedRatioCount"]/#["D"]) & /@ group]|>
    ]], groups], {#["Name"], #["Lambda"]} &]
];
orientationSummary = orientationSummarize[orientationResults];
Dataset[orientationSummary]''')
code('''orientationRPlot = ListPlot[
  Table[Cases[Select[orientationSummary, #["Name"] == name &],
    a_Association /; NumericQ[a["MeanR"]] :>
      {a["Lambda"], If[NumericQ[a["SE"]], Around[a["MeanR"], a["SE"]], a["MeanR"]]}],
    {name, orientationConfig["Names"]}],
  Joined -> True, PlotMarkers -> Automatic, IntervalMarkers -> "Bars",
  PlotLegends -> orientationConfig["Names"], Frame -> True,
  FrameLabel -> {"lambda", "<r> (media entre realizaciones)"},
  GridLines -> {None, {2 Log[2] - 1, 0.5307, 0.5996}},
  PlotRange -> {{0, 1}, {0, 0.7}}, ImageSize -> Large,
  PlotLabel -> "Referencias: Poisson 0.3863; ortogonal 0.5307; unitaria 0.5996"];
orientationDegeneracyPlot = ListLinePlot[
  Flatten[Table[{
    ({#["Lambda"], #["MeanZeroFraction"]} & /@ Select[orientationSummary, #["Name"] == name &]),
    ({#["Lambda"], #["MeanUndefinedFraction"]} & /@ Select[orientationSummary, #["Name"] == name &])},
    {name, orientationConfig["Names"]}], 1],
  PlotLegends -> Flatten[({# <> " gaps cero", # <> " pares 0/0"} & /@ orientationConfig["Names"])],
  Frame -> True, FrameLabel -> {"lambda", "fraccion"}, PlotRange -> All, ImageSize -> Large];
Column[{orientationRPlot, orientationDegeneracyPlot}]''')
cell('Section','7. P(r), P(s) y movimiento de eigenfases para una realizacion')
cell('Text','Selecciona familia y semilla. Los paneles de P(r) usan las fases originales; P(s) usa el unfolding existente y puede fallar si no es monotono. No suprimas niveles para forzar un ajuste. El diagrama de eigenfases usa puntos sin unir: ordenar las fases en cada lambda no sigue la identidad de los eigenestados. Para resolver cruces evitados, estrecha la ventana y densifica lambda; una malla de 21 puntos solo permite exploracion.')
code('''orientationSelectedName = "oo";
orientationSelectedSeed = 23;
orientationPhaseWindow = {-0.5, 0.5};
orientationSelected = SortBy[Select[orientationResults,
  #["Name"] == orientationSelectedName && #["Seed"] == orientationSelectedSeed &], #["Lambda"] &];
orientationSlices = DeleteDuplicates[Table[
  First[MinimalBy[orientationSelected, Abs[#["Lambda"] - target] &]], {target, {0., 0.5, 1.}}]];
Column[Table[With[{label = Row[{row["Name"], ", seed=", row["Seed"], ", lambda=", row["Lambda"]}]},
  QuantumWalks`QWMisc`QWPr[row["Phases"], "AllowDegeneracies" -> True,
    "DegeneracyTolerance" -> orientationConfig["Tolerance"], PlotLabel -> label]],
  {row, orientationSlices}]]''')
code('''Column[Table[QuantumWalks`QWMisc`QWPs[row["Phases"],
  "AllowDegeneracies" -> True, "DegeneracyTolerance" -> orientationConfig["Tolerance"],
  PlotLabel -> Row[{row["Name"], ", lambda=", row["Lambda"]}]],
  {row, orientationSlices}]]''')
code('''orientationPhasePlot = ListPlot[Flatten[Table[
  ({row["Lambda"], #} & /@ Select[row["Phases"],
    orientationPhaseWindow[[1]] <= # <= orientationPhaseWindow[[2]] &]),
  {row, orientationSelected}], 1],
  Frame -> True, FrameLabel -> {"lambda", "epsilon"},
  PlotRange -> {{0, 1}, orientationPhaseWindow}, PlotStyle -> PointSize[0.003],
  PlotLabel -> "Eigenfases: puntos sin seguimiento de eigenvectores", ImageSize -> Large];
orientationPhasePlot''')
cell('Section','8. Exportar resumen y figuras (opcional)')
code('''orientationColumns = {"Name", "Lambda", "MeanR", "SE", "ValidRealizations", "Realizations", "MeanZeroFraction", "MeanUndefinedFraction"};
Export[FileNameJoin[{orientationDirectory, "summary.csv"}],
  Prepend[(Lookup[#, orientationColumns] & /@ orientationSummary), orientationColumns], "CSV"];
Export[FileNameJoin[{orientationDirectory, "mean_r.pdf"}], orientationRPlot];
Export[FileNameJoin[{orientationDirectory, "degeneracies.pdf"}], orientationDegeneracyPlot];
Export[FileNameJoin[{orientationDirectory, "eigenphases.pdf"}], orientationPhasePlot];
orientationDirectory''')
cell('Text','Interpretacion: si C0 y C(lambda) tienen el mismo espectro y conservan la simetria antiunitaria, pero cambia P(r), la orientacion respecto al shift influye en las correlaciones. Esto aun puede deberse a ruptura de otras simetrias unitarias: antes de afirmar caos, separar esos sectores y comprobar escalamiento en tamano. No se espera monotonicidad en lambda para un camino individual.')
(base/'cells.json').write_text(json.dumps(cells,ensure_ascii=True,indent=2))
for i,c in enumerate(cells):
 if c['style']=='Input': (base/f'cell_{i:02d}.wl').write_text(c['text']+'\n')
print('Prepared',len(cells),'cells;',sum(c['style']=='Input' for c in cells),'input cells')
