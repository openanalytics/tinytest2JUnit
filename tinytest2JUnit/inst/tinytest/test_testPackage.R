
tmpFile <- tempfile()
result <- testPackage("tinytest", file = tmpFile, verbose = 0)
expect_inherits(result, "tinytests2JUnit")
startFile <- readLines(tmpFile, n = 1)
expect_equal(startFile, '<?xml version="1.0" encoding="UTF-8"?>')

tmpLib <- tempdir()
fibPackage <- system.file(
  "example_package/fib_1.0.0.tar.gz",
  package = "tinytest2JUnit",
  mustWork = TRUE
)
install.packages(fibPackage, type = "source", repos = NULL, lib = tmpLib)

testResults <- testPackage("fib", ncpu = 2, errorOnFailure = FALSE)
expect_inherits(
  testResults,
  "tinytests2JUnit",
  info = "testPackage with cluster and custom lib works and errorOnFailure works!"
)
expect_equal(sum(sapply(testResults, isFALSE)), 2L, info = "2 failed tinytests")

tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_equal(tags$attributes$errors, 1L, info = "The hard crash is correctly registed as an Error.")


cluster <- parallel::makeCluster(2)
tryCatch(
  expr = {
    testResults <- testPackage("fib", ncpu = cluster, errorOnFailure = FALSE, lib.loc = tmpLib)
    expect_inherits(
      testResults,
      "tinytests2JUnit",
      info = "Custom clusters works."
    )
  },
  finally =  parallel::stopCluster(cluster)
)


expect_error(
  testPackage("fib", lib.loc = tmpLib),
  info = "By default an error is raised when a test failure occurs"
)
