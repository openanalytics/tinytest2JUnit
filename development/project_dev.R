

roxygen2::roxygenize("tinytest2JUnit")

library(tinytest)

# tiny test examples
out <- tinytest::run_test_dir(system.file("tinytest", package="tinytest"))
summary(out)
tinytest::run_test_dir(system.file("tinytest", package="tinytest"))

# possible ways to run tests on tinytest2JUnit
out1 <- tinytest::test_package("tinytest2JUnit", testdir = "inst/tinytest")	
out2 <- tinytest::run_test_dir(system.file("tinytest", package="tinytest2JUnit"))
out3 <- tinytest::test_all("tinytest2JUnit")

tmpFile1 <- tempfile(fileext = ".xml")
tmpFile2 <- tempfile(fileext = ".xml")
writeJUnit(out, tmpFile1)
writeJUnit(out2, tmpFile2)
xml1 <- xmlParse(tmpFile1)
xml2 <- xmlParse(tmpFile2)
expect_identical(xml1, xml2)
expect_equal(xml1, xml2)

#> expect_identical(xml1, xml2)
#----- FAILED[attr]: <-->
#		call| expect_identical(xml1, xml2)
#diff| TRUE 
#> expect_equal(xml1, xml2)
#----- PASSED      : <-->
#		call| expect_equal(xml1, xml2)
# Difference in duration!

res1 <- tinytest::run_test_file(system.file("tinytest/test_partial_skipped.R", package="tinytest2JUnit"))
res2 <- tinytest::run_test_file(system.file("tinytest/test_everything_skipped.R", package="tinytest2JUnit"))

# testing on reproducing testthat output
tmpFile <- tempfile(fileext = ".xml")
res1_out <- writeJUnit(res1, tmpFile)

# try to capture output of run_test_file
#out <- capture.output(tinytest::run_test_dir(system.file("tinytest", package="tinytest2JUnit")))
#skipped <- grepl("Exited", out)
out <- run_test_dir_all_info(system.file("tinytest", package="tinytest2JUnit"))
res1_out <- writeJUnit(out, tmpFile)
 

library(testthat)
devtools::test("tinytest2JUnit")

tdir <- tempdir()
out <- testthat::test_package("tinytest2JUnit", reporter = testthat::MultiReporter$new(list(testthat::SummaryReporter$new(file = file.path(tdir, "test-results.txt")),
						testthat::JunitReporter$new(file = file.path(tdir, "results.xml")))))
testthat::test_package("tinytest2JUnit", reporter = testthat::JunitReporter$new())
testthat::test_package("tinytest2JUnit", reporter = testthat::MultiReporter$new())


