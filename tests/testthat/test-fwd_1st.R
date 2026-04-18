library(xadr)

test_that("fwd_Real creates xad_fwd_real with correct value", {
  x <- fwd_Real(2.71)
  expect_s3_class(x, "xad_fwd_real")
  expect_equal(fwd_getValue(x), 2.71, tolerance = 1e-12)
  expect_equal(fwd_getDerivative(x), 0.0, tolerance = 1e-12)
})

test_that("fwd_Real default value is 0", {
  x <- fwd_Real()
  expect_equal(fwd_getValue(x), 0.0, tolerance = 1e-12)
})

test_that("fwd_setDerivative and fwd_getDerivative work", {
  x <- fwd_Real(1.0)
  fwd_setDerivative(x, 1.0)
  expect_equal(fwd_getDerivative(x), 1.0, tolerance = 1e-12)
})

test_that("forward mode: derivative of identity function", {
  # f(x) = x, f'(x) = 1
  x <- fwd_Real(3.0)
  fwd_setDerivative(x, 1.0)
  expect_equal(fwd_getDerivative(x), 1.0, tolerance = 1e-12)
  expect_equal(fwd_getValue(x), 3.0, tolerance = 1e-12)
})

test_that("forward mode: derivative of addition", {
  # f(x, y) = x + y, df/dx = 1
  x <- fwd_Real(1.0); fwd_setDerivative(x, 1.0)
  y <- fwd_Real(2.0)
  z <- fwd_add(x, y)
  expect_equal(fwd_getValue(z), 3.0, tolerance = 1e-12)
  expect_equal(fwd_getDerivative(z), 1.0, tolerance = 1e-12)
})

test_that("forward mode: derivative of multiplication", {
  # f(x, y) = x * y, df/dx = y
  x <- fwd_Real(3.0); fwd_setDerivative(x, 1.0)
  y <- fwd_Real(4.0)
  z <- fwd_mul(x, y)
  expect_equal(fwd_getValue(z), 12.0, tolerance = 1e-12)
  expect_equal(fwd_getDerivative(z), 4.0, tolerance = 1e-12)
})

test_that("forward mode: sin derivative", {
  # f(x) = sin(x), f'(x) = cos(x)
  x_val <- 1.3
  x <- fwd_Real(x_val); fwd_setDerivative(x, 1.0)
  y <- fwd_sin(x)
  expect_equal(fwd_getValue(y), sin(x_val), tolerance = 1e-12)
  expect_equal(fwd_getDerivative(y), cos(x_val), tolerance = 1e-12)
})

test_that("forward mode: cos derivative", {
  # f(x) = cos(x), f'(x) = -sin(x)
  x_val <- 0.7
  x <- fwd_Real(x_val); fwd_setDerivative(x, 1.0)
  y <- fwd_cos(x)
  expect_equal(fwd_getValue(y), cos(x_val), tolerance = 1e-12)
  expect_equal(fwd_getDerivative(y), -sin(x_val), tolerance = 1e-12)
})

test_that("forward mode: exp derivative", {
  # f(x) = exp(x), f'(x) = exp(x)
  x_val <- 2.0
  x <- fwd_Real(x_val); fwd_setDerivative(x, 1.0)
  y <- fwd_exp(x)
  expect_equal(fwd_getValue(y), exp(x_val), tolerance = 1e-10)
  expect_equal(fwd_getDerivative(y), exp(x_val), tolerance = 1e-10)
})

test_that("forward mode: log derivative", {
  # f(x) = log(x), f'(x) = 1/x
  x_val <- 5.0
  x <- fwd_Real(x_val); fwd_setDerivative(x, 1.0)
  y <- fwd_log(x)
  expect_equal(fwd_getValue(y), log(x_val), tolerance = 1e-12)
  expect_equal(fwd_getDerivative(y), 1.0 / x_val, tolerance = 1e-12)
})

