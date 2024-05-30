testResults <- runTestDir(
  system.file("example_tests/crashing_tests", package = "tinytest2JUnit"),
  verbose = 0
)

expect_inherits(testResults, "tinytests2JUnit", info = "tinytests2JUnit is returned")
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

testDir <- system.file("example_tests/multiple_files", package = "tinytest2JUnit")
files <- sort(dir(testDir))
testResults <- runTestDir(testDir, verbose = 0)
expect_inherits(testResults, "tinytests2JUnit", info = "tinytests2JUnit is returned")

vctFiles <- vapply(testResults, attr, "file", FUN.VALUE = character(1L))
splitPerFile <- lapply(files, function(f) testResults[vctFiles == f])
expect_true(
  all(vapply(splitPerFile, inherits, 'tinytests2JUnit', FUN.VALUE = logical(1))),
  info = 'Subsetting tinytests2JUnit yields tinytests2JUnit'
)

# Test file duration property:
expect_true(is.numeric(attr(testResults, "fileDurations")), info = "File durations is reported")
expect_equal(
  files,
  names(attr(testResults, "fileDurations")),
  info = "Duration of all files are reported."
)
expect_equal(
  names(attr(splitPerFile[[1]], "fileDurations")),
  target = files[1],
  info = "After subset duration of only relevant files is still reported."
)
expect_equal(
  attr(splitPerFile[[2]][[1]], 'file'),
  names(attr(splitPerFile[[2]], "fileDurations")),
  info = "Name fileDurations is equal to the file attribute of the tinytest object"
)

# Test file timestamp
expect_true(
  is.character(attr(testResults, "fileTimestamps")),
  info = "File timestamps is reported"
)
expect_equal(
  names(attr(splitPerFile[[2]], "fileTimestamps")),
  target = files[2],
  info = "fileTimestamps is present after subsetting and only for relevant files."
)

# Test file hostnames
expect_equal(
  names(attr(splitPerFile[[2]], "fileHostnames")),
  target = files[2],
  info = "fileHostnames is present after subsetting and only for relevant files."
)

# Test disabled.
expect_equal(attr(testResults, 'disabled'), attr(splitPerFile[[1]], 'disabled'))


tagsMultipleFiles <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_true(
  tagsMultipleFiles$attributes$tests == 3L,
  info = "runTestDir also works with non-crashing tests."
)
expect_true(
  tagsMultipleFiles$attributes$failures == 1L,
  info = "runTestDir also still correctly reports normal failing tests."
)
expect_true(
  tagsMultipleFiles$attributes$disabled == 0L,
  info = "tinytests2JUnit results in disabled reporting"
)
expect_true(
  !is.null(tagsMultipleFiles$content[[1]]$attributes$time),
  info = "time is reported for tinytests2JUnit objects"
)
expect_true(
  !is.null(tagsMultipleFiles$content[[1]]$attributes$hostname),
  info = "hostname is reported for tinytests2JUnit objects"
)
expect_true(
  !is.null(tagsMultipleFiles$content[[1]]$attributes$timestamp),
  info = "timestamp is reported for tinytests2JUnit objects"
)

testResults <- runTestDir(
  system.file("example_tests/get_call_wd", package = "tinytest2JUnit"),
  verbose = 2
)
testResults <- tinytest::run_test_dir(
  system.file("example_tests/get_call_wd", package = "tinytest2JUnit"),
  verbose = 2
)

if (at_home()) { # Problems on windows computer. 
  expect_true(
    all(unlist(testResults)),
    info = "runTestDir correctly sets working directory and calling directory"
  )
}

# Test disabled tests are being reported:
testDir <- system.file("example_tests/skips", package = "tinytest2JUnit")
testResults <- runTestDir(testDir, verbose = 0)
expect_equal(attr(testResults, "disabled"), "test_everything_skipped.R")
tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_equal(tags$attributes$disabled, 1L)


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
