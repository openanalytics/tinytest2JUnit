# Project: tinytest2JUnit
# 
# Author: ltuijnder
###############################################################################




testDirSimple <- system.file("example_tests","simple_tests", package = "tinytest2JUnit", mustWork = TRUE)


expect_stdout(run_and_convert(testDirSimple))