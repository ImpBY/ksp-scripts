@LAZYGLOBAL OFF. // #include init

GLOBAL WARP_MAX_PHYSICS IS 3.
GLOBAL WARP_MAX_RAILS IS 7.
GLOBAL WARP_RAILS_BUFF IS LIST(10, 30, 60, 225, 675, 10000, 150000).
GLOBAL WARP_ALLOW IS FALSE.
GLOBAL WARP_ALLOW_TEMP IS FALSE.

GLOBAL WARP_MIN_ALTS IS LEXICON(
  "Moho", 10000,
  "Eve", 90000,
  "Gilly", 8000,
  "Kerbin", 70000,
  "Mun", 5000,
  "Minmus", 3000,
  "Duna", 50000,
  "Ike", 5000,
  "Dres", 10000,
  "Jool", 200000,
  "Laythe", 50000,
  "Vall", 24500,
  "Tylo", 30000,
  "Bop", 24500,
  "Pol", 5000,
  "Eeloo", 4000
).

LOCAL bl IS LIST().
LIST BODIES IN bl.
FOR b IN bl {
  IF WARP_MIN_ALTS:HASKEY(b:NAME) AND b:ATM:EXISTS {
    SET WARP_MIN_ALTS[b:NAME] TO MAX(WARP_MIN_ALTS[b:NAME],b:ATM:HEIGHT).
  }
}

FUNCTION warpTime {
  RETURN -diffTime("WARP").
}

FUNCTION setMaxWarp {
  PARAMETER mp IS 3, mr IS 7.
  SET WARP_MAX_PHYSICS TO mp.
  SET WARP_MAX_RAILS TO mr.
}

FUNCTION pickWarpMode {
  IF WARP_MIN_ALTS:HASKEY(BODY:NAME) AND ALTITUDE <= WARP_MIN_ALTS[BODY:NAME] AND
    NOT LIST("LANDED","SPLASHED","PRELAUNCH"):CONTAINS(STATUS) { RETURN "PHYSICS". }
  RETURN "RAILS".
}

FUNCTION pickWarp {
  IF WARPMODE = "PHYSICS" { RETURN WARP_MAX_PHYSICS. }

  FROM { LOCAL i IS WARP_MAX_RAILS. } UNTIL i < 1 STEP { SET i TO i - 1. } DO {
    IF warpTime() > WARP_RAILS_BUFF[i-1] { RETURN i. }
  }

  RETURN 0.
}

FUNCTION killWarp {
  KUNIVERSE:TIMEWARP:CANCELWARP().
  WAIT UNTIL SHIP:UNPACKED.
}

FUNCTION warpAllow{
  RETURN WARP_ALLOW.
}

FUNCTION warpAllowTemp{
  RETURN WARP_ALLOW_TEMP.
}

FUNCTION warpStatus {
  PARAMETER wa IS FALSE.
  IF wa {
    pOut("WARP set to AUTOMATIC mode.").
  } ELSE {
    pOut("WARP set to MANUAL mode.").
  }
  SET WARP_ALLOW TO wa.
  append("warpStatus(" + wa + ").").
}

FUNCTION warpTemp {
  PARAMETER wa IS FALSE.
  IF wa {
    pOut("tempWARP set to AUTOMATIC mode.").
  } ELSE {
    pOut("tempWARP set to MANUAL mode.").
  }
  SET WARP_ALLOW_TEMP TO wa.
  append("warpTemp(" + wa + ").").
}

FUNCTION doWarp {
  PARAMETER wt, stop_func IS { RETURN FALSE. }.

  setTime("WARP",wt).

  IF warpTime() < WARP_RAILS_BUFF[0] { RETURN FALSE. }
  IF WARP_ALLOW OR WARP_ALLOW_TEMP {
    pOut("Auto warp " + formatTS(wt)).
  } ELSE {
    pOut("Manual warp " + formatTS(wt)).
  }
  
  UNTIL stop_func() OR warpTime() <= 0 {
    LOCAL want_mode IS pickWarpMode().
    IF WARPMODE <> want_mode {
      IF WARP_ALLOW OR WARP_ALLOW_TEMP {
        pOut("Switching warp mode to: " + want_mode).
        SET WARP TO 0.
        SET WARPMODE TO want_mode.
      }
    } ELSE {
      LOCAL want_warp IS pickWarp().
      IF WARP_ALLOW OR WARP_ALLOW_TEMP {
        IF WARP <> want_warp {
          SET WARP TO want_warp.
        }
      } ELSE {
        IF WARP > want_warp {
          SET WARP TO want_warp.
        }
      }
    }
    PRINT "                                     " AT (0,0).
    PRINT "                                     " AT (0,1).
    PRINT "          " + formatTS(wt) + "          " AT (0,2).
    PRINT "                                     " AT (0,3).
    PRINT "                                     " AT (0,4).
    WAIT 0.
  }
  IF WARP <> 0 { SET WARP TO 0. }
  IF warpTime() > 0 { pOut("Ending time warp early."). }
  WAIT UNTIL SHIP:UNPACKED.
  warpTemp(WARP_ALLOW).
  
  pOut("Time warp over.").
  RETURN TRUE.
}
