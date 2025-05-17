@LAZYGLOBAL OFF. // #include init

FOR f IN LIST(
  "lib_geo.ks", // #include lib_geo
  "lib_orbit_phase.ks" // #include lib_orbit_phase
) { runScript(f,debug()). }

FUNCTION isPhasePeriodBetter {
  PARAMETER pp, bpp.
  PARAMETER op, min_p, max_p.
  IF pp >= min_p AND pp <= max_p AND ABS(pp - op) < ABS(bpp - op) { RETURN TRUE. }
  RETURN FALSE.
}

FUNCTION nodeGeoPhasingOrbit {
  PARAMETER craft, lat, lng, days_limit IS 25.

  pOut("Plotting node to create a phasing orbit that will pass over ("+ROUND(lat,1)+","+ROUND(lng,1)+")").

  LOCAL ok IS TRUE.

  LOCAL orb IS craft:ORBIT.
  LOCAL b IS orb:BODY.
  LOCAL u_time IS TIME:SECONDS.

  IF ok AND NOT latOkForInc(lat,orb:INCLINATION) {
    pOut("ERROR: Inclination " +ROUND(orb:INCLINATION,1)+ " degrees lower than target latitude.").
    SET ok TO FALSE.
  }

  IF ok {
    LOCAL lng_drift IS 360 * orb:PERIOD / b:ROTATIONPERIOD.

    LOCAL ta1 IS firstTAAtLat(orb,lat).
    LOCAL ta2 IS secondTAAtLat(orb,lat).
    LOCAL ta1_time IS u_time + secondsToTA(craft, u_time, ta1).
    LOCAL ta2_time IS u_time + secondsToTA(craft, u_time, ta2).

    LOCAL lng1 IS spotAtTime(b,craft,ta1_time):LNG.
    LOCAL lng2 IS spotAtTime(b,craft,ta2_time):LNG.

    LOCAL lng_diff1 IS mAngle(lng1 - lng).
    LOCAL lng_diff2 IS mAngle(lng2 - lng).

    LOCAL pp1_ok IS TRUE.
    LOCAL pp2_ok IS TRUE.
    LOCAL pp1_secs IS b:ROTATIONPERIOD * lng_diff1 / 360.
    LOCAL pp2_secs IS b:ROTATIONPERIOD * lng_diff2 / 360.
    IF (pp1_secs + ta1_time - u_time) > (days_limit * ONE_DAY) { SET pp1_ok TO FALSE. }
    IF (pp2_secs + ta2_time - u_time) > (days_limit * ONE_DAY) { SET pp2_ok TO FALSE. }
    IF NOT pp1_ok AND NOT pp2_ok {
      pOut("ERROR: Phased orbits will not pass over target within time limit ("+days_limit+" days).").
      SET ok TO FALSE.
    }

    IF ok {
      LOCAL min_alt IS orb:PERIAPSIS + 1000.
      LOCAL max_alt IS b:SOIRADIUS - (b:RADIUS * 5).
      LOCAL min_p IS orbitPeriodForAlt(b,orb,ta1,min_alt).
      LOCAL max_p IS orbitPeriodForAlt(b,orb,ta2,max_alt).

      LOCAL phase_p IS 0.
      LOCAL num_orbits IS 0.
      LOCAL node_ta IS 0.
      LOCAL node_time IS 0.
      LOCAL orb_count IS 0.

      LOCAL done IS FALSE.
      UNTIL done {
        SET orb_count TO orb_count + 1.
        LOCAL pp1 IS pp1_secs / orb_count.
        IF pp1_ok AND isPhasePeriodBetter(pp1, phase_p, orb:PERIOD, min_p, max_p) {
          SET phase_p TO pp1.
          SET num_orbits TO orb_count.
          SET node_ta TO ta1.
          SET node_time TO ta1_time.
        }
        LOCAL pp2 IS pp2_secs / orb_count.
        IF pp2_ok AND isPhasePeriodBetter(pp2, phase_p, orb:PERIOD, min_p, max_p) {
          SET phase_p TO pp2.
          SET num_orbits TO orb_count.
          SET node_ta TO ta2.
          SET node_time TO ta2_time.
        }
        IF pp1 < min_p AND pp2 < min_p { SET done TO TRUE. }
      }

      IF ok {
        IF phase_p > 0 AND num_orbits > 0 AND node_time > u_time {
          pOut("Selected phase period: " + ROUND(phase_p,1) + "s. Orbits: " + num_orbits).
          LOCAL opp_alt IS orbitAltForPeriod(b,orb,node_ta,phase_p).
          LOCAL pnode IS nodeAlterOrbit(node_time, opp_alt).
          addNode(pnode).
        } ELSE {
          pOut("ERROR: Could not determine a valid phase period.").
          SET ok TO FALSE.
        }
      }
    }
  }

  RETURN ok.
}