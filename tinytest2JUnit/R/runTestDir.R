#' @importFrom parallel makeCluster clusterExport clusterCall clusterEvalQ
#' @importFrom utils getSrcFilename getSrcLocation getSrcDirectory tail getFromNamespace
#' @importFrom tools file_path_sans_ext
NULL

#' Help function to generate the formatted string for a single stack frame.
#'
#' Help function to generate the formatted string for a single stack frame.
#' 
#' @param framecall `character(n)`: deparsed call for the given stack. Each element corresponds to 
#'    a line.
#' @param frameN `integer(1)`: frame nummer.
#' @param hasSrcInfo `logical(1)`: Does the call have any source info? 
#' @param dirName `character(1)`: the directory name of the source file.
#' @param fileName `character(1)`: filename of the source. Value ignored if hasSrcInfo=TRUE.
#' @param lineNr `character(1)`: linenr in the source where the call occured..
#'    Value ignored if hasSrcInfo=TRUE.
#' 
#' @return `characer(1)` the formatted character string containing info of a single frame in the 
#'   stackstrace
#'
#' @details
#' For a given frame in the stack the string is formatted as follows (substitute the arguments 
#'  between the curly braces)
#' \code{
#' {frameN}| {call[1]}
#' {frameN}| {call[2]}
#' {frameN}| {call[3]}
#' {frameN}| {call[3]}
#' ---> at File={dirName/fileName} Line={line}:
#' }
#' 
#' For example for only a single line error:
#' \code{
#' 1: stop("This is a crash")
#' ---> at File=R/my_r_code_file.R Line=234
#' }
#'
#' Currently all call lines are printed for a given stack. 
#' The last line with source file info only printed if hasSrcInfo=TRUE. Else it is ommited. 
formattedFrame <- function(framecall, frameN, hasSrcInfo, dirName, fileName, lineNr) {
  prefixCall <- paste0(frameN, "| ")
  result <- paste(prefixCall, framecall, collapse = "\n")
  if (hasSrcInfo) {
    result <- paste0(
      result, "\n", 
      "---> at File=", file.path(dirName, fileName), " Line=", lineNr
    )
  }
  return(result)
}

#' Get formatted stack trace for an uncaught error from a tinytest test file.
#' 
#' getFormattedStacktrace is a helper function that formats stacktrace for uncaught errors from a 
#' tinytest run file. 
#' 
#' @details 
#' This function assumes that it directly called from a withCallingHandler 
#' error handling function! This fact is then used to remove the calling handler info from the 
#' stack such that stack directly starts from where the error was thrown.
#' 
#' The function also removes the calls from the stack that involve 
#' executing the `test_file`. The internals of runTestDir and tinytest are not of intererst. 
#' And the highest level of the stack to consider is the top level of the test_file.
#' 
#' Note, this does mean that errors that occur on the top-level of the test file will not have a 
#' a stacktrace!
#' For example: "Error: object 'x' not found" where x is attempted to be resolved 
#' at the root levels
#' 
#' @return `character(1)` a single length character string suitable to be printed to the end-user.
#'   In case of no stakctrace (eg the error occured at root level of the script) NA_character_ 
#'   is returned!
getFormattedStacktrace <- function() {
  trace <- .traceback(4)
  hasSrcInfo <- vapply(trace, function(frame) !is.null(attr(frame, "srcref")), logical(1))
  fileNames <- lapply(trace, utils::getSrcFilename)
  lineNr <- lapply(trace, utils::getSrcLocation)
  dirNames <- lapply(trace, utils::getSrcDirectory)
  result <- Map(
    f = formattedFrame,
    framecall = trace,
    frameN = seq_along(trace),
    hasSrcInfo = hasSrcInfo,
    dirName = dirNames,
    fileName = fileNames,
    lineNr = lineNr
  )

  # Remove parts of the stack that involve the internals of tinytest and tinytest2JUnit. 
  isFrameProvokingTest <- vapply(
    X = trace,
    FUN = function(frame) {
      # Note this stack depeneds on how we call the tinytest::run_test_file( !
      startsWith(as.character(frame[1]), "tinytest::run_test_file(file = file,")
    },
    FUN.VALUE = logical(1)
  )

  # If internals of tinytest change: simply default back to showing whole stacktrace
  if (any(isFrameProvokingTest)) {
    # There should be only 1 but you never known...
    indx <- utils::tail(which(isFrameProvokingTest), n = 1)

    # Remove tinytest internals. If these ever change: default to the whole stack
    if (indx > 2) {

      oneStackDeeper <- as.character(trace[[indx - 1]])
      twoStackDeeper <- as.character(trace[[indx - 2]])
      internalsTinytest <- "eval(expr, envir = e)"
      internalIsAsExpected <- (oneStackDeeper == internalsTinytest &&
        twoStackDeeper == internalsTinytest)
      if (internalIsAsExpected) {
        if (indx == 3) return(NA_character_) # No stacktrace
        result <- result[1:(indx - 3)] 
      }
    }
  }
  
  # Seperate the frame in the printing with a blank line. To improve readability
  paste0(
    vapply(X = result, FUN = `[[`, 1, FUN.VALUE = character(1)),
    collapse = "\n\n"
  )
}

