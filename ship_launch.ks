@LAZYGLOBAL OFF. SWITCH TO 1. IF NOT EXISTS("1:/init.ks") { RUNPATH("0:/init_select.ks"). }. RUNONCEPATH("1:/init.ks").

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
GLOBAL ORBIT_LOW IS 80000. //MAX(BODY:ATM:HEIGHT * 1.05, ORBIT_PE).
GLOBAL mission_end_mode IS 888.
GLOBAL ANG_PREC IS 0.2.
GLOBAL ALT_PREC IS 1.0.

runCraftInit().

UNTIL runMode() = 99 {
LOCAL rm IS runMode().
IF rm < 0 {
  rcsOn().
  sasOn().
  IF NEW_NAME <> "" { shipUpdate(NEW_NAME). }
  store("runScript(" + CHAR(34) + CRAFT_FILE_RUN + CHAR(34) + "," + debug() + ").","autorun.ks").
  warpStatus(SHIP_WARP_ALLOW).
  runMode(1,99).

} ELSE IF rm = 1 {
  LOCAL ap IS ORBIT_LOW.
  runScript("lib_launch_geo.ks",debug()).
  LOCAL launch_details IS calcLaunchDetails(ap,ORBIT_INC,ORBIT_LAN).
  LOCAL az IS launch_details[0].
  IF ORBIT_LAN > -1 AND ABS(ORBIT_INC + SHIP:GEOPOSITION:LAT) > ANG_PREC {
    LOCAL launch_time IS launch_details[1].
    warpToLaunch(launch_time).
  }
  delScript("lib_launch_geo.ks",debug()).
  runScript("lib_launch_nocrew.ks",debug()).
  setTWR(SHIP_TWR).
  setThrControl(SHIP_THR_CONTROL).
  setMaxQControl(SHIP_MAXQ_THR).
  setOrbitSlow(SHIP_ORBIT_SLOW).
  append("doLaunch(801," + ap + "," + (ORBIT_DIR * az) + "," + ORBIT_INC + "," + ORBIT_CIRK + ").").
  doLaunch(801,ap,(ORBIT_DIR * az),ORBIT_INC,ORBIT_CIRK).

} ELSE IF rm < 50 {
  runScript("lib_launch_nocrew.ks",debug()).
  rcsOff().
  sasOff().
  resume().

} ELSE IF MOD(rm,10) = 9 AND rm > 800 AND rm < 999 {
  runScript("lib_steer.ks",debug()).
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
  runScript("lib_ant.ks",debug()).
  runScript("lib_panels.ks",debug()).
  doAnt().
  doPanels().
  runMode(803).

} ELSE IF rm = 803 {
  delResume().
  runMode(mission_end_mode).

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
