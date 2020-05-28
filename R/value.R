#' The value of sum(a)/sum(b) of a tree omitting nodes below a cutoff
#'
#' This is a greedy algorithm to obtain a tree with a high average value, which
#' is `sum(a) / sum(b)` of all the nodes in the tree that remain after
#' temporarily discarding low-value nodes.  The tree is not modified in this
#' process.
#'
#' @details
#' Nodes are traversed in post-order (leaves first).
#'
#' * Nodes whose value `a / b` is below the cutoff are discarded by not adding
#'   their values `a` and `b` to their parents' values `a` and `b`.
#' * Nodes whose value `a / b` is above the cutoff add their value `a` to their
#'   parent's value `a`, and their value `b` to their parents' value `b`.
#'
#' Hence by the time the root node is reached, its `a` is now effectively
#' `sum(a)` of the undiscarded descendants, and similarly its `b` is `sum(b)` of
#' the undiscarded descendants, so its final value `a / b` is effectively
#' `sum(a) / sum(b`)`.
#'
#' @param `tree` (`environment`) The whole tree, originally created by
#'   [tree_from_edges()].
#' @param `cutoff` (`numeric`) An estimate of the true maximum possible value of
#'   the tree, used to greedily discard nodes.  Obtained from [median_value()].
#' @param `dfs_order` (`character`) A vector of node IDs in depth-first search
#'   order, from a `node$subtree_dfs$dfs`, created by [set_subtrees()].
#'
#' @return
#' * `value` (`numeric`) The value of the tree if it were pruned greedily by
#' this algorithm, to be used by [update_bounds()].

value <- function(tree, cutoff, dfs_order) {
  # Traverse the nodes twice.
  # First time: initialise the subtotals `sub_a` and `sub_b` to the actual `a`
  # and `b` of each node.  The subtotals will be incremented instead of `a` and
  # `b` themselves, because this is a temporary calculation.
  for (node_id in dfs_order) {
    node <- tree[[node_id]]
    node$sub_a <- node$a
    node$sub_b <- node$b
  }
  # Second time: leaves first, calculate and propagate values.
  # [-1] omits the root node of this subtree, because it can't propagate its
  # value to its parent.
  for (node_id in rev(dfs_order[-1])) {
    node <- tree[[node_id]]
    # Calculate the temporary value
    value <- node$sub_a / node$sub_b
    # Skip if the value is below the cutoff
    if (value < cutoff) next
    # Otherwise add a and b to the parent
    parent <- node$parent
    parent$sub_a <- parent$sub_a + node$sub_a
    parent$sub_b <- parent$sub_b + node$sub_b
  }
  # Return the value of the root of this subtree
  subroot <- tree[[dfs_order[1]]]
  subroot$sub_a / subroot$sub_b
}
