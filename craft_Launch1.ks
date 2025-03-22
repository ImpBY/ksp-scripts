IF NOT findPath("start_edit") {
  GLOBAL f IS FALSE.
  edit CRAFT_FILE_INIT.
  pOut("AG1 to continue after edit").
  ON AG1 { SET f TO TRUE. }
  WAIT UNTIL f.
  COPYPATH(CRAFT_FILE_INIT,"0:/craft_" + SHIP:NAME + "_init.ks").
  store("","start_edit").
}
runScript("ship_launch.ks",debug()).
