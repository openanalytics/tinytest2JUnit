# Project: timytestToJunit
# 
# Author: ltuijnder
###############################################################################



#' Convert tinytest output to JUnit xml
#' 
#' Convert the tinytest output dataframe to JUnit xml. 
#' 
#' @details
#' Reference for JUnit XML format: https://llg.cubic.org/docs/junit/
#' 
#' @param df output
#' @return `character(n)` a character vector where each line represents a line in the .xml output.
#' @author ltuijnder
#' @export
convert_2_junit <- function(df){
  
  result = c("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
  
  
  
  return(result)
  
}
