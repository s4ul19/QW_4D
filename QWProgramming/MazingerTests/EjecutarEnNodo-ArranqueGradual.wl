(* Compatibility loader; the implementation lives in QWMisc.wl. *)
Get[FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]],
  "scripts", "load_project.wl"}]];
