@LAZYGLOBAL OFF. // #include init

FOR f IN LIST(
  "lib_orbit.ks", // #include lib_orbit
  "lib_burn.ks" // #include lib_burn
) { runScript(f,debug()). }

FUNCTION changeOrbit {
  PARAMETER doExec, can_stage, limit_dv.
  PARAMETER u_time.
  PARAMETER ap, pe, w.
  PARAMETER alt_prec IS 0.01.

  LOCAL ok IS TRUE.
  LOCAL dv_req IS 0.

  LOCAL o IS ORBITAT(SHIP,u_time).
  LOCAL w_diff IS 0.
  IF w >= 0 { SET w_diff TO mAngle(w - o:ARGUMENTOFPERIAPSIS). }
  LOCAL ap_diff IS ap - o:APOAPSIS.
  LOCAL pe_diff IS pe - o:PERIAPSIS.
  LOCAL double_pe_burn IS (ap < o:PERIAPSIS).

  IF w_diff > 0.05 OR ABS(ap_diff) > (alt_prec * ap) {
    LOCAL n2 IS nodeAlterOrbit(u_time + secondsToTA(SHIP,u_time,w_diff), ap).
    addNode(n2).
    UNTIL NOT n2:ORBIT:HASNEXTPATCH { SET n2:ETA TO n2:ETA + o:PERIOD. }
    IF doExec {
      SET ok TO execNode(can_stage).
      SET u_time TO bufferTime().
    } ELSE {
      SET dv_req TO dv_req + nodeDV(n2).
      SET u_time TO bufferTime(u_time) + n2:ETA.
    }
    SET o TO ORBITAT(SHIP,u_time).
  }

  IF ok AND (w_diff > 0.05 OR ABS(pe_diff) > (alt_prec * pe)) {
    LOCAL ap_ta IS 180.
    IF double_pe_burn { SET ap_ta TO 0. }
    LOCAL n3 IS nodeAlterOrbit(u_time + secondsToTA(SHIP,u_time,ap_ta), pe).
    addNode(n3).
    UNTIL NOT n3:ORBIT:HASNEXTPATCH { SET n3:ETA TO n3:ETA + o:PERIOD. }
    IF doExec { SET ok TO execNode(can_stage). }
    ELSE { SET dv_req TO dv_req + nodeDV(n3). }
  }

  IF ok AND NOT doExec AND dv_req > 0 {
    pOut("Delta-v requirement: " + ROUND(dv_req,1) + "m/s.").
    IF dv_req > limit_dv {
      SET ok TO FALSE.
      pOut("ERROR: exceeds delta-v allowance ("+ROUND(limit_dv,1)+"m/s).").
    }
  }

  RETURN ok.
}

FUNCTION doOrbitChange {
  PARAMETER can_stage,limit_dv.
  PARAMETER ap,pe.
  PARAMETER w IS -1.
  PARAMETER alt_prec IS 0.01.

  LOCAL ok IS TRUE.
  IF HASNODE {
    IF NEXTNODE:ETA > nodeBuffer() { SET ok TO execNode(can_stage). }
    removeAllNodes().
  }
  LOCAL u_time IS bufferTime().
  IF ok { SET ok TO changeOrbit(FALSE,FALSE,limit_dv,u_time,ap,pe,w,alt_prec). }
  removeAllNodes().
  IF ok { SET ok TO changeOrbit(TRUE,can_stage,0,u_time,ap,pe,w,alt_prec). }
  removeAllNodes().
  RETURN ok.
}