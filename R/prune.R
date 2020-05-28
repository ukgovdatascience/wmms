#' Prune or merge nodes according to their value vs bounds of the true maximum
#'
#' Whereas `value()` simulates greedily pruning the tree to obtain its maximum
#' possible value, this algorithm really prunes the tree, but only when it can
#' be proved that a node is not part of the maximum.  This is part of a process
#' that is repeated until the tree obtains its true maximum.
#'
#' @details
#' * Leaf nodes whose value `a/b` is lower than `bounds$low` are pruned, because
#'   they will not be part of the maximum.
#' * Nodes (not only leaf nodes) whose value `a/b` is equal to or above
#'   `bounds$low`, and below (but not equal to) `bounds$high`, are kept.  They
#'   might yet be part of the maximum.
#' * Nodes (not only leaf nodes) whose value `a/b` is above `bounds$high` are
#'   'merged' into their parent, because they will be part of the maximum.
#' * If a non-leaf node's value `a/b` is lower than `bounds$low`, and it has
#'   exactly one child, then merge the child into this node, and reapply all
#'   these rules, because its value `a/b` has changed and it might now be a
#'   leaf, or have acquired more than one child.  If the only child exists, it
#'   is because its value `a/b` is between the bounds, and might be high enough
#'   to compensate for its parent's low value.
#'
#' To 'merge' a node into is parent:
#'
#' 1. Add the node's value `a` to the parent's value `a`
#' 2. Add the node's value `b` to the parent's value `b`
#' 3. Make any children of the node children of the parent instead.  Such
#'    children exist when their values `a/b` are between the bounds, so they
#'    have neither been pruned, nore been merged into their parent.
#'
#' Once a child has been pruned, it is no longer included in the `children`
#' environment of its parent.  However, the `parent` object of the child still
#' links to the parent, so it is still possible to know which child belonged to
#' which parent in the original tree.  The child still exists because it is
#' still in the the environment that is the overall tree.  It just won't be
#' reached from the root node.
#'
#' @param `tree` (`environment`) The whole tree, originally created by
#'   [tree_from_edges()].
#' @param `bounds` A list of `low` and `high` numeric values between which the
#'   true maximum value of the tree has been sought.  The bounds will initially
#'   be `list(low = -Inf, high = Inf)`.
#' @param `dfs_env` (`environment`) An environment containing an object called
#'   `dfs` that is a named list of `NULL` values, where the names are IDs of
#'   nodes in depth-first order.  Obtained from [set_subtrees()].
#'
#' @return
#' There is no return value. The tree is modified in place.

prune <- function(tree, bounds, dfs_env) {
  dfs_order <- names(dfs_env$dfs)
  # First: prune/merge children of the root of this subtree
  for (node_id in rev(dfs_order[-1])) {
    node <- tree[[node_id]]
    # Calculate the value and number of children
    value <- node$a / node$b
    is_low <- value < bounds$low
    n_children <- length(node$children)
    # If value is low, and there is exactly one child, then merge the child,
    # recalculate, and continue merging until either there are no more children,
    # there is more than one child, or the value is high.
    while (is_low && n_children == 1L) {
      # Merge the child
      child <- as.list(node$children)[[1]]
      merge_child_into_parent(child, dfs_env)
      # Recalculate
      value <- node$a / node$b
      is_low <- value < bounds$low
      n_children <- length(node$children)
    }
    # If value is still low, then, if there are (now) no children (node is a
    # leaf), then prune, otherwise skip.
    if (is_low) {
      if (n_children == 0L) {
        # Node is (now) a leaf, so prune by removing from parent's children
        .Internal(remove(node$id, node$parent$children, FALSE))
        dfs_env$dfs[[node$id]] <- NULL
        next
      }
      # Node isn't a leaf, so skip
      next
    }
    # If value is high, merge with parent, and reassign any children to their
    # grandparent.
    is_high <- value >= bounds$high
    if (is_high) {
      merge_child_into_parent(node, dfs_env)
      next
    }
  }
  # Now deal with the root of this subtree.  Possibly merge a child into it.
  # This is the same as the possible merge in prune_node() and is only repeated
  # here for performance reasons, to avoid recalculating value, is_low and
  # n_children more times than necessary.  Otherwise this would be a function.
  node <- tree[[dfs_order[1]]]
  # Calculate the value and number of children
  value <- node$a / node$b
  is_low <- value < bounds$low
  n_children <- length(node$children)
  # If value is low, and there is exactly one child, then merge the child,
  # recalculate, and continue merging until either there are no more children,
  # there is more than one child, or the value is high.
  while (is_low && n_children == 1L) {
    # Merge the child
    child <- as.list(node$children)[[1]]
    merge_child_into_parent(child, dfs_env)
    # Recalculate
    value <- node$a / node$b
    is_low <- value < bounds$low
    n_children <- length(as.list(node$children))
  }
  NULL
}
