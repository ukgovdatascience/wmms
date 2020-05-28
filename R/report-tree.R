#' Report the final state of the tree
#'
#' Takes the directed edges from [directed()], and the maximised `tree`, and
#' appends the tree values to the edges. The columns `from` and `to` are
#' converted back to `numeric`, which is how they would have been when they were
#' given to `maximum_average_values()`.
#'
#' @param `edges` (`data frame`) Originally created by [directed()].
#' @param `tree` (`environment`) Originally created by [tree_from_edges()].
#'
#' @return
#' A data frame, one row per node.  The same columns as `edges` (see
#' [directed()]), plus:
#'
#' * `depth` The depth of the node in the original tree, before optimisation.
#' * `ancestor` Of all the nodes that this node's value is averaged with, the ID
#'    of ancestor that is closest to the root.  All the nodes between this node
#'    and that ancestor have the same average value, and there might be other
#'    descendants of that ancestor that do too.
#' * `value` The average value of all the descendants of the `ancestor` that are
#'   averaged together by `sum(a) / sum(b)`.

report_tree <- function(edges, tree) {
  n <- nrow(edges)
  depth    <- .Internal(vector("integer", n))
  ancestor <- .Internal(vector("character", n))
  value    <- .Internal(vector("double", n))
  i <- 0L
  for (node_id in as.character(edges$to)) {
    i <- i + 1L
    node <- tree[[node_id]]
    depth[i] <- node$depth
    ancestor[i] <- node$ancestor_id
    value[i] <- node$value
  }
  edges$depth <- depth
  edges$ancestor <- as.double(ancestor)
  edges$value <- value
  edges
}
