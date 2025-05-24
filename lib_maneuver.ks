@LAZYGLOBAL OFF. // #include init

FOR f IN LIST(
  "lib_dv.ks" // #include lib_dv
) { runScript(f,debug()). }

// Redefine this function to allow rcs rotation on some stages.
global use_rcs4rotation is { return false. }.

function check_stage {
  LOCAL acc IS SHIP:AVAILABLETHRUST / MASS.
  IF acc > 0 {
    wait 0.
  } ELSE {
    IF moreEngines() {
      IF STAGE:READY AND stageTime() > 0.5 {
        doStage().
        pDV().
      }
    } ELSE {
      pOut("No thrust available for burn.").
    }
  }
}

function rotate2 {
  // Rotetes ship to direction. Releases lock on stearing!!! lock must be reaquired after function call.
  parameter dir, max_time is 60, angle_precision is 0.15.
  local ok is true.
  pOut("Start rotate to direction").
    lock steering to dir.
    local starttime is time:seconds.
    if use_rcs4rotation () { rcs on. }
    local lock dyaw to abs(dir:yaw - ship:facing:yaw).
    local lock dpitch to abs(dir:pitch - ship:facing:pitch).
    local lock droll to abs(dir:roll - ship:facing:roll).
    until dyaw < angle_precision and dpitch < angle_precision and droll < angle_precision{
        if time:seconds - starttime > max_time {
            print beep.
      pOut("ERROR: can't rotate rocket to target in " + max_time + "seconds").
            hudMsg("ERROR: can't rotate rocket to target in " + max_time + "seconds", RED).
            set ok to false.
        }
    }
    if use_rcs4rotation () { rcs off. }
    unlock steering.
  pOut("Rotate complete").
  return ok.
}

function nodedv {
  parameter r1.
  parameter r2.
  parameter r2_new.

  set r1 to r1 + body:radius.
  set r2 to r2 + body:radius.
  set r2_new to r2_new + body:radius.

  return sqrt(2 * body:mu / r1) * (sqrt(r2_new / (r1 + r2_new)) - sqrt(r2 / (r1 + r2))).
}

function anode {
  parameter altm.
  // create apoapsis maneuver node
  pOut("Apoapsis maneuver, orbiting " + body:name).
  print "   Apoapsis: " + round(apoapsis/1000,5) + "km".
  print "  Periapsis: " + round(periapsis/1000,5) + "km -> " + round(altm/1000,5) + "km".

  // setup node
  local dv is nodedv(apoapsis, periapsis, altm).
  pOut("Apoapsis burn dv: " + round(dv,2) + "m/s").
  return node(time:seconds + eta:apoapsis, 0, 0, dv).
}

function pnode {
  parameter altm.
  // create apoapsis maneuver node
  pOut("Periapsis maneuver, orbiting " + body:name).
  print "   Apoapsis: " + round(apoapsis/1000,5) + "km -> " + round(altm/1000,5) + "km".
  print "  Periapsis: " + round(periapsis/1000,5) + "km".

  // setup node
  local dv is nodedv(periapsis, apoapsis, altm).
  pOut("Periapsis burn dv: " + round(dv,2) + "m/s").
  return node(time:seconds + eta:periapsis, 0, 0, dv).
}

function get_burntime {
  parameter dv.

  update_engines().
  local thrustSum is 0.0.
  local denomSum is 0.0.

  for eng in engs {
      if eng:isp > 0 {
          local thrust is eng:maxthrust * (eng:thrustlimit / 100).
          set thrustSum to thrustSum + thrust.
          set denomSum to denomSum + (thrust / eng:isp).
      }
  }
  set dv to dv/2.

  local ispavg is thrustSum / denomSum.
  local ve is ispavg * g0.
  local m0 is ship:mass.
  local t is (m0 * g0 / denomSum) * (1 - constant:e^(-dv/ve)).

  local sss is nextnode:eta - t.
  local drag is 0.
  print "t " + t.
  until sss > nextnode:eta {
      local bpos is POSITIONAT(ship:body, sss) - POSITIONAT(ship, sss).
      local vel is VELOCITYAT(ship, sss):orbit - POSITIONAT(ship, sss).
      local altm is bpos:mag.
      set drag to drag + (body:mu/altm^2) * cos(vang(bpos, vel))* 0.01.
      //set drag to drag + ( body:mu/((altitude + body:radius)^2)) * 0.01.
      set sss to sss + 0.01.
  }
  print "drag " + drag.
  set dv to dv + drag.

  return 2*(m0 * g0 / denomSum) * (1 - constant:e^(-dv/ve)).
}

