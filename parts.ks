LOCAL MODLIST IS "0:/parts_log/".
DELETEPATH(MODLIST).
FOR p IN SHIP:PARTS {
  LOG ("MODULES FOR PART NAMED " + p:NAME) TO MODLIST + p:NAME.
  FOR mn IN p:MODULES {
    LOG "________________________________" TO MODLIST + p:NAME.
    LOG "Module: " + mn TO MODLIST + p:NAME.
    LOG "__ events ______________________" TO MODLIST + p:NAME.
    LOG p:GETMODULE(mn):ALLEVENTS TO MODLIST + p:NAME.
    LOG "__ fields ______________________" TO MODLIST + p:NAME.
    LOG p:GETMODULE(mn):ALLFIELDS TO MODLIST + p:NAME.
    LOG "__ actions _____________________" TO MODLIST + p:NAME.
    LOG p:GETMODULE(mn):ALLACTIONS TO MODLIST + p:NAME.
    LOG "________________________________" TO MODLIST + p:NAME.
  }
}.
PRINT "complete".
