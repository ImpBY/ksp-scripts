@LAZYGLOBAL OFF. SWITCH TO 1. IF NOT EXISTS("1:/init.ks") { RUNPATH("0:/init_select.ks"). }. RUNONCEPATH("1:/init.ks").
warpStatus(FALSE).
rcsOn().
sasOff().
rcsExecNode().
rcsOff().
sasOn().
