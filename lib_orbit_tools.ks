@LAZYGLOBAL OFF. // #include init

FOR f IN LIST(
  "lib_burn.ks", // #include lib_burn
  "lib_steer.ks" // #include lib_steer
) { runScript(f,debug()). }

FUNCTION getBSOheight {
  RETURN (SQRT(SHIP:BODY:MU) * SHIP:BODY:ROTATIONPERIOD / (2 * CONSTANT():PI))^(2 / 3) - SHIP:BODY:RADIUS.
}

FUNCTION CalculateTransferAngle {
  PARAMETER OrbitA, TargetLNG.
  LOCAL A1 IS (SHIP:BODY:RADIUS + SHIP:ALTITUDE + OrbitA)/2.
  LOCAL A2 IS OrbitA.
  RETURN TargetLNG + 180 * (1 - (A1 / A2)^1.5) + 180.
}

FUNCTION dvSpeedAngle {
  PARAMETER targetPoint IS SHIP:BODY:ROTATIONPERIOD.
  LOCAL dv_cur_angle IS ABS(360 / SHIP:ORBIT:PERIOD - 360 / targetPoint).
  pOut("Angle speed: " + ROUND(dv_cur_angle,6) + " grad/s").
  RETURN dv_cur_angle.
}

FUNCTION execAdv {
  PARAMETER str IS { RETURN SHIP:VELOCITY:ORBIT. }.
  PARAMETER thr IS { RETURN 0. }.
  PARAMETER stopFunction IS { RETURN TRUE. }.
  rcsOff().
  sasOff().
  SET BURN_THROTTLE TO 0.
  throttleTo({ RETURN BURN_THROTTLE. }).
  steerTo({ RETURN str(). }).
  UNTIL stopFunction() {
    LOCAL acc IS SHIP:AVAILABLETHRUST / MASS.
    IF acc > 0 {
      IF VANG(str(), SHIP:FACING:FOREVECTOR) < 0.4 {
        SET BURN_THROTTLE TO burnThrottle(thr()).
      } ELSE {
        SET BURN_THROTTLE TO 0.
      }
      WAIT 0.
    } ELSE {
      IF moreEngines() {
        IF STAGE:READY AND stageTime() > 0.5 {
          rcsOn().
          SET SHIP:CONTROL:FORE TO 1.0.
          WAIT 0.3.
          doStage().
          WAIT 0.4.
          SET SHIP:CONTROL:FORE TO 0.0.
          rcsOff().
        }
      } ELSE {
        pOut("No thrust available for burn.").
        steerOff().
        throttleTo().
        RETURN FALSE.
      }
    }
  }
  steerOff().
  throttleTo().
  RETURN TRUE.
}

FUNCTION warpCloseToBurn {
  PARAMETER t.
  LOCAL warp_time IS TIME:SECONDS + t - 300.
  IF warp_time > TIME:SECONDS {
    steerSun().
    WAIT UNTIL steerOk(1,4,60,FALSE).
    doWarp(warp_time).
    WAIT UNTIL TIME:SECONDS > warp_time.
  }
}

FUNCTION warpToBurn {
  PARAMETER t.
  LOCAL time_to_warp IS t - 20.
  IF time_to_warp > 0 { doWarp(TIME:SECONDS + time_to_warp). }
}

FUNCTION getStableOrbit {
  PARAMETER t IS ETA:APOAPSIS.
  pOut("Get stable orbit").
  IF ETA:APOAPSIS > ETA:PERIAPSIS { SET t TO 0. }
  LOCAL ok IS FALSE.
  LOCAL h IS MAX(1.02 * BODY:ATM:HEIGHT, 4000).
  LOCAL LOCK V1 TO SHIP:VELOCITY:ORBIT.
  LOCAL LOCK V2 TO VXCL(SHIP:UP:VECTOR, SHIP:VELOCITY:ORBIT):NORMALIZED * SQRT(SHIP:BODY:MU / (SHIP:BODY:RADIUS + ALTITUDE)).
  LOCAL LOCK str TO V2 - V1.
  LOCAL LOCK thr TO MIN(MAX(20 * (1 - PERIAPSIS / h), 0.01), 1).
  LOCAL LOCK sf TO PERIAPSIS >= h.
  warpCloseToBurn(t).
  steerTo({ RETURN str. }).
  warpToBurn(t).
  steerTo({ RETURN str. }).
  WAIT UNTIL steerOk(1,4,20,FALSE).
  WAIT UNTIL ETA:APOAPSIS < 1.
  pOut("Start burn").
  SET ok TO execAdv( { RETURN str. }, { RETURN thr. }, { RETURN sf. } ).
  IF ok {
    pOut("Orbit ok").
  } ELSE { pOut("Burn error"). }
  RETURN ok.
}

