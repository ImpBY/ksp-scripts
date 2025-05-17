@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

FOR f IN LIST(
  "lib_orbit_change.ks", // #include lib_orbit_change
  "lib_orbit_match.ks" // #include lib_orbit_match
) { runScript(f,debug()). }

GLOBAL NEW_NAME IS "Orbit0".
GLOBAL ORBIT_BODY IS SHIP:BODY.
GLOBAL ORBIT_AP IS 74000.
GLOBAL ORBIT_PE IS 74000.
GLOBAL ORBIT_LAN IS -1.
GLOBAL ORBIT_INC IS 0.
GLOBAL ORBIT_W IS -1.

GLOBAL SHIP_WARP_ALLOW IS FALSE.
GLOBAL mission_end_mode IS 888.
GLOBAL ANG_PREC IS 0.2.
GLOBAL ALT_PREC IS 1.0.

runCraftInit().

UNTIL runMode() = 99 {
LOCAL rm IS runMode().
IF rm < 0 {
  IF NEW_NAME <> "" { sysUpdate(NEW_NAME). }
  store("runScript(" + CHAR(34) + CRAFT_FILE_RUN + CHAR(34) + "," + debug() + ").","autorun.ks").
  warpStatus(SHIP_WARP_ALLOW).
  runMode(1,99).

} ELSE IF rm = 1 {
  delResume().
  warpStatus(SHIP_WARP_ALLOW).
  runMode(2).
  
} ELSE IF rm = 2 {
  IF SHIP:BODY = ORBIT_BODY {
    runMode(801).
  } ELSE {
    IF modeTime() < 5 { pOut("waiting target body: " + ORBIT_BODY). }
  }
  WAIT 10.

} ELSE IF MOD(rm,10) = 9 AND rm > 800 AND rm < 999 {
  runScript("lib_steer.ks",debug()).
  hudMsg("Error state. Hit abort to recover (mode " + abortMode() + ").").
  steerSun().
  WAIT UNTIL MOD(runMode(),10) <> 9.

} ELSE IF rm = 801 {
  runScript("lib_orbit_match.ks",debug()).
  runScript("lib_dv.ks",debug()).
  IF doOrbitMatch(TRUE,stageDV(),ORBIT_INC,ORBIT_LAN,ANG_PREC) {
    runMode(802).
  } ELSE {
    runMode(809).
  }

} ELSE IF rm = 802 {
  runScript("lib_orbit_change.ks",debug()).
  runScript("lib_dv.ks",debug()).
  IF doOrbitChange(TRUE,stageDV(),ORBIT_AP,ORBIT_PE,ORBIT_W,ALT_PREC) {
    runMode(803).
  } ELSE {
    runMode(809).
  }

} ELSE IF rm = 803 {
  pOut("Activate modules").
  runScript("lib_ant.ks",debug()).
  runScript("lib_panels.ks",debug()).
  doAnt().
  doPanels().
  runMode(804).

} ELSE IF rm = 804 {
  delResume().
  runMode(mission_end_mode,99).

} ELSE IF rm = mission_end_mode {
  runScript("lib_steer.ks",debug()).
  hudMsg("Mission complete. Hit abort to retry (mode " + abortMode() + ").").
  steerSun().
  WAIT UNTIL runMode() <> mission_end_mode.
}

WAIT 0.

}
cleanCraft().
runScript("c.ks",TRUE).
runScript("u.ks",TRUE).
rcsOff().
sasOn().
REBOOT.
