@LAZYGLOBAL OFF.

IF ADDONS:AVAILABLE("RT") {
  runScript("lib_ant_rt.ks",debug()).
} ELSE {
  runScript("lib_ant_sq.ks",debug()).
}