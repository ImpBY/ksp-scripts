@LAZYGLOBAL OFF.SWITCH TO 1. IF NOT EXISTS("1:/init.ks") { RUNPATH("0:/init_select.ks"). }. RUNONCEPATH("1:/init.ks").
FOR f IN LIST(
"lib_ant.ks"
) { runScript(f,debug()). }

doAnt().
doAnt(FALSE).
//doAnt(TRUE,"launch").
