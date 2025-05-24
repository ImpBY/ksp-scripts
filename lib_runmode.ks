@LAZYGLOBAL OFF. // #include init

GLOBAL RM_FN IS "rm.ks".
GLOBAL RM_RM IS -1.
GLOBAL RM_AM IS -1.
GLOBAL RM_COUNT IS 0.


setTime("RM").
setTime("RM_COUNT").
GLOBAL modeTime IS diffTime@:BIND("RM").
resume(RM_FN).

ON AG9 {
  PRINT "INPUT: " + RM_COUNT + " (tempWARP CONTROL)".
  warpTemp(NOT warpAllowTemp()).
  warpStatus(FALSE).
  RETURN TRUE.
}

ON AG10 {
  IF TIME:SECONDS > TIMES["RM_COUNT"] {
    SET RM_COUNT TO 0.
    setTime("RM_COUNT", TIME:SECONDS + 10).
    PRINT "INPUT: " + RM_COUNT + " (timeout)".
    RETURN TRUE.
  }
  SET RM_COUNT TO RM_COUNT + 1.
  setTime("RM_COUNT", TIME:SECONDS + 10).
  IF        RM_COUNT = 1 { PRINT "SET CODE: " + RM_COUNT + " (WARP CONTROL) CURRENT: " + warpAllow().
  } ELSE IF RM_COUNT = 2 { PRINT "SET CODE: " + RM_COUNT + " (UPDATE + REBOOT)".
  } ELSE IF RM_COUNT = 3 { PRINT "SET CODE: " + RM_COUNT + " (SS MODE + REBOOT)".
  } ELSE IF RM_COUNT = 4 { PRINT "SET CODE: " + RM_COUNT + " (CLEAN + REBOOT)".
  } ELSE { SET RM_COUNT TO 0. PRINT "SET CODE: " + RM_COUNT + " (NO ACTION)". }
  RETURN TRUE.
}

ON ABORT {
  IF RM_COUNT = 0 {
    PRINT "INPUT: ABORT".
    IF RM_AM > 0 { pOut("Abort to mode: " + RM_AM,FALSE). runMode(RM_AM, 0, FALSE). }
  } ELSE IF RM_COUNT = 1 {
    PRINT "INPUT: " + RM_COUNT + " (WARP CONTROL)".
    warpStatus(NOT warpAllow()).
  } ELSE IF RM_COUNT = 2 {
    PRINT "INPUT: " + RM_COUNT + " (UPDATE + REBOOT)".
    runScript("u.ks",TRUE).
    REBOOT.
  } ELSE IF RM_COUNT = 3 {
    PRINT "INPUT: " + RM_COUNT + " (SS MODE + REBOOT)".
    runScript("c.ks",TRUE).
    runScript("u.ks",TRUE).
    store("runScript(" + CHAR(34) + "s.ks" + CHAR(34) + "," + debug() + ").","autorun.ks").
    warpStatus(FALSE).
    rcsOff().
    sasOn().
    REBOOT.
  } ELSE IF RM_COUNT = 4 {
    PRINT "INPUT: " + RM_COUNT + " (CLEAN + REBOOT)".
    runScript("c.ks",TRUE).
    rcsOff().
    sasOn().
    CORE:VOLUME:DELETE("/boot").
    SET CORE:BOOTFILENAME TO "".
    REBOOT.
  }
  SET RM_COUNT TO 0.
  setTime("RM_COUNT", TIME:SECONDS).
  RETURN TRUE.
}

FUNCTION pMode {
  LOCAL s IS "Run mode: " + RM_RM.
  IF RM_AM > 0 { SET s TO s + ", Abort mode: " + RM_AM. }
  pOut(s).
}

FUNCTION logModes {
  store("SET RM_RM TO " + RM_RM + ".", RM_FN).
  IF RM_AM > 0 { append("SET RM_AM TO " + RM_AM + ".", RM_FN). }
  append("pMode().", RM_FN).
}

FUNCTION runMode {
  PARAMETER rm IS -1, am IS -1, p IS TRUE.

  IF rm >= 0 {
    IF am >= 0 { SET RM_AM TO am. }
    SET RM_RM TO rm.
    setTime("RM").
    logModes().
    if p { pMode(). }
  }
  RETURN RM_RM.
}

FUNCTION abortMode {
  PARAMETER am IS -1.
  IF am >= 0 { SET RM_AM TO am. logModes(). }
  RETURN RM_AM.
}

FUNCTION resetMode {
  SET RM_RM TO -1.
  SET RM_AM TO -1.
  store("SET RM_RM TO " + RM_RM + ".", RM_FN).
  append("SET RM_AM TO " + RM_AM + ".", RM_FN).
  append("pMode().", RM_FN).
}