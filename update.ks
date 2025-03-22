@LAZYGLOBAL OFF.
SWITCH TO 1.

// Функция для обновления загрузочного файла процессоров
FUNCTION updateProcessorBootFiles {
  LOCAL pl IS LIST().
  LIST PROCESSORS IN pl.
  FOR p IN pl {
    IF p:MODE = "READY" AND p:BOOTFILENAME <> "None" {
      SET p:BOOTFILENAME TO "/boot/boot.ks".
    }
    p:VOLUME:DELETE("/boot").
  }
  COPYPATH("0:/boot/boot.ks","1:/boot/boot.ks").
}

// Функция для загрузки скриптов
FUNCTION loadScripts {
  LOCAL fl TO VOLUME(0):FILES:KEYS.
  FOR f IN fl {
    IF f:CONTAINS(".ks") AND findPath(f) <> "" {
      loadScript(f, debug(), f, TRUE).
    }
  }
}

// Основная логика
updateProcessorBootFiles().
RUNPATH("0:/init_multi.ks").
//debugOn().
delScript("init.ks").
delScript("init_common.ks").

RUNPATH("0:/init_select.ks").
RUNPATH("1:/init.ks").

loadScripts().

RUNPATH("0:/init_select.ks").
RUNPATH("1:/init.ks").

//debugOff().
pOut("Update complete").
