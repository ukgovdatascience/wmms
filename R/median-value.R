#' The median of a/b of each node where a/b is between the bounds
#'
#' A numeric value that is the median of the values of all nodes whose value is
#' between `bounds$low` and `bounds$high` (inclusive).  This is used as an
#' estimate of the true maximum possible value of the tree.  The bounds are the
#' known limits of the true maximum.  The value of a single node is `a / b` of
#' its own values `a` and `b`.
#'
#' @param `tree` (`environment`) The whole tree, originally created by
#'   [tree_from_edges()].
#' @param `bounds` A list of `low` and `high` numeric values between which the
#'   true maximum value of the tree is sought.  The bounds will initially be
#'   `list(low = -Inf, high = Inf)`.
#' @param `dfs_order` (`character`) A vector of node IDs in depth-first search
#'   order, from a `node$subtree_dfs$dfs`, created by [set_subtrees()].
#'
#' @return
#' A numeric value that is the median of the values of all nodes whose value is
#' between `bounds$low` and `bounds$high` (inclusive), to be used by [value()].

median_value <- function(tree, bounds, dfs_order) {
  # Traverse the nodes, leaves first, i.e. post-order
  values <- .Internal(vector("double", length(dfs_order)))
  i <- 0L
  for (node_id in rev(dfs_order)) {
    node <- tree[[node_id]]
    value <- node$a / node$b
    if (value >= bounds$low && value <= bounds$high) {
      i <- i + 1L
      values[i] <- value
    }
  }
  median_fast(values)
}
