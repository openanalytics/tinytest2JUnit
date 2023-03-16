
#' Write the results in a `tinytests`-object into JUnit xml report.
#' 
#' Write the [tinytest::tinytests()]-object to a JUnit XML reporting file.  
#' 
#' @param tinytests `tinytests` object to convert to JUnit xml.
#' @param file `character(1)`: Full file path to the .xml file to write the JUnit xml into. 
#'  Example: "/home/ltuijnder/documents/results.xml".
#' @param overwrite `logical(1)`: should the file be overwritten if it already exist? 
#'  By default TRUE.
#' 
#' @return `invisible: TRUE`.
#' @author ltuijnder
#' @seealso The JUnit-xml report format: https://llg.cubic.org/docs/junit/
#' 
#' @section Errors:
#' In case of overwrite = FALSE and the file already exist an error is thrown.
#' 
#' @export
writeJUnit <- function(tinytests, file, overwrite = TRUE){
  
  fileExists <- file.exists(file)
  if(fileExists && !overwrite){
    stop("Overwrite is set to = FALSE and specified file already exist:", file)
  }
  
  JUnitXML <- constructTeststuitesTag(testResults = tinytests)
  cat('<?xml version="1.0" encoding="UTF-8"?>\n', file = file, append = !overwrite)
  cat(format(JUnitXML), sep = "\n", file = file, append = TRUE)
  
  invisible(TRUE)
}
