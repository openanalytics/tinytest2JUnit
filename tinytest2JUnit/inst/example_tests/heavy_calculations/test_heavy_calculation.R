# Project: tinytest2JUnit
# 
# Author: ltuijnder
###############################################################################


#dir <- "~/git/tinytest2JUnit/inst/example_tests/heavy_calculations/"

heavyCalc <- function() {
  
  Sys.sleep(runif(1, 1, 3)) # sleep for 1 to 3 seconds
  TRUE
}


expect_true(heavyCalc(), info = "heavy calculations")
