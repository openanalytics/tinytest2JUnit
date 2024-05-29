
#' Write the results of a `tinytests`-object into JUnit xml report.
#' 
#' Write the `tinytests`-object to a JUnit XML reporting file. If a `tinytests2JUnit` is provided 
#' (returned by [runTestDir()]) more info will get reported.
#' 
#' @param tinytests `tinytests`-object to convert to JUnit xml. 
#' @param file `character(1) | connection`: Full file path or connection object to write the 
#'  JUnit xml content to. By default `stdout()` connection is used.
#' @param overwrite `logical(1)`: should the file be overwritten if it already exist? 
#'  By default TRUE.
#' 
#' @return `invisible(TRUE)` Might get another use in the future.
#' 
#' @seealso The JUnit XML report format:  \url{https://llg.cubic.org/docs/junit/}
#' 
#' @section Errors:
#' In case of overwrite = FALSE and the file already exists an error is thrown.
#' 
#' @section Side-effects:
#' Side effects are registered as 'passed' tests in the JUnit output and have been given a status 
#' "SIDE-EFFECT". The call and diff is also returned in the standard-output of the testcase tag.
#' 
#' They are not considred failures and would thus not stop a pipeline.
#' 
#' @section tinytests to JUnit:
#' 
#' To comply the the JUnit specification the tests results are adapted as follows:
#'
#' * A single test run `tinytests` is mapped to a `<testsuites>` tag. 
#' * All `tinytest` results from a single file are mapped to a single `<testsuite>` tag. 
#'   * The name of the testsuite is equal to the test file name (without the file suffix)
#' * An individual `tinytest` object (eg. a single `except_*` exception test) is mapped to a 
#'   `<testcase>` tag. 
#'   * The name of the testcase is equal to the fileName + Line specification of where the expect
#'     statement is performed + the info.
#'
#' For reference: \url{https://llg.cubic.org/docs/junit/}
#' 
#' @export
#' @examples 
#' # Run tests with `tinytest`
#' dirWithTests <- system.file("example_tests/multiple_files",package = "tinytest2JUnit")
#' testresults <- runTestDir(dirWithTests)
#' 
#' writeJUnit(testresults) # Writes content to stdout
#' 
#' tmpFile <- tempfile(fileext = ".xml")
#' writeJUnit(tinytests = testresults, file = tmpFile)
writeJUnit <- function(tinytests, file = stdout(), overwrite = TRUE) {
  
  if (!isSingleLengthCharNonNA(file) && !inherits(file, "connection")) {
    stop("File should be single length non-NA character or a connection object.")
  }
  if (is.character(file)) {
    fileExists <- file.exists(file)
    if (fileExists && !overwrite) {
      stop("Overwrite is set to FALSE and specified file already exists: ", file)
    }
  }
  
  junitXML <- constructTestsuitesTag(testResults = tinytests)
  cat('<?xml version="1.0" encoding="UTF-8"?>\n', file = file, append = FALSE)
  cat(format(junitXML), sep = "\n", file = file, append = TRUE)
  
  invisible(TRUE)
}
