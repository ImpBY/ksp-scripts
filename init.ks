@LAZYGLOBAL OFF.

GLOBAL RESUME_FN IS "resume.ks".
GLOBAL DISK_PREFIX IS "".
GLOBAL DISK_LOCAL IS "".

shipUpdate().

runScript("init_common.ks",FALSE).

FUNCTION shipUpdate {
  PARAMETER sn IS SHIP:NAME.
  SET SHIP:NAME TO sn.
  sysUpdate().
}

FUNCTION sysUpdate {
  SET DISK_PREFIX TO SHIP:NAME + "Disk".
  SET DISK_LOCAL TO DISK_PREFIX + "0".
  SET CORE:VOLUME:NAME TO DISK_LOCAL.
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
  PARAMETER t, fn IS RESUME_FN, mfs IS 0.
  delScript(fn,debug()).
  LOG t TO (DISK_LOCAL + ":/" + fn).
}

FUNCTION append {
  PARAMETER t, fn IS RESUME_FN, mfs IS 0.
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
