% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/runTestDir.R
\name{runTestDir}
\alias{runTestDir}
\title{Run all the test files in a directory}
\usage{
runTestDir(
  dir = "inst/tinytest",
  at_home = FALSE,
  pattern = "^test.*\\\\.[rR]$",
  cluster = NULL,
  lc_collate = getOption("tt.collate", NA),
  ...
)
}
\arguments{
\item{dir}{\code{character(1)} path to directory}

\item{at_home}{\code{logical(1)} should local tests be run? By default FALSE. Unlike
\code{\link[tinytest:run_test_dir]{tinytest::run_test_dir()}} which is meant to be called in a local interactive context. This
function is meant to be called in a non-interactive CI environment, where we want to mimic the
behaviour of how tests would get run by R CMD Check.
See also \code{at_home} documentation in tinytest package.}

\item{pattern}{\code{character(1)} A regular expression that is used to find
scripts in \code{dir} containing tests (by default \code{.R} or \code{.r}
files starting with \code{test}).}

\item{cluster}{A \code{cluster} object to run the test files on. Note, it is
expected that the clusters has already been prepared. Most notable, the package to test
should already been loaded. \code{runTestDir} will load the package
"tinytest" for you into the clusters. See \code{\link[tinytest:run_test_dir]{tinytest::run_test_dir()}} for more details.}

\item{lc_collate}{See \code{\link[tinytest:run_test_dir]{tinytest::run_test_dir()}}.}

\item{...}{Arguments passed on to \code{\link[tinytest:run_test_file]{tinytest::run_test_file()}}}
}
\value{
A \code{tinytests2Junit} object to be provided to the \code{\link[=writeJUnit]{writeJUnit()}} function.
}
\description{
\code{\link[=runTestDir]{runTestDir()}} is a drop in replacement for \code{\link[tinytest:run_test_dir]{tinytest::run_test_dir()}} with the key
difference that errors thrown from within a test file are caught and get reported with a
a stacktrace in the JUnit report. In addition, some extra metrics are recored for the JUnit
report, such as: timestamp, test duration, hostname and if tests are disabled (see details for
more info).
}
\details{
\code{\link[=runTestDir]{runTestDir()}} is meant as a CI-friendly alternative to the native \code{\link[tinytest:run_test_dir]{tinytest::run_test_dir()}}.
It catches errors that are raised in the tests files and adds them as a "failed" \code{tinytest}
in the output.

\code{\link[tinytest:run_test_dir]{tinytest::run_test_dir()}} would have let the error bubble up, stop the testing process and
not report any failures from other tests. One is then also forced to look into the
logs of the CI to see what the error was. The output of \code{\link[=runTestDir]{runTestDir()}} in combination with
\code{\link[=writeJUnit]{writeJUnit()}} will present you the error in the JUnit togheter with a stack trace. Next to the
test results of the other files that ran without a problem.

If you prefer the behaviour of \code{\link[tinytest:run_test_dir]{tinytest::run_test_dir()}} you can still use it in combination
\code{\link[=writeJUnit]{writeJUnit()}}.

Caught errors are returned in the output as as sub-class of \code{tinytest} object. This is however
considred implemenation detail and can be subject to change.

Note, function arguments explicilty listed in \code{\link[tinytest:run_test_dir]{tinytest::run_test_dir()}} but not here can still
still be provided via \code{...}
}
\section{tinytests2JUnit}{

The returned object is a \code{tinytests2JUnit} object (note the plural). This object
contains additional info compared to a \code{tinytests} object that is used in the JUnit report.

The following additional info will get reported:
\itemize{
\item The timestamp per test file on when it got invoked.
\item The test duration per test file.
\item The system hostname per test file on where it got invoked. This is mainly of interests for
different \code{clusters}.
\item If a test file is disabled. A test file is considered disabled if no tests
occur with in the file.
It is then assumed that at the top of file some conditional statement
made the test file exist early.
}
}

\examples{
# Run tests with `tinytest`
dirWithTests <- system.file("example_tests/multiple_files",package = "tinytest2JUnit")
testresults <- runTestDir(dirWithTests)

writeJUnit(testresults) # Writes content to stdout
}
\seealso{
\itemize{
\item \code{\link[tinytest:run_test_dir]{tinytest::run_test_dir()}} for how the function is inteded to behave.
\item \code{\link[=writeJUnit]{writeJUnit()}} where it is expected that the output of this function to be provided to.
\item \code{\link[=testPackage]{testPackage()}} for an higher-level function to simply test a package.
}
}
