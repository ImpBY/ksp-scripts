@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init
IF NOT runScript("autorun.ks") {
  IF NOT runCraft(). {
    rcsOff().
    sasOn().
    pOut("Manual start next program").
  }
}
