@LAZYGLOBAL OFF.

runScript("lib_parts.ks",debug()).

GLOBAL CHUTE_LIST IS LIST().

GLOBAL CHUTES_MOD IS "ModuleParachute".
GLOBAL chuteCanDeploy IS canEvent@:BIND("раскрыть парашют").
GLOBAL chuteDeploy IS modEvent@:BIND("раскрыть парашют").
GLOBAL chuteCanDisarm IS canEvent@:BIND("отменить раскрытие").
GLOBAL chuteDisarm IS modEvent@:BIND("отменить раскрытие").
GLOBAL safeStatus IS "безопасно".
GLOBAL chuteStatus IS modFieldGet@:BIND("раскрытие").

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
      IF chuteCanDeploy(m) AND chuteStatus(m) = safeStatus { chuteDeploy(m). SET act TO TRUE. }
    }
  }
  IF act { listChutes(). }
}

FUNCTION disarmChutes {
  listChutes(TRUE).
  FOR m IN CHUTE_LIST { IF chuteCanDisarm(m) { chuteDisarm(m). SET act TO TRUE. } }
  listChutes().
}

listChutes(TRUE).