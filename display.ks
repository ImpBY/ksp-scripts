CORE:DOEVENT("Open Terminal").
SWITCH TO 1.
CLEARSCREEN.
WHEN ALT:RADAR > 4000 THEN {
  WHEN ALT:RADAR < 3000 THEN {
    SAS OFF.
    RCS OFF.
  }
  WHEN ALT:RADAR < 300 THEN {
    SAS OFF.
    RCS OFF.
  }
}

UNTIL FALSE {
  PRINT "                            " AT (0,3).
  PRINT "ALTITUDE:  " + ROUND(SHIP:ALTITUDE,2) + " m      " AT (0,4).
  PRINT "                            " AT (0,5).
  PRINT "APOAPSIS:  " + ROUND(SHIP:APOAPSIS,2) + " m      " AT (0,6).
  PRINT "PERIAPSIS: " + ROUND(SHIP:PERIAPSIS,2) + " m      " AT (0,7).
  PRINT "                            " AT (0,8).
  PRINT "ETA to AP: " + ROUND(ETA:APOAPSIS) + " s      " AT (0,9).
  PRINT "ETA to PE: " + ROUND(ETA:PERIAPSIS) + " s      " AT (0,10).
  PRINT "                            " AT (0,11).
  PRINT "SHIP FUEL" AT (0,12).
  PRINT "  solid:   " + ROUND(SHIP:SOLIDFUEL,2) + " L      " AT (0,13).
  PRINT "  liquid:  " + ROUND(SHIP:LIQUIDFUEL,2) + " L      " AT (0,14).
  PRINT "  oxidizer:  " + ROUND(SHIP:OXIDIZER,2) + " L      " AT (0,15).
  PRINT "                            " AT (0,16).
  PRINT "STAGE FUEL" AT (0,17).
  PRINT "  solid:   " + ROUND(STAGE:SOLIDFUEL,2) + " L      " AT (0,18).
  PRINT "  liquid:  " + ROUND(STAGE:LIQUIDFUEL,2) + " L      " AT (0,19).
  PRINT "  oxidizer:  " + ROUND(STAGE:OXIDIZER,2) + " L      " AT (0,20).
  PRINT "                            " AT (0,21).
  WAIT 0.1.
}
