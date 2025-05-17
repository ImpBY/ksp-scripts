@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

runScript("lib_chutes.ks",debug()). // #include lib_chutes
UNTIL FALSE {
  FOR m IN CHUTE_LIST {
    pOut(modFieldGet("���������",m)).
    pOut(chuteStatus(m)).
  }
  WAIT 1.
}