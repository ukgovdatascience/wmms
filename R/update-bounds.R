#' Narrow the bounds by comparing the tree's value with an estimated maximum
#'
#' The true maximum value of the tree is sought between lower and upper bounds.
#'
#' @details
#' The true maximum value of the tree is sought between lower and upper bounds.
#' The bounds can be narrowed by first estimating the true maximum with
#' [median_value()], then greedily (but temporarily) pruning the tree to remove
#' nodes with values below that estimate, and then comparing the value of that
#' (temporarily) pruned tree with the estimate.  The pruning and valuing is done
#' in a single call to [value()].
#'
#' Depending on the `value` relative to the `estimate`:
#'
#' * The lower bound can always be raised to the value of the (temporarily) pruned
#'   tree.
#' * If the value of the (temporarily) pruned tree is equal to or below the
#'   estimate, then the upper bound is lowered to the estimate, because it can be
#'   proved that the estimate is an upper bound for the true maximum.
#'
#' @param `bounds` A list of `low` and `high` numeric values between which the
#'   true maximum value of the tree is sought.  The bounds will initially be
#'   `list(low = -Inf, high = Inf)`.
#' @param `estimate` (`numeric`) An estimate of the maximum possible value of the
#'   tree, from [median_value()].
#' @param `value` (`numeric`) The value of the tree when greedily pruned by
#'   removing nodes with values below `estimate`, from [value()].
#'
#' @return
#' An updated copy of `bounds`, to be used by [prune()].

update_bounds <- function(bounds, estimate, value) {
  if (value >= bounds$low) bounds$low <- value
  if (value <= estimate) bounds$high <- estimate
  bounds
}
