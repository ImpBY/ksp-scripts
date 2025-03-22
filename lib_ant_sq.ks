@LAZYGLOBAL OFF.

runScript("lib_parts.ks",debug()).

GLOBAL ANT_MOD IS "ModuleDeployableAntenna".
GLOBAL antStatus IS partModFieldGet@:BIND("статус",ANT_MOD).
GLOBAL antActivate IS partEvent@:BIND("раскрыть антенну",ANT_MOD).
GLOBAL antDeactivate IS partEvent@:BIND("убрать антенну",ANT_MOD).

GLOBAL ANT_TAG_MOD IS "KOSNameTag".
GLOBAL antTag IS partModFieldGet@:BIND("name tag",ANT_TAG_MOD).

GLOBAL ANT_TX_MOD IS "ModuleDataTransmitter".
GLOBAL antCommStatus IS partModFieldGet@:BIND("состояние антенны",ANT_TX_MOD).

FUNCTION doAntPart {
  PARAMETER p, f IS TRUE, f_wait IS TRUE.
  IF antStatus(p) = "сложено" AND f { antActivate(p). }
  IF antStatus(p) = "развёрнута" AND NOT f { antDeactivate(p). }
  WAIT UNTIL NOT (antStatus(p) <> "сложено" AND antStatus(p) <> "развёрнута") OR NOT f_wait.
}

FUNCTION doAnt {
  PARAMETER f IS TRUE, t IS "", f_wait IS TRUE.
  FOR p IN SHIP:PARTS {
    IF p:HASMODULE(ANT_MOD) {
      IF (t = "") OR (t <> "" AND antTag(p):CONTAINS(t)) { doAntPart(p,f,f_wait). }
    }
  }
}
