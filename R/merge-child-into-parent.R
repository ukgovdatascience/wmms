#' Merge a child node into its parent
#'
#' Nodes that are only-children may be merged into their parents, because
#' the matter of whether they are in the optimum tree depends entirely on
#' whether their parents are.
#'
#' @details
#' 1. Their values `a` and `b` are added to the parent's values `a` and `b`.
#' 2. They are removed from the parent's `children` environment.
#' 3. Their children, if any, are added to the parent's `children`
#'    environment (their grandparent).
#' 4. They are removed from the depth-first search order.
#' 5. They are given a value `merged <- TRUE` for use by [propagate_value()],
#'    which applies the averaged value of the eventual ancestor to the node.
#'
#' @param `node` (`environment`) The node to be subsumed by its parent.
#' @param `dfs_env` (`environment`) An environment containing an object called
#'   `dfs` that is a named list of `NULL` values, where the names are IDs of
#'   nodes in depth-first order.  See [set_subtrees()].
#'
#' @return
#' There is no return value. The tree is modified in place.

merge_child_into_parent <- function(child, dfs_env) {
  parent <- child$parent
  # Add the child's values to the parent
  parent$a <- parent$a + child$a
  parent$b <- parent$b + child$b
  # Reassign former child's children to the parent
  for (grandchild in as.list(child$children)) {
    # We don't need to remove the grandchild from the child, because the child
    # will no longer be traversed once it has been removed from its parent's
    # children and the depth-first search.
    parent$children[[grandchild$id]] <- grandchild   # Add grandchild to its grandparent
    grandchild$parent <- parent                      # Assign grandparent to grandchild
  }
  # Remove the child from its parent's children, and from the depth-first
  # search.
  .Internal(remove(child$id, parent$children, FALSE))
  dfs_env$dfs[[child$id]] <- FALSE
  # Mark the child as merged
  child$merged <- TRUE
  NULL
}
