

#' Test an R package and report the results in JUnit 
#'
#' Run all tests of a package and report the results as JUnit xml. This function 
#' can be seen as a drop in replacement for [tinytest::test_package()] but with a 
#' key difference that uncaught errors will be catched and reported JUnit!
#' This function is intended to be used in a test stage of a CI build.
#' 
#' @param pkgname `character(1)`. Name of the package to tests. 
#' @param file `character(1) | connection`: Full file path or connection object to write the 
#'   JUnit xml content to. By default `stdout()` connection is used.
#' @param errorOnFailure `logical(1)` Should an error be raised (after writing the JUnit) when a 
#'   at least one test failed? By default TRUE. This is done as a 
#'   convenience to have the CI fail at the test stage on failure.
#' @param testDir `character(1)` testing directory of the package. See ?[tinytest::test_package()] 
#'   for more details.
#' @param lib.loc `character(1) | NULL` Library location where the package is installed. 
#'   By default: `NULL` meaning the package is searched on the standard .libPaths().
#' @param at_home `logical(1)` should local test be run? By default FALSE as we want to as closely 
#'    mimic the environement of how tests would get ran in CRAN. 
#'    See for more details [tinytest::test_package()].
#' @param ncpu `postive integer(1) | clutser` Either an integer specifying the amount of cpu's 
#'   to parralize the testing over or a `cluster` object to run the tests in.
#' @param ... Extra arguments passed on to [runTestDir()]
#' 
#' @return If `errorOnFailure` = FALSE, a `tinytests2JUnit` object (a subclass of `tinytests` 
#'   object that captures more info for export to JUnit). Else, an error is raised if at least 
#'   on failure occurs. Meant as convenience to automatically stop the CI build.
#'
#' @details 
#' [testPackage()] is meant as a CI-friendly alternative to the native [tinytest::test_package()]. 
#' Next to directly reporting the tests results in a JUnit xml format, it also catches errors that 
#' are raised in the tests files and reports them as "error" in the JUnit. 
#'
#' [tinytest::test_package()] would have let the error bubble up, stop the testing 
#' process and not report any failures from other test files. One is then also forced 
#' to look into the logs of the CI to see what the error was. [testPackage()] presents you that
#' error in the JUnit with a stacktrace. Next to all the test results of the other files that 
#' ran without a problem. 
#' 
#' If you prefer the behaviour from [tinytest::test_package()], you can still use it in 
#' combination with [writeJUnit()] if all tests results pass.
#'  
#' Just like [tinytest::test_package()] an error is raised if at least one failure occured during 
#' testing. Obviously catched errors are also seen as failures. This error is raised
#' **after** the test results have been written away to the file, such that your CI can still pick 
#' it up and report the failure.
#' The error raising is done as a convenience to stop the CI from continue if test-failure occured.
#' You can opt-out of this behaviour by setting the `errorOnFailure` parameter to FALSE. Then a
#' case `tinytests2JUnit` object is returned (a sub-class of `tinytests` object containing addition 
#' info for the JUnit). 
#' Caught errors are also captured in this object as `tinytest`-objects. They 
#' actually have a special sub-class but this is considered an internal implemenation detail.
#' 
#' [testPackage()] is NOT meant to be called from within your `tests/tinytests.R` file! Tests 
#' invoked by R CMD Check or on CRAN should still make use of [tinytest::test_package()].
#' This function is only meant to be called from within a testing step in your CI to 
#' report the test results in an JUnit xml format.
#' 
#' @inheritSection writeJUnit Side-effects
#' @inheritSection writeJUnit tinytests to JUnit
#' @export
#' @seealso [runTestDir()] and [tinytest::test_package()].
testPackage <- function(
  pkgname,
  file = stdout(),
  errorOnFailure = TRUE, 
  testdir = "tinytest",
  lib.loc = NULL,
  at_home = FALSE,
  ncpu = NULL,
  ...
) {
  oldlibpaths <- .libPaths()

  if (!is.null(lib.loc)) { 
    e <- new.env()
    e$libs <- c(lib.loc, oldlibpaths)
      
    if (!dir.exists(lib.loc)) 
      warning("lib.loc '", lib.loc, "' not found.")
    .libPaths(c(lib.loc, oldlibpaths))
  }

  on.exit({
    if (is.numeric(ncpu)) parallel::stopCluster(cluster)
    .libPaths(oldlibpaths)
  })

  if (!dir.exists(testdir)) { # if not customized test dir
    # find the installed test dir
    newTestDir <- system.file(testdir, package = pkgname, lib.loc = lib.loc)
    if (newTestDir == "") {
      stop("testdir '", testdir, "' not found for package '", pkgname, "'")
    } else {
      testdir <- newTestDir
    }
  }

  # set up cluster if required
  cluster <- if (is.null(ncpu)) NULL
  if (is.null(ncpu)) {
    cluster <- NULL 
  } else if (is.numeric(ncpu)) {
    cluster <- parallel::makeCluster(ncpu, outfile = "")
  } else if (inherits(ncpu, "cluster")) {
    cluster <- ncpu
  } else {
    stop("ncpu must be NULL, 'numeric', or 'cluster'")
  }

  # By now we have a cluster, or NULL. Load the pkg under scrutiny.
  if (is.null(cluster)) {
    library(pkgname, character.only = TRUE, lib.loc = lib.loc)
  } else {
    if (!is.null(lib.loc)) {
      # to prevent a R CMD check warning we must create a dummy libs here
      # as well
      libs <- NULL
      parallel::clusterExport(cluster, "libs", envir = e)
      parallel::clusterEvalQ(cluster, .libPaths(libs))
    }
    parallel::clusterCall(cluster, library, pkgname, character.only = TRUE, lib.loc = lib.loc)
  }

  out <- runTestDir(testdir, at_home = at_home, cluster = cluster, ...) 
  vTestFailed <- sapply(out, isFALSE)
  if (any(vTestFailed) && errorOnFailure) {
    writeLines(vapply(out[vTestFailed], format, type = "long", FUN.VALUE = character(1)))
    stop(sum(vTestFailed), " out of ", length(out), " tests failed", call.= FALSE)
  } 
  out
}
