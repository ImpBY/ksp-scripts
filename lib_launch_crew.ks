@LAZYGLOBAL OFF.

FOR f IN LIST(
  "lib_launch_common.ks",
  "lib_chutes.ks",
  "lib_parts.ks"
) { runScript(f,debug()). }

GLOBAL LCH_LES_ALT IS BODY:ATM:HEIGHT * 0.62.
GLOBAL LCH_CHUTE_ALT IS BODY:ATM:HEIGHT * 0.3.

FUNCTION fireLES {
  FOR p IN SHIP:PARTSNAMED("LaunchEscapeSystem") {
    p:GETMODULE("ModuleEnginesFX"):DOACTION("activate engine",TRUE).
  }
}

FUNCTION jettisonLES {
  FOR p IN SHIP:PARTSNAMED("LaunchEscapeSystem") {
    pOut("Jettisoning LES").
    decouplePart(p).
  }
  disableLES().
}

FUNCTION launchLES {
  IF ALTITUDE > LCH_LES_ALT {
    fireLES().
    jettisonLES().
  }
}

FUNCTION doLaunch {
  PARAMETER exit_mode, ap, az IS 90, i IS SHIP:LATITUDE.

  launchInit(ap,az,i).

  LOCAL LOCK rm TO runMode().

UNTIL rm = exit_mode {
  IF rm = 1 {
    throttleTo({ RETURN getThrottle() * MIN(MAX(50*(1 - APOAPSIS / ap),0.11),1). }).
    steerLaunch().
    countDown().
    runMode(2,21).

  } ELSE IF rm = 2 {
    IF NOT isSteerOn() { steerLaunch(). }
    launchSteerUpdate().
    IF modeTime() > 3 {
      rcsOff().
      sasOff().
      doStage().
      launchClamp().
      hudMsg("Liftoff!").
      runMode(11).
    }

  } ELSE IF rm = 11 {
    IF NOT isSteerOn() { steerLaunch(). }
    launchSteerUpdate().
    launchStaging().
    IF APOAPSIS >= ap {
      throttleOff().
      runMode(12).
    }

  } ELSE IF rm = 12 {
    steerSurf().
    IF ALTITUDE > BODY:ATM:HEIGHT {
      rcsOff().
      sasOff().
      pDV().
      runMode(13).
    }
    // IF APOAPSIS < BODY:ATM:HEIGHT {
      // throttleTo({ RETURN getThrottle() * MIN(MAX(90*(1 - APOAPSIS / ap),0.11),1). }).
      // runMode(11).
    // }
    // IF APOAPSIS < ap { LOCK THROTTLE TO MIN(MAX(90*(1 - APOAPSIS / ap),0.11),1). }
    // ELSE { throttleTo(). }

  } ELSE IF rm = 13 {
    launchCirc(ap).
    runMode(14).

  } ELSE IF rm = 14 {
    IF PERIAPSIS > BODY:ATM:HEIGHT {
      sepLauncher().
      throttleOff().
      pDV().
      runMode(exit_mode,0).
    } ELSE { runMode(21,0). }

  } ELSE IF rm = 21 {
    throttleOff().
    steerOff().
    IF hasLES() {
      hudMsg("LAUNCH ABORT!", RED, 50).
      fireLES().
      decoupleByTag("FINAL").
    } ELSE { hudMsg("MANUAL STAGING REQUIRED!", RED, 50). }
    runMode(22).

  } ELSE IF rm = 22 {
    IF modeTime() > 6 {
      steerSurf(FALSE).
      IF hasLES() { JettisonLES(). }
      runMode(23).
    }

  } ELSE IF rm = 23 {
    IF modeTime() > 6 { runMode(31). }

  } ELSE IF rm = 31 {
    IF ALTITUDE > LCH_CHUTE_ALT { steerSurf(FALSE). }
    runMode(32).

  } ELSE IF rm = 32 {
    IF ALTITUDE < LCH_CHUTE_ALT {
      steerOff().
      IF hasChutes() { hudMsg("Will deploy parachutes once safe."). }
      runMode(33).
    }

  } ELSE IF rm = 33 {
    IF hasChutes() { deployChutes(). }
    IF LIST("LANDED","SPLASHED"):CONTAINS(STATUS) {
      hudMsg("Touchdown.").
      WAIT 0.
      CORE:DOEVENT("Toggle Power").
    }

  } ELSE {
    pOut("Unexpected run mode: " + rm).
    BREAK.

  }

  IF hasLES() AND rm < 20 { launchLES(). }
  IF hasFairing() { launchFairing(). }
  IF hasModules() { launchModules(). }
  WAIT 0.
}

}