@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

FOR f IN LIST(
"lib_ant.ks" // #include lib_ant
) { runScript(f,debug()). }

doAnt().
doAnt(FALSE).
//doAnt(TRUE,"launch").
