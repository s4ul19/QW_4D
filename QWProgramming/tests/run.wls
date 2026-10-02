(* Run: wolframscript -file tests/run.wls; Get from a notebook also works. *)
Module[{root = DirectoryName[$InputFileName], reports, failed, results},
  reports = TestReport /@ (FileNameJoin[{root, #}] & /@ {"NotebookTests.wlt", "QWMisc.wlt", "NotebookIntegrity.wlt"});
  failed = Total[# ["TestsFailedCount"] & /@ reports];
  Print["Tests passed: ", Total[#["TestsSucceededCount"] & /@ reports], "; failed: ", failed];
  results = Flatten[Values[#["TestResults"]] & /@ reports];
  Scan[Function[r, If[r["Outcome"] =!= "Success",
    Print[r["TestID"], ": ", r["Outcome"], " actual=", r["ActualOutput"], " expected=", r["ExpectedOutput"]]]], results];
  If[$FrontEnd === Null, Exit[If[failed == 0, 0, 1]], reports]
];
