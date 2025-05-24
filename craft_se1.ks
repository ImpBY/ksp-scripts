@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

FOR f IN LIST(
  "lib_chutes.ks", // #include lib_chutes
  "lib_launch_common.ks", // #include lib_launch_common
  "lib_steer.ks" // #include lib_steer
) { runScript(f,debug()). }

steerTo().
pOut("3").
WAIT 1.
pOut("2").
WAIT 1.
pOut("1").
WAIT 1.
pOut("START").
doStage().
WAIT 3.
WHEN ALTITUDE > 49000 AND ALTITUDE < 52000 AND ABS(VERTICALSPEED) > 770 AND ABS(VERTICALSPEED) < 180 THEN { deployChutes(). }
WHEN VERTICALSPEED < 0 THEN { pOut("Apoapsis"). doStage(). }
WHEN ALT:RADAR > 50 AND VERTICALSPEED < 0 THEN {
  deployChutes().
  steerOff().
  WHEN ALT:RADAR < 50 THEN { killWarp(). }
}
WAIT UNTIL hasLanded().
pOut("LANDED").