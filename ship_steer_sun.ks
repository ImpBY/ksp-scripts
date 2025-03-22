@LAZYGLOBAL OFF. SWITCH TO 1. IF NOT EXISTS("1:/init.ks") { RUNPATH("0:/init_select.ks"). }. RUNONCEPATH("1:/init.ks").

GLOBAL SHIP_WARP_ALLOW IS FALSE.
GLOBAL mission_end_mode IS 888.
GLOBAL EC_CAP IS 0.
GLOBAL EC_AMOUNT IS 0.

runCraftInit().

UNTIL runMode() = 99 {
LOCAL rm IS runMode().
IF rm < 0 {
  store("runScript(" + CHAR(34) + "s.ks" + CHAR(34) + "," + debug() + ").","autorun.ks").
  warpStatus(SHIP_WARP_ALLOW).
  runMode(801,99).

} ELSE IF MOD(rm,10) = 9 AND rm > 800 AND rm < 999 {
  runScript("lib_steer.ks",debug()).
  hudMsg("Error state. Hit abort to recover (mode " + abortMode() + ").").
  steerSun().
  WAIT UNTIL MOD(runMode(),10) <> 9.

} ELSE IF rm = 801 {
  IF SHIP:STATUS = "ORBITING" OR SHIP:STATUS = "SUB_ORBITAL" OR SHIP:STATUS = "ESCAPING" { runMode(802,99). }
  ELSE { runMode(99). }

} ELSE IF rm = 802 {
  IF HASNODE { runMode(803). }
  ELSE { runMode(805,99). }

} ELSE IF rm = 803 {
  runScript("lib_burn.ks",debug()).
  IF execNode(TRUE) { runMode(801). }
  ELSE { runMode(804,801). }

} ELSE IF rm = 804 {
  runScript("lib_rcs_burn.ks",debug()).
  IF rcsExecNode() { runMode(801). }
  ELSE { runMode(809,801). }

} ELSE IF rm = 805 {
  runScript("lib_steer.ks",debug()).
  hudMsg("Mission complete. Hit abort to retry (mode " + abortMode() + ").").
  pOut("Start steering to Sun").
  steerSun().
  runMode(807).
  
} ELSE IF rm = 806 {
  runScript("lib_ant.ks",debug()).
  pOut("Low EC power").
  doAnt(FALSE).
  steerOff().
  runMode(807).

} ELSE IF rm = 807 {
  IF SHIP:ELECTRICCHARGE > 50 AND modeTime() > 3 { runMode(808). }
  WAIT 1.

} ELSE IF rm = 808 {
  runScript("lib_ant.ks",debug()).
  pOut("EC Power ok").
  doAnt().
  steerSun().
  pOut("AG1 to proccess NODE").
  ON AG1 { IF HASNODE { runMode(803). }. }
  runMode(mission_end_mode).

} ELSE IF rm = mission_end_mode {
  steerSun().
  IF SHIP:ELECTRICCHARGE < 50 { runMode(806). }
  WAIT 1.

}

WAIT 0.

}
cleanCraft().
runScript("c.ks",TRUE).
runScript("u.ks",TRUE).
rcsOff().
sasOn().
REBOOT.
