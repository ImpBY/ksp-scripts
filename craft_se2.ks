sasOff().
rcsOff().

LOCAL az IS 90.
LOCAL pc IS 90.
LOCAL pc1 IS 45.
LOCAL uA IS -3.
LOCAL thr IS 1.

throttleTo().
steerTo().
pOut("3").
WAIT 1.
pOut("2").
WAIT 1.
pOut("1").
WAIT 1.
pOut("START").
doStage().
throttleTo({ RETURN thr. }).
doStage().
WAIT 0.2.
steerTo({ RETURN HEADING(az,pc):VECTOR. }).
pOUt("AZIMUT: " + az).
pOut("PITCH : " + pc).

WAIT UNTIL AIRSPEED > 60.
SET pc TO pc1.
pOut("PITCH : " + pc).

WAIT UNTIL AIRSPEED > 280 OR VERTICALSPEED < 0.

steerTo({ RETURN HEADING(az,90 - VANG(SHIP:UP:VECTOR, SHIP:SRFPROGRADE:VECTOR)+uA):VECTOR. }).

WAIT UNTIL AIRSPEED > 580 OR VERTICALSPEED < 0.

steerTo({ RETURN HEADING(az,90):VECTOR. }).

WAIT UNTIL ALTITUDE > 40000 OR VERTICALSPEED < 0 OR APOAPSIS > 80000.

steerTo({ RETURN HEADING(az,0):VECTOR. }).

killWarp().
throttleTo().
steerOff().
sasOn().
rcsOn().

pOut("Wait apoapsis.").
WAIT UNTIL VERTICALSPEED < 0.

doStage().
pOut("Apoapsis reach.").
steerTo({ RETURN HEADING(az,0):VECTOR. }).

pOut("Wait 3000").
WAIT UNTIL ALT:RADAR < 3000.
sasOff().
rcsOff().
AG6 ON.
pOut("chute 1").

pOut("Wait 300").
WAIT UNTIL ALT:RADAR < 300.
AG7 ON.
pOut("chute 2").

steerOff().

pOut("Wait Landing").

WAIT UNTIL ALT:RADAR < 50.
killWarp().
throttleOff().
steerOff().

WAIT UNTIL hasLanded().
pOut("Landed").
