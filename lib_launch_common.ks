@LAZYGLOBAL OFF. // #include init

FOR f IN LIST(
  "lib_burn.ks", // #include lib_burn
  "lib_steer.ks", // #include lib_steer
  "lib_orbit.ks", // #include lib_orbit
  "lib_orbit_tools.ks", // #include lib_orbit_tools
  "lib_ant.ks", // #include lib_ant
  "lib_panels.ks", // #include lib_panels
  "lib_runmode.ks" // #include lib_runmode
) { runScript(f,debug()). }

GLOBAL OPT_TWR IS 2.0.
GLOBAL MIN_TWR IS 0.1.
GLOBAL MIN_THR IS 0.05.
GLOBAL MIN_ETA_APOAPSIS IS 45.
GLOBAL LCH_MAXQ IS 35000.
GLOBAL LCH_MAXQ_MIN IS LCH_MAXQ * 0.5.
GLOBAL LCH_MAXQ_THR IS TRUE.
GLOBAL LCH_PITCH_SPEED IS 100.
GLOBAL LCH_MAX_THRUST IS 0.
GLOBAL LCH_MAX_AGL IS 15.
GLOBAL LCH_ORBIT_VEL IS 0.
GLOBAL LCH_ORBIT_SLOW IS TRUE.
GLOBAL LCH_VEC IS UP:VECTOR.
GLOBAL LCH_I IS 0.
GLOBAL LCH_AN IS TRUE.
GLOBAL LCH_THR_CONTROL IS TRUE.

GLOBAL LCH_AP IS 80000.
GLOBAL LCH_NOATMO IS 8000.
GLOBAL LCH_FAIRING_PRES_K IS 200.

GLOBAL LCH_PITCH_ALT_K IS 0.05/70.
GLOBAL LCH_CURVE_ALT_K IS 60/70.
GLOBAL LCH_MAX_STEER_K IS 40/70.
GLOBAL LCH_FAIRING_ALT_K IS 60/70.
GLOBAL LCH_MODULES_ALT_K IS 70/70.

GLOBAL LCH_PITCH_ALT IS MAX(BODY:ATM:HEIGHT * LCH_PITCH_ALT_K, 500).
GLOBAL LCH_CURVE_ALT IS MAX(BODY:ATM:HEIGHT, LCH_NOATMO) * LCH_CURVE_ALT_K.
GLOBAL LCH_MAX_STEER IS MAX(BODY:ATM:HEIGHT, LCH_NOATMO) * LCH_MAX_STEER_K.
GLOBAL LCH_FAIRING_ALT IS MAX(BODY:ATM:HEIGHT, LCH_NOATMO) * LCH_FAIRING_ALT_K.
GLOBAL LCH_MODULES_ALT IS MAX(BODY:ATM:HEIGHT, LCH_NOATMO) * LCH_MODULES_ALT_K.

GLOBAL LCH_HAS_LES IS FALSE.
GLOBAL LCH_HAS_FAIRING IS FALSE.
GLOBAL LCH_FAIRING_LIST IS LIST().
GLOBAL LCH_HAS_CLAMP IS FALSE.
GLOBAL LCH_CLAMP_LIST IS LIST().
GLOBAL LCH_HAS_MODULES IS TRUE.

FUNCTION pTWR {
  IF LCH_THR_CONTROL {
    LOCAL heregrav IS BODY:MU/((ALTITUDE + BODY:RADIUS)^2).
    LOCAL twr IS SHIP:AVAILABLETHRUST / (heregrav * SHIP:MASS).
    pOut("Available TWR is " + twr).
    pOut("Target TWR is " + OPT_TWR).
  } ELSE {
    pOut("Throttle not controlled").
  }
}

FUNCTION setTWR {
  PARAMETER twr IS 2.0.
  SET OPT_TWR TO MAX(twr, MIN_TWR).
  pTWR().
}

FUNCTION setThrControl {
  PARAMETER ctrlS IS TRUE.
  SET LCH_THR_CONTROL TO ctrlS.
}

FUNCTION setMaxQControl {
  PARAMETER maxqS IS TRUE.
  SET LCH_MAXQ_THR TO maxqS.
}

