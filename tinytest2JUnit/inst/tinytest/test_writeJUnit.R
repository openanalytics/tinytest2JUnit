


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
    writeJUnit(tinytests = testresults, file = tmpFile),
    info = paste0("writeJUnit() succeeded for directory: ", folderName[i])
  )
  expect_true(file.exists(tmpFile))
  
  expect_equal(
    readLines(tmpFile, n = 1),
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  )
  
}


# Test that when overwrite = TRUE. The file is actually being overwritten.

randomTestFolder <- sample(foldersToTest, size  = 1)
testresults <- writeJUnit(tinytests = testresults, file = tmpFile)

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