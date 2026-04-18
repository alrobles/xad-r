#!/usr/bin/env Rscript
#
# swap_pricer.R — Simplified interest rate swap gradient example
#
# Demonstrates adjoint (reverse) mode differentiation for computing
# the sensitivity of a swap payoff to multiple market rates.
#
# Payoff = sum_i(rate_i * notional_i * year_fraction_i)
# Gradient w.r.t. rates = (notional_i * year_fraction_i)
# (the DV01 in basis points is gradient * 0.0001)
#

library(xadr)

# Market data
notionals      <- c(1e6, 2e6, 1.5e6, 3e6)
year_fractions <- c(0.25, 0.5, 0.75, 1.0)
rates          <- c(0.020, 0.022, 0.024, 0.026)

# Expected sensitivities
expected_sens <- notionals * year_fractions

cat("=== Simplified Interest Rate Swap Gradient ===\n\n")

# -----------------------------------------------------------------
# Compute gradient using adjoint mode
# -----------------------------------------------------------------
f <- function(...) {
  xs <- list(...)
  result <- xs[[1]] * (notionals[[1]] * year_fractions[[1]])
  for (i in seq_along(notionals)[-1]) {
    result <- result + xs[[i]] * (notionals[[i]] * year_fractions[[i]])
  }
  result
}

g <- gradient_adjoint(f, rates)

# Present value (passive calculation)
pv <- sum(rates * notionals * year_fractions)

cat(sprintf("Present value: %.2f\n\n", pv))
cat("Rate sensitivities (dPV/d_rate_i):\n")
for (i in seq_along(rates)) {
  cat(sprintf("  Rate %d (%.1f%%): sensitivity = %8.1f  (expected %8.1f)\n",
              i, rates[i]*100, g[[i]], expected_sens[[i]]))
}

cat("\nDV01 (per basis point, 0.01%):\n")
for (i in seq_along(rates)) {
  dv01 <- g[[i]] * 0.0001
  cat(sprintf("  Rate %d: DV01 = %.2f\n", i, dv01))
}
