# Project: tinytest2JUnit
# 
# Author: ltuijnder
###############################################################################


returns_true <- function() TRUE

expect_false( 
  if(returns_true()){
      TRUE
    }else{
      FALSE
    }
)
