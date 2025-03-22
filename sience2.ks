FUNCTION countdown {
  FROM {LOCAL i IS 3.} UNTIL i = 0 STEP {SET i TO i - 1.} DO {
    PRINT i.
    WAIT 1.
  }
  PRINT "start".
}

FUNCTION log_data {
  PARAMETER filename.
  LOG time:seconds + ";" + 
      ship:altitude + ";" + 
      ship:verticalspeed + ";" + 
      ship:sensors:temp + ";" +  
      ship:sensors:pres + ";" +  
      ship:sensors:acc:mag + ";" +  
      ship:sensors:grav:mag + ";" 
  TO filename.
}

LOCK STEERING TO HEADING(90, 90) + R(0,0,-90).

countdown().
STAGE.

WAIT UNTIL ALT:RADAR > 300 OR SHIP:AIRSPEED > 100.
PRINT "recover triggers start".

WHEN SHIP:ALTITUDE > 70000 THEN {
  PRINT "atmosphere leave".
  STAGE.
}

WHEN ALT:RADAR < 300 THEN {
  PRINT "parachute activate".
  STAGE.
  UNLOCK STEERING.
}

PRINT "logging start".
UNTIL ALT:RADAR < 300 AND SHIP:AIRSPEED < 100 {
  log_data("0:/logs/log3.csv").
  WAIT 0.5.
}

PRINT "logging stop".
WAIT UNTIL STATUS = "LANDED" OR STATUS = "SPLASHED".
PRINT "landed".