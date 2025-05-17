@LAZYGLOBAL OFF. // #include init

FOR f IN LIST(
  "lib_orbit.ks", // #include lib_orbit
  "lib_burn.ks" // #include lib_burn
) { runScript(f,debug()). }

FUNCTION periodOk {
  PARAMETER p0,p1,pro.
  RETURN ABS(p0 - p1) < 0.1 OR (p0 > p1 AND pro) OR (p0 < p1 AND NOT pro).
}

FUNCTION tweakPeriod {
  PARAMETER p1.

  LOCAL pro IS (OBT:PERIOD < p1).
  steerOrbit(pro).
  WAIT UNTIL steerOk(1,2).

  throttleTo({ RETURN 0.1. }).
  WAIT UNTIL periodOk(OBT:PERIOD,p1, pro).
  throttleTo().
  dampSteering().
  throttleOff().
}

FUNCTION orbitAltForPeriod {
  PARAMETER planet, orb, ta, phase_p.
  LOCAL r1 IS radiusAtTA(orb,ta).
  LOCAL phase_a IS ((planet:MU * (phase_p^2))/(4*(CONSTANT:PI^2)))^(1/3).
  LOCAL r2 IS (2 * phase_a) - r1.
  RETURN r2 - planet:RADIUS.
}

FUNCTION orbitPeriodForAlt {
  PARAMETER planet, orb, ta, r2_alt.
  LOCAL r1 IS radiusAtTA(orb,ta).
  LOCAL a IS (r1 + r2_alt + planet:RADIUS)/2.
  RETURN 2 * CONSTANT:PI() * SQRT(a^3 / planet:MU).
}