
#' Write the results of a `tinytests`-object into JUnit xml report.
#' 
#' Write the `tinytests`-object to a JUnit XML reporting file.
#' 
#' @section Side-effects:
#' Side effects are registered as a tests in the JUnit output and have been given a status 
#' "SIDE-EFFECT". The call and diff is also returned in the standard-output of the testcase tag.
#' 
#' They are however not considered as failures and would thus not stop a pipeline.
#' 
#' @param tinytests `tinytests`-object to convert to JUnit xml.
#' @param file `character(1) | connection`: Full file path or connection object to write the 
#'  JUnit xml content to. By default `stdout()` connection is used.
#' @param overwrite `logical(1)`: should the file be overwritten if it already exist? 
#'  By default TRUE.
#' 
#' @return `invisible(logical(1))` the results of [tinytest::all_pass()] on the tinytests object.
#' 
#' @seealso The JUnit XML report format:  \url{https://llg.cubic.org/docs/junit/}
#' 
#' @section Errors:
#' In case of overwrite = FALSE and the file already exists an error is thrown.
#' 
#' @export
#' @examples 
#' # Run tests with `tinytest`
#' dirWithTests <- system.file("example_tests/multiple_files",package = "tinytest2JUnit")
#' testresults <- runTestDir(dirWithTests, verbose = FALSE)
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
