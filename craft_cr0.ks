@LAZYGLOBAL OFF.

LOCAL AZIMUT IS 90.
LOCK PANGL TO 90.
LOCAL ap IS 180000.

LOCAL Stage1FinalPitch IS 60.
LOCAL TurnTime IS 120.

FOR f IN LIST(
  "lib_launch_common.ks",
  "lib_steer.ks"
) { runScript(f,debug()). }

WAIT 10.
pOut("BURN").
throttleTo({ RETURN 1. }).
rcsOn().
doStage().
WAIT 3.
pOut("Engine ready").
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

WAIT UNTIL ( Stage1List[0]:RESOURCES[0]:Amount < 1 ) OR ( Stage1List[0]:RESOURCES[1]:Amount < 1 ) OR ( APOAPSIS > ap ).

WHEN ALTITUDE < 100 THEN { pOut("kill Warp"). killWarp(). }

steerSurf().

throttleOff().
pOut("Separete booster").
WAIT 2.
doStage().
WAIT 3.
doStage().
throttleTo({ RETURN 1. }).

WAIT UNTIL (APOAPSIS > ap AND ALTITUDE > 100000) OR VERTICALSPEED < 0.
throttleOff().
pOut("APOAPSIS is ok").

WHEN ALTITUDE > 141000 THEN {
  steerOff().
  pOut("Enter to space").
  WHEN ALTITUDE < 141000 THEN {
    steerSurf(FALSE).
    pOut("Chutes activate").
    doStage().
  }
}

pOut("Prepare to landing").
WHEN ALT:RADAR < 10000 THEN {
  rcsOff().
}

WAIT UNTIL hasLanded().
pOut("LANDED").