@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { RUNPATH("0:/init_select.ks"). }. RUNONCEPATH("1:/init.ks").
runScript("lib_chutes.ks",debug()).
UNTIL FALSE {
  FOR m IN CHUTE_LIST {
    pOut(modFieldGet("раскрытие",m)).
    pOut(chuteStatus(m)).
  }
  WAIT 1.
}