

testResults <- tinytest::run_test_dir(
  dir = system.file("example_tests/empty_tests", package = "tinytest2JUnit"), 
  verbose = FALSE
)
tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_equal(
  attr(tags, "class"),
  "XMLtag",
  info = "constructTestsuitesTag returns a xml tag object"
)
expect_equal(tags$attributes$tests, 0L, info = "empty test file results in 0 tests")
expect_true(
  all(c("name", "tests", "failures", "errors", "time", "disabled") %in% names(tags$attributes)), 
  info = "Expected testsuites tag attributes are present"
)
expect_true(!is.na(tags$attributes$time), info = "Total run time is reported.")
expect_true(
  tinytest2JUnit:::isSingleLengthCharNonNA(tags$attributes$name),
  info = "Testsuites name is set"
)


testResults <- tinytest::run_test_dir(
  system.file("example_tests/heavy_calculations", package = "tinytest2JUnit"), verbose = FALSE
)
tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_true(tags$attributes$time > 1, info = "Time duration is correctly reported")
expect_true(tags$attributes$tests == 1L, info = "Tests are reported")
expect_equal(tags$content[[1]]$name, "testsuite", info = "testsuite tag is present.")

testResults <- tinytest::run_test_dir(
  dir = system.file("example_tests/multi_line_except_statement", package = "tinytest2JUnit"), 
  verbose = FALSE
)
tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_equal(
  attr(tags, "class"),
  "XMLtag",
  info = "multi line except statements does not cause problems."
)

testResults <- tinytest::run_test_dir(
  dir = system.file("example_tests/multiple_files", package = "tinytest2JUnit"), 
  verbose = FALSE
)
tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_true(tags$attributes$tests == 3L)
expect_true(tags$attributes$failures == 1L)
expect_equal(
  vapply(
    tags$content,
    function(testsuite) testsuite$attributes$name,
    FUN.VALUE = character(1)
  ),
  target = c("test_file1", "test_file2"),
  info = "Name of testsuite-tag is equal to the test_file without suffix."
)
expect_equal(
  tags$content[[1]]$content[[1]]$attributes, 
  list(classname = "test_file1", name = "Line:9", status = "PASSED"),
  info = "testcase name and status are correctly set"
)
expect_equal(
  tags$content[[1]]$content[[2]]$attributes, 
  list(classname = "test_file1", name = "Line:10 : Some info", status = "PASSED"),
  info = "Info get's added to the the testcase name."
)
expect_equal(
  tags$content[[2]]$content[[1]]$attributes, 
  list(classname = "test_file2", name = "Line:9-&gt;Line:15", status = "FAILED"),
  info = "Failed testcase are handled!"
)


testResults <- tinytest::run_test_dir(
  dir = system.file("example_tests/skips", package = "tinytest2JUnit"), 
  verbose = FALSE
)
tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_true(tags$attributes$tests == 1L, info = "Skipped tests are not reported.")


testResults <- tinytest::run_test_dir(
  dir = system.file("example_tests/side_effects", package =  "tinytest2JUnit"), 
  verbose = FALSE
)
tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_true(tags$attributes$tests == 3L, info  = "Side effect is reported")
# TODO if side-effect is correctly reported.
