@LAZYGLOBAL OFF.

runScript("lib_parts.ks",debug()).

GLOBAL ANT_MOD IS "ModuleRTAntenna".
GLOBAL antStatus IS partModFieldGet@:BIND("Status",ANT_MOD).
GLOBAL antTarget IS partModFieldSet@:BIND("Target",ANT_MOD).
GLOBAL antActivate IS partAction@:BIND("Activate",ANT_MOD).
GLOBAL antDeactivate IS partAction@:BIND("Deactivate",ANT_MOD).

GLOBAL ANT_TAG_MOD IS "KOSNameTag".
GLOBAL antTag IS partModFieldGet@:BIND("Name Tag",ANT_TAG_MOD).

GLOBAL ANT_TX_MOD IS "ModuleRTDataTransmitter".
GLOBAL antCommStatus IS partModFieldGet@:BIND("Comms",ANT_TX_MOD).

FUNCTION doAntPart {
  PARAMETER p, f IS TRUE.
  IF antStatus(p) = "off" AND f {
    antActivate(p).
    LOCAL t IS getValue(antTag(p),"Target").
    IF t <> "" { antTarget(p,t). }
  }
  IF antStatus(p) <> "off" AND NOT f {
    antDeactivate(p).
  }
}

FUNCTION doAnt {
  PARAMETER f IS TRUE, t IS "".
  FOR p IN SHIP:PARTS {
    IF p:HASMODULE(ANT_MOD) {
      IF (t = "") OR (t <> "" AND antTag(p):CONTAINS(t)) { doAntPart(p,f). }
    }
  }
}
