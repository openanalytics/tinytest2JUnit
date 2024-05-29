
tmpFile <- tempfile(fileext = ".xml")
expect_inherits(
  testPackage("tinytest", file = tmpFile, verbose = 0),
  "tinytests2JUnit",
  info = "Works with package in standard lib path."
)
startFile <- readLines(tmpFile, n = 1)
expect_equal(startFile, '<?xml version="1.0" encoding="UTF-8"?>')


tmpLib <- tempdir()
fibPackage <- system.file(
  "example_package/fib_1.0.0.tar.gz",
  package = "tinytest2JUnit",
  mustWork = TRUE
)
install.packages(fibPackage, type = "source", repos = NULL, lib = tmpLib)

testDir <- system.file("example_package/fib/inst/tinytest", package = "tinytest2JUnit")
expect_inherits(
  result <- testPackage(
    "fib",
    file = "/dev/null", 
    testdir = testDir,
    verbose = 0,
    lib.loc = tmpLib,
    errorOnFailure = FALSE
  ),
  "tinytests2JUnit",
  info = "Works with a directly provided path and custom lib and errorOnFailure = FALSE."
)
expect_equal(sum(sapply(result, isFALSE)), 2L, info = "2 failed tinytests")

expect_inherits(
  testResults <- testPackage(
    "fib",
    file = "/dev/null",
    ncpu = 2,
    errorOnFailure = FALSE,
    lib = tmpLib,
    verbose = 0
  ),
  "tinytests2JUnit",
  info = "Parralization works"
)

tags <- tinytest2JUnit:::constructTestsuitesTag(testResults)
expect_equal(tags$attributes$errors, 1L, info = "The hard crash is correctly registed as an Error.")


cluster <- parallel::makeCluster(2)
tryCatch(
  expr = {
    testResults <- testPackage(
      "fib",
      file = "/dev/null",
      ncpu = cluster,
      errorOnFailure = FALSE,
      lib.loc = tmpLib
    )
    expect_inherits(
      testResults,
      "tinytests2JUnit",
      info = "Custom clusters works."
    )
  },
  finally =  parallel::stopCluster(cluster)
)


expect_error(
  testPackage("fib", file = "/dev/null", lib.loc = tmpLib),
  info = "By default an error is raised when a test failure occurs"
)
