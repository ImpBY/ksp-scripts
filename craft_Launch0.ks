@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

GLOBAL NEW_NAME IS "Launch1".
GLOBAL ORBIT_AP IS 100000.
GLOBAL ORBIT_PE IS 100000.
GLOBAL ORBIT_LOW IS MAX(BODY:ATM:HEIGHT * 1.05, ORBIT_PE-100000).
GLOBAL ORBIT_LAN IS -1.
GLOBAL ORBIT_INC IS 0.
GLOBAL ORBIT_W IS -1.
GLOBAL ORBIT_DIR IS -1.

GLOBAL STEER_SUN IS TRUE.
GLOBAL ORBIT_CIRK IS TRUE.
GLOBAL SHIP_ORBIT_SLOW IS FALSE.
GLOBAL SHIP_MAXQ_THR IS TRUE.
GLOBAL SHIP_TWR IS 2.0.
GLOBAL SHIP_THR_CONTROL IS TRUE.
GLOBAL SHIP_WARP_ALLOW IS TRUE.
GLOBAL ANG_PREC IS 0.2.
GLOBAL ALT_PREC IS 1.0.

IF HASTARGET {
  SET ORBIT_AP TO MAX(MIN((TARGET:OBT:APOAPSIS + TARGET:OBT:PERIAPSIS) / 3, 500000), ORBIT_LOW).
  SET ORBIT_PE TO ORBIT_AP.
  SET ORBIT_LOW TO ORBIT_AP.
  SET ORBIT_LAN TO TARGET:OBT:LAN.
  SET ORBIT_INC TO TARGET:OBT:INCLINATION.
}

GLOBAL SHIP_FILE IS "ship_launch.ks".
