
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
#' @param file `character(1)`: Full file path to the .xml file to write the JUnit xml to. 
#'  Example: "/home/user/documents/results.xml".
#' @param overwrite `logical(1)`: should the file be overwritten if it already exist? 
#'  By default TRUE.
#' 
#' @return `invisible: TRUE`.
#' @seealso The JUnit XML report format:  \url{https://llg.cubic.org/docs/junit/}
#' 
#' @section Errors:
#' In case of overwrite = FALSE and the file already exists an error is thrown.
#' 
#' @export
writeJUnit <- function(tinytests, file, overwrite = TRUE) {
  
  fileExists <- file.exists(file)
  if (fileExists && !overwrite) {
    stop("Overwrite is set to FALSE and specified file already exists: ", file)
  }
  
  JUnitXML <- constructTestsuitesTag(testResults = tinytests)
  cat('<?xml version="1.0" encoding="UTF-8"?>\n', file = file, append = !overwrite)
  cat(format(JUnitXML), sep = "\n", file = file, append = TRUE)
  
  invisible(TRUE)
}
