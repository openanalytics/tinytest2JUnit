# Project: timytestToJunit
# 
# Author: ltuijnder
###############################################################################


#' tinytest the specified directory and save the result to JUnit
#' 
#' tinytest a specified with tinytest and save the results in JUnit xml format to the specified file. 
#' Or print in to stdout.
#' 
#' @param path `character(1)` file path to root of the package. Either a source root repositry or a 
#'   built package with test = TRUE.
#' @param file `character(1) | NULL` .xml file path to save the JUnit tests results to. Or NULL to print
#' the xml to stdout. By default NULL.
#' 
#' @return to be ignored.
#' @author ltuijnder
#' @export
run_and_convert <- function(dir = ".", file = NULL){
  
  test_results <- tinytest::run_test_dir(dir, verbose = FALSE, color = FALSE)
  duration <- attr(test_results,"duration")
  test_results_df <- as.data.frame(test_results)
}

