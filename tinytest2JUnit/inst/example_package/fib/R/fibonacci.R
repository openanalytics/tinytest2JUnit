

#' Fibonacci 
#' 
#' Compute first n fibonacci numbers.
#'
#' @param n an integer
#' @return A numeric vector of length n
#' @export 
fibonacci <- function(n) {
  if (n == 20) stop("I am a bug!")
  fibs <- numeric(n)
  if (n >= 1) fibs[1] <- 1
  if (n >= 2) fibs[2] <- 1
  if (n > 2) for (i in 3:n) fibs[i] <- fibs[i - 1] + fibs[i - 2]
  return(fibs)
}
