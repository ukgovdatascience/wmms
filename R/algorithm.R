#' A subtree that maximises sum(a)/sum(b) of nodes connected with the root
#'
#' The algorithm searches for the optimum between bounds.  At each iteration,
#' the bounds are narrowed, according to the median of nodes within the bounds,
#' comparied with the the value of sum(a)/sum(b) obtained by greedily pruning
#' nodes whose value is out of bounds.  The stopping rule is that only the root
#' node remains.  The optimum tree can either be reconstructed by setting the
#' bounds equal to the optimum value and estimating the median once more.
#'
#' @details
#' # Overall algorithm
#'
#' A worked example is in a Google Sheet:
#' https://docs.google.com/spreadsheets/d/1wCiS0IU6EDkvjXVjRP_MwScVqtBqxqgLj3ODDsErRJ4.
#'
#' 1. Set the `bounds` to `-Infinity, +Infinity`
#' 1. Calculate the `median value` of all nodes that are between the `bounds`
#'    (inclusive). A node's value is `a / b` of that node, excluding any
#'    children.  The first time this step is done, all the nodes will be
#'    included in the median because the bounds will be `-Infinity, +Infinity`.
#' 1. Modify node values temporarily, to decide how to narrow the bounds.  In
#'    post-order (leaves first):
#'    1. Calculate the node value `a / b`.
#'    1. If the node value is lower than the `median value`, skip to the next
#'      node.
#'    1. Add the node's `a` and `b` to the parent node's `a` and `b`.
#' 1. Compare the `greedy value` of the root node `a / b`, obtained by the
#'    previous step, with the `bounds` and the `median value`.
#'    1. If the `greedy value` is above the `lower bound` then raise the `lower
#'      bound` to the `greedy value`.
#'    1. If the `greedy value` is below the `median value` then lower the `upper
#'      bound` to the `median value`.
#' 1. Undo any temporary modifications made to node values in the previous
#'    steps.
#' 1. If the `bounds` are equal to each other, stop.  This rule is necessary
#'    because otherwise, when this is the case, no nodes will be pruned, so the
#'    other stopping rule (only the root node remains) will never be triggered.
#' 1. Prune the tree permanently.  In post-order (leaves first):
#'    1. If the node's value `a / b` is below the `lower bound`, and the node is
#'      a leaf (has no children), then prune it.  It can't possibly be in the
#'      optimum tree.
#'    1. If the node's value `a / b` is below the `lower bound`, and the node has
#'      exactly one child, then add the child's `a` and `b` to the this node's
#'      `a` and `b`, adopt the children of the child to become children of this
#'      node, and prune the child.  Then return to the previous step with the
#'      new values of `a` and `b` and the new number of children, because the
#'      node might now be a leaf (have no children).  We can do this because
#'      this node and its child will either both be in the optimum tree, or both
#'      be pruned eventually, so they might as well be combined to save
#'      computating them individually.
#'    1. If the node's value `a / b` is equal to or above the `upper bound`, then
#'      add this node's `a` and `b` to its parent's `a` and `b`, make this
#'      node's children into children of this node's parent, and finally prune
#'      this node.  We can do this because we know that this node will be
#'      included in the optimum tree as long as its parent is included too, so
#'      they might as well be combined to save computating them individually.
#'    1. If none of the previous rules apply then keep the node in the tree for
#'      now.  It might be combined with an ancestor later, when applying the
#'      above rules to its ancestors.
#' 1. If more than one node remains, return to the second step, which calculates
#'    the `median value` of all nodes that are between the `bounds` (inclusive).
#' 1. If only one node remains (the root node) then stop.  Its value `a / b` is
#' now equivalent to `sum(a) / sum(b)` of all the nodes in the optimum tree, and
#'    is the maximum possible.
#'
#' This algorithm is applied to each node in depth-first post-order, beginning
#' with children of the root.  After the first iteration, the loop will
#'
#' 1. find the next node that hasn't yet been merged into others
#' 1. restore that node and its descendants to their original state
#' 1. apply the algorithm to that node and its descendants.
#'
#' This will be done until every node has been iterated over.  Having done so,
#' the value of any node its maximum possible value, either connected to the
#' overall root, or appended to one of its subtrees.
#'
#' @details
#' # Subtrees
#'
#' The algorithm doesn't optimise branches off the optimum tree.  It prunes so
#' aggressively that it will prune whole subtrees of nodes without attempting
#' any merges that would at least minimise the cost of appending branches to the
#' optimum subtree.  This happens when narrowed bounds exclude a whole branch of
#' nodes that had previously been within bounds.  Because each node in turn is
#' out of bounds, they are immediately pruned.
#'
#' This is dealt with as follows:
#'
#' 1. In depth-first pre-order
#' 1. If the node hasn't been optimised, then
#' 1. Restore it and its descendants to their original state.
#' 1. Optimise it and its descendants.
#' 1. Keep going through the depth-first pre-order, which because it is an
#'    environment will reflect the status of any nodes newly optimised.
#'
#' This increases the algorithmic complexity somewhat, but is still practical
#' for large trees.
#'
#' @source
#'
#' Carlson J., Eppstein D. (2006) The Weighted Maximum-Mean Subtree and Other
#' Bicriterion Subtree Problems. In: Arge L., Freivalds R. (eds) Algorithm
#' Theory – SWAT 2006. SWAT 2006. Lecture Notes in Computer Science, vol 4059.
#' Springer, Berlin, Heidelberg https://doi.org/10.1007/11785293_37
#'
#' See also:
#'
#' Klau G.W., Ljubić I., Mutzel P., Pferschy U., Weiskircher R. (2003)
#' The Fractional Prize-Collecting Steiner Tree Problem on Trees. In: Di
#' Battista G., Zwick U. (eds) Algorithms - ESA 2003. ESA 2003. Lecture Notes in
#' Computer Science, vol 2832. Springer, Berlin, Heidelberg
#' https://doi.org/10.1007/978-3-540-39658-1_62
#' @docType package
#' @name wmms
NULL
