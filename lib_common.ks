@LAZYGLOBAL OFF. // #include init

// logging
GLOBAL LOG_FILE IS "".

FUNCTION logOn {
  PARAMETER lf IS "0:/logs/" + padRep(0,"_",SHIP:NAME) + ".log".
  SET LOG_FILE TO lf.
  doLog(SHIP:NAME).
  IF lf <> "" { pOut("Log file: " + LOG_FILE). }
}

FUNCTION logOff {
  SET LOG_FILE TO "".
}

FUNCTION doLog {
  PARAMETER t.
  IF LOG_FILE <> "" { LOG t TO LOG_FILE. }
}

// debug
GLOBAL vDEB IS FALSE.

FUNCTION debugOn {
  SET vDEB TO TRUE.
}

FUNCTION debugOff {
  SET vDEB TO FALSE.
}

FUNCTION debug {
  RETURN vDEB.
}

// print
GLOBAL INIT_MET_TS IS -1.
GLOBAL INIT_MET IS "".

FUNCTION padRep {
  PARAMETER l, s, t.
  RETURN (""+t):PADLEFT(l):REPLACE(" ",s).
}

FUNCTION formatTS {
  PARAMETER u_time1, u_time2 IS TIME:SECONDS.
  LOCAL ts IS (TIME - TIME:SECONDS) + ABS(u_time1 - u_time2).
  RETURN "[" + padRep(2,"0",ts:YEAR - 1) + " " + padRep(3,"0",ts:DAY - 1) + " " + ts:CLOCK + "]".
}

FUNCTION formatMET {
  LOCAL m IS ROUND(MISSIONTIME).
  IF m > INIT_MET_TS {
    SET INIT_MET_TS TO m.
    SET INIT_MET TO formatTS(TIME:SECONDS - m).
  }
  RETURN INIT_MET.
}

FUNCTION pOut {
  PARAMETER t, wt IS TRUE, col IS -1, row IS -1.
  IF row > -1 {
    PRINT t AT (col,row).
  } ELSE {
    IF wt { SET t TO formatMET() + " " + t. }
    PRINT t.
    doLog(t).
  }
}

FUNCTION hudMsg {
  PARAMETER t, c IS YELLOW, s IS 40.
  HUDTEXT(t, 3, 2, s, c, FALSE).
  pOut("HUD: " + t).
}

// functions
FUNCTION doStage {
  pOut("Staging.").
  setTime("STAGE").
  STAGE.
}

FUNCTION mAngle {
  PARAMETER a.
  UNTIL a >= 0 { SET a TO a + 360. }
  RETURN MOD(a,360).
}

FUNCTION getValue {
  PARAMETER s, pn.
  LOCAL pn1 IS "".
  FOR s1 IN s:SPLIT(";") {
    SET pn1 TO s1:SPLIT("=").
    IF pn1:LENGTH > 1 {
      IF pn1[0]:CONTAINS(pn) { RETURN pn1[1]. }
    }
  }
  RETURN "".
}

FUNCTION hasLanded {
  RETURN LIST("LANDED","SPLASHED"):CONTAINS(STATUS).
}