FUNCTION setOrbitSlow {
  PARAMETER olS IS TRUE.
  SET LCH_ORBIT_SLOW TO olS.
}

FUNCTION launchQ {
  RETURN SHIP:Q * CONSTANT:AtmToKPa * 1000.
}

FUNCTION getThrottle {
  PARAMETER twr IS OPT_TWR.
  IF NOT LCH_THR_CONTROL { RETURN 1. }
  IF ALT:RADAR < LCH_PITCH_ALT { RETURN 1. }
  IF MAXTHRUST > 0 {
    LOCAL heregrav IS BODY:MU/((ALTITUDE + BODY:RADIUS)^2).
    LOCAL maxtwr IS MAXTHRUST / (heregrav * SHIP:MASS).
    
    LOCAL sQ IS launchQ().
    PRINT "                                     " AT (0,0).
    PRINT "                                     " AT (0,1).
    PRINT "          " + sQ + "                           " AT (0,2).
    PRINT "          " + ETA:APOAPSIS + "                           " AT (0,3).
    PRINT "                                     " AT (0,4).
    PRINT "                                     " AT (0,5).
    
    IF sQ > LCH_MAXQ_MIN AND LCH_MAXQ_THR {
      IF sQ < LCH_MAXQ {
        SET twr TO twr * ((LCH_MAXQ - sQ) / (LCH_MAXQ - LCH_MAXQ_MIN))^2.
      } ELSE {
        SET twr TO 0.
      }
    }
    IF ALTITUDE > LCH_MAX_STEER AND LCH_ORBIT_SLOW {
      SET twr TO twr * ((LCH_AP - ALTITUDE) / (LCH_AP - LCH_MAX_STEER))^2.
      IF ETA:APOAPSIS < MIN_ETA_APOAPSIS {
        SET twr TO twr + (MIN_ETA_APOAPSIS - ETA:APOAPSIS) / 4.
      }
    }
    LOCAL LCH_THR IS MAX(MIN(MAX(twr, MIN_TWR), maxtwr) / maxtwr, MIN_THR).
    
    RETURN LCH_THR.
  }
  RETURN 0.
}

FUNCTION mThrust {
  PARAMETER mt IS -1.
  IF mt >= 0 { SET LCH_MAX_THRUST TO mt. }
  RETURN LCH_MAX_THRUST.
}

FUNCTION hasFairing {
  RETURN LCH_HAS_FAIRING.
}

FUNCTION hasLES {
  RETURN LCH_HAS_LES.
}

FUNCTION hasClamp {
  RETURN LCH_HAS_CLAMP.
}

FUNCTION hasModules {
  RETURN LCH_HAS_MODULES.
}

FUNCTION disableLES {
  SET LCH_HAS_LES TO FALSE.
}

FUNCTION checkFairing {
  SET LCH_HAS_FAIRING TO FALSE.
  LCH_FAIRING_LIST:CLEAR.
  SET LCH_FAIRING_LIST TO partListByName("fairing").
  SET LCH_HAS_FAIRING TO (SHIP:PARTSTAGGED("LaunchFairing"):LENGTH > 0 OR LCH_FAIRING_LIST:LENGTH > 0) AND CAREER():CANDOACTIONS.
  IF LCH_HAS_FAIRING { pOut("Fairing found"). }
}

FUNCTION checkClamp {
  SET LCH_HAS_CLAMP TO FALSE.
  LCH_CLAMP_LIST:CLEAR.
  SET LCH_CLAMP_LIST TO partListByName("clamp").
  SET LCH_HAS_CLAMP TO (SHIP:PARTSTAGGED("LaunchClamp"):LENGTH > 0 OR LCH_CLAMP_LIST:LENGTH > 0) AND CAREER():CANDOACTIONS.
  IF LCH_HAS_CLAMP { pOut("Clamp found"). }
}

FUNCTION checkLES {
  SET LCH_HAS_LES TO FALSE.
  SET LCH_HAS_LES TO (SHIP:PARTSTAGGED("LaunchEscapeSystem"):LENGTH > 0 AND CAREER():CANDOACTIONS).
}

