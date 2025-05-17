@LAZYGLOBAL OFF. // #include init

GLOBAL vDEB IS FALSE.

GLOBAL TIMES IS LEXICON().
GLOBAL LOG_FILE IS "".
GLOBAL INIT_MET_TS IS -1.
GLOBAL INIT_MET IS "".
GLOBAL stageTime IS diffTime@:BIND("STAGE").
GLOBAL CRAFT_SPECIFIC IS LEXICON().
GLOBAL CRAFT_FILE_RUN IS "craft.ks".
GLOBAL g0 IS BODY:MU/BODY:RADIUS^2.
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
"Eeloo", 4000).
GLOBAL WARP_MAX_PHYSICS IS 3.
GLOBAL WARP_MAX_RAILS IS 7.
GLOBAL WARP_RAILS_BUFF IS LIST(10, 30, 60, 225, 675, 10000, 150000).
GLOBAL WARP_ALLOW IS FALSE.
GLOBAL WARP_ALLOW_ IS FALSE.

GLOBAL RESUME_FN IS "resume.ks".
GLOBAL DISK_PREFIX IS "".
GLOBAL DISK_LOCAL IS "".

GLOBAL RCS_CONTROLLED IS TRUE.
GLOBAL RCS_MEMORY IS SAS.

GLOBAL SAS_CONTROLLED IS TRUE.
GLOBAL SAS_MEMORY IS RCS.

RCS OFF.
SAS OFF.
initWarpLex().
debugOff().
killWarp().
setTime("STAGE").
sysUpdate().
SWITCH TO 1.
CORE:DOEVENT("Open Terminal").

FUNCTION debugOn {
  SET vDEB TO TRUE.
}

FUNCTION debugOff {
  SET vDEB TO FALSE.
}

FUNCTION debug {
  RETURN vDEB.
}

FUNCTION loadScript {
  PARAMETER fn, loud IS debug(), fnn IS fn, repl IS FALSE.

  IF repl { delScript(fnn,loud). }

  LOCAL lfp IS DISK_LOCAL + ":/" + fnn.
  IF EXISTS(lfp) { RETURN lfp. }

  LOCAL afp IS "Archive:/" + fn.
  IF EXISTS(afp) {
    LOCAL afs IS VOLUME(0):OPEN(fn):SIZE.
    IF loud { pOut("cpf: " + afp + " (" + afs + " bytes)"). }
    COPYPATH(afp,lfp).
    IF loud { pOut("cpt: " + lfp). }
    RETURN lfp.
  } ELSE {
    IF loud { pOut(afp + " not found"). }
    RETURN "".
  }
}

FUNCTION runScript {
  PARAMETER fn, loud IS debug(), fnn IS fn, repl IS FALSE.
  LOCAL lpf IS loadScript(fn,loud,fnn,repl).
  IF lpf <> "" {
    IF loud { pOut("run: " + lpf). }
    RUNONCEPATH(lpf).
    RETURN TRUE.
  }
  RETURN FALSE.
}

FUNCTION delScript {
  PARAMETER fn, loud IS debug().
  LOCAL lfp IS DISK_LOCAL + ":/" + fn.
  IF EXISTS(lfp) {
    IF loud { pOut("del: " + lfp). }
    DELETEPATH(lfp).
  }
}

FUNCTION delResume {
  delScript(RESUME_FN,debug()).
}

FUNCTION store {
  PARAMETER t, fn IS RESUME_FN.
  delScript(fn,debug()).
  LOG t TO (DISK_LOCAL + ":/" + fn).
}

FUNCTION append {
  PARAMETER t, fn IS RESUME_FN.
  LOG t TO (DISK_LOCAL + ":/" + fn).
}

FUNCTION resume {
  PARAMETER fn IS RESUME_FN.
  LOCAL lfp IS DISK_LOCAL + ":/" + fn.
  IF EXISTS(lfp) { RUNPATH(lfp). }
}

FUNCTION findPath {
  PARAMETER fn.
  LOCAL lfp IS DISK_LOCAL + ":/" + fn.
  IF EXISTS(lfp) { RETURN lfp. }
  RETURN "".
}

FUNCTION sysUpdate {
  PARAMETER sn IS SHIP:NAME.
  SET SHIP:NAME TO sn.
  SET DISK_PREFIX TO SHIP:NAME + "Disk".
  SET DISK_LOCAL TO DISK_PREFIX + "0".
  SET CORE:VOLUME:NAME TO DISK_LOCAL.
}

FUNCTION runCraft {
  loadScript("u.ks",debug()).
  loadScript("c.ks",debug()).
  loadScript("ship_steer_sun.ks",debug(),"s.ks").
  loadScript("ship_node.ks",debug(),"n.ks").
  loadScript("ship_node_rcs.ks",debug(),"nr.ks").

  setTime("MST").
  IF MISSIONTIME > 0 { setTime("MST",TIME:SECONDS - MISSIONTIME). }
  ELSE { WHEN MISSIONTIME > 0 THEN { setTime("MST",TIME:SECONDS - MISSIONTIME). } }

  IF NOT findPath(CRAFT_FILE_RUN) {
    LOCAL cn IS "craft_" + SHIP:NAME + ".ks".
    if NOT loadScript(cn,debug(),CRAFT_FILE_RUN) { loadScript("craft_Launch0.ks",debug(),CRAFT_FILE_RUN). }
    edit CRAFT_FILE_RUN.
    pOut("AG1 to continue after edit").
    GLOBAL f IS FALSE.
    ON AG1 { SET f TO TRUE. }
    WAIT UNTIL f.
  }

  RETURN runScript(CRAFT_FILE_RUN,debug()).
}

FUNCTION cleanCraft {
  delScript(CRAFT_FILE_RUN).
  LOG "" TO CRAFT_FILE_RUN.
}

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
