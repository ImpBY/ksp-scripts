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
COPYPATH("0:/boot/boot.ks","1:/boot/boot.ks").
REBOOT.