#' Faster median function
#'
#' This is a slimmed-down version of [median()] that doesn't do any checks and
#' only works on the data type we need.
#'
#' @examples
#' x <- runif(1000)
#' bench::mark(median(x), median_fast(x))
median_fast <- function(x) {
  n <- length(x)
  half <- (n + 1L) %/% 2L
  half_bounds <- half + 0L:1L
  if (n%%2L == 1L) {
    sort_fast(x)[half]
  } else {
    mean_fast(sort_partial_fast(x, partial = half_bounds)[half_bounds])
  }
}

sort_fast <- function(x) {
  x[.Internal(order(na.last = TRUE, decreasing = FALSE, x))]
}

sort_partial_fast <- function(x, partial) {
  .Internal(psort(x, partial))
}

mean_fast <- function(x) {
  .Internal(mean(x))
}