#' tinytestJUnit test results
#'
#' An object of class `tinytests2JUnit`. Note the plurar. A subclass of [tinytest::tinytests()] 
#' containing extra info recordings that are used in the export to JUnit.
#'
#' @param x `tinytests2JUnit` object to subset. 
#' @param i object to subset the `x` with. 
#'
#' @details 
#' Following details are recorded when running the tests files and stored as additional attributes 
#' to the object:
#' 
#' * **fileDurations**: `named-numeric(n)`. Names = filename of tests files, value = duration 
#'   in seconds on how long the test file took to run.
#' * **fileTimestamps**: `named-character(n)`. Names = filename of tests files, value = timestamp 
#'   when the test was invoked.
#' * **fileHostnames**: `named-character(n)`. Names = filename of tests files, value = The hostname 
#'   of the system that ran the tests. (Usefull in combination with clusters). 
#' * **disabled**: `character`. A character vector of filenames where no tests were ran. 
#'    They are flagged as disabled tests.
#' 
#' @aliases tinytests2JUnit
#' 
#' @export 
#' @rdname tinytests2JUnit 
`[.tinytests2JUnit` <- function(x, i) {
  r <- unclass(x)[i]
  files <- unique(vapply(r, attr, "file", FUN.VALUE = character(1)))
  structure(
    r,
    class = c("tinytests2JUnit", "tinytests"),
    duration = NULL,
    fileDurations = attr(x, 'fileDurations')[files],
    fileTimestamps = attr(x, 'fileTimestamps')[files],
    fileHostnames = attr(x, 'fileHostnames')[files],
    disabled = attr(x, 'disabled')
  )
}

