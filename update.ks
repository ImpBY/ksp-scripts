@LAZYGLOBAL OFF. COPYPATH("0:/init.ks","1:/init.ks"). RUNONCEPATH("1:/init.ks"). // #include init
SWITCH TO 1.

FUNCTION updateProcessorBootFiles {
  LOCAL pl IS LIST().
  LIST PROCESSORS IN pl.
  FOR p IN pl {
    IF p:MODE = "READY" AND p:BOOTFILENAME <> "None" {
      SET p:BOOTFILENAME TO "/boot/boot.ks".
    }
    p:VOLUME:DELETE("/boot").
  }
  COPYPATH("0:/boot/boot.ks","1:/boot/boot.ks").
}

FUNCTION loadScripts {
  LOCAL fl TO VOLUME(0):FILES:KEYS.
  FOR f IN fl {
    IF f:CONTAINS(".ks") AND findPath(f) <> "" {
      loadScript(f, debug(), f, TRUE).
    }
  }
}

updateProcessorBootFiles().
loadScripts().

pOut("Update complete").
