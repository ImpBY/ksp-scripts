@LAZYGLOBAL OFF.

GLOBAL RESUME_FN IS "resume.ks".
GLOBAL VOLUME_NAMES IS LIST().
GLOBAL DISK_PREFIX IS "".
GLOBAL DISK_LOCAL IS "".

shipUpdate().

runScript("init_common.ks",FALSE).

IF debug() { pVolumes(). }

FUNCTION shipUpdate {
  PARAMETER sn IS SHIP:NAME.
  SET SHIP:NAME TO sn.
  listVolumes().
}

FUNCTION sysUpdate {
  SET DISK_PREFIX TO SHIP:NAME + "Disk".
  SET DISK_LOCAL TO DISK_PREFIX + "0".
  SET CORE:VOLUME:NAME TO DISK_LOCAL.
}

FUNCTION setVolumeList {
  PARAMETER vnl.
  SET VOLUME_NAMES TO vnl.
  pVolumes().
}

FUNCTION listVolumes {
  sysUpdate().
  SET VOLUME_NAMES TO LIST(DISK_LOCAL).

  LOCAL disk_num IS 1.
  LOCAL pl IS LIST().
  LIST PROCESSORS IN pl.
  FOR p IN pl {
    LOCAL LOCK vn TO p:VOLUME:NAME.
    IF p:MODE = "READY" AND p:BOOTFILENAME = "None" AND vn <> DISK_LOCAL {
      IF vn = "" {
        SET p:VOLUME:NAME TO (DISK_PREFIX + disk_num).
        SET disk_num TO disk_num + 1.
      }
      VOLUME_NAMES:ADD(vn).
    }
  }
}

FUNCTION pVolumes {
  FOR vn IN VOLUME_NAMES { pOut("Volume(" + vn + ") has " + VOLUME(vn):FREESPACE + " bytes."). }
}

FUNCTION findPath {
  PARAMETER fn.
  FOR vn IN VOLUME_NAMES {
    LOCAL lfp IS vn + ":/" + fn.
    IF EXISTS(lfp) { RETURN lfp. }
  }
  RETURN "".
}

FUNCTION findSpace {
  PARAMETER fn, mfs.
  FOR vn IN VOLUME_NAMES { IF VOLUME(vn):FREESPACE > mfs { RETURN vn + ":/" + fn. } }
  pOut("ERROR: no room!").
  pVolumes().
  RETURN "".
}

FUNCTION loadScript {
  PARAMETER fn, loud IS debug(), fnn IS fn, repl IS FALSE.

  IF repl { delScript(fnn,loud). }

  LOCAL lfp IS findPath(fnn).
  IF lfp <> "" { RETURN lfp. }

  LOCAL afp IS "Archive:/" + fn.
  IF EXISTS(afp) {
    LOCAL afs IS VOLUME(0):OPEN(fn):SIZE.
    IF loud { pOut("cpf: " + afp + " (" + afs + " bytes)"). }

    SET lfp TO findSpace(fnn, afs).
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
  LOCAL lfp IS findPath(fn).
  IF lfp <> "" {
    IF loud { pOut("del: " + lfp). }
    DELETEPATH(lfp).
  }
}

FUNCTION delResume {
  delScript(RESUME_FN,debug()).
}

FUNCTION store {
  PARAMETER t, fn IS RESUME_FN, mfs IS 150.
  delScript(fn,debug()).
  LOG t TO findSpace(fn,mfs).
}

FUNCTION append {
  PARAMETER t, fn IS RESUME_FN, mfs IS 150.
  LOCAL lfp IS findPath(fn).
  IF lfp <> "" LOG t TO lfp.
  ELSE LOG t TO findSpace(fn,mfs).
}

FUNCTION resume {
  PARAMETER fn IS RESUME_FN.
  LOCAL lfp IS findPath(fn).
  IF lfp <> "" { RUNPATH(lfp). }
}