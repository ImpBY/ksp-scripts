@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

FOR f IN LIST(
"lib_orbit.ks", // #include lib_orbit
"lib_orbit_match.ks", // #include lib_orbit_match
"lib_orbit_tools.ks" // #include lib_orbit_tools
) { runScript(f,debug()). }

GLOBAL SAT_ANGL IS 0.
GLOBAL NEW_NAME IS "Sat" + SAT_ANGL.
GLOBAL ORBIT_AP IS getBSOheight().
GLOBAL ORBIT_PE IS ORBIT_AP.
GLOBAL ORBIT_LAN IS -1.
GLOBAL ORBIT_INC IS 0.
GLOBAL ORBIT_DIR IS 1.
GLOBAL ORBIT_CIRK IS TRUE.

GLOBAL SHIP_WARP_ALLOW IS FALSE.
GLOBAL ORBIT_LOW IS MAX(BODY:ATM:HEIGHT * 1.05, ORBIT_PE).
GLOBAL mission_end_mode IS 888.
GLOBAL ANG_PREC IS 0.001.
GLOBAL ALT_PREC IS 0.001.

GLOBAL SHIP_MAXQ_THR IS TRUE.
GLOBAL SHIP_TWR IS 2.0.
GLOBAL SHIP_THR_CONTROL IS TRUE.
GLOBAL SHIP_ORBIT_SLOW IS TRUE.
GLOBAL KSC_LAT IS { RETURN -74.5576222763096. }.
GLOBAL TP IS SHIP:BODY:ROTATIONPERIOD.
GLOBAL SAT_POS IS { RETURN KSC_LAT() + SAT_ANGL. }.

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
  delScript("lib_launch_geo.ks",debug()). // #include lib_launch_geo
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
  runScript("lib_orbit_match.ks",debug()). // #include lib_orbit_match
  IF doOrbitMatch(FALSE,stageDV(),ORBIT_INC,-1,ANG_PREC) { runMode(803). }
  ELSE { runMode(809,802). }

} ELSE IF rm = 803 {
  runScript("lib_orbit.ks",debug()). // #include lib_orbit
  runScript("lib_burn.ks",debug()). // #include lib_burn
  runScript("lib_orbit_tools.ks",debug()). // #include lib_orbit_tools
  IF ABS(APOAPSIS - ORBIT_AP) > ALT_PREC * ORBIT_AP {
    IF NOT HASNODE {
      setTime("TRA",TIME:SECONDS + (CalculateTransferAngle(ORBIT_AP + SHIP:BODY:RADIUS,SAT_POS()) - SHIP:GEOPOSITION:LNG) / dvSpeedAngle(TP)).
      pOut("Time to optimal angle: " + ROUND(-diffTime("TRA"),1) + " s").
      ADD(nodeAlterOrbit(TIMES["TRA"],ORBIT_AP)).
    }
    IF execNode(TRUE) { runMode(804). }
    ELSE { runMode(809,802). }
  } ELSE { runMode(804). }

} ELSE IF rm = 804 {
  runScript("lib_orbit.ks",debug()). // #include lib_orbit
  runScript("lib_burn.ks",debug()). // #include lib_burn
  IF ABS(APOAPSIS - PERIAPSIS) > ALT_PREC * APOAPSIS {
    pOut("Circulate current orbit").
    IF NOT HASNODE { ADD(nodeAlterOrbit(timeHeigth(ORBIT_AP), ORBIT_AP)). }
    IF execNode(TRUE,{ RETURN SHIP:ORBIT:PERIOD >= SHIP:BODY:ROTATIONPERIOD. },{ RETURN MIN(MAX(40*(1 - SHIP:ORBIT:PERIOD / SHIP:BODY:ROTATIONPERIOD), 0.001), 1). }) { runMode(805). }
    ELSE { runMode(809,802). }
  } ELSE { runMode(805). }

} ELSE IF rm = 805 {
  pOut("Activate modules").
  runScript("lib_ant.ks",debug()). // #include lib_ant
  runScript("lib_panels.ks",debug()). // #include lib_panels
  doAnt().
  doPanels().
  runMode(806).

} ELSE IF rm = 806 {
  delResume().
  runMode(mission_end_mode).

} ELSE IF rm = mission_end_mode {
  runScript("lib_steer.ks",debug()). // #include lib_steer
  hudMsg("Mission complete. Hit abort to retry (mode " + abortMode() + ").").
  steerSun().
  pout("Target  longtitude: " + ROUND(mAngle(SAT_POS()),2)).
  pout("Current longtitude: " + ROUND(mAngle(SHIP:GEOPOSITION:LNG),2)).
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
