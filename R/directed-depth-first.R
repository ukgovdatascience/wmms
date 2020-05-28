#' Make an EMST directed and return the depth-first search order
#'
#' Euclidean Minimum Spanning Tree (EMST) edgelists from
#' [emstreeR::ComputeMST()] aren't directed.  We also need to know a depth-first
#' search order of the nodes, to traverse them in loops rather than by
#' recursion, which would reach the stack limit.  This function does both.  A
#' list is returned containing the modified `edges`, and a `dfs_order` element
#' that names the nodes in depth-first search order.  The `tree` is modified in
#' place.
#'
#' @param `tree` (`environment`) A potentially undirected tree, originally from
#'   [tree_from_edges()].
#' @param `edges` A data frame with one row per edge, and at least the two
#'   `numeric` columns `from` and `to` for the IDs of the nodes being connected
#'   by the edge.  Must be the same as was used by [tree_from_edges()] to create
#'   `tree` from the output of [emstreeR::ComputeMST()].
#' @param `root_id` (`numeric`) The ID of the node to treat as the root.
#'
#' @return
#' A list containing `edges` with some values of the `to` and `from` columns
#' exchanged so that the graph is directed, and `dfs_order`, which is a vector
#' of node IDs in the order that they would be visited in a depth-first search.
#' the `tree` is modified in place, so is not retured.

directed_depth_first <- function(tree, edges, root_id) {
  # Prepare to walk the tree from the root downwards
  tree[[root_id]]$original_parent <- list(id = "0") # Dummy
  stack <- list()
  stack[[1]] <- tree[[root_id]] # Begin by putting the root node into the stack
  n <- nrow(edges) + 1L
  dfs_order <- character(n) # Node IDs in depth-first preorder
  parents <- character(n)   # A lookup vector of parents of nodes
  i <- 0L
  # Walk the tree
  while (length(stack) > 0L) {
    i <- i + 1L
    # Pop a node from the stack
    node <- stack[[1]]
    stack[[1]] <- NULL
    # Add the node to the depth-first search order
    dfs_order[i] <- node$id
    # Add the parent of the node to the lookup vector of parents of nodes
    parents[i] <- node$original_parent$id
    # Remove the node from the 'children' of any children, and assign itself as
    # their parent instead.
    original_children <- node$original_children
    for (child in as.list(original_children)) {
      .Internal(remove(node$id, child$original_children, FALSE))
      child$original_parent <- node
    }
    children_list <- as.list(node$original_children, sort = FALSE)
    # Append any children to the stack
    stack <- c(children_list, stack)
  }
  # Make a lookup vector of parents of nodes. The value is the id of the parent,
  # and the name is the id of the child.
  parents <- setNames(as.numeric(parents), dfs_order)
  # We can use this to exchange the from/to columns of `edges` to align with the
  # depth-first search.
  orig_from <- edges$from
  exchange_which <- which(edges$from != parents[as.character(edges$to)])
  edges$from[exchange_which] <- edges$to[exchange_which]
  edges$to[exchange_which] <- orig_from[exchange_which]
  # Now that `edges` is directed, assign the edge values to the destination
  # nodes.
  edges_to <- as.character(edges$to)
  a <- edges$a
  b <- edges$b
  for (j in seq_len(n - 1L)) {
    node <- tree[[edges_to[j]]]
    node$original_a <- a[j]
    node$original_b <- b[j]
  }
  list(edges = edges, dfs_order = dfs_order)
}