FUNCTION launchInit {
  PARAMETER ap,az,i,c IS TRUE.
  
  SET LCH_AP TO MAX(ap, MAX(BODY:ATM:HEIGHT * 1.06, LCH_NOATMO)).
  
  SET LCH_ORBIT_VEL TO SQRT(BODY:MU/(BODY:RADIUS + LCH_AP)).
  SET LCH_I TO i.
  SET LCH_AN TO (az < 90 OR az > 270 OR ((az = 90 OR az = 270) AND LATITUDE < 0)).
  SET LCH_PITCH_ALT TO MAX(BODY:ATM:HEIGHT * LCH_PITCH_ALT_K, ALT:RADAR + 200).
  SET LCH_CURVE_ALT TO MAX(BODY:ATM:HEIGHT, LCH_NOATMO) * LCH_CURVE_ALT_K.
  SET LCH_MAX_STEER TO MAX(BODY:ATM:HEIGHT, LCH_NOATMO) * LCH_MAX_STEER_K.
  SET LCH_FAIRING_ALT TO MAX(BODY:ATM:HEIGHT, LCH_NOATMO) * LCH_FAIRING_ALT_K.
  SET LCH_MODULES_ALT TO MAX(BODY:ATM:HEIGHT, LCH_NOATMO) * LCH_MODULES_ALT_K.

  checkFairing().
  checkClamp().
  checkLES().
  mThrust(0).

  IF runMode() < 0 {
    hudMsg("Prepare for launch...").
    pOut("Launch to apoasis: " + LCH_AP).
    runMode(1).
  }
}

FUNCTION launchStaging {
  LOCAL mt IS SHIP:MAXTHRUSTAT(0).
  LOCAL prev_mt IS mThrust().
  IF mt = 0 OR mt < prev_mt {
    IF STAGE:READY AND stageTime() > 0.2 {
      mThrust(0).
      // rcsOn().
      // SET SHIP:CONTROL:FORE TO 1.0.
      // steerTo(). WAIT 0.25.
      doStage().
      // WAIT 0.25. SET SHIP:CONTROL:FORE TO 0.0.
      // rcsOff().
      // steerLaunch().
    }
  } ELSE IF prev_mt = 0 AND mt > 0 AND stageTime() > 0.2 {
    pTWR().
    mThrust(mt).
    IF hasFairing() { checkFairing(). }
    IF hasLES() { checkLES(). }
  }
}

FUNCTION launchFairing {
  IF ((ALTITUDE > LCH_FAIRING_ALT OR (LCH_FAIRING_PRES_K > launchQ() AND SHIP:AIRSPEED > 200 )) AND hasFairing()) {
    steerTo().
    LOCAL e IS "сбросить".
    LOCAL mn IS "ModuleProceduralFairing".
    partEventByTag(e,mn,"LaunchFairing").
    FOR p IN LCH_FAIRING_LIST { partEvent(e,mn,p). }
    LOCAL e IS "jettison fairing".
    LOCAL mn IS "ProceduralFairingDecoupler".
    FOR p IN LCH_FAIRING_LIST { partEvent(e,mn,p). }
    SET LCH_HAS_FAIRING TO FALSE.
    WAIT UNTIL STAGE:READY AND stageTime() > 0.2.
    steerLaunch().
  }
}

FUNCTION launchModules {
  IF ALTITUDE > LCH_MODULES_ALT AND hasModules() {
    doPanels(TRUE,"Launch").
    doAnt(TRUE,"Launch").
    SET LCH_HAS_MODULES TO FALSE.
  }
}

FUNCTION sepLauncher {
  IF SHIP:PARTSTAGGED("LAUNCHER"):LENGTH > 0 {
    steerOrbit().
    WAIT UNTIL steerOk().
    UNTIL SHIP:PARTSTAGGED("LAUNCHER"):LENGTH = 0 {
      WAIT UNTIL STAGE:READY AND stageTime() > 0.5.
      doStage().
      WAIT 0.
    }
    WAIT 0.2.
    dampSteering().
  }
}