function execnode {
  parameter nd.
  parameter align_time is 60.

  pOut("Executing node.").
  print "    Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

  local burntime is get_burntime (nd:deltav:mag).
  print "    Estimated burn duration: " + round(burntime, 2) + " s".

  warpto(time:seconds + nd:eta - burntime / 2 - align_time).
  wait until warp = 0 and ship:unpacked.

  pOut("Navigating node target.").
  rotate2(lookdirup(nd:deltav, ship:facing:topvector), align_time).

  // lets try to 'auto' correct if node direction is changed
  lock steering to lookdirup(nd:deltav, ship:facing:topvector).

  // Add 1 sec as fine tune will require ~2 sec instead of 1
  pOut("Waiting to burn start.").
  wait until nd:eta <= (burntime / 2).

  // throttle is 100% until there is less than 1 second of time left to burn
  // when there is less than 1 second - decrease the throttle linearly
  local lock max_acc to ship:maxthrust / ship:mass.
  function get_throttle {
      if(max_acc < 0.001){ return 0. } // if stage was burnt out
      return min(max(nd:deltav:mag / max_acc, 0.005), 1).
  }
  lock throttle to get_throttle().

  // here's the tricky part, we need to cut the throttle
  // as soon as our nd:deltav and initial deltav start facing opposite directions (or close to it)
  // this check is done via checking the dot product of those 2 vectors
  local ndv0 is nd:deltav.
  until vdot(ndv0, nd:deltav) < 0.01 {
      check_stage().
  }

  lock throttle to 0.
  pOut("End burn, remain dv " + round(nd:deltav:mag, 2) + "m/s, vdot: " + round(vdot(ndv0, nd:deltav), 1)).
  unlock steering.
  unlock throttle.
  wait 1.

  // set throttle to 0 just in case
  SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}

function execute_current_node {
  execnode(nextnode).
}

function get_azimuth {
  parameter orbitincl.
  return 90+orbitincl.
}

function get_throttle {
  parameter opt_twr.
  if maxthrust > 0 {
      local heregrav is body:mu/((altitude + body:radius)^2).
      local maxtwr is ship:maxthrust / (heregrav * ship:mass).
      return min(opt_twr / maxtwr, 1).
  } else {
      return 0.
  }
}

function launch2orbit{
  parameter orbitalt1, orbitincl.

  // trajectory parameters
  local ramp is altitude + 25.
  local pitch1 is 0.
  local gt0 is 0.
  local gt1 is 0.
  local gt2 is 0.

  // velocity parameters
  local opt_twr is 0.

  if body:name = "Kerbin" {
      set gt0 to 1000.
      set gt1 to 40000.
      set gt2 to 60000.
      set pitch1 to 75.
      set opt_twr to 1.8.
  }

  // adjust altitudes to start position
  local launch_altitude is altitude.
  set gt0 to gt0 + launch_altitude.
  set gt1 to gt1 + launch_altitude.
  set gt2 to gt2 + launch_altitude.

  pOut("All systems GO. Ignition!").
  hudMsg("All systems GO. Ignition!").
  wait 0.2.
  stage.

  lock steering to up + R(0, 0, -180).
  update_engines().

  local calc_t is {
      if apoapsis >= orbitalt1 {
          return 0.
      }
      if apoapsis > 0.9995 * orbitalt1 {
              return 0.01 * get_throttle(opt_twr).
      } else if apoapsis > 0.995 * orbitalt1 {
              return 0.05 * get_throttle(opt_twr).
      }
      return get_throttle(opt_twr).
  }.

  lock throttle to calc_t().

  until altitude >= ramp { check_stage(). }
  pOut("Liftoff!").

  until altitude >= gt0 { check_stage(). }
  pOut("Beginning gravity turn.").
  local lock arr to (altitude - gt0) / (gt1 - gt0).
  local lock pda to (cos(arr * 180) + 1) / 2.
  local lock pt to pitch1 * ( 1 - pda ).
  local lock pitchvector to heading(get_azimuth(orbitincl), 90-pt).
  lock steering to lookdirup(pitchvector:vector, ship:facing:topvector).

  until altitude >= gt1 { check_stage(). }
  pOut("Stop pitching.").
  local sset is lookdirup(pitchvector:vector, ship:facing:topvector).
  lock steering to sset.

  when altitude > 70000 then AG9 on.

  until altitude >= gt2 { check_stage(). }
  pOut("Navigating orbit prograde.").
  lock steering to lookdirup(prograde:vector, ship:facing:topvector).

  if altitude < body:atm:height {
      until altitude > body:atm:height { check_stage(). }
      pOut("Leaving atmosphere.").
  }

  until apoapsis > orbitalt1 { check_stage(). }

  lock throttle to 0.
  wait 1.
  unlock throttle.
  unlock steering.

  local nd is anode(apoapsis).
  add nd.
  execute_current_node().
  remove nd.
  pOut(round(apoapsis/1000, 2) + "km - " + round(periapsis/1000, 2) + " km orbit is reached!").
}

function deorbit {

  pOut("Deorbiting...").
  rotate2(lookdirup(retrograde:vector, ship:facing:topvector)).

  // burn retrograde until done
  lock throttle to 1.
  until periapsis < 0 or ship:liquidfuel = 0 and ship:solidfuel = 0 {
      check_stage().
  }

  unlock throttle.
  unlock steering.
}