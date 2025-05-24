@LAZYGLOBAL OFF.
SWITCH TO 1.
LOCAL craftVolume IS VOLUME(1).
LOCAL fl TO craftVolume:FILES:KEYS.
FOR f IN fl { craftVolume:DELETE(f). }
LIST.
PRINT "Clean complete".
