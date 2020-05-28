#' Restore a node to its original state
#'
#' When the algorithm returns to a subtree that was pruned, it must return the
#' node's `parent`, `children` and values `a` and `b` to their original state.
#' This is done by copying `original_*` values.  It is also done before the
#' first pass of the algorithm, because nodes are created with only `original_*`
#' values.
#'
#' @param `tree` (`environment`) Originally created by [tree_from_edges()].
#' @param `dfs_order` (`character`) A vector of node IDs in depth-first search
#'   order, from a `node$subtree_dfs$dfs`, created by [set_subtrees()].
#'
#' @return
#' No value is returned.  The node is modified in place.

restore_subtree <- function(tree, dfs_order) {
  for (node_id in dfs_order) {
    node <- tree[[node_id]]
    node$parent <- node$original_parent
    node$a <- node$original_a
    node$b <- node$original_b
    node$merged <- FALSE
    # Create a new container environment of the same child environments.
    node$children <- list2env(as.list(node$original_children, ordered = FALSE))
  }
  NULL
}
