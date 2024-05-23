

heavyCalc <- function() {
  
  Sys.sleep(runif(1, 0, 1)) # sleep for 0 to 1 seconds
  TRUE
}

expect_true(heavyCalc())
expect_true(TRUE, info = "Some info")
