@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

FOR f IN LIST(
  "lib_burn.ks" // #include lib_burn
) { runScript(f,debug()). }

warpStatus(FALSE).
rcsOff().
sasOff().
execNode(FALSE).
rcsOff().
sasOn().
