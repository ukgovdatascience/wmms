#' Propagate values from parents to children (mutates the tree)
#'
#' The value of a node is the the values of its ancestor, with which it has been
#' averaged.  This function propagates the values down the tree from ancestors
#' to descendants.
#'
#' @param `tree` (`environment`) Originally created by [tree_from_edges()].
#' @param `dfs_order` (`character`) A vector of node IDs in depth-first search
#'   order.
#'
#' @return
#' There is no return value. Nodes are modified in place.

propagate_value <- function(tree, dfs_order) {
  for (node_id in dfs_order[-1]) {
    node <- tree[[node_id]]
    if (node$merged) {
      parent <- node$parent
      node$value <- parent$value
      node$ancestor_id <- parent$ancestor_id
      next
    }
    # Not a merged node, so has its own value
    node$value <- node$a / node$b
    node$ancestor_id <- node$id
  }
  NULL
}
