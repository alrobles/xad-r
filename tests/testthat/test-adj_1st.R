library(xadr)

test_that("xad_version returns a string", {
  v <- xad_version()
  expect_type(v, "character")
  expect_true(nchar(v) > 0)
})

test_that("adj_Real creates xad_adj_real with correct value", {
  # adj_Real derivatives require an active tape
  tape <- adj_createTape()
  on.exit(adj_deactivateTape(tape))
  x <- adj_Real(3.14)
  adj_registerInput(tape, x)
  adj_newRecording(tape)
  expect_s3_class(x, "xad_adj_real")
  expect_equal(adj_getValue(x), 3.14, tolerance = 1e-12)
  expect_equal(adj_getDerivative(x), 0.0, tolerance = 1e-12)
})

test_that("adj_Real default value is 0", {
  x <- adj_Real()
  expect_equal(adj_getValue(x), 0.0, tolerance = 1e-12)
})

test_that("adj_setDerivative and adj_getDerivative work", {
  tape <- adj_createTape()
  on.exit(adj_deactivateTape(tape))
  x <- adj_Real(1.0)
  adj_registerInput(tape, x)
  adj_newRecording(tape)
  # Manually set derivative (simulating output seed)
  adj_setDerivative(x, 2.5)
  expect_equal(adj_getDerivative(x), 2.5, tolerance = 1e-12)
})

test_that("adjoint mode: simple addition gradient", {
  # f(x1, x2) = x1 + x2
  # grad = (1, 1)
  f <- function(x1, x2) x1 + x2
  g <- gradient_adjoint(f, c(1.0, 2.0))
  expect_equal(g[["x1"]], 1.0, tolerance = 1e-12)
  expect_equal(g[["x2"]], 1.0, tolerance = 1e-12)
})

test_that("adjoint mode: simple multiplication gradient", {
  # f(x1, x2) = x1 * x2
  # grad = (x2, x1)
  f <- function(x1, x2) x1 * x2
  g <- gradient_adjoint(f, c(3.0, 4.0))
  expect_equal(g[["x1"]], 4.0, tolerance = 1e-12)
  expect_equal(g[["x2"]], 3.0, tolerance = 1e-12)
})

test_that("adjoint mode: polynomial gradient", {
  # f(x) = x^3
  # f'(x) = 3*x^2
  f <- function(x) x^3
  g <- gradient_adjoint(f, c(2.0))
  expect_equal(g[["x1"]], 12.0, tolerance = 1e-10)
})

test_that("adjoint mode: composition of operations", {
  # f(x1, x2, x3, x4) = x1 + x2 - x3 * x4
  # grad = (1, 1, -x4, -x3)
  x <- c(1.0, 1.5, 1.3, 1.2)
  f <- function(x1, x2, x3, x4) x1 + x2 - x3 * x4
  g <- gradient_adjoint(f, x)
  expect_equal(g[[1]], 1.0, tolerance = 1e-12)
  expect_equal(g[[2]], 1.0, tolerance = 1e-12)
  expect_equal(g[[3]], -x[4], tolerance = 1e-12)
  expect_equal(g[[4]], -x[3], tolerance = 1e-12)
})

test_that("adjoint mode: sin function gradient", {
  # f(x) = sin(x)
  # f'(x) = cos(x)
  f <- function(x) adj_sin(x)
  x_val <- 1.3
  g <- gradient_adjoint(f, x_val)
  expect_equal(g[[1]], cos(x_val), tolerance = 1e-12)
})

test_that("adjoint mode: exp function gradient", {
  # f(x) = exp(x)
  # f'(x) = exp(x)
  f <- function(x) adj_exp(x)
  x_val <- 2.0
  g <- gradient_adjoint(f, x_val)
  expect_equal(g[[1]], exp(x_val), tolerance = 1e-10)
})

test_that("adjoint mode: log function gradient", {
  # f(x) = log(x)
  # f'(x) = 1/x
  f <- function(x) adj_log(x)
  x_val <- 3.0
  g <- gradient_adjoint(f, x_val)
  expect_equal(g[[1]], 1.0 / x_val, tolerance = 1e-12)
})

test_that("adjoint mode: sqrt function gradient", {
  # f(x) = sqrt(x)
  # f'(x) = 0.5 / sqrt(x)
  f <- function(x) adj_sqrt(x)
  x_val <- 4.0
  g <- gradient_adjoint(f, x_val)
  expect_equal(g[[1]], 0.5 / sqrt(x_val), tolerance = 1e-12)
})

test_that("adjoint mode: subtraction with scalar", {
  # f(x) = x - 1
  # f'(x) = 1
  f <- function(x) x - 1.0
  g <- gradient_adjoint(f, c(5.0))
  expect_equal(g[[1]], 1.0, tolerance = 1e-12)
})

test_that("adjoint mode: division by scalar", {
  # f(x) = x / 2
  # f'(x) = 0.5
  f <- function(x) x / 2.0
  g <- gradient_adjoint(f, c(4.0))
  expect_equal(g[[1]], 0.5, tolerance = 1e-12)
})

test_that("adjoint mode: negation", {
  # f(x) = -x
  # f'(x) = -1
  f <- function(x) -x
  g <- gradient_adjoint(f, c(3.0))
  expect_equal(g[[1]], -1.0, tolerance = 1e-12)
})

test_that("adj_getValue and adj_getDerivative on arithmetic results", {
  tape <- adj_createTape()
  on.exit(adj_deactivateTape(tape))
  x <- adj_Real(3.0); adj_registerInput(tape, x)
  y <- adj_Real(4.0); adj_registerInput(tape, y)
  adj_newRecording(tape)
  z <- adj_mul(x, y)
  expect_equal(adj_getValue(z), 12.0, tolerance = 1e-12)
})

test_that("print.xad_adj_real produces output", {
  tape <- adj_createTape()
  on.exit(adj_deactivateTape(tape))
  x <- adj_Real(2.0)
  adj_registerInput(tape, x)
  adj_newRecording(tape)
  adj_setDerivative(x, 1.0)
  expect_output(print(x), "xad_adj_real")
})

test_that("as.numeric.xad_adj_real extracts value", {
  x <- adj_Real(7.5)
  expect_equal(as.numeric(x), 7.5, tolerance = 1e-12)
})

test_that("named inputs preserve names in gradient", {
  f <- function(a, b) a * b
  g <- gradient_adjoint(f, c(a = 2.0, b = 5.0))
  expect_named(g, c("a", "b"))
  expect_equal(g[["a"]], 5.0, tolerance = 1e-12)
  expect_equal(g[["b"]], 2.0, tolerance = 1e-12)
})

