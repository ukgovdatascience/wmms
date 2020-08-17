#' Create a tree of environments from a dataframe of edges
#'
#' Create a tree from a data frame, one row per edge.
#'
#' @details
#' Create a tree from a data frame, one row per edge, with the columns:
#'
#' * `from` ID of a node.
#' * `to` ID of a child of `from`.
#'
#' The edges don't have to be of a directed tree.  The tree will be made
#' directed later by [directed()].
#'
#' For each row, an environment is created that contains the `id` of that row.
#' The environment also contains another environment, `children`, which contains
#' an environment for each child node.  Finally it contains a logical value
#' `merged`, initialised to `FALSE`.
#'
#' One more environment is created to contain all the other environments
#' ("nodes"), named by their `id`.  That environment is what this function
#' returns.
#'
#' @param `edges` A data frame with the columns `from` (ID of a node) and `to`
#'   (ID of a child node of `from`), such as you get from
#'   [emstreeR::ComputeMST()].
#'
#' @return
#' An environment containing one environment (node) per node ID in `edges`,
#' either the `to` or the `from` column.
#'
#' * `id` (`character`).
#' * `original_children`, an environment that is a list of environments, one for
#'   each child of the node.  It is called `original_children` because copies
#'   will later be made that might be pruned.
#' * `merged`, a logical value initialised to `FALSE`.

tree_from_edges <- function(edges) {
  from <- as.character(edges$from)
  to <- as.character(edges$to)
  ids <- unique(c(from, to))
  # Construct each node as an environment.
  # Give each node an empty environment to hold child nodes (hash very unlikely
  # to be worthwhile; most nodes will have only one child).
  l <- length(ids)
  tree <- setNames(.Internal(vector("list", l)), ids)
  for (i in seq_len(l)) {
    node <- new.env(hash = FALSE) # Hash not worth it for so few objects
    node$id <- ids[i]
    node$original_children <- new.env(hash = FALSE) # Not likely to have many.
    node$merged <- FALSE
    tree[[i]] <- node
  }
  # Turn the list of nodes into an environment with a hash for fast lookup.
  tree <- list2env(tree)
  # Link nodes to each other.
  for (i in seq_along(from)) {
    from_id <- from[i]
    to_id <- to[i]
    parent = tree[[from_id]]
    child = tree[[to_id]]
    parent$original_children[[to_id]] <- child
    child$original_children[[from_id]] <- parent
  }
  tree
}
