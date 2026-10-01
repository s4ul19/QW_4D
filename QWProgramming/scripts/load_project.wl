(* Portable, offline project loader. Load via Get from scripts or notebooks. *)
Module[{root = DirectoryName[DirectoryName[$InputFileName]], dependencyDirectory, libs, configuredPath, candidates, required, validLibrariesQ},
  (* An explicit path takes priority; otherwise search beside the project and
     its two parent directories. Dependencies can remain outside the repository. *)
  configuredPath = Environment["JA_LIBS_PATH"];
  required = {"ForScience-0.88.45.paclet", "QuantumWalks/DQWL.wl",
    "QuantumWalks/CTQW.wl", "QuantumWalks/Billiards/Common.wl",
    "QMB/OldQMB.wl", "QMB/GeneralQM.wl", "QMB/RMT.wl", "QMB/QKT.wl"};
  validLibrariesQ[path_] := StringQ[path] && DirectoryQ[path] &&
    AllTrue[required, FileExistsQ[FileNameJoin[{path, #}]] &];
  If[StringQ[configuredPath] && configuredPath =!= "",
    libs = ExpandFileName[configuredPath];
    If[!validLibrariesQ[libs],
      Print["JA_LIBS_PATH is incomplete or unavailable: ", libs]; Return[$Failed]],
    candidates = ExpandFileName /@ (FileNameJoin[{root, #}] & /@
      {"JA_libs", "../JA_libs", "../../JA_libs"});
    libs = SelectFirst[candidates, validLibrariesQ, Missing["Dependencies"]];
    If[MissingQ[libs],
      Print["JA_libs was not found. Set JA_LIBS_PATH to an external directory containing QuantumWalks, QMB and ForScience-0.88.45.paclet."];
      Return[$Failed]]];
  If[Quiet[FindFile["ForScience`"]] === $Failed,
    dependencyDirectory = CreateDirectory[];
    ExtractArchive[FileNameJoin[{libs, "ForScience-0.88.45.paclet"}], dependencyDirectory];
    PacletDirectoryLoad[FileNameJoin[{dependencyDirectory, "ForScience-0.88.45"}]]];
  Quiet[Needs["ForScience`"], {Set::write, SetDelayed::write}];
  (* Loading bundled source directly avoids update checks and installation. *)
  Block[{ForScience`PacletUtils`FormatUsage = Identity},
  Quiet[
  If[!MemberQ[$Packages, "QuantumWalks`Billiards`"],
    Get[FileNameJoin[{libs, "QuantumWalks", "DQWL.wl"}]];
    Get[FileNameJoin[{libs, "QuantumWalks", "CTQW.wl"}]];
    Scan[Get[FileNameJoin[{libs, "QuantumWalks", "Billiards", #}]] &,
      {"Common.wl", "Rectangle.wl", "Sinai.wl", "Bunimovich.wl", "Ellipse.wl", "Cardioid.wl"}]];
  If[!MemberQ[$Packages, "QMB`"],
    Scan[Get[FileNameJoin[{libs, "QMB", #}]] &,
      {"OldQMB.wl", "GeneralQM.wl", "RMT.wl", "QKT.wl",
       "ManyBody/SpinChains.wl", "ManyBody/BoseHubbard.wl", "ManyBody/Fermions.wl"}]];
  , {Remove::rmnsm}]];
  Get[FileNameJoin[{root, "QWMisc.wl"}]]
];
