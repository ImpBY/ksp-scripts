@LAZYGLOBAL OFF.

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

debugOff().

GLOBAL TIMES IS LEXICON().
GLOBAL LOG_FILE IS "".
GLOBAL INIT_MET_TS IS -1.
GLOBAL INIT_MET IS "".
GLOBAL stageTime IS diffTime@:BIND("STAGE").
GLOBAL CRAFT_SPECIFIC IS LEXICON().
GLOBAL CRAFT_FILE_INIT IS "craft_init".
GLOBAL CRAFT_FILE_RUN IS "craft".
// GLOBAL g0 IS KERBIN:MU/KERBIN:RADIUS^2.
GLOBAL g0 IS BODY:MU/BODY:RADIUS^2.
GLOBAL WARP_MIN_ALTS IS LEXICON(
"Moho",  10000,
"Eve",  90000,
"Gilly",  8000,
"Kerbin",  70000,
"Mun",  5000,
"Minmus",  3000,
"Duna",  50000,
"Ike",  5000,
"Dres",  10000,
"Jool",  200000,
"Laythe",  50000,
"Vall",  24500,
"Tylo",  30000,
"Bop",  24500,
"Pol",  5000,
"Eeloo",  4000).
GLOBAL WARP_MAX_PHYSICS IS 3.
GLOBAL WARP_MAX_RAILS IS 7.
GLOBAL WARP_RAILS_BUFF IS LIST(10, 30, 60, 225, 675, 10000, 150000).
GLOBAL WARP_ALLOW IS FALSE.
GLOBAL WARP_ALLOW_ IS FALSE.

killWarp().
setTime("STAGE").
loadScript("craft_" + SHIP:NAME + "_init.ks",debug(),CRAFT_FILE_INIT).
loadScript("craft_" + SHIP:NAME + ".ks",debug(),CRAFT_FILE_RUN).
SWITCH TO 1.
CORE:DOEVENT("Open Terminal").

setTime("MST").
IF MISSIONTIME > 0 { setTime("MST",TIME:SECONDS - MISSIONTIME). }
ELSE { WHEN MISSIONTIME > 0 THEN { setTime("MST",TIME:SECONDS - MISSIONTIME). } }

initWarpLex().

FOR f IN LIST(
"lib_runmode.ks",
"lib_ant.ks",
"lib_panels.ks",
"lib_burn.ks",
"lib_rcs_burn.ks"
) { runScript(f,debug()). }
loadScript("u.ks",debug()).
loadScript("c.ks",debug()).
loadScript("ship_steer_sun.ks",debug(),"s.ks").
loadScript("ship_node.ks",debug(),"n.ks").
loadScript("ship_node_rcs.ks",debug(),"nr.ks").

FUNCTION runCraftInit {
  RETURN runScript(CRAFT_FILE_INIT,debug()).
}

FUNCTION runCraft {
  RETURN runScript(CRAFT_FILE_RUN,debug()).
}

FUNCTION cleanCraft {
  delScript(CRAFT_FILE_INIT).
  delScript(CRAFT_FILE_RUN).
  LOG "" TO CRAFT_FILE_INIT.
  LOG "" TO CRAFT_FILE_RUN.
}

GLOBAL RCS_CONTROLLED IS TRUE.
GLOBAL RCS_MEMORY IS SAS.
RCS OFF.

FUNCTION rcsOn {
  IF NOT RCS_CONTROLLED { SET RCS_MEMORY TO RCS. }
  RCS ON.
  SET RCS_CONTROLLED TO TRUE.
}

FUNCTION rcsOff {
  IF NOT RCS_CONTROLLED { SET RCS_MEMORY TO RCS. }
  RCS OFF.
  SET RCS_CONTROLLED TO TRUE.
}

FUNCTION rcsRestore {
  SET RCS TO RCS_MEMORY.
  SET RCS_CONTROLLED TO FALSE.
}

GLOBAL SAS_CONTROLLED IS TRUE.
GLOBAL SAS_MEMORY IS RCS.
SAS OFF.

FUNCTION sasOn {
  IF NOT SAS_CONTROLLED { SET SAS_MEMORY TO RCS. }
  SAS ON.
  SET SAS_CONTROLLED TO TRUE.
}

FUNCTION sasOff {
  IF NOT SAS_CONTROLLED { SET SAS_MEMORY TO RCS. }
  SAS OFF.
  SET SAS_CONTROLLED TO TRUE.
}

FUNCTION sasRestore {
  SET SAS TO SAS_MEMORY.
  SET SAS_CONTROLLED TO FALSE.
}

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

FUNCTION setTime {
  PARAMETER n, t IS TIME:SECONDS.
  SET TIMES[n] TO t.
}

FUNCTION diffTime {
  PARAMETER n.
  RETURN TIME:SECONDS - TIMES[n].
}

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

FUNCTION initWarpLex {
  LOCAL bl IS LIST().
  LIST BODIES IN bl.
  FOR b IN bl { IF WARP_MIN_ALTS:HASKEY(b:NAME) AND b:ATM:EXISTS {
    SET WARP_MIN_ALTS[b:NAME] TO MAX(WARP_MIN_ALTS[b:NAME],b:ATM:HEIGHT).
  } }
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
  SET WARP_ALLOW_ TO wa.
  append("warpTemp(" + wa + ").").
}

FUNCTION doWarp {
  PARAMETER wt, stop_func IS { RETURN FALSE. }.

  setTime("WARP",wt).

  IF warpTime() < WARP_RAILS_BUFF[0] { RETURN FALSE. }
  IF WARP_ALLOW OR WARP_ALLOW_ {
    pOut("Auto warp " + formatTS(wt)).
  } ELSE {
    pOut("Manual warp " + formatTS(wt)).
  }
  
  IF ADDONS:KAC:AVAILABLE {
    LOCAL f_a IS TRUE.
    FOR a IN LISTALARMS("All") {
      IF a:TYPE = "RAW" AND a:NAME = SHIP:NAME AND ABS(a:REMAINING - (wt - TIME:SECONDS)) < 30 { SET f_a TO FALSE. }
    }
    IF wt - 30 > TIME:SECONDS AND f_a {
      LOCAL wa IS ADDALARM("RAW",wt,SHIP:NAME,"").
      pOut("Warp alarm added").
    }
  }
  
  UNTIL stop_func() OR warpTime() <= 0 {
    LOCAL want_mode IS pickWarpMode().
    IF WARPMODE <> want_mode {
      IF WARP_ALLOW OR WARP_ALLOW_ {
        pOut("Switching warp mode to: " + want_mode).
        SET WARP TO 0.
        SET WARPMODE TO want_mode.
      }
    } ELSE {
      LOCAL want_warp IS pickWarp().
      IF WARP_ALLOW OR WARP_ALLOW_ {
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
  
  IF ADDONS:KAC:AVAILABLE {
    FOR a IN LISTALARMS("All") {
      IF a:REMAINING < 30 {
        DELETEALARM(a:ID).
        pOut("Warp alarm deleted").
      }
    }
  }
  pOut("Time warp over.").
  RETURN TRUE.
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