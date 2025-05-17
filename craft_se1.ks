@LAZYGLOBAL OFF. // #include init

runScript("lib_chutes.ks").
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