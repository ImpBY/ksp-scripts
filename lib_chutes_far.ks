@LAZYGLOBAL OFF. // #include init

runScript("lib_parts.ks",debug()). // #include lib_parts

GLOBAL CHUTE_LIST IS LIST().

// __ events ______________________
// [0] = "(callable) выпуск, is KSPEvent"
// [1] = "(callable) вкл./выкл. инфо, is KSPEvent"
// __ fields ______________________
// [0] = "(settable) мин. давление, is Single"
// [1] = "(settable) высота, is Single"
// [2] = "(get-only) запасных куполов, is Int32"
// __ actions _____________________
// [0] = "(callable) выпуск, is KSPAction"
// [1] = "(callable) отцепить, is KSPAction"
// [2] = "(callable) снять со взвода, is KSPAction"

GLOBAL CHUTES_MOD IS "RealChuteFAR".
GLOBAL chuteCanDeploy IS canEvent@:BIND("выпуск").
GLOBAL chuteDeploy IS modEvent@:BIND("выпуск").
GLOBAL chuteCanDisarm IS canEvent@:BIND("снять со взвода").
GLOBAL chuteDisarm IS modEvent@:BIND("снять со взвода").

listChutes(TRUE).

FUNCTION hasChutes {
  RETURN CHUTE_LIST:LENGTH > 0.
}

FUNCTION listChutes {
  PARAMETER all IS FALSE.
  WAIT 0.
  CHUTE_LIST:CLEAR.
  FOR m IN SHIP:MODULESNAMED(CHUTES_MOD) {
    pOut(m:PART:TITLE + ": " + chuteCanDeploy(m),FALSE).
    IF all OR chuteCanDeploy(m) { CHUTE_LIST:ADD(m). }
  }
}

FUNCTION deployChutes {
  LOCAL act IS FALSE.
  IF ALTITUDE < BODY:ATM:HEIGHT AND VERTICALSPEED < 0 {
    FOR m IN CHUTE_LIST {
      IF chuteCanDeploy(m) AND NOT chuteCanDisarm(m) { chuteDeploy(m). AG8 ON. SET act TO TRUE. }
    }
  }
  IF act { listChutes(). }
}

FUNCTION disarmChutes {
  listChutes(TRUE).
  FOR m IN CHUTE_LIST { IF chuteCanDisarm(m) { chuteDisarm(m). SET act TO TRUE. } }
  listChutes().
}
