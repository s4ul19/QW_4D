If[!TrueQ[orientationChecksPassed],
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
]
