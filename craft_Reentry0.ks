@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

GLOBAL NEW_NAME IS "Resc0".
GLOBAL ORBIT_LOW IS MAX(BODY:ATM:HEIGHT * 1.05, ORBIT_PE-100000).
GLOBAL SHIP_TWR IS 1.8.
GLOBAL ANG_PREC IS 0.2.
GLOBAL ALT_PREC IS 1.0.
GLOBAL STEER_SUN IS TRUE.

GLOBAL SHIP_FILE IS "ship_reentry.ks".
