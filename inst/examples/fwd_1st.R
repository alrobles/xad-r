#!/usr/bin/env Rscript
#
# fwd_1st.R — Forward (tangent-linear) mode example
#
# Replicates the xad-py fwd_1st sample in R:
#   f(x0, x1, x2, x3) = x0 + x1 - x2 * x3
#
# Computes df/dx0 using forward mode (one run per derivative).
#

library(xadr)

# Input values
x0 <- 1.0
x1 <- 1.5
x2 <- 1.3
x3 <- 1.2

cat("=== Forward (tangent-linear) mode example ===\n\n")

# -----------------------------------------------------------------
# High-level API: gradient_forward()
# -----------------------------------------------------------------
f <- function(x0, x1, x2, x3) x0 + x1 - x2 * x3

g <- gradient_forward(f, c(x0, x1, x2, x3))

cat("Function value: y =", x0 + x1 - x2 * x3, "\n")
cat("Gradient (forward mode):\n")
cat(sprintf("  dy/dx0 = %g  (expected  1)\n", g[[1]]))
cat(sprintf("  dy/dx1 = %g  (expected  1)\n", g[[2]]))
cat(sprintf("  dy/dx2 = %g  (expected -%.4g)\n", g[[3]], x3))
cat(sprintf("  dy/dx3 = %g  (expected -%.4g)\n", g[[4]], x2))

cat("\n")

# -----------------------------------------------------------------
# Low-level forward mode: compute only df/dx0
# -----------------------------------------------------------------
x0_ad <- fwd_Real(x0); fwd_setDerivative(x0_ad, 1.0)  # seed x0
x1_ad <- fwd_Real(x1)
x2_ad <- fwd_Real(x2)
x3_ad <- fwd_Real(x3)

y_ad <- x0_ad + x1_ad - x2_ad * x3_ad

cat("=== Low-level forward mode API (df/dx0 only) ===\n")
cat(sprintf("y      = %g\n", fwd_getValue(y_ad)))
cat(sprintf("dy/dx0 = %g  (expected 1)\n", fwd_getDerivative(y_ad)))
