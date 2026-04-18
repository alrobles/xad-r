# xad-r: R Bindings for XAD Automatic Differentiation

[![R-CMD-check](https://github.com/alrobles/xad-r/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/alrobles/xad-r/actions/workflows/R-CMD-check.yml)
[![License: AGPL-3](https://img.shields.io/badge/License-AGPL--3-blue.svg)](LICENSE.md)

`xadr` is an R package that brings the high-performance [XAD](https://github.com/alrobles/xad)
C++ automatic differentiation library to R. It provides:

- **Adjoint (reverse) mode**: Compute the full gradient vector of a scalar function in a
  single backward sweep — ideal for many-input, single-output problems (machine learning,
  risk sensitivities).
- **Forward (tangent-linear) mode**: Propagate derivatives forward alongside function
  evaluation — ideal for few-input problems.
- **50+ differentiable math functions**: `sin`, `cos`, `exp`, `log`, `sqrt`, `erf`, and
  many more, all with exact analytic derivatives.
- **R operator overloading**: Use standard R arithmetic (`+`, `-`, `*`, `/`, `^`) with
  active variables seamlessly.
- **High-level convenience API**: `gradient_adjoint()` and `gradient_forward()` for
  one-line gradient computation.

---

## Installation

```r
# Install from GitHub (requires devtools and a C++17 compiler)
# devtools::install_github("alrobles/xad-r")
```

**System requirements:** C++17 compiler (GCC ≥ 7, Clang ≥ 5, MSVC 2017+), R ≥ 4.0.

---

## Quick Start

### Adjoint (Reverse) Mode

Computes the **full gradient** in a single backward sweep:

```r
library(xadr)

# f(x0, x1, x2, x3) = x0 + x1 - x2 * x3
f <- function(x0, x1, x2, x3) x0 + x1 - x2 * x3

gradient_adjoint(f, c(1.0, 1.5, 1.3, 1.2))
#   x1   x2   x3    x4
#  1.0  1.0 -1.2  -1.3
```

### Forward Mode

Propagates derivatives forward (one run per input):

```r
# f(x1, x2) = x1^2 + x1 * x2
f <- function(x1, x2) x1^2 + x1 * x2

gradient_forward(f, c(3.0, 4.0))
#  x1  x2
#  10   3
```

### Low-level Tape API (Adjoint Mode)

```r
library(xadr)

tape <- adj_createTape()

x0 <- adj_Real(1.0); adj_registerInput(tape, x0)
x1 <- adj_Real(1.5); adj_registerInput(tape, x1)
x2 <- adj_Real(1.3); adj_registerInput(tape, x2)
x3 <- adj_Real(1.2); adj_registerInput(tape, x3)

adj_newRecording(tape)

y <- x0 + x1 - x2 * x3

adj_registerOutput(tape, y)
adj_setDerivative(y, 1.0)
adj_computeAdjoints(tape)

cat("y =", adj_getValue(y), "\n")
cat("dy/dx0 =", adj_getDerivative(x0), "\n")  # 1.0
cat("dy/dx1 =", adj_getDerivative(x1), "\n")  # 1.0
cat("dy/dx2 =", adj_getDerivative(x2), "\n")  # -1.2
cat("dy/dx3 =", adj_getDerivative(x3), "\n")  # -1.3
```

### Low-level Forward Mode API

```r
library(xadr)

x0 <- fwd_Real(1.0); fwd_setDerivative(x0, 1.0)  # seed dx0=1
x1 <- fwd_Real(1.5)
x2 <- fwd_Real(1.3)
x3 <- fwd_Real(1.2)

y <- x0 + x1 - x2 * x3

cat("y      =", fwd_getValue(y), "\n")
cat("dy/dx0 =", fwd_getDerivative(y), "\n")  # 1.0
```

---

## Math Functions

The following math functions are available for both adjoint (`adj_*`) and forward
(`fwd_*`) mode active variables:

| Function | Description |
|----------|-------------|
| `adj_sin` / `fwd_sin` | Sine |
| `adj_cos` / `fwd_cos` | Cosine |
| `adj_tan` / `fwd_tan` | Tangent |
| `adj_asin` / `fwd_asin` | Arc sine |
| `adj_acos` / `fwd_acos` | Arc cosine |
| `adj_atan` / `fwd_atan` | Arc tangent |
| `adj_atan2` / `fwd_atan2` | Two-argument arc tangent |
| `adj_exp` / `fwd_exp` | Exponential |
| `adj_exp2` / `fwd_exp2` | Base-2 exponential |
| `adj_expm1` / `fwd_expm1` | exp(x) - 1 |
| `adj_log` / `fwd_log` | Natural logarithm |
| `adj_log2` / `fwd_log2` | Base-2 logarithm |
| `adj_log10` / `fwd_log10` | Base-10 logarithm |
| `adj_log1p` / `fwd_log1p` | log(1 + x) |
| `adj_sqrt` / `fwd_sqrt` | Square root |
| `adj_cbrt` / `fwd_cbrt` | Cube root |
| `adj_pow` / `fwd_pow` | Power (both args active) |
| `adj_pow_scalar` / `fwd_pow_scalar` | Power (scalar exponent) |
| `adj_abs` / `fwd_abs` | Absolute value |
| `adj_sinh` / `fwd_sinh` | Hyperbolic sine |
| `adj_cosh` / `fwd_cosh` | Hyperbolic cosine |
| `adj_tanh` / `fwd_tanh` | Hyperbolic tangent |
| `adj_asinh` / `fwd_asinh` | Inverse hyperbolic sine |
| `adj_acosh` / `fwd_acosh` | Inverse hyperbolic cosine |
| `adj_atanh` / `fwd_atanh` | Inverse hyperbolic tangent |
| `adj_erf` / `fwd_erf` | Error function |
| `adj_erfc` / `fwd_erfc` | Complementary error function |
| `adj_floor` / `fwd_floor` | Floor |
| `adj_ceil` / `fwd_ceil` | Ceiling |
| `adj_round` | Round (adjoint only) |
| `adj_hypot` / `fwd_hypot` | Hypotenuse |
| `adj_min` / `fwd_min` | Minimum |
| `adj_max` / `fwd_max` | Maximum |
| `adj_fmod` / | Floating-point remainder |
| `adj_copysign` | Copy sign |

---

## Examples

See `inst/examples/` for full examples:

- `adj_1st.R` — First-order adjoint mode
- `fwd_1st.R` — First-order forward mode
- `swap_pricer.R` — Interest rate swap sensitivity

---

## Architecture

```
xad-r/
├── DESCRIPTION          # R package metadata
├── NAMESPACE            # R exports
├── CMakeLists.txt       # Standalone CMake build
├── cmake/
│   └── FindR.cmake      # R installation discovery
├── R/
│   ├── adj_1st.R        # Adjoint mode S3 methods + gradient_adjoint()
│   ├── fwd_1st.R        # Forward mode S3 methods + gradient_forward()
│   ├── math.R           # Generic math function dispatchers
│   └── xadr-package.R  # Package documentation
├── src/
│   ├── Makevars         # R build flags
│   ├── Makevars.win     # Windows build flags
│   ├── xad_bindings.cpp # Rcpp C++ bindings
│   ├── include/XAD/     # Pre-generated xad headers
│   └── xad/             # XAD C++ library (git submodule)
├── tests/testthat/      # testthat test suite
└── inst/examples/       # Example R scripts
```

The package compiles `src/xad/src/Tape.cpp` (the XAD tape engine) and
`src/xad_bindings.cpp` (Rcpp bindings) into a shared library loaded by R.

---

## Development

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/alrobles/xad-r.git
cd xad-r

# Install R package in development mode
Rscript -e "devtools::install()"

# Run tests
Rscript -e "devtools::test()"

# R CMD check
Rscript -e "rcmdcheck::rcmdcheck()"
```

---

## License

Copyright © 2010–2026 Xcelerit Computing Ltd.

Licensed under the [GNU Affero General Public License v3.0](LICENSE.md).
