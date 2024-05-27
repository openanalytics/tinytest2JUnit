

#' Construct the JUnit `</testsuites>` tag
#' 
#' Convert the `tinytests2Junit` or `tinytests`-object containing test across 
#' possibly multiple files into a JUnit `</testsuites>` tag. More details are reported to the 
#' JUnit if a `tinytests2JUnit` object compared to the native `tinytests` object.
#' 
#' @details
#' Reference for JUnit XML format: https://llg.cubic.org/docs/junit/
#'
#' See [tinytests2Junit()] which additional info is recorded.
#' 
#' @param testResults `tinytests2Junit | `tinytests` object to convert into a JUnit XML object 
#'   Usually the result of [runTestDir()] for a `tinytests2JUnit` object or native `tinytests`
#'   produced by [tinytest::test_package()] or [tinytest::run_test_dir()].
#'
#' @return `XMLtag`: with tag-name = `</testsuites>`. This is the root of the JUnit XML document.
constructTestsuitesTag <- function(testResults) {
 
  stopifnot(inherits(testResults, "tinytests"))
  
  vctTestFiles <- vapply(
    testResults,
    function(tinytest) attr(tinytest, "file"),
    FUN.VALUE = character(1)
  )
  isFailure <- vapply(
    testResults,
    function(tinytest) isFALSE(tinytest) && !inherits(tinytest, "uncaught-error"),
    FUN.VALUE = logical(1)
  )
  isError <- vapply(
    testResults,
    function(tinytest) isFALSE(tinytest) && inherits(tinytest, "uncaught-error"),
    FUN.VALUE = logical(1)
  )
  
  attributes <- list(
    name = "tinytest results", 
    tests = length(testResults), 
    failures = sum(isFailure, na.rm = TRUE),
    errors = sum(isError, na.rm = TRUE),
    disabled = length(attr(testResults, "disabled"))
  )
  
  duration <- attr(testResults, "duration")
  if (is.numeric(duration) && !is.na(duration)) attributes$time <- as.character(duration)
  
  uFiles <- unique(vctTestFiles)
  testsuiteTags <- Map(
    f = constructTestsuiteTag,
    testsFile = lapply(uFiles, function(f) testResults[vctTestFiles == f]),
    id = seq_along(uFiles) - 1 # JUnit uses 0 based index.
  )
  tag(
    "testsuites",
    attributes = attributes,
    content = testsuiteTags
  )
}

#' Construct JUnit `</testsuite>` tag 
#' 
#' Construct the `</testsuite>` tag of a `tinytest`, given all the `tinytest` results 
#' from a single test file. 
#'
#' @details
#' In case a `tinytest2JUnit` is provided following additional info can be reported:
#' 
#' * testsuite duration.
#' * timestamp when the testsuite was performed.
#' * hostname where the testsuite was ran.
#' 
#' @param testsFile `tinytests2JUnit | tinytests` -object with all test 
#'    results of a specified test file. At least a single test is expected.
#' @param id `integer(1)` testsuite id.
#' 
#' @return `XMLtag`: with tag-name = `</testsuite>` 
#'   that contains all the test results per test file.
constructTestsuiteTag <- function(testsFile, id) {
  
  stopifnot(inherits(testsFile, "tinytests"))
  
  isFailed <- vapply(
    testsFile,
    function(tinytest) isFALSE(tinytest) && !inherits(tinytest, "uncaught-error"),
    FUN.VALUE = logical(1)
  )
  isError <- vapply(
    testsFile,
    function(tinytest) isFALSE(tinytest) && inherits(tinytest, "uncaught-error"),
    FUN.VALUE = logical(1)
  )
  fileName <- attr(testsFile[[1]], "file")
  fileNameWithoutExt <- tools::file_path_sans_ext(fileName) 
  attributes <- list(
    name = escapeXml(fileNameWithoutExt),
    id = id,
    tests = length(testsFile),
    failures = sum(isFailed, na.rm = TRUE),
    errors = sum(isError, na.rm = TRUE)
  )

  if (inherits(testsFile, 'tinytests2JUnit')) {
    attributes$hostname <- escapeXml(attr(testsFile, "fileHostnames")[fileName])
    attributes$time <- as.character(attr(testsFile, "fileDurations")[fileName])
    attributes$timestamp <- escapeXml(attr(testsFile, "fileTimestamps")[fileName])
  }
  
  tag(
    "testsuite",
    attributes = attributes,
    content = lapply(testsFile, constructTestcaseTag)
  )
}


