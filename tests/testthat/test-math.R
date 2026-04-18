library(xadr)

test_that("adjoint mode math: tanh gradient", {
  # f(x) = tanh(x), f'(x) = 1 - tanh^2(x)
  x_val <- 0.5
  f <- function(x) adj_tanh(x)
  g <- gradient_adjoint(f, x_val)
  expected <- 1 - tanh(x_val)^2
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("adjoint mode math: atan gradient", {
  # f(x) = atan(x), f'(x) = 1/(1+x^2)
  x_val <- 1.0
  f <- function(x) adj_atan(x)
  g <- gradient_adjoint(f, x_val)
  expected <- 1.0 / (1 + x_val^2)
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("adjoint mode math: asin gradient", {
  # f(x) = asin(x), f'(x) = 1/sqrt(1-x^2)
  x_val <- 0.5
  f <- function(x) adj_asin(x)
  g <- gradient_adjoint(f, x_val)
  expected <- 1.0 / sqrt(1 - x_val^2)
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("adjoint mode math: acos gradient", {
  # f(x) = acos(x), f'(x) = -1/sqrt(1-x^2)
  x_val <- 0.5
  f <- function(x) adj_acos(x)
  g <- gradient_adjoint(f, x_val)
  expected <- -1.0 / sqrt(1 - x_val^2)
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("adjoint mode math: erf gradient", {
  # f(x) = erf(x), f'(x) = 2/sqrt(pi) * exp(-x^2)
  x_val <- 1.0
  f <- function(x) adj_erf(x)
  g <- gradient_adjoint(f, x_val)
  expected <- (2.0 / sqrt(pi)) * exp(-x_val^2)
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("adjoint mode math: log1p gradient", {
  # f(x) = log1p(x), f'(x) = 1/(1+x)
  x_val <- 2.0
  f <- function(x) adj_log1p(x)
  g <- gradient_adjoint(f, x_val)
  expected <- 1.0 / (1 + x_val)
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("adjoint mode math: expm1 gradient", {
  # f(x) = expm1(x), f'(x) = exp(x)
  x_val <- 1.0
  f <- function(x) adj_expm1(x)
  g <- gradient_adjoint(f, x_val)
  expected <- exp(x_val)
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("adjoint mode math: hypot gradient", {
  # f(x,y) = hypot(x,y) = sqrt(x^2+y^2)
  # df/dx = x/sqrt(x^2+y^2)
  x_val <- 3.0; y_val <- 4.0
  f <- function(x, y) adj_hypot(x, y)
  g <- gradient_adjoint(f, c(x_val, y_val))
  h <- sqrt(x_val^2 + y_val^2)
  expect_equal(g[[1]], x_val / h, tolerance = 1e-12)
  expect_equal(g[[2]], y_val / h, tolerance = 1e-12)
})

test_that("adjoint mode math: atan2 gradient", {
  # f(y,x) = atan2(y,x)
  # df/dy = x/(x^2+y^2), df/dx = -y/(x^2+y^2)
  y_val <- 1.0; x_val <- 1.0
  f <- function(y, x) adj_atan2(y, x)
  g <- gradient_adjoint(f, c(y_val, x_val))
  denom <- x_val^2 + y_val^2
  expect_equal(g[[1]], x_val / denom, tolerance = 1e-12)
  expect_equal(g[[2]], -y_val / denom, tolerance = 1e-12)
})

test_that("adjoint mode math: sinh gradient", {
  # f(x) = sinh(x), f'(x) = cosh(x)
  x_val <- 0.5
  f <- function(x) adj_sinh(x)
  g <- gradient_adjoint(f, x_val)
  expect_equal(g[[1]], cosh(x_val), tolerance = 1e-12)
})

test_that("adjoint mode math: cosh gradient", {
  # f(x) = cosh(x), f'(x) = sinh(x)
  x_val <- 0.5
  f <- function(x) adj_cosh(x)
  g <- gradient_adjoint(f, x_val)
  expect_equal(g[[1]], sinh(x_val), tolerance = 1e-12)
})

test_that("adjoint mode math: abs gradient (positive)", {
  # f(x) = |x|, f'(x) = 1 for x>0
  x_val <- 3.0
  f <- function(x) adj_abs(x)
  g <- gradient_adjoint(f, x_val)
  expect_equal(g[[1]], 1.0, tolerance = 1e-12)
})

test_that("adjoint mode math: cbrt gradient", {
  # f(x) = cbrt(x), f'(x) = 1/(3*x^(2/3))
  x_val <- 8.0
  f <- function(x) adj_cbrt(x)
  g <- gradient_adjoint(f, x_val)
  expected <- 1.0 / (3.0 * x_val^(2/3))
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("adjoint mode math: asinh gradient", {
  # f(x) = asinh(x), f'(x) = 1/sqrt(1+x^2)
  x_val <- 1.0
  f <- function(x) adj_asinh(x)
  g <- gradient_adjoint(f, x_val)
  expected <- 1.0 / sqrt(1 + x_val^2)
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("forward mode math: tanh gradient", {
  x_val <- 0.5
  f <- function(x) fwd_tanh(x)
  g <- gradient_forward(f, x_val)
  expected <- 1 - tanh(x_val)^2
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("forward mode math: erf gradient", {
  x_val <- 1.0
  f <- function(x) fwd_erf(x)
  g <- gradient_forward(f, x_val)
  expected <- (2.0 / sqrt(pi)) * exp(-x_val^2)
  expect_equal(g[[1]], expected, tolerance = 1e-12)
})

test_that("forward and adjoint gradients agree on complex function", {
  # f(x1, x2) = exp(x1) * sin(x2) + log(x1 + x2)
  x1_val <- 1.5; x2_val <- 0.8
  xvals <- c(x1_val, x2_val)

  f_adj <- function(x1, x2) {
    adj_add(
      adj_mul(adj_exp(x1), adj_sin(x2)),
      adj_log(adj_add(x1, x2))
    )
  }
  f_fwd <- function(x1, x2) {
    fwd_add(
      fwd_mul(fwd_exp(x1), fwd_sin(x2)),
      fwd_log(fwd_add(x1, x2))
    )
  }

  g_adj <- gradient_adjoint(f_adj, xvals)
  g_fwd <- gradient_forward(f_fwd, xvals)

  expect_equal(g_fwd[[1]], g_adj[[1]], tolerance = 1e-10)
  expect_equal(g_fwd[[2]], g_adj[[2]], tolerance = 1e-10)
})
