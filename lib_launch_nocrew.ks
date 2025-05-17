@LAZYGLOBAL OFF. // #include init

FOR f IN LIST(
  "lib_launch_common.ks" // #include lib_launch_common
) { runScript(f,debug()). }

FUNCTION doLaunch {
  PARAMETER exit_mode, ap, az IS 90, i IS SHIP:LATITUDE, cirk IS TRUE.

  launchInit(ap,az,i).

  LOCAL LOCK rm TO runMode().

UNTIL rm = exit_mode {
  IF rm = 1 {
    throttleTo({ RETURN getThrottle(). }).
    steerLaunch().
    countDown().
    runMode(2).

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
      throttleTo().
      steerSurf().
      runMode(12).
    }

  } ELSE IF rm = 12 {
    IF ALTITUDE > BODY:ATM:HEIGHT {
      pDV().
      throttleTo().
      runMode(13).
    }
    IF APOAPSIS < ap {
      throttleTo({ RETURN getThrottle(). }).
    } ELSE {
      throttleTo().
    }

  } ELSE IF rm = 13 {
    IF cirk {
      launchCirc(ap).
      runMode(14).
    } ELSE {
      runMode(16).
    }

  } ELSE IF rm = 14 {
    IF PERIAPSIS > BODY:ATM:HEIGHT {
      sepLauncher().
      pDV().
      runMode(16).
    } ELSE { runMode(15,0). }

  } ELSE IF rm = 15 {
    throttleOff().
    steerOff().
    sasOn().
    CORE:DOEVENT("Toggle Power").
    
  } ELSE IF rm = 16 {
    IF hasFairing() { launchFairing(). }
    IF hasModules() { launchModules(). }
    throttleTo().
    steerOff().
    sasOff().
    runMode(exit_mode,0).

  } ELSE {
    pOut("Unexpected run mode: " + rm).
    BREAK.

  }

  IF hasFairing() { launchFairing(). }
  IF hasModules() { launchModules(). }
  WAIT 0.
}

}
