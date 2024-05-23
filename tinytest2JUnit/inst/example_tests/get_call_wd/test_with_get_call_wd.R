# Note This file is expected to be executed from tinytest/test_runTestDir.R
library(tinytest)

currentWD <- getwd()
filePath <- system.file(
  "example_tests/get_call_wd",
  package = "tinytest2JUnit"
)

callWD <- get_call_wd()

expect_equal(
  currentWD,
  filePath,
  info = "Tinytest executes test_files from within the directory of the test_file"
)

# Below assumes that this test_file executed from the tinytest/ directory!
dirWhereItGotExecutedFrom <- system.file(
  "tinytest",
  package = "tinytest2JUnit"
)
expect_equal(
  callWD,
  dirWhereItGotExecutedFrom,
  info = "get_call_wd is correctly set."
)
