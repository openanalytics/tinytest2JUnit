

#' Construct the JUnit testsuites tag
#' 
#' Convert the tinytests object containing test across possibly multiple files into a JUnit 
#' testsuites tag.
#' 
#' @details
#' Reference for JUnit XML format: https://llg.cubic.org/docs/junit/
#' 
#' @param testResults \link[tinytest]{tinytests}-object to convert into a JUnit xml object.
#'   Usually the result of calling [tinytest::test_package()].
#' @return `XMLtag`: with tag-name = "testsuites". This is the root of the JUnit xml document.
#' @author ltuijnder
constructTestsuitesTag <- function(testResults){
 
  stopifnot(inherits(testResults, "tinytests"))
  
  vctTestFiles <- vapply(testResults, function(tinytest) attr(tinytest, "file"), FUN.VALUE = character(1))
  vctFailed <- !vapply(testResults, function(tinytest) tinytest, FUN.VALUE = logical(1))
  
  attributes = list(
    name = "tinytest results", 
    tests = length(vctFailed), 
    failures = sum(vctFailed)
  )
  
  duration <- attr(testResults, "duration")
  if(is.numeric(duration) && !is.na(duration)) attributes$duration <- as.character(duration)
  
  tag(
    name = "testsuites",
    attributes = attributes,
    content = lapply(X = unique(vctTestFiles),  FUN = function(file){
        constructTestsuiteTag(testResults[vctTestFiles==file])
      })
  )
}

#' Construct JUnit testsuite tag 
#' 
#' Construct the "testsuite" of the a tinytest, given all the tinytests results from a single test file. 
#' 
#' @param testResultsSingleFile `tinytests` with all test results of a specified test file.
#' @return `XMLtag`: with tag-name = "testsuite" and contains all the tests results of the file.
#' @author ltuijnder
constructTestsuiteTag <- function(testResultsSingleFile){
  
  stopifnot(inherits(testResultsSingleFile, "tinytests"))
  
  vctFailed = !vapply(testResultsSingleFile, function(tinytest) tinytest, FUN.VALUE = logical(1))
  
  attributes = list(
    name = attr(testResultsSingleFile[[1]], "file"),  
    tests = length(vctFailed), 
    failures = sum(vctFailed)
  )
  
  tag(
    name = "testsuite",
    attributes = attributes,
    content = lapply(testResultsSingleFile, constructTestcaseTag)
  )
  
}


#' Construct JUnit testcase tag 
#' 
#' Construct JUnit testcase tag based on a single tinytest results.
#' 
#' @param tinytest a [tinytest::tinytest()]-object representing an individual test case. 
#' @return `XMLtag`: with tag-name = "tinytest" and contains all the tests results of the file.
#' @author ltuijnder
constructTestcaseTag <- function(tinytest){
  
  stopifnot(inherits(tinytest, "tinytest"))
  
  attributes <- list()
  
  # Name = filename + line number
  nameTestcase = paste0(attr(tinytest, "file"),": L",attr(tinytest, "fst"))
  if(attr(tinytest, "fst") != attr(tinytest, "lst")){
    nameTestcase <- paste0(nameTestcase, "-L", attr(tinytest, "lst"))
  }
  attributes$name <- nameTestcase
  
  if(tinytest){
    attributes$status <- "PASSED"
    return(tag("testcase", attributes = attributes))
  }
  
  attributes$status <- "FAILED"
  
  # Construct the failure tag
  failureTagAttr <- list(type = attr(tinytest, "short"))
  if(!is.na(attr(tinytest, "info"))) failureTagAttr$message <- attr(tinytest, "info")
  
  callCharVect <- utils::capture.output(print( attr(tinytest, "call")))
  call <- paste0('call| ', callCharVect)
  if(!is.na(attr(tinytest, "diff"))){
    diff <- paste0('diff| ', attr(tinytest, "diff"))
  }else{
    diff = character(0L)
  }
  failureTagContent <- paste0(c(call, diff), collapse = "\n")
  
  failureTag <- tag(
    name = "failure",
    attributes = failureTagAttr,
    content = list(failureTagContent)
  )
  tag(
    name = "testcase",
    attributes = attributes,
    content = list(failureTag)
  )
}