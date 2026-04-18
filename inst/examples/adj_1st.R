#!/usr/bin/env Rscript
#
# adj_1st.R — Adjoint (reverse) mode example
#
# Replicates the xad-py adj_1st sample in R:
#   f(x0, x1, x2, x3) = x0 + x1 - x2 * x3
#
# Computes f and all first-order derivatives in a single backward sweep.
#

library(xadr)

# Input values
x0 <- 1.0
x1 <- 1.5
x2 <- 1.3
x3 <- 1.2

cat("=== Adjoint (reverse) mode example ===\n\n")

# -----------------------------------------------------------------
# High-level API: gradient_adjoint()
# -----------------------------------------------------------------
f <- function(x0, x1, x2, x3) x0 + x1 - x2 * x3

g <- gradient_adjoint(f, c(x0, x1, x2, x3))

cat("Function value: y =", x0 + x1 - x2 * x3, "\n")
cat("Gradient (adjoint mode):\n")
cat(sprintf("  dy/dx0 = %g  (expected  1)\n", g[[1]]))
cat(sprintf("  dy/dx1 = %g  (expected  1)\n", g[[2]]))
cat(sprintf("  dy/dx2 = %g  (expected -%.4g)\n", g[[3]], x3))
cat(sprintf("  dy/dx3 = %g  (expected -%.4g)\n", g[[4]], x2))

cat("\n")

# -----------------------------------------------------------------
# Low-level tape API (mirrors the C++ and Python samples exactly)
# -----------------------------------------------------------------
tape <- adj_createTape()

x0_ad <- adj_Real(x0); adj_registerInput(tape, x0_ad)
x1_ad <- adj_Real(x1); adj_registerInput(tape, x1_ad)
x2_ad <- adj_Real(x2); adj_registerInput(tape, x2_ad)
x3_ad <- adj_Real(x3); adj_registerInput(tape, x3_ad)

adj_newRecording(tape)

y_ad <- x0_ad + x1_ad - x2_ad * x3_ad

adj_registerOutput(tape, y_ad)
adj_setDerivative(y_ad, 1.0)
adj_computeAdjoints(tape)

cat("=== Low-level tape API ===\n")
cat(sprintf("y = %g\n", adj_getValue(y_ad)))
cat("First order derivatives:\n")
cat(sprintf("  dy/dx0 = %g\n", adj_getDerivative(x0_ad)))
cat(sprintf("  dy/dx1 = %g\n", adj_getDerivative(x1_ad)))
cat(sprintf("  dy/dx2 = %g\n", adj_getDerivative(x2_ad)))
cat(sprintf("  dy/dx3 = %g\n", adj_getDerivative(x3_ad)))
