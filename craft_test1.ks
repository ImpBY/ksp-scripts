@LAZYGLOBAL OFF. IF NOT EXISTS("1:/init.ks") { COPYPATH("0:/init.ks","1:/init.ks"). }. RUNONCEPATH("1:/init.ks"). // #include init

GLOBAL f_exit IS FALSE.
// GLOBAL v_count IS 0.
// GLOBAL v_time IS TIME:SECONDS.

// ON AG1 {
  // SET v_count TO v_count + 1.
  // SET v_time TO TIME:SECONDS + 5.
  // pOut("Exit Code: " + v_count).
  // RETURN TRUE.
// }

// ON ABORT {
  // IF TIME:SECONDS < v_time {
    // pOut("Result: " + v_count).
    // IF v_count > 2 SET f_exit TO TRUE.
  // }
  // SET v_count TO 0.
  // RETURN TRUE.
// }

UNTIL f_exit {
  WAIT 0.1.
}.