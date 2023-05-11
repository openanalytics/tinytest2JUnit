


foldersToTest <- system.file("example_tests", package = "tinytest2JUnit") |>
  list.dirs(full.names = TRUE, recursive = FALSE)

folderName <- system.file("example_tests", package = "tinytest2JUnit") |>
  list.dirs(full.names = FALSE, recursive = FALSE)

# Test that writeJUnit can deal with all the test folders defined in example_tests
for (i in seq_along(foldersToTest)) {
  
  tmpFile <- tempfile(fileext = ".xml")
  if(file.exists(tmpFile)) stop("File should not have existed!")
  
  testresults <- tinytest::run_test_dir(foldersToTest[i], verbose = F)

  expect_true(	
    tinytest2JUnit::writeJUnit(tinytests = testresults, file = tmpFile),
    info = paste0("writeJUnit() succeeded for directory: ", folderName[i])
  )
  expect_true(file.exists(tmpFile))
  
	  expect_equal(
	    readLines(tmpFile, n = 1),
	    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	  )
  
}

# Test that when overwrite = TRUE. The file is actually being overwritten.

tmpFile <- tempfile(fileext = ".xml")
if(file.exists(tmpFile)) stop("File should not have existed!")

randomTestFolder <- sample(foldersToTest, size  = 1)
testresults <- tinytest::run_test_dir(randomTestFolder, verbose = F)

writeJUnit(tinytests = testresults, file = tmpFile)
nLinesWrittenFirstTime <- length(readLines(tmpFile))

writeJUnit(tinytests = testresults, file = tmpFile, overwrite = TRUE)
nLinesWrittenSecondTime <- length(readLines(tmpFile))

expect_equal(
  nLinesWrittenFirstTime, nLinesWrittenSecondTime, 
  info = "Overwrite = TRUE does overwrite the file")

expect_error(writeJUnit(tinytests = testresults, file = tmpFile, overwrite = FALSE),
  info = "Overwrite = FALSE does indeed not overwrite a file if it already exists.")

# Test writeJUnit on empty tinytest results

testresults <- tinytest::test_package("tinytest2JUnit", testdir = file.path(system.file("example_tests/empty_test_folder", package =  "tinytest2JUnit")), verbose = F)
writeJUnit(tinytests = testresults, file = tmpFile, overwrite = TRUE)

expect_true(	
		writeJUnit(tinytests = testresults, file = tmpFile, overwrite = TRUE),
		info = "writeJUnit() succeeded for empty directory")
expect_true(file.exists(tmpFile))

expect_equal(
		readLines(tmpFile, n = 1),
		"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
)
