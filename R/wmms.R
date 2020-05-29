#' Find the highest possible sum(a)/sum(b) of any subtree
#'
#' This is an exact algorithm to obtain a subtree, connected with the root, that
#' has the highest possible average value per node, which is `sum(a) / sum(b)`
#' of all the edges in the tree that remain after discarding low-value nodes.
#'
#' For details of the algorithm, see the documentation for `wmms`.
#'
#' @param `edges` A data frame of edges of the tree, with at least the columns
#'   `to` and `from` (integer IDs of nodes), and `a` and `b` (numeric).  The
#'   `from` and `to` IDs will be swapped where necessary to ensure that `to` is
#'   the one that is further from the root node.  Then the edge values `a` and
#'   `b` will be treated as belonging to the node rather than to the edge.
#'   Passed to [tree_from_edges()].
#' @param `root_id` (`numeric`) The ID of the root node of the tree.  Passed to
#'   [directed()] and other functions.
#'
#' @return
#' The original `edges` data frame, with the `from` and `to` values swapped
#' where necessary to ensure the edges are directed away from the root node, and
#' with the additional columns:
#'
#' * `ancestor` Of all the nodes that a node's value is averaged with, the ID of
#'   ancestor that is closest to the root.  All the nodes between this edge and
#'   that ancestor have the same average value, and there might be other
#'   descendants of that ancestor that do too.
#' * `value` The average value of all the descendants of the `ancestor` that are
#'   averaged together by `sum(a) / sum(b)`.  An nodes's `value` is less than
#'   `average` if the node isn't part of the maximum subtree. But it is still
#'   the highest possible for that node if it were added to the maximum subtree
#'   with any others in its set.
#'
#'   Because there is still exactly one node per edge, the node values can be
#'   interpreted as edge values again.
#' @export

weighted_maximum_mean_subtrees <- function(edges, root_id) {
  # Convert root_id to character to use as an environment name.
  root_id <- as.character(root_id)
  # Convert the edgelist into a tree of nodes, represented as environments.
  tree <- tree_from_edges(edges)
  # Ensure the tree is directed, and obtain a depth-first search order of nodes
  # to loop over.  The tree is modified in place.
  d <- directed_depth_first(tree, edges, root_id)
  edges <- d$edges
  dfs_order <- d$dfs_order
  not_root_id <- dfs_order[-1]
  # Give each node a list of itself and its descendants.
  set_subtrees(tree, dfs_order)
  # Give the children of the root proper `$a` and `$b` values, so that if they
  # have no children of their own, `propagate_value()` won't assign them a
  # zero-length value from their non-existant `$a` and `$b`.
  for (node in as.list(tree[[root_id]]$original_children)) {
    node$a <- node$original_a
    node$b <- node$original_b
  }
  # Mark the depth of the nodes in the tree before optimisation
  tree[[root_id]]$depth <- 0L # Initialise the depth of the root node
  for (node_id in not_root_id) {
    node <- tree[[node_id]]
    node$depth <- node$original_parent$depth + 1L
  }
  # Prune subtrees to maximise their `sum(a) / sum(b)`.  In depth-first order,
  # so that any sub-subtrees that are pruned will subsequently be optimised in
  # their own right.
  for (node_id in not_root_id) {
    node <- tree[[node_id]]
    # If it is the first node of a subtree that hasn't yet been optimised, and
    # is not a leaf.
    if (!node$merged && length(node$subtree_dfs$dfs) != 1L) {
      weighted_maximum_mean_subtree(tree = tree, node$subtree_dfs)
    }
  }
  # Propagate node values down from the children of the root.
  propagate_value(tree, dfs_order)
  # Return the original edgelist, now directed and with `ancestor` and `value`
  # columns to describe the tree's final state.
  report_tree(d$edges, tree)
}

#' Maximise one subtree
#'
#' After preparing the tree by making it directed and finding a depth-first
#' search order, [weighted_maximum_mean_subtrees()] applies this function
#' recursively to nodes that haven't yet been merged into an optimum subtree.
#'
#' @param `dfs_env` (`environment`) An environment containing an object called
#'   `dfs` that is a named list of `NULL` values, where the names are IDs of
#'   nodes in depth-first order.  Obtained from [set_subtrees()].
#' @param `tree` (`environment`) The whole tree, originally created by
#'   [tree_from_edges()].
#'
#' @return
#' There is no return value.  The `tree` is modified in place.

weighted_maximum_mean_subtree <- function(tree, dfs_env) {
  # (re)set the nodes in the subtree to their original state.
  restore_subtree(tree, names(dfs_env$dfs))
  # The algorithm searches for the true value between two bounds.  Begin with
  # bounds infinitely wide.
  bounds <- list(low = -Inf, high = Inf)
  # Then loop until the maximum is achieved, which will be when the root has
  # zero children.
  while (length(dfs_env$dfs) > 1L) { # At 1, only the subtree's root is left.
    dfs_order <- names(dfs_env$dfs)
    # Estimate the true maximum of sum(a)/sum(b) of a rooted subtree as the
    # median of the a/b values of each node, discarding any a/b that is
    # outside the bounds.
    estimate <- median_value(tree, bounds, dfs_order)
    # Calculate the value of subtree obtained by greedily pruning to achieve
    # the estimate.
    greedy_value <- value(tree, estimate, dfs_order)
    # The greedy value rules out part of the search space, depending on which
    # side of the estimate it is.  So update the bounds.
    bounds <- update_bounds(bounds, estimate, greedy_value)
    # It's now safe to prune leaf nodes whose a/b is below the bounds, and to
    # combine other nodes whose a/b is above the bounds with their parent.
    prune(tree, bounds, dfs_env)
  }
  NULL
}
