@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

FOR f IN LIST(
  "lib_orbit_change.ks", // #include lib_orbit_change
  "lib_orbit_match.ks" // #include lib_orbit_match
) { runScript(f,debug()). }

GLOBAL NEW_NAME IS "S2".
GLOBAL ORBIT_AP IS 80000.
GLOBAL ORBIT_PE IS 80000.
GLOBAL ORBIT_LAN IS -1.
GLOBAL ORBIT_INC IS 0.
GLOBAL ORBIT_W IS -1.
GLOBAL ORBIT_DIR IS 1.
GLOBAL ORBIT_CIRK IS TRUE.

GLOBAL SHIP_MAXQ_THR IS TRUE.
GLOBAL SHIP_TWR IS 2.0.
GLOBAL SHIP_THR_CONTROL IS TRUE.
GLOBAL SHIP_WARP_ALLOW IS FALSE.
GLOBAL SHIP_ORBIT_SLOW IS FALSE.
GLOBAL ORBIT_LOW IS 80000. //MAX(BODY:ATM:HEIGHT * 1.05, ORBIT_PE).
GLOBAL mission_end_mode IS 888.
GLOBAL ANG_PREC IS 0.2.
GLOBAL ALT_PREC IS 1.0.

IF SHIP_FILE { runScript(CRAFT_FILE_RUN,debug()). }

UNTIL runMode() = 99 {
LOCAL rm IS runMode().
IF rm < 0 {
  rcsOn().
  sasOn().
  IF NEW_NAME <> "" { sysUpdate(NEW_NAME). }
  store("runScript(" + CHAR(34) + CRAFT_FILE_RUN + CHAR(34) + "," + debug() + ").","autorun.ks").
  warpStatus(SHIP_WARP_ALLOW).
  runMode(1,99).

} ELSE IF rm = 1 {
  LOCAL ap IS ORBIT_LOW.
  runScript("lib_launch_geo.ks",debug()). // #include lib_launch_geo
  LOCAL launch_details IS calcLaunchDetails(ap,ORBIT_INC,ORBIT_LAN).
  LOCAL az IS launch_details[0].
  IF ORBIT_LAN > -1 AND ABS(ORBIT_INC + SHIP:GEOPOSITION:LAT) > ANG_PREC {
    LOCAL launch_time IS launch_details[1].
    warpToLaunch(launch_time).
  }
  delScript("lib_launch_geo.ks",debug()).
  runScript("lib_launch_nocrew.ks",debug()). // #include lib_launch_nocrew
  setTWR(SHIP_TWR).
  setThrControl(SHIP_THR_CONTROL).
  setMaxQControl(SHIP_MAXQ_THR).
  setOrbitSlow(SHIP_ORBIT_SLOW).
  append("doLaunch(801," + ap + "," + (ORBIT_DIR * az) + "," + ORBIT_INC + "," + ORBIT_CIRK + ").").
  doLaunch(801,ap,(ORBIT_DIR * az),ORBIT_INC,ORBIT_CIRK).

} ELSE IF rm < 50 {
  runScript("lib_launch_nocrew.ks",debug()). // #include lib_launch_nocrew
  rcsOff().
  sasOff().
  resume().

} ELSE IF MOD(rm,10) = 9 AND rm > 800 AND rm < 999 {
  runScript("lib_steer.ks",debug()). // #include lib_steer
  hudMsg("Error state. Hit abort to recover (mode " + abortMode() + ").").
  steerSun().
  WAIT UNTIL MOD(runMode(),10) <> 9.

} ELSE IF rm = 801 {
  delResume().
  warpStatus(SHIP_WARP_ALLOW).
  delScript("lib_launch_nocrew.ks",debug()).
  delScript("lib_launch_common.ks",debug()).
  runMode(802).

} ELSE IF rm = 802 {
  pOut("Activate modules").
  runScript("lib_ant.ks",debug()). // #include lib_ant
  runScript("lib_panels.ks",debug()). // #include lib_panels
  doAnt().
  doPanels().
  runMode(803).

} ELSE IF rm = 803 {
  delResume().
  runMode(mission_end_mode).

} ELSE IF rm = mission_end_mode {
  runScript("lib_steer.ks",debug()). // #include lib_steer
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