#' Construct JUnit `</testcase>` tag 
#' 
#' Construct JUnit `</testcase>` tag based on a single `tinytest` result.
#' 
#' @param tinytest a `tinytest`-object representing an individual test case. 
#' @return `XMLtag`: with tag-name = `tinytest` and contains the test result per test.
constructTestcaseTag <- function(tinytest) {
  
  stopifnot(inherits(tinytest, "tinytest"))

  if (isTRUE(tinytest)) {
    testcaseTag <- passedTestcaseTag(tinytest)   
  } else if (isFALSE(tinytest) && !inherits(tinytest, "uncaught-error")) {
    testcaseTag <- failureTestcaseTag(tinytest)
  } else if (isFALSE(tinytest) && inherits(tinytest, "uncaught-error")) {
    testcaseTag <- errorTestcaseTag(tinytest)
  } else { # tinytest = NA = side-effect
    testcaseTag <- sideeffectTestcaseTag(tinytest)
  }
  return(testcaseTag)
}

#' Helper function to construct the name of a testcase 
#'
#' Helper function to construct the name of a testcase. Note, the charater is already xml escaped.
#' 
#' @param tinytest a `tinytest` object. (does not matter what result)
#' @return `character(1)` the testcase name to use for this tinytest object.
nameTestcase <- function(tinytest) {
  
  fst <- attr(tinytest, "fst")
  lst <- attr(tinytest, "lst")
  info <- attr(tinytest, "info")

  # Name = Line:{fst}->Line:{lst} : {info}
  name <- ""
  if (!is.na(fst)) {
    name <- paste0(name, "Line:", fst)
  }
  if (!is.na(lst) && (fst != lst)) {
    name <- paste0(name, "->Line:", lst)
  }
  if (!is.na(info)) {
    infoSplit <- strsplit(info[1], "\n")[[1]]
    name <- paste0(name, " : ", infoSplit[1])
  }
  if (nchar(name) == 0) name <- "unnamed"
  name <- escapeXml(name)
  return(name)
}

#' Helper function specifying the 'classname' attribute of the testcase tag.
#' 
#' Helper function specifying the 'classname' attribute of the testcase tag. 
#' Currently equal to the fileName. The classname is already xml escaped.
#' 
#' @param tinytest a `tinytest`-object representing an individual test case. 
#' @return `character(1)` being the 'classname'
classnameTestcase <- function(tinytest) {
  file <- attr(tinytest, "file")
  fileName <- tools::file_path_sans_ext(file) 
  escapeXml(fileName)
}

#' Construct a testcase-tag for a passed test.
#' 
#' @param tinytest a `tinytest` object already validated to be a "PASSED" test.
#' @return a `testase` `XMLtag`
passedTestcaseTag <- function(tinytest) {
  testcaseTag <- tag(
    name = "testcase",
    attributes = list(
      classname = classnameTestcase(tinytest),
      name = nameTestcase(tinytest),
      status = "PASSED"
    )
  )
  return(testcaseTag)
}


#' Helper function generating the body of a failure description tag!
#'
#' Helper function generating the body of a failure description tag! Attempts to mimic the print 
#' behaviour of a tinytest object.
#'
#' @param tinytest A `tinytest` objec that is considered failed!.
#' @return `character(1)` being the failure tag description body. This string is already propery
#'   xml escaped.
constructFailureDescription <- function(tinytest) {
  call <- attr(tinytest, "call")
  if (is.language(call)) {
    callDesc <- paste0('call| ', deparse(call))
  } else {
    callDesc <- character(0L)
  }

  diff <- attr(tinytest, "diff")
  if (!is.na(diff)) {
    diffDesc <- paste0('diff| ', diff) 
  } else {
    diffDesc <- character(0L)
  }
  
  info <- attr(tinytest, "info")
  if (!is.na(info)) {
    infoSplit <- strsplit(info[1], "\n")[[1]]
    infoDesc <- paste0('info| ', infoSplit) 
  } else {
    infoDesc <- character(0L)
  }

  failureDescription <- escapeXmlText(paste0(c(callDesc, diffDesc, infoDesc), collapse = "\n"))
  failureDescription
}

