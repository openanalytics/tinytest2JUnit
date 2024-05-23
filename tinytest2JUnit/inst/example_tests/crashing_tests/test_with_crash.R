library(tinytest)

expect_true(TRUE, info = "passing tests")

a <- \() stop("bla")
b <- \() a()
d <- \() b()

d()
