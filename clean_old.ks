@LAZYGLOBAL OFF.
SWITCH TO 1.

LOCAL pl IS LIST().
LIST PROCESSORS IN pl.
FOR p IN pl {
  IF p:MODE = "READY" AND p:BOOTFILENAME <> "None" {
    SET p:BOOTFILENAME TO "/boot/boot.ks".
  }
  p:VOLUME:DELETE("/boot").
}
COPYPATH("0:/boot/boot.ks","1:/boot/boot.ks").

RUNPATH("0:/init_multi.ks").
// debugOn().

cleanCraft().

FOR f IN LIST(
  "init.ks",
  "init_common.ks",
  "rm.ks",
  "resume.ks",
  "autorun.ks",
  "ship.ks",
  "c.ks",
  "u.ks",
  "uc.ks",
  "n.ks",
  "nr.ks",
  "s.ks"
) { delScript(f,debug()). }

LOCAL fl TO VOLUME(0):FILES:KEYS.

FOR f IN fl {
  IF f:CONTAINS(".ks") {
    IF findPath(f) <> "" {
      delScript(f,debug()).
    }
  }
}

LOCAL fl TO VOLUME(1):FILES:KEYS.

FOR f IN fl {
  IF f:CONTAINS(".ks") {
    IF findPath(f) <> "" {
      delScript(f,debug()).
    }
  }
}

//debugOff().
pOut("Clean complete").
