
#' Test if single length character non NA.
#' @param x object to test.
#' @return `logical(1)`
#' @author ltuijnder
isSingleLengthCharNonNA <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}


#' Convert any will character vector to a single length character vector 
#'
#' @param x a `character`
#' @return x a single-length character vector Non-NA
#' @examples
#' tinytest2JUnit:::charVecToSingleLength(c("Hello", "World")) # -> "HelloWorld"
#' tinytest2JUnit:::charVecToSingleLength(c("Hello", NA_character_)) # -> "HelloNA"
#' tinytest2JUnit:::charVecToSingleLength(character(0L))) # -> ""
charVecToSingleLength <- function(x) {
  if (length(x) == 0) return("")
  x[is.na(x)] <- "NA"
  if (length(x) == 1) return(x)
  return(paste0(x, collapse = ""))
}
