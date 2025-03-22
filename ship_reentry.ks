@LAZYGLOBAL OFF. SWITCH TO 1. IF NOT EXISTS("1:/init.ks") { RUNPATH("0:/init_select.ks"). }. RUNONCEPATH("1:/init.ks").

GLOBAL NEW_NAME IS "S2".
GLOBAL ORBIT_AP IS 80000.
GLOBAL ORBIT_PE IS 80000.
GLOBAL ORBIT_LAN IS -1.
GLOBAL ORBIT_INC IS 0.
GLOBAL ORBIT_W IS -1.
GLOBAL ORBIT_DIR IS 1.

GLOBAL SHIP_WARP_ALLOW IS FALSE.
GLOBAL ORBIT_LOW IS MAX(BODY:ATM:HEIGHT * 1.05, ORBIT_PE).
GLOBAL mission_end_mode IS 888.
GLOBAL ANG_PREC IS 0.2.
GLOBAL ALT_PREC IS 1.0.

runCraftInit().

UNTIL runMode() = 99 {
LOCAL rm IS runMode().
IF rm < 0 {
  rcsOn().
  sasOn().
  IF NEW_NAME <> "" { shipUpdate(NEW_NAME). }
  store("runScript(" + CHAR(34) + CRAFT_FILE_RUN + CHAR(34) + "," + debug() + ").","autorun.ks").
  runMode(1,99).
  
} ELSE IF rm = 1 {
  IF ALTITUDE > BODY:ATM:HEIGHT {
    WAIT 10.
    runMode(800).
  }

} ELSE IF rm = 800 {
  runScript("lib_reentry.ks",debug()).
  append("doReentry(1,99).").
  doReentry(0,99).
}

WAIT 0.

}

cleanCraft().
runScript("c.ks",TRUE).
runScript("u.ks",TRUE).
rcsOff().
sasOn().
REBOOT.
