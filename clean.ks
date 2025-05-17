@LAZYGLOBAL OFF. // #include init
SWITCH TO 1.
LOCAL fl TO VOLUME(1):FILES:KEYS.
FOR f_ IN fl { VOLUME(1):DELETE(f_). }
LIST.
PRINT "Clean complete".
