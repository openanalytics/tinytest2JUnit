
#' Test if single length character non NA.
#' @param x object to test.
#' @return `logical(1)`
#' @author ltuijnder
isSingleLengthCharNonNA <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}
