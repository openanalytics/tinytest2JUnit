# Project: tinytest2JUnit
# 
# Author: ltuijnder
###############################################################################


returnsTrue <- function() TRUE

expect_false( 
  if (returnsTrue()) {
    TRUE
  } else {
    FALSE
  }
)
