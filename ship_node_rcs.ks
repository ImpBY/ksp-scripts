@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

warpStatus(FALSE).
rcsOn().
sasOff().
rcsExecNode().
rcsOff().
sasOn().