#' Internal wrapper arround tinytest::run_test_file
#' 
#' Internal wrapper arround [tinytest::run_test_file()] that records the test duration and 
#' catches uncaught errors and logs the stacktrace of where the error occured. 
#'
#' @details 
#' The response is a subclass of the `tinytests` object called: `tinytests2Junit` 
#' object which captures additional info for the reporting to JUnit:
#' 
#' * Duration to run the file.
#' * Timestamp when the test was run.
#' * hostname of the computer where it was ran on.
#' 
#' The caught error is turned into a subclass uncaught-error of tinytest. This is implementation 
#' detail and only to be understood by constructJUnitTag.
#'
#' If an error occured it is captured and `uncaught-error` object (subclass of `tinytest`) is 
#' returned in the `tinytests` object.
#' This tinytest object represents a "failed" tests that will get reported as an Error in the 
#' JUnit. Various aspects of the error are also captured like the the stacktrace.
#' 
#' @param file `character(1)` test file to run. 
#' @param ... arguments passed on to [tinytest::run_test_file()] 
#'
#' @return a `tinytests2JUnit` object (being a subclass of `tinytest` object).
#' @importFrom tinytest tinytest run_test_file
runTestFile <- function(file, ...) { 

  formattedStacktrace <- NA_character_
  timeStart <- Sys.time()
  testOutput <- tryCatch(
    # Catch safe the stacktrace where the uncaught error is signaled using 'withCallingHandlers'
    expr = withCallingHandlers(
      expr = tinytest::run_test_file(file = file, ...),
      error = function(e) formattedStacktrace <<- getFormattedStacktrace()
    ),
    error = function(e) {
      if (!is.null(e$call)) {
        errorPrint <- paste0("Error in ", deparse(e$call)[1], ": ", e$message)
      } else {
        errorPrint <- paste0("Error: ", e$message)
      }
      info <- paste(
        paste0("Uncaught error in test file: ", basename(file)),
        errorPrint,
        sep = "\n"
      )
      errorTest <- tinytest::tinytest(
        result = FALSE,
        call = e$call,
        diff = "No test captured since an error occured.",
        info = info,
        file = basename(file), 
        exception = e,
        formattedStacktrace = formattedStacktrace
      )
      class(errorTest) <- c("uncaught-error", "tinytest") # subclass
      return(structure(list(errorTest), class = "tinytests"))
    }
  )
  timeEnd <- Sys.time()

  # Take by preference the file defintion internally used by tinytest
  file <- if (length(testOutput) != 0) attr(testOutput[[1]], "file") else basename(file)

  fileDurations <- as.numeric(timeEnd) - as.numeric(timeStart)
  names(fileDurations) <- file 
  attr(testOutput, "fileDurations") <- fileDurations

  fileTimestamps <- strftime(timeStart, "%Y-%m-%dT%H:%M:%S%z")
  names(fileTimestamps) <- file
  attr(testOutput, "fileTimestamps") <- fileTimestamps

  fileHostnames <- Sys.info()['nodename']
  names(fileHostnames) <- file
  attr(testOutput, "fileHostnames") <- fileHostnames 

  attr(testOutput, "disabled") <- if (length(testOutput) == 0) file else character(0L)
  
  class(testOutput) <- c('tinytests2JUnit', class(testOutput))
  return(testOutput)
}

