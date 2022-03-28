# Minimise:

# AB costs 1
# A 1B

# ABC costs 1
# A 1B 1C

# AB costs 1
# A 1B 2C

# ABC costs 2
# A 3B 1C

# ABDE costs 10
# A 21B 19C
#       23D 1E
#
# BC   = 20
# BD   = 22
# BDE  = 15
# BCDE = 16

# ABDE costs 10
# A 9B 7C
#      11D 1E
#
# BC  =  8
# BD  = 10
# BDE =  7

test_that("Tree A-1B is correct", {
  tree <- data.frame(
    from =  1,
      to =  2,
       a = -1,
       b =  1
  )
  solution <- data.frame(
        from =  1,
          to =  2,
           a = -1,
           b =  1,
       depth =  1,
    ancestor =  2,
       value = -1
  )
  result <- weighted_maximum_mean_subtrees(tree, root_id = 1)
  expect_equal(result, solution)
})

test_that("Tree A-1B-1C is correct", {
  tree <- data.frame(
    from =  c(1, 2),
      to =  c(2, 3),
       a = -c(1, 1),
       b =  c(1, 1)
  )
  solution <- data.frame(
        from =  c(1, 2),
          to =  c(2, 3),
           a = -c(1, 1),
           b =  c(1, 1),
       depth =  c(1, 2),
    ancestor =  c(2, 2),
       value = -c(1, 1)
  )
  result <- weighted_maximum_mean_subtrees(tree, root_id = 1)
  expect_equal(result, solution)
})

test_that("Tree A-1B-2C is correct", {
  tree <- data.frame(
    from =  c(1, 2),
      to =  c(2, 3),
       a = -c(1, 2),
       b =  c(1, 1)
  )
  solution <- data.frame(
        from =  c(1, 2),
          to =  c(2, 3),
           a = -c(1, 2),
           b =  c(1, 1),
       depth =  c(1, 2),
    ancestor =  c(2, 3),
       value = -c(1, 2)
  )
  result <- weighted_maximum_mean_subtrees(tree, root_id = 1)
  expect_equal(result, solution)
})

test_that("Tree A-3B-1C is correct", {
  tree <- data.frame(
    from =  c(1, 2),
      to =  c(2, 3),
       a = -c(3, 1),
       b =  c(1, 1)
  )
  solution <- data.frame(
        from =  c(1, 2),
          to =  c(2, 3),
           a = -c(3, 1),
           b =  c(1, 1),
       depth =  c(1, 2),
    ancestor =  c(2, 2),
       value = -c(2, 2)
  )
  result <- weighted_maximum_mean_subtrees(tree, root_id = 1)
  expect_equal(result, solution)
})

test_that("Tree A-9B-7C A-11D-1E is correct", {
  tree <- data.frame(
    from =  c( 1,  2,  2, 4),
      to =  c( 2,  3,  4, 5),
       a = -c(21, 19, 23, 1),
       b =  c( 1,  1,  1, 1)
  )
  solution <- data.frame(
        from =  c( 1,  2,  2,  4),
          to =  c( 2,  3,  4,  5),
           a = -c(21, 19, 23,  1),
           b =  c( 1,  1,  1,  1),
       depth =  c( 1,  2,  2,  3),
    ancestor =  c( 2,  3,  2,  2),
       value = -c(15, 19, 15, 15)
  )
  result <- weighted_maximum_mean_subtrees(tree, root_id = 1)
  expect_equal(result, solution)
})

# # Solve for integer examples by brute force.
# library(tidyverse)
# r <- 1:23
# candidates <- expand_grid(B = r, C = r, D = r, E = r)
# # solutions <-
# candidates |>
#   filter(
#     C < B,
#     D > B,
#   ) |>
#   rowwise() |>
#   mutate(
#     BC = mean(c(B, C)),
#     BD = mean(c(B, D)),
#     BDE = mean(c(B, D, E)),
#     BCDE = mean(c(B, C, D, E)),
#     BC_remainder = BC %% 1,
#     BD_remainder = BD %% 1,
#     BDE_remainder = BDE %% 1,
#     BCDE_remainder = BCDE %% 1
#   ) |>
#   filter(
#     BDE < BC,
#     BDE < BCDE
#   ) |>
#   arrange(BC_remainder, BD_remainder, BDE_remainder, BCDE_remainder)
