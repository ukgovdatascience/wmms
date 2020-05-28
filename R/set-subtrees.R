#' Give each node a list of its descendants
#'
#' After finding the optimal subtree connected with the root, some subtrees will
#' probably have been pruned.  These are then optimised in their own right,
#' recursively, so that the value of adding the to the optimum subtree is known.
#' To recurse into subtrees, each node keeps a list of its descendants in
#' depth-first search order, so that a depth-first search search doesn't have to
#' be performed for every pruned subtree.  The list is wrapped in an
#' environment, so that when it is passed to functions, the functions can modify
#' it in place.
#'
#' @param `tree` (`environment`) Originally from [directed()].
#' @param `dfs_order` (`character`) A vector of node IDs in depth-first search
#'   order, originally from [directed()].
#'
#' @return
#' No value is returned.  The nodes are modified in place.

set_subtrees <- function(tree, dfs_order) {
  # For each node, create an empty list in an environment, where the list will
  # store IDs of descendants.
  empty_list <- list()
  for (node in as.list(tree, ordered = FALSE)) {
    subtree_dfs <- new.env(hash = FALSE) # Hash not worthwhile for most nodes
    subtree_dfs$dfs <- empty_list
    node$subtree_dfs <- subtree_dfs
  }
  # For each node, leaves first, prepend it to its own subtree, then prepend its
  # subtree to its parent's subtree.
  for (node_id in rev(dfs_order)) {
    node <- tree[[node_id]]
    subtree_dfs <- node$subtree_dfs
    self <- setNames(.Internal(vector("list", 1)), node_id) # named NULL
    # Prepend self to own subtree
    subtree_dfs$dfs <- c(self, subtree_dfs$dfs)
    # Prepend subtree to parent's subtree
    parent_subtree_dfs <- node$original_parent$subtree_dfs
    parent_subtree_dfs$dfs <- c(subtree_dfs$dfs, parent_subtree_dfs$dfs)
  }
  NULL
}
