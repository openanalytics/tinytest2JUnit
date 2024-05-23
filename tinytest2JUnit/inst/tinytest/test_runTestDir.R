testResults <- runTestDir(
  system.file("example_tests/crashing_tests", package = "tinytest2JUnit"),
  verbose = 0
)
expect_inherits(testResults, "tinytests", info = "tinytests is returned")
expect_true(
  all(vapply(testResults, inherits, "tinytest", FUN.VALUE = logical(1))),
  info = "all items are tinytest"
)
expect_false(all(unlist(testResults)), info = "Crashing tests is reported as failin tinytest")

tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_equal(
  attr(tags, "class"),
  "XMLtag",
  info = "constructTestsuitesTag works with the results from runTestDir."
)
expect_equal(tags$attributes$tests, 1L, info = "Crashing test is reported")
expect_equal(tags$attributes$failures, 0L, info = "Crashing test is not reported as failure")
expect_equal(tags$attributes$errors, 1L, info = "Crashing test is reported as error")
expect_equal(tags$content[[1]]$attributes$errors, 1L, info = "Crashing test is reported as error")

testResultsMultipleFiles <- runTestDir(
  system.file("example_tests/multiple_files", package = "tinytest2JUnit"),
  verbose = 0
)
tagsMultipleFiles <- tinytest2JUnit:::constructTestsuitesTag(testResultsMultipleFiles)
expect_true(
  tagsMultipleFiles$attributes$tests == 3L,
  info = "runTestDir also works with non-crashing tests."
)
expect_true(
  tagsMultipleFiles$attributes$failures == 1L,
  info = "runTestDir also still correctly reports normal failing tests."
)


testResults <- runTestDir(
  system.file("example_tests/get_call_wd", package = "tinytest2JUnit"),
  verbose = 2
)
expect_true(
  all(unlist(testResults)),
  info = "runTestDir correctly sets working directory and calling directory"
)



cluster <- try(parallel::makeCluster(2))
if (inherits(cluster, "try-error")) {
  exit_file("Cannot create cluster. Skipping cluster tests.")
}

tryCatch(
  resultCluster <- runTestDir(
    system.file("example_tests/multiple_files", package = "tinytest2JUnit"),
    cluster = cluster,
    verbose = 0
  ),
  finally = parallel::stopCluster(cluster)
)

expect_true(exists("resultCluster"), info = "Cluster running is supported")
tagsMultipleFiles <- tinytest2JUnit:::constructTestsuitesTag(resultCluster)
expect_true(
  length(resultCluster) == 3L,
  info = "runTestDir correctly runs with clusters."
)
