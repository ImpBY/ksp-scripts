@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

LOCAL AZIMUT IS 90.
LOCK PANGL TO 90.
LOCAL ap IS 500000.

LOCAL Stage1FinalPitch IS 30.
LOCAL TurnTime IS 125.

FOR f IN LIST(
  "lib_launch_common.ks", // #include lib_launch_common
  "lib_steer.ks" // #include lib_steer
) { runScript(f,debug()). }

WAIT 10.
pOut("BURN").
throttleTo({ RETURN 1. }).
doStage().
WAIT 3.
steerTo({ RETURN HEADING(AZIMUT,PANGL):VECTOR. }).
pOUt("AZIMUT: " + AZIMUT).
pOut("PITCH : " + PANGL).
pOut("START").
doStage().

WAIT UNTIL AIRSPEED > 60.

LOCAL TimeZero IS TIME:SECONDS.
LOCAL Stage1List IS SHIP:PARTSTAGGED("Stage1Tank"). 

LOCK PANGL TO MAX((90-Stage1FinalPitch)*(TurnTime + TimeZero - TIME:SECONDS)/TurnTime + Stage1FinalPitch, Stage1FinalPitch).

pOut("PITCH : " + PANGL).

WAIT UNTIL (( Stage1List[0]:RESOURCES[0]:Amount < 1 ) OR ( Stage1List[0]:RESOURCES[1]:Amount < 1 ) OR ( APOAPSIS > ap )).

throttleOff().
steerOff().
pOut("Control free").

WAIT 2.
doStage().

WAIT 3.
doStage().

WHEN VERTICALSPEED < 0 THEN {
  doStage().
  pOut("Apoapsis").
}

WHEN ALT:RADAR > 50 AND VERTICALSPEED < 0 THEN {
  steerOff().
  pOut("Control free").
  WHEN ALT:RADAR < 100 THEN { killWarp(). }
}

WAIT UNTIL hasLanded().
pOut("LANDED").