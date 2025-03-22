@LAZYGLOBAL OFF.

IF findPath("lib_chutes_far.ks") {
  runScript("lib_chutes_far.ks",debug()).
} ELSE IF findPath("lib_chutes_sq.ks") {
  runScript("lib_chutes_sq.ks",debug()).
} ELSE {
  runScript("lib_chutes_far.ks",debug()).
  IF NOT hasChutes {
    delScript("lib_chutes_far.ks",debug()).
    runScript("lib_chutes_sq.ks",debug()).
  }
}