#' Construct a testcase-tag for a failed test.
#' 
#' @param tinytest a `tinytest` object already validated to be a "FAILURE" test.
#' @return a `testase` `XMLtag`
failureTestcaseTag <- function(tinytest) {
  
  short <- attr(tinytest, "short")
  diff <- attr(tinytest, "diff")
  failureTag <- tag(
    name = "failure",
    attributes = list(
      message = if (!is.na(diff)) escapeXml(diff[1]) else "",
      type = if (!is.na(short)) short else "failure"
    ),
    content = list(
      constructFailureDescription(tinytest)
    )
  )
  testcaseTag <- tag(
    name = "testcase",
    attributes = list(
      classname = classnameTestcase(tinytest),
      name = nameTestcase(tinytest),
      status = "FAILED"
    ),
    content = list(failureTag)
  )
  return(testcaseTag)
}

#' Construct a testcase-tag for an error test.
#'
#' @param tinytest a `tinytest` object already validated to be a "ERROR" test.
#' @return a `testase` `XMLtag`
errorTestcaseTag <- function(tinytest) {
  
  e <- attr(tinytest, "exception")
  if (!is.null(e$call)) {
    errorMsg <- paste0("Error in ", deparse(e$call[1]), ": ", e$message)
  } else {
    errorMsg <- paste0("Error: ", e$message)
  }

  formattedStacktrace <- attr(tinytest, "formattedStacktrace")
  if (!is.na(formattedStacktrace)) {
    stacktraceDesc <- paste0("Stacktrace:\n\n", attr(tinytest, "stacktrace"))
  } else {
    stacktraceDesc <- "No Stacktrace available!"
  }

  errorDescription <- paste0(
    paste0("Uncaught error in test file: ", basename(attr(tinytest, "file"))),
    "No other tests from the test file could be captured duo the error.",
    errorMsg,
    "\n",
    stacktraceDesc,
    collapse = "\n"
  )
  errorDescription <- escapeXmlText(errorDescription)
  errorTagMessage <- paste0("Uncaught error in test file: ", basename(attr(tinytest, "file")))

  errorTag <- tag(
    name = "error",
    attributes = list(
      message = escapeXml(errorTagMessage),
      type = "Error"
    ),
    content = list(errorDescription)
  )
  testcaseTag <- tag(
    name = "testcase",
    attributes = list(
      classname = classnameTestcase(tinytest),
      name = nameTestcase(tinytest),
      status = "FAILED"
    ),
    content = list(errorTag)
  )
  return(testcaseTag)
  
}

#' Construct a testcase-tag for a side-effect test.
#' 
#' @param tinytest a `tinytest` object already validated to be a "SIDE-EFFECT" test.
#' @return a `testase` `XMLtag`
sideeffectTestcaseTag <- function(tinytest) {
  
  name <- "SIDE-EFFECT detected: "

  # Not sure if fst and/or lst will be defined for SIDE-EFFECT but in either case just 
  # add it anyway.
  fst <- attr(tinytest, "fst")
  lst <- attr(tinytest, "lst")
  if (!is.na(fst)) {
    name <- paste0(name, ": L", fst)
  }
  if (!is.na(lst) && (fst != lst)) {
    name <- paste0(name, "-L", lst)
  }
  testcaseTag <- tag(
    name = "testcase",
    attributes = list(
      classname = classnameTestcase(tinytest),
      name = escapeXml(name),
      status = "SIDE-EFFECT"
    ),
    content = list(
      tag(
        name = "system-out",
        content = list(
          constructFailureDescription(tinytest)
        )
      )
    )
  )
  return(testcaseTag)
}
