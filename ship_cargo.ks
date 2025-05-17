@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

FOR f IN LIST(
  "lib_launch_crew.ks", // #include lib_launch_crew
  "lib_reentry.ks", // #include lib_reentry
  "lib_transfer.ks", // #include lib_transfer
  "lib_rendezvous.ks", // #include lib_rendezvous
  "lib_orbit_match.ks", // #include lib_orbit_match
  "lib_orbit_change.ks" // #include lib_orbit_change
) { runScript(f,debug()). }

GLOBAL ORBIT_LOW IS MAX(BODY:ATM:HEIGHT * 1.05, 8000).
GLOBAL SHIP_WARP_ALLOW IS FALSE.
GLOBAL ANG_PREC IS 0.2.
GLOBAL ALT_PREC IS 1.0.
GLOBAL mission_end_mode IS 888.

runCraftInit().

FUNCTION validMoonTarget {
  RETURN HASTARGET AND TARGET:OBT:BODY:OBT:BODY = BODY.
}

FUNCTION validLocalTarget {
  RETURN HASTARGET AND TARGET:OBT:BODY = BODY.
}

UNTIL runMode() = 99 {
LOCAL rm IS runMode().
IF rm < 0 {
  store("runScript(" + CHAR(34) + CRAFT_FILE_RUN + CHAR(34) + "," + debug() + ").","autorun.ks").
  warpStatus(SHIP_WARP_ALLOW).

  runScript("lib_launch_geo.ks",debug()).

  hudMsg("Please select a target").
  pOut("Waiting.").
  WAIT UNTIL validMoonTarget() OR validLocalTarget().

  pOut("Valid target. Calculating launch details.").
  LOCAL ap IS MAX(MIN((TARGET:OBT:APOAPSIS + TARGET:OBT:PERIAPSIS) / 3, 500000), ORBIT_LOW).
  LOCAL b_I IS TARGET:OBT:INCLINATION.
  LOCAL b_LAN IS TARGET:OBT:LAN.
  IF validMoonTarget() {
    SET b_I TO TARGET:OBT:BODY:OBT:INCLINATION.
    SET b_LAN TO TARGET:OBT:BODY:OBT:LAN.
  }
  LOCAL launch_details IS calcLaunchDetails(ap,b_I,b_LAN).
  LOCAL az IS launch_details[0].
  IF b_LAN > -1 AND ABS(b_I + SHIP:GEOPOSITION:LAT) > ANG_PREC {
    LOCAL launch_time IS launch_details[1].
    warpToLaunch(launch_time).
  }

  delScript("lib_launch_geo.ks",debug()).
  runScript("lib_launch_crew.ks",debug()).
  SET OPT_TWR TO SHIP_TWR.

  store("doLaunch(801," + ap + "," + az + "," + b_I + ").").
  doLaunch(801,ap,az,b_I).

} ELSE IF rm > 50 AND rm < 99 {
  runScript("lib_reentry.ks",debug()).
  resume().

} ELSE IF rm > 100 AND rm < 150 {
  runScript("lib_transfer.ks",debug()).
  resume().

} ELSE IF rm > 400 AND rm < 450 {
  runScript("lib_rendezvous.ks",debug()).
  resume().

} ELSE IF MOD(rm,10) = 9 AND rm > 800 AND rm < 999 {
  runScript("lib_steer.ks",debug()).
  hudMsg("Error state. Hit abort to switch to recovery mode: " + abortMode() + ".").
  steerSun().
  WAIT UNTIL MOD(runMode(),10) <> 9.

} ELSE IF rm = 801 {
  delResume().
  delScript("lib_launch_crew.ks",debug()).
  delScript("lib_launch_common.ks",debug()).
  runMode(802).
} ELSE IF rm = 802 {
  runScript("lib_orbit_match.ks",debug()).
  IF validMoonTarget() {
    LOCAL b_I IS TARGET:OBT:BODY:OBT:INCLINATION.
    LOCAL b_LAN IS TARGET:OBT:BODY:OBT:LAN.
    IF doOrbitMatch(FALSE,stageDV(),b_I,b_LAN,ANG_PREC) { runMode(811). }
    ELSE { runMode(809,802). }
  } ELSE IF validLocalTarget() {
    LOCAL b_I IS TARGET:OBT:INCLINATION.
    LOCAL b_LAN IS TARGET:OBT:LAN.
    IF doOrbitMatch(FALSE,stageDV(),b_I,b_LAN,ANG_PREC) { runMode(811). }
    ELSE { runMode(809,802). }
  } ELSE {
    pOut("No valid target selected.").
    hudMsg("Select new target.").
    runMode(803).
  }
} ELSE IF rm = 803 {
  IF validMoonTarget() OR validLocalTarget() { runMode(802). }

} ELSE IF rm = 811 {
  runScript("lib_transfer.ks",debug()).
  IF validMoonTarget() {
    LOCAL t_B IS TARGET:OBT:BODY.
    LOCAL t_AP IS TARGET:APOAPSIS.
    LOCAL t_I IS TARGET:OBT:INCLINATION.
    LOCAL t_LAN IS TARGET:OBT:LAN.
    store("doTransfer(821, FALSE, "+t_B+","+t_AP+","+t_I+","+t_LAN+").").
    doTransfer(821, FALSE, t_B, t_AP, t_I, t_LAN).
  } ELSE IF validLocalTarget() {
    runMode(821).
  } ELSE {
    pOut("No valid target selected.").
    hudMsg("Select new target.").
    runMode(803).
  }

} ELSE IF rm = 821 {
  delResume().
  IF validLocalTarget() {
    runScript("lib_rendezvous.ks",debug()).
    LOCAL t IS TARGET.
    store("changeRDZ_DIST(25).").
    append("doRendezvous(831,VESSEL(" + CHAR(34) + t:NAME + CHAR(34) + "),FALSE).").
    changeRDZ_DIST(25).
    doRendezvous(831,t,FALSE).
  } ELSE {
    pOut("No valid target selected.").
    hudMsg("Select new target or hit abort to return to Kerbin.").
    runMode(822,mission_end_mode).
  }
} ELSE IF rm = 822 {
  IF validLocalTarget() { runMode(821,0). }

} ELSE IF rm = 831 {
  delResume().
  pOut("Rendezvous complete.").
  IF HASTARGET { SET TARGET TO "". }
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