FUNCTION fineCirculating {
  PARAMETER h IS ALTITUDE.
  pOut("Orbit patcher start").
  pOut("Altitude: " + ROUND(ALTITUDE,2) + " m").
  pOut("Target:   " + ROUND(h,2) + " m").
  LOCAL ok IS TRUE.
  IF APOAPSIS < h AND ok {
    pOut("Get AP > h").
    SET ok TO execAdv( { RETURN SHIP:PROGRADE:VECTOR. }, { RETURN MIN(MAX(20 * (1 - APOAPSIS / h), 0.01), 1). }, { RETURN APOAPSIS > 1.001 * h. } ).
  }
  IF PERIAPSIS > h AND ok {
    pOut("Get PE < h").
    SET ok TO execAdv( { RETURN SHIP:RETROGRADE:VECTOR. }, { RETURN MIN(MAX(20 * (1 - h / PERIAPSIS), 0.01), 1). }, { RETURN PERIAPSIS < 0.999 * h. } ).
  }
  pOut("Wait optimal height").
  LOCAL LOCK V1 TO SHIP:VELOCITY:ORBIT.
  LOCAL LOCK V2 TO VXCL(SHIP:UP:VECTOR, SHIP:VELOCITY:ORBIT):NORMALIZED * SQRT(SHIP:BODY:MU / (SHIP:BODY:RADIUS + ALTITUDE)).
  LOCAL LOCK str TO V2 - V1.
  LOCAL done IS FALSE.
  LOCAL f_WARP IS TRUE.
  LOCAL dh IS ABS(h - ALTITUDE).
  IF dh > 0.05 * h { steerSun(). WAIT UNTIL steerOk(1,4,60,FALSE). }
  UNTIL done {
    SET dh TO ABS(h - ALTITUDE).
    IF dh < 5 OR ETA:PERIAPSIS < 1 OR ETA:APOAPSIS < 1 OR (APOAPSIS - PERIAPSIS) < 0.02 * APOAPSIS {
      pOut("Height optimal").
      SET ok TO TRUE.
      SET done TO TRUE.
    } ELSE IF ALTITUDE < h AND ETA:PERIAPSIS < ETA:APOAPSIS AND PERIAPSIS < BODY:ATM:HEIGHT {
      pOut("ERROR height").
      SET done TO TRUE.
    } ELSE IF dh < 1000 AND WARP > 0 { SET WARP TO 0. }
    ELSE IF dh < 5000 AND WARP > 1 { SET WARP TO 1. }
    ELSE IF dh < 20000 AND WARP > 2 { SET WARP TO 2. }
    ELSE IF dh < 100000 AND WARP > 3 { SET WARP TO 3. }
    ELSE IF dh < 400000 AND WARP > 4 { SET WARP TO 4. }
    ELSE IF dh < 1000000 AND WARP > 5 { SET WARP TO 5. }
    IF f_WARP {
      IF dh < 0.05 * h {
        killWarp().
        SET f_WARP TO FALSE.
        steerTo({ RETURN str. }).
        WAIT UNTIL steerOk(1,4,60,FALSE).
      }
    }
    WAIT 0.
  }
  killWarp().
  IF ok {
    pOut("Start burn").
    LOCAL LOCK thr TO MIN(MAX(str:MAG / 10, 0.01), 1).
    LOCAL LOCK sf TO (APOAPSIS - PERIAPSIS) < (0.01 * ALTITUDE).
    SET ok TO execAdv( { RETURN str. }, { RETURN thr. }, { RETURN sf. } ).
    IF ok {
      LOCAL LOCK str TO PROGRADE:VECTOR.
      LOCAL LOCK thr TO MIN(MAX(1 - SHIP:ORBIT:SEMIMAJORAXIS / (SHIP:BODY:RADIUS + ALTITUDE), 0.0001), 1).
      LOCAL LOCK sf TO SHIP:ORBIT:SEMIMAJORAXIS > (SHIP:BODY:RADIUS + h).
      SET ok TO execAdv( { RETURN str. }, { RETURN thr. }, { RETURN sf. } ).
    }
  }
  pOut("Orbit patcher stop").
  steerOff().
  RETURN ok.
}

FUNCTION nodeCirculating {
  PARAMETER m_time IS TIME:SECONDS + ETA:APOAPSIS, h IS MAX(1.02 * BODY:ATM:HEIGHT, 4000).
  LOCAL ok IS FALSE.
  IF NOT HASNODE AND PERIAPSIS < h {
    LOCAL v0 IS VELOCITYAT(SHIP,m_time):ORBIT:MAG.
    LOCAL v1 IS SQRT(BODY:MU/(BODY:RADIUS + h)).
    LOCAL n IS NODE(m_time, 0, 0, v1 - v0).
    ADD(n).
  }
  IF HASNODE { SET ok TO execNode(TRUE). }
  RETURN ok.
}
