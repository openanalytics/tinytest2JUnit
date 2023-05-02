

roxygen2::roxygenize("tinytest2JUnit")

# tiny test examples

out <- tinytest::run_test_dir(system.file("tinytest", package="tinytest"), verbose=0)
summary(out)
tinytest::run_test_dir(system.file("tinytest", package="tinytest"))

tinytest::test_package("tinytest2JUnit", testdir = "inst/tinytest")	
tinytest::test_all(pkgdir = "tinytest2JUnit")
tinytest::run_test_dir(system.file("tinytest", package="tinytest2JUnit"))

res1 <- tinytest::run_test_file(system.file("tinytest/test_partial_skipped.R", package="tinytest2JUnit"))
res2 <- tinytest::run_test_file(system.file("tinytest/test_everything_skipped.R", package="tinytest2JUnit"))

tmpFile <- tempfile(fileext = ".xml")
res1_out <- writeJUnit(res1, tmpFile)


summary(out)

library(testthat)
devtools::test("tinytest2JUnit")

tdir <- tempdir()
out <- testthat::test_package("tinytest2JUnit", reporter = testthat::MultiReporter$new(list(testthat::SummaryReporter$new(file = file.path(tdir, "test-results.txt")),
						testthat::JunitReporter$new(file = file.path(tdir, "results.xml")))))
testthat::test_package("tinytest2JUnit", reporter = testthat::JunitReporter$new())

path <- file.path(pkg_root(), "project_pkg/tests/testthat")
test_file(file.path(getwd(), "tinytest2JUnit/tests/testthat/test-all_skipped.R"), reporter = default_reporter())
