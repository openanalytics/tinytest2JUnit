library(tinytest)

expect_true(TRUE, info = "passing tests")

a <- function() stop("bla")
b <- function() a()
d <- function() b()

d()
