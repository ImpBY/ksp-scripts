@LAZYGLOBAL OFF.
// this lives on the archive, run it once on start-up to copy
// either "0:/init.ks" or "0/init_multi.ks" to "1:/init.ks"

copyOverInit().

FUNCTION copyOverInit {
  // LOCAL disk_count IS 1.
  // LOCAL pl IS LIST().
  // LIST PROCESSORS IN pl.
  // FOR p IN pl {
    // IF p:MODE = "READY" AND p:BOOTFILENAME = "None" {
      // SET disk_count TO disk_count + 1.
    // }
  // }

  // IF disk_count > 1 {
    // PRINT "Multi-disk init".
    // COPYPATH("0:/init_multi.ks","1:/init.ks").
  // } ELSE {
    PRINT "Single-disk init".
    COPYPATH("0:/init.ks","1:/init.ks").
  // }
}