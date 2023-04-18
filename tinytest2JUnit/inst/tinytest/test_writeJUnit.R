
testresults <- tinytest::run_test_dir(system.file("example_tests", package="tinytest2JUnit"), verbose = F)


# Test that when overwrite = TRUE. The file is actually being overwritten.

tmpFile <- tempfile(fileext = ".xml")
if(file.exists(tmpFile)) stop("File should not have existed!")

writeJUnit(tinytests = testresults, file = tmpFile)
nLinesWrittenFirstTime <- length(readLines(tmpFile))

writeJUnit(tinytests = testresults, file = tmpFile, overwrite = TRUE)
nLinesWrittenSecondTime <- length(readLines(tmpFile))

expect_equal(
		nLinesWrittenFirstTime, nLinesWrittenSecondTime, 
		info = "Overwrite = TRUE does overwrite the file")

expect_error(writeJUnit(tinytests = testresults, file = tmpFile, overwrite = FALSE),
		info = "Overwrite = FALSE does indeed not overwrite a file if it already exists.")