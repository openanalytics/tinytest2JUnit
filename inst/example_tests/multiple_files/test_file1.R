# Project: tinytest2JUnit
# 
# Author: ltuijnder
###############################################################################


dir <- "~/git/tinytest2JUnit/inst/example_tests/simple_tests/"


heavy_calculation <- function(){
  
  Sys.sleep(runif(1,0,1)) # sleep for 0 to 1 seconds
  TRUE
}

expect_true(heavy_calculation())
expect_true(TRUE, info = "Some info")