test_that("forward mode: sqrt derivative", {
  # f(x) = sqrt(x), f'(x) = 0.5/sqrt(x)
  x_val <- 9.0
  x <- fwd_Real(x_val); fwd_setDerivative(x, 1.0)
  y <- fwd_sqrt(x)
  expect_equal(fwd_getValue(y), sqrt(x_val), tolerance = 1e-12)
  expect_equal(fwd_getDerivative(y), 0.5 / sqrt(x_val), tolerance = 1e-12)
})

test_that("forward mode: pow derivative", {
  # f(x) = x^3, f'(x) = 3*x^2
  x_val <- 2.0
  x <- fwd_Real(x_val); fwd_setDerivative(x, 1.0)
  y <- fwd_pow_scalar(x, 3.0)
  expect_equal(fwd_getValue(y), x_val^3, tolerance = 1e-12)
  expect_equal(fwd_getDerivative(y), 3.0 * x_val^2, tolerance = 1e-12)
})

test_that("gradient_forward: simple polynomial", {
  # f(x1, x2) = x1^2 + x1*x2
  # grad = (2*x1 + x2, x1)
  f <- function(x1, x2) x1^2 + x1 * x2
  g <- gradient_forward(f, c(3.0, 4.0))
  expect_equal(g[[1]], 2*3 + 4, tolerance = 1e-12)
  expect_equal(g[[2]], 3.0, tolerance = 1e-12)
})

test_that("gradient_forward: matches gradient_adjoint", {
  f_adj <- function(x1, x2) x1 * adj_sin(x1) + x2^2
  f_fwd <- function(x1, x2) x1 * fwd_sin(x1) + x2^2
  xvals <- c(1.0, 2.0)
  g_adj <- gradient_adjoint(f_adj, xvals)
  g_fwd <- gradient_forward(f_fwd, xvals)
  expect_equal(g_fwd, g_adj, tolerance = 1e-10)
})

test_that("gradient_forward preserves named inputs", {
  f <- function(a, b) a + 2 * b
  g <- gradient_forward(f, c(a = 1.0, b = 2.0))
  expect_named(g, c("a", "b"))
  expect_equal(g[["a"]], 1.0, tolerance = 1e-12)
  expect_equal(g[["b"]], 2.0, tolerance = 1e-12)
})

test_that("print.xad_fwd_real produces output", {
  x <- fwd_Real(5.0)
  fwd_setDerivative(x, 1.0)
  expect_output(print(x), "xad_fwd_real")
})

test_that("as.numeric.xad_fwd_real extracts value", {
  x <- fwd_Real(3.14)
  expect_equal(as.numeric(x), 3.14, tolerance = 1e-12)
})

test_that("forward mode operators: + - * / ^", {
  x <- fwd_Real(2.0); fwd_setDerivative(x, 1.0)
  y <- fwd_Real(3.0)

  # x + y, d/dx = 1
  r <- x + y
  expect_equal(fwd_getValue(r), 5.0, tolerance = 1e-12)
  expect_equal(fwd_getDerivative(r), 1.0, tolerance = 1e-12)

  # x - y, d/dx = 1
  r <- x - y
  expect_equal(fwd_getValue(r), -1.0, tolerance = 1e-12)
  expect_equal(fwd_getDerivative(r), 1.0, tolerance = 1e-12)

  # x * y, d/dx = y = 3
  r <- x * y
  expect_equal(fwd_getValue(r), 6.0, tolerance = 1e-12)
  expect_equal(fwd_getDerivative(r), 3.0, tolerance = 1e-12)

  # x / y, d/dx = 1/y = 1/3
  r <- x / y
  expect_equal(fwd_getValue(r), 2/3, tolerance = 1e-12)
  expect_equal(fwd_getDerivative(r), 1/3, tolerance = 1e-12)

  # x^3, d/dx = 3*x^2 = 12
  r <- x^3
  expect_equal(fwd_getValue(r), 8.0, tolerance = 1e-12)
  expect_equal(fwd_getDerivative(r), 12.0, tolerance = 1e-12)
})
