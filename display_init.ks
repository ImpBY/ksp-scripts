@LAZYGLOBAL OFF. // #include init
SWITCH TO 1.
RUNPATH("0:/clean.ks").
LOCAL pl IS LIST().
LIST PROCESSORS IN pl.
FOR p IN pl {
  IF p:MODE = "READY" AND p:BOOTFILENAME <> "None" {
    SET p:BOOTFILENAME TO "/boot/boot.ks".
  }
  p:VOLUME:DELETE("/boot").
}
COPYPATH("0:/display.ks","1:/boot/boot.ks").
COPYPATH("0:/b.ks","1:/b.ks").
COPYPATH("0:/c.ks","1:/c.ks").
REBOOT.