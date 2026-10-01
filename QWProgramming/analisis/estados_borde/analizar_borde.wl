(* Compatibilidad con los notebooks anteriores.
   Para usar tambien EigenstateAtEnergy, carga el paquete QWMisc.wl.
   Las definiciones del analisis de frontera tienen una sola fuente. *)
Get[FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
  "QWMisc", "BoundarySpectrum.wl"}]];