FUNCTION launchClamp {
  IF LCH_HAS_CLAMP {
    UNTIL SHIP:PARTSTAGGED("LaunchClamp"):LENGTH = 0 AND LCH_CLAMP_LIST:LENGTH = 0 {
      WAIT UNTIL STAGE:READY AND stageTime() > 0.5.
      doStage().
      checkClamp().
      WAIT 0.
    }
  }
  SET LCH_HAS_CLAMP TO FALSE.
}

FUNCTION launchCirc {
  PARAMETER h IS APOAPSIS.
  IF NOT HASNODE {
    IF h > APOAPSIS { SET h TO APOAPSIS. }
    ADD(nodeAlterOrbit(timeHeigth(h), h)).
    // LOCAL m_time IS TIME:SECONDS + ETA:APOAPSIS.
    // LOCAL v0 IS VELOCITYAT(SHIP,m_time):ORBIT:MAG.
    // LOCAL v1 IS SQRT(BODY:MU/(BODY:RADIUS + APOAPSIS)).
    // LOCAL n IS NODE(m_time, 0, 0, v1 - v0).
    // addNode(n).
  }
  IF HASNODE { execNode(TRUE). }
}

FUNCTION launchBearing {
  LOCAL lat IS SHIP:LATITUDE.
  LOCAL vo IS SHIP:VELOCITY:ORBIT.
  IF (LCH_I > 0 AND ABS(lat) < 90 AND MIN(LCH_I,180 - LCH_I) >= ABS(lat)) {
    LOCAL az IS ARCSIN( COS(LCH_I) / COS(lat) ).
    IF NOT LCH_AN { SET az TO mAngle(180 - az). }
    IF vo:MAG >= LCH_ORBIT_VEL { RETURN az. }
    LOCAL x IS (LCH_ORBIT_VEL * SIN(az)) - VDOT(vo,HEADING(90,0):VECTOR).
    LOCAL y IS (LCH_ORBIT_VEL * COS(az)) - VDOT(vo,HEADING(0,0):VECTOR).
    RETURN mAngle(90 - ARCTAN2(y, x)).
  } ELSE {
    IF LCH_I < 90 { RETURN 90. }
    ELSE { RETURN 270. }
  }
}

FUNCTION launchPitch {
  RETURN MIN(90, MAX(0, MAX(90 * (1 - SQRT(ALTITUDE / LCH_CURVE_ALT)), LCH_PITCH_SPEED - VERTICALSPEED))).
}

FUNCTION launchMaxSteer {
  LOCAL max_ang IS LCH_MAX_AGL.
  LOCAL sQ IS launchQ().
  IF sQ > LCH_MAXQ_MIN {
    IF sQ < LCH_MAXQ {
      SET max_ang TO max_ang * ((LCH_MAXQ - sQ) / (LCH_MAXQ - LCH_MAXQ_MIN))^2.
    } ELSE {
      SET max_ang TO 3.
    }
  }
  IF ALTITUDE < LCH_MAX_STEER {
    SET max_ang TO max_ang * (1 - (LCH_MAX_STEER - ALTITUDE) / LCH_MAX_STEER)^2.
  }
  RETURN MAX(max_ang, 3).
}

FUNCTION launchSteerUpdate {
  IF ALT:RADAR <= LCH_PITCH_ALT {
    SET LCH_VEC TO HEADING(launchBearing(),90):VECTOR.
  } ELSE {
    LOCAL cur_v IS SHIP:VELOCITY:SURFACE.
    LOCAL new_v IS HEADING(launchBearing(),launchPitch()):VECTOR.
    LOCAL max_ang IS launchMaxSteer().
    IF VANG(cur_v,new_v) > max_ang { SET new_v TO ANGLEAXIS(max_ang,VCRS(cur_v,new_v)) * cur_v. }
    SET LCH_VEC TO new_v.
  }
}

FUNCTION steerLaunch {
  steerTo({ RETURN LCH_VEC. }).
}

FUNCTION countdown {
  FROM {LOCAL i IS 10.} UNTIL i = 0 STEP {SET i TO i - 1.} DO {
    PRINT i.
    WAIT 1.
  }
  PRINT "start".
}
