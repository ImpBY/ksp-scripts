@LAZYGLOBAL OFF.

GLOBAL TIMES IS LEXICON().
GLOBAL stageTime IS diffTime@:BIND("STAGE").
GLOBAL CRAFT_FILE_RUN IS "craft.ks".
GLOBAL SHIP_FILE IS "ship.ks".

GLOBAL RESUME_FN IS "resume.ks".
GLOBAL DISK_PREFIX IS "".
GLOBAL DISK_LOCAL IS "".

FOR f IN LIST(
  "lib_runmode.ks", // #include lib_runmode
  "lib_navigation.ks", // #include lib_navigation
  "lib_common.ks", // #include lib_common
  "lib_warp.ks" // #include lib_warp
) { runScript(f,debug()). }

debugOff().
killWarp().
setTime("STAGE").
sysUpdate(SHIP:NAME).
SWITCH TO 1.
CORE:DOEVENT("Open Terminal").

FUNCTION setTime {
  PARAMETER n, t IS TIME:SECONDS.
  SET TIMES[n] TO t.
}

FUNCTION diffTime {
  PARAMETER n.
  RETURN TIME:SECONDS - TIMES[n].
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
  LOG t TO DISK_LOCAL + ":/" + fn.
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
  PARAMETER sn.
  IF NOT sn { RETURN. }
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
    if NOT loadScript(cn,debug(),CRAFT_FILE_RUN) { RETURN "". }
    edit CRAFT_FILE_RUN.
    pOut("AG1 to continue after edit").
    GLOBAL flagCraftEdit IS FALSE.
    ON AG1 { SET flagCraftEdit TO TRUE. }
    WAIT UNTIL flagCraftEdit.
  }

  LOCAL RESULT TO runScript(CRAFT_FILE_RUN,debug()).
  IF SHIP_FILE { SET RESULT TO runScript(SHIP_FILE,debug()). }
  RETURN RESULT.
}

FUNCTION cleanCraft {
  delScript(CRAFT_FILE_RUN).
  LOG "" TO CRAFT_FILE_RUN.
}
