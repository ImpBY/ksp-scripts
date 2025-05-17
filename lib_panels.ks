@LAZYGLOBAL OFF. // #include init

runScript("lib_parts.ks",debug()). // #include lib_parts

GLOBAL PANELS_MOD IS "ModuleDeployableSolarPanel".
GLOBAL panelsActivate IS partEvent@:BIND("развернуть солнечную панель",PANELS_MOD).
GLOBAL panelsDeactivate IS partEvent@:BIND("свернуть солнечную панель",PANELS_MOD).

GLOBAL PANELS_TAG_MOD IS "KOSNameTag".
GLOBAL panelsTag IS partModFieldGet@:BIND("Name Tag",PANELS_TAG_MOD).

FUNCTION doPanelsPart {
  PARAMETER p, f IS TRUE.
  IF f { panelsActivate(p). }
  ELSE { panelsDeactivate(p). }
}

FUNCTION doPanels {
  PARAMETER f IS TRUE, t IS "".
  FOR p IN SHIP:PARTS {
    IF p:HASMODULE(PANELS_MOD) {
      IF (t = "") OR (t <> "" AND panelsTag(p):CONTAINS(t)) { doPanelsPart(p,f). }
    }
  }
}
