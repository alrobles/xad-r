library(xadr)

test_that("gradient_adjoint: full xad-py adj_1st example", {
  # Replicates the xad-py adj_1st sample:
  # f(x0, x1, x2, x3) = x0 + x1 - x2 * x3
  # at (1.0, 1.5, 1.3, 1.2)
  # grad = (1, 1, -1.2, -1.3)
  x <- c(1.0, 1.5, 1.3, 1.2)

  f <- function(x0, x1, x2, x3) {
    x0 + x1 - x2 * x3
  }

  g <- gradient_adjoint(f, x)

  y_expected <- x[1] + x[2] - x[3] * x[4]
  expect_equal(g[[1]], 1.0,    tolerance = 1e-12)
  expect_equal(g[[2]], 1.0,    tolerance = 1e-12)
  expect_equal(g[[3]], -x[4],  tolerance = 1e-12)
  expect_equal(g[[4]], -x[3],  tolerance = 1e-12)
})

test_that("gradient_forward: forward mode single derivative", {
  # Replicates xad-py fwd_1st sample:
  # f(x0, x1, x2, x3) = x0 + x1 - x2 * x3
  # df/dx0 = 1
  x <- c(1.0, 1.5, 1.3, 1.2)

  f <- function(x0, x1, x2, x3) x0 + x1 - x2 * x3

  # df/dx0 (seed x0 = 1, rest 0)
  xs <- lapply(x, fwd_Real)
  fwd_setDerivative(xs[[1]], 1.0)
  y <- do.call(f, xs)
  expect_equal(fwd_getValue(y), x[1] + x[2] - x[3]*x[4], tolerance = 1e-12)
  expect_equal(fwd_getDerivative(y), 1.0, tolerance = 1e-12)
})

test_that("adjoint tape low-level API", {
  # Low-level tape usage (mirrors C++ sample)
  tape <- adj_createTape()
  on.exit(adj_deactivateTape(tape))

  x0 <- adj_Real(1.0); adj_registerInput(tape, x0)
  x1 <- adj_Real(1.5); adj_registerInput(tape, x1)
  x2 <- adj_Real(1.3); adj_registerInput(tape, x2)
  x3 <- adj_Real(1.2); adj_registerInput(tape, x3)

  adj_newRecording(tape)

  y <- x0 + x1 - x2 * x3
  adj_registerOutput(tape, y)
  adj_setDerivative(y, 1.0)
  adj_computeAdjoints(tape)

  expect_equal(adj_getValue(y),          1.0 + 1.5 - 1.3*1.2, tolerance = 1e-12)
  expect_equal(adj_getDerivative(x0),  1.0,  tolerance = 1e-12)
  expect_equal(adj_getDerivative(x1),  1.0,  tolerance = 1e-12)
  expect_equal(adj_getDerivative(x2), -1.2,  tolerance = 1e-12)
  expect_equal(adj_getDerivative(x3), -1.3,  tolerance = 1e-12)
})

test_that("swap pricer style: gradient of linear combination", {
  # Simplified swap payoff: sum_i(rate_i * notional_i)
  # Gradient w.r.t. rates = notionals
  notionals <- c(1e6, 2e6, 3e6)
  rates     <- c(0.02, 0.025, 0.03)

  f <- function(...) {
    xs <- list(...)
    result <- xs[[1]] * notionals[[1]]
    for (i in seq_along(notionals)[-1]) {
      result <- result + xs[[i]] * notionals[[i]]
    }
    result
  }

  g <- gradient_adjoint(f, rates)
  expect_equal(g[[1]], notionals[[1]], tolerance = 1e-6)
  expect_equal(g[[2]], notionals[[2]], tolerance = 1e-6)
  expect_equal(g[[3]], notionals[[3]], tolerance = 1e-6)
})
