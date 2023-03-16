# Project: tinytest2JUnit
# 
# Author: ltuijnder
###############################################################################

dir <- "~/git/tinytest2JUnit/inst/example_tests/simple_tests/"


add <- function(a, b){
  a + b
}

add_one <- function(a){
  a + 1
}

expect_equal(current = add(1,1), target = 2, info = "Math works.")
expect_equal(current = add_one(1), target = 2, info = "Math works with 1")
expect_equal(current = add_one(-1), target = 0)
expect_equal(current = add_one(-1), target = 1)
