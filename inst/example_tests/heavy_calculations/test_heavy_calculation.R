# Project: tinytest2JUnit
# 
# Author: ltuijnder
###############################################################################


heavy_calculation <- function(){
  
  Sys.sleep(runif(1,1,3)) # sleep for 1 to 3 seconds
  TRUE
}


expect_true(heavy_calculation(), info = "heavy calculations")