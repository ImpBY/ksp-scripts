@LAZYGLOBAL OFF.

FUNCTION canEvent {
  PARAMETER e, m.
  RETURN m:HASEVENT(e).
}

FUNCTION canAction {
  PARAMETER a, m.
  RETURN m:HASACTION(a).
}

FUNCTION modEvent {
  PARAMETER e, m.
  m:DOEVENT(e).
  pOut(m:PART:TITLE + ": " + e).
}

FUNCTION modAction {
  PARAMETER a, m.
  m:DOACTION(a,TRUE).
  pOut(m:PART:TITLE + ": " + a).
}

FUNCTION partEvent {
  PARAMETER e, mn, p.
  IF p:HASMODULE(mn) {
    LOCAL m IS p:GETMODULE(mn).
    IF canEvent(e,m) { modEvent(e,m). RETURN TRUE. }
  }
  RETURN FALSE.
}

FUNCTION partAction {
  PARAMETER a, mn, p.
  IF p:HASMODULE(mn) {
    LOCAL m IS p:GETMODULE(mn).
    IF canAction(a,m) { modAction(a,m). RETURN TRUE. }
  }
  RETURN FALSE.
}

FUNCTION partEventByTag {
  PARAMETER e, mn, tn.
  FOR p IN SHIP:PARTSTAGGED(tn) { partEvent(e, mn, p). }
}

FUNCTION partActionByTag {
  PARAMETER a, mn, tn.
  FOR p IN SHIP:PARTSTAGGED(tn) { partAction(a, mn, p). }
}

FUNCTION modFieldGet {
  PARAMETER fn, m.
  IF m:HASFIELD(fn) { RETURN m:GETFIELD(fn). }
  RETURN "-".
}

FUNCTION modFieldSet {
  PARAMETER fn, m, fv.
  IF m:HASFIELD(fn) { m:SETFIELD(fn, fv). pOut(m:PART:TITLE + ":" + fn + " < " + fv). RETURN TRUE. }
  RETURN FALSE.
}

FUNCTION partModFieldGet {
  PARAMETER fn, mn, p.
  IF p:HASMODULE(mn) { RETURN modFieldGet(fn, p:GETMODULE(mn)). }
  RETURN "-".
}

FUNCTION partModFieldSet {
  PARAMETER fn, mn, p, fv.
  IF p:HASMODULE(mn) { RETURN modFieldSet(fn, p:GETMODULE(mn), fv). }
  RETURN FALSE.
}

FUNCTION partListByName {
  PARAMETER pn.
  LOCAL l IS LIST().
  FOR p IN SHIP:PARTS {
    IF p:NAME:CONTAINS(pn) { l:ADD(p). }
  }
  RETURN l.
}

FUNCTION decouplePart {
  PARAMETER p.

  IF NOT (partEvent("decouple node","ModuleDockingNode",p)
  OR partEvent("decouple","ModuleDecouple",p)
  OR partEvent("decouple","ModuleAnchoredDecoupler",p))
  AND p:HASPARENT { decouplePart(p:PARENT). }
}

FUNCTION decoupleByTag {
  PARAMETER t.
  FOR p IN SHIP:PARTSTAGGED(t) { decouplePart(p). }
}