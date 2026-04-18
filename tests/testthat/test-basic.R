test_that("package loads successfully", {
  expect_true(require(xad, quietly = TRUE))
})

test_that("xad_version returns version string", {
  version <- xad_version()
  expect_type(version, "character")
  expect_equal(version, "0.1.0")
})

test_that("xad_info runs without error", {
  expect_output(xad_info(), "xad-r")
  expect_output(xad_info(), "Version")
})