#' Run all the test files in a directory
#'
#' [runTestDir()] is a drop in replacement for [tinytest::run_test_dir()] with the key 
#' difference that errors thrown from within a test file are caught and get reported with a 
#' a stacktrace in the JUnit report. In addition, some extra metrics are recored for the JUnit 
#' report, such as: timestamp, test duration, hostname and if tests are disabled (see details for 
#' more info).
#' 
#' @param dir `character(1)` path to directory
#' @param at_home `logical(1)` should local tests be run? By default FALSE. Unlike 
#'   [tinytest::run_test_dir()] which is meant to be called in a local interactive context. This 
#'   function is meant to be called in a non-interactive CI environment, where we want to mimic the
#'   behaviour of how tests would get run by R CMD Check. 
#'   See also `at_home` documentation in tinytest package.
#' @param pattern `character(1)` A regular expression that is used to find
#'   scripts in \code{dir} containing tests (by default \code{.R} or \code{.r}
#'   files starting with \code{test}).
#' @param cluster A `cluster` object to run the test files on. Note, it is 
#'   expected that the clusters has already been prepared. Most notable, the package to test 
#'   should already been loaded. `runTestDir` will load the package 
#'   "tinytest" for you into the clusters. See [tinytest::run_test_dir()] for more details.
#' @param lc_collate See [tinytest::run_test_dir()].
#' @param ... Arguments passed on to [tinytest::run_test_file()]
#' 
#' @return A `tinytests2Junit` object to be provided to the [writeJUnit()] function.
#' 
#' @details
#' [runTestDir()] is meant as a CI-friendly alternative to the native [tinytest::run_test_dir()]. 
#' It catches errors that are raised in the tests files and adds them as a "failed" `tinytest` 
#' in the output. 
#'
#' [tinytest::run_test_dir()] would have let the error bubble up, stop the testing process and 
#' not report any failures from other tests. One is then also forced to look into the 
#' logs of the CI to see what the error was. The output of [runTestDir()] in combination with 
#' [writeJUnit()] will present you the error in the JUnit togheter with a stack trace. Next to the 
#' test results of the other files that ran without a problem. 
#' 
#' If you prefer the behaviour of [tinytest::run_test_dir()] you can still use it in combination 
#' [writeJUnit()].
#'
#' Caught errors are returned in the output as as sub-class of `tinytest` object. This is however 
#' considred implemenation detail and can be subject to change.
#' 
#' Note, function arguments explicilty listed in [tinytest::run_test_dir()] but not here can still
#' still be provided via `...`
#' 
#' @section tinytests2JUnit:
#' The returned object is a `tinytests2JUnit` object (note the plural). This object 
#' contains additional info compared to a `tinytests` object that is used in the JUnit report.
#' 
#' The following additional info will get reported:
#' 
#' * The timestamp per test file on when it got invoked. 
#' * The test duration per test file.
#' * The system hostname per test file on where it got invoked. This is mainly of interests for 
#'   different `clusters`. 
#' * If a test file is disabled. A test file is considered disabled if no tests 
#'   occur with in the file. 
#'   It is then assumed that at the top of file some conditional statement 
#'   made the test file exist early.
#'
#' @seealso 
#' * [tinytest::run_test_dir()] for how the function is inteded to behave.
#' * [writeJUnit()] where it is expected that the output of this function to be provided to.
#' * [testPackage()] for an higher-level function to simply test a package.
#' 
#' @export 
#' @examples 
#' # Run tests with `tinytest`
#' dirWithTests <- system.file("example_tests/multiple_files",package = "tinytest2JUnit")
#' testresults <- runTestDir(dirWithTests)
#' 
#' writeJUnit(testresults) # Writes content to stdout
runTestDir <- function(
  dir = "inst/tinytest", 
  at_home = FALSE,
  pattern = "^test.*\\.[rR]$",
  cluster = NULL,
  lc_collate = getOption("tt.collate", NA),
  ...
) {

  t0 <- Sys.time()

  testfiles <- dir(dir, pattern = pattern, full.names = TRUE)
  testfiles <- localeSort(testfiles, lc_collate)

  # If internals change do not crash
  try(setCallWd <- utils::getFromNamespace("set_call_wd", "tinytest")) 
  if (!inherits(cluster, "cluster")) {
    # set pwd here, to save time in run_test_file.
    oldwd <- getwd()
    try(setCallWd(oldwd)) 
    on.exit({
      setwd(oldwd)
      try(setCallWd(oldwd))
    })
    setwd(dir)  
    testOutput <- lapply(
      X = basename(testfiles),
      FUN = runTestFile,
      at_home = at_home,
      ...
    )
  } else {
    parallel::clusterEvalQ(cl = cluster, library(tinytest))           
    testOutput <- parallel::parLapply(
      cl = cluster,
      X = testfiles,
      fun = runTestFile,
      at_home = at_home,
      ...
    )
  }

  fileDurations <- unlist(lapply(testOutput, attr, 'fileDurations'), recursive = FALSE)
  fileTimestamps <- unlist(lapply(testOutput, attr, 'fileTimestamps'), recursive = FALSE)
  fileHostnames <- unlist(lapply(testOutput, attr, 'fileHostnames'), recursive = FALSE)
  disabled <- unlist(lapply(testOutput, attr, 'disabled'), recursive = FALSE)
  if (length(disabled) == 0) disabled <- character(0L) # Since: unlist(list()) -> NULL

  td <- abs(as.numeric(Sys.time()) - as.numeric(t0))
  structure(
    unlist(testOutput, recursive = FALSE),
    class = c("tinytests2JUnit", "tinytests"),
    duration = td,
    fileDurations = fileDurations,
    fileTimestamps = fileTimestamps,
    fileHostnames = fileHostnames,
    disabled = disabled 
  )
}


# Copied over from tinytest
localeSort <- function(x, lcCollate = NA, ...) {
  if (is.na(lcCollate)) return(sort(x, ...))

  # catch current locale
  oldCollate <- Sys.getlocale("LC_COLLATE")

  # set to user-defined locale if possible, otherwise sort using current locale 
  colset <- tryCatch(
    expr = {
      Sys.setlocale("LC_COLLATE", lcCollate)
      TRUE
    }, 
    warning = function(e) { 
      msg <- sprintf("Could not sort test files in 'C' locale, using %s\n", oldCollate)
      message(paste(msg, e$message, "\n")) 
      FALSE
    }, 
    error = warning
  )
  out <- sort(x)

  # reset to old locale
  if (colset) Sys.setlocale("LC_COLLATE", oldCollate)
  out
}
