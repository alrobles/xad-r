# XAD-Py: Comprehensive Repository Analysis

[![Python](https://img.shields.io/pypi/pyversions/xad.svg)](https://auto-differentiation.github.io/tutorials/python)

> Full analysis of the [`auto-differentiation/xad-py`](https://github.com/auto-differentiation/xad-py) repository — Python bindings for the XAD automatic differentiation library.

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Architecture](#architecture)
- [Differentiation Modes](#differentiation-modes)
  - [Adjoint (Reverse) Mode](#adjoint-reverse-mode)
  - [Forward Mode](#forward-mode)
- [API Reference](#api-reference)
  - [Active Types (Real)](#active-types-real)
  - [Tape API](#tape-api)
  - [Math Functions](#math-functions)
  - [Exceptions](#exceptions)
  - [Convenience Functions](#convenience-functions)
- [Build System](#build-system)
- [Testing](#testing)
- [Samples](#samples)
- [Application Areas](#application-areas)
- [Related Projects](#related-projects)

---

## Overview

**Package name:** `xad`
**Version:** 1.5.1.3
**License:** GNU Affero General Public License v3.0 (AGPL-3.0-or-later)
**Copyright:** © 2010–2024 Xcelerit Computing Ltd.
**Python support:** 3.8, 3.9, 3.10, 3.11, 3.12 (CPython)
**Platforms:** Linux, macOS, Windows

XAD is a library designed for [automatic differentiation](https://auto-differentiation.github.io/tutorials/aad/), aimed at both beginners and advanced users. It is intended for use in production environments, emphasizing performance and ease of use. The Python bindings (`xad-py`) wrap the high-performance [XAD C++ core library](https://github.com/auto-differentiation/xad) using [pybind11](https://pybind11.readthedocs.io/en/stable/).

**Key features:**

- Support for both **forward** and **adjoint (reverse)** modes at the first order
- Strong exception-safety guarantees
- High performance, as demonstrated in extensive production use
- Over 50 differentiable math functions
- Context-manager based tape for clean resource management

---

## Repository Structure

```
xad-py/
├── .clang-format               # C++ code formatting rules
├── .github/                    # GitHub CI/CD workflows, templates, Dependabot
│   ├── ISSUE_TEMPLATE/
│   ├── SECURITY.md
│   ├── boring-cyborg.yml
│   ├── dependabot.yml
│   ├── pull_request_template.md
│   └── workflows/
├── .gitignore
├── .gitmodules                 # Git submodule references (XAD core, pybind11)
├── .pre-commit-config.yaml     # Pre-commit hooks configuration
├── CHANGELOG.md                # Release history
├── CMakeLists.txt              # Top-level CMake build file
├── CODE_OF_CONDUCT.md          # Contributor Covenant v2.1
├── CONTRIBUTING.md             # Contribution guidelines
├── LICENSE.md                  # AGPL-3.0 full text
├── README.md                   # Project README
├── build_extensions.py         # Poetry build hook for native C++ extensions
├── poetry.lock                 # Locked dependency versions
├── pyproject.toml              # Poetry project configuration & build settings
│
├── src/                        # C++ source code (pybind11 bindings)
│   ├── CMakeLists.txt          # Build config for the extension module
│   ├── module.cpp              # Main pybind11 module (_xad) definition
│   ├── real.hpp                # Active type bindings (AReal, FReal)
│   ├── tape.hpp                # Tape bindings (adjoint mode recording)
│   ├── math.hpp                # 50+ math function bindings
│   ├── exceptions.hpp          # XAD exception bindings
│   ├── pybind11/               # pybind11 library (git submodule)
│   └── xad/                    # XAD C++ core library (git submodule)
│
├── xad/                        # Python package
│   ├── __init__.py             # Package root: value(), derivative(), __version__
│   ├── adj_1st/                # Adjoint (reverse) mode subpackage
│   │   └── __init__.py
│   ├── fwd_1st/                # Forward mode subpackage
│   │   └── __init__.py
│   ├── math/                   # Math functions subpackage
│   │   └── __init__.py
│   └── exceptions/             # Custom exceptions subpackage
│       └── __init__.py
│
├── tests/                      # Test suite (pytest)
│   ├── test_package.py
│   ├── test_real_operations.py
│   ├── test_math_functions_derivatives.py
│   ├── test_tape.py
│   └── test_exceptions.py
│
└── samples/                    # Example scripts
    ├── adj_1st.py              # Adjoint mode example
    ├── fwd_1st.py              # Forward mode example
    └── swap_pricer.py          # Real-world swap pricing example
```

---

## Architecture

### Design Decisions

1. **pybind11 bindings** — The project uses [pybind11](https://pybind11.readthedocs.io/) to create Python bindings from C++, providing near-native performance with a clean Python API.

2. **Git submodules** — The C++ XAD core library (`src/xad/`) and pybind11 (`src/pybind11/`) are included as git submodules, keeping the dependency pinned and reproducible.

3. **CMake + Poetry** — The build system uses **CMake** (C++17) for compiling the native extension, orchestrated by a **Poetry** build hook (`build_extensions.py`).

4. **Compiled wheel distribution** — The package is distributed as a compiled wheel with native extensions (`xad/_xad.*` and `xad/**/*.pyi` type stubs).

5. **Submodule architecture** — The pybind11 module `_xad` exposes four submodules:
   - `adj_1st` — Adjoint mode (Real + Tape)
   - `fwd_1st` — Forward mode (Real only)
   - `math` — Math functions
   - `exceptions` — Exception types

### C++ Binding Layer

The main entry point is `src/module.cpp`, which defines the `_xad` pybind11 module:

```
PYBIND11_MODULE(_xad, m)
├── adj_1st submodule
│   ├── py_real<AReal>()    ← from real.hpp
│   └── py_tape()           ← from tape.hpp
├── fwd_1st submodule
│   └── py_real<FReal>()    ← from real.hpp
├── math submodule          ← from math.hpp
│   ├── add_math_functions<AReal>()
│   ├── add_math_functions<FReal>()
│   └── add_math_functions<double>()
└── exceptions submodule    ← from exceptions.hpp
```

The `py_real<T>()` function is templated over the active type (`AReal` or `FReal`), sharing operator/method definitions while `add_extra_methods()` adds type-specific functionality (e.g., `setAdjoint`, `shouldRecord`, `getSlot` for `AReal` only).

---

## Differentiation Modes

### Adjoint (Reverse) Mode

**Module:** `xad.adj_1st`
**Active type:** `AReal` (wraps `xad::AReal<double>`)

Uses a **Tape** to record operations during the forward pass, then propagates derivatives backward from outputs to inputs. This is efficient for functions with **many inputs and few outputs** (e.g., computing gradients).

**Workflow:**
1. Create active variables (`Real`)
2. Create and activate a `Tape` (via context manager)
3. Register inputs on the tape
4. Start a new recording
5. Compute the function
6. Register outputs and seed output adjoints
7. Call `computeAdjoints()` to propagate derivatives backward
8. Read input derivatives

```python
import xad.adj_1st as xadj

x0_ad = xadj.Real(1.0)
x1_ad = xadj.Real(1.5)
x2_ad = xadj.Real(1.3)
x3_ad = xadj.Real(1.2)

with xadj.Tape() as tape:
    tape.registerInput(x0_ad)
    tape.registerInput(x1_ad)
    tape.registerInput(x2_ad)
    tape.registerInput(x3_ad)
    tape.newRecording()

    y = x0_ad + x1_ad - x2_ad * x3_ad

    tape.registerOutput(y)
    y.derivative = 1.0
    tape.computeAdjoints()

    print(f"dy/dx0 = {x0_ad.derivative}")  # 1.0
    print(f"dy/dx1 = {x1_ad.derivative}")  # 1.0
    print(f"dy/dx2 = {x2_ad.derivative}")  # -1.2
    print(f"dy/dx3 = {x3_ad.derivative}")  # -1.3
```

### Forward Mode

**Module:** `xad.fwd_1st`
**Active type:** `FReal` (wraps `xad::FReal<double>`)

Propagates derivatives forward alongside the function evaluation. This is efficient for functions with **few inputs and many outputs**. No tape is required.

**Workflow:**
1. Create active variables (`Real`)
2. Seed the derivative of the input of interest (set to 1.0)
3. Compute the function
4. Read output derivative

```python
import xad.fwd_1st as xfwd

x0_ad = xfwd.Real(1.0)
x1_ad = xfwd.Real(1.5)
x2_ad = xfwd.Real(1.3)
x3_ad = xfwd.Real(1.2)

# Compute derivative w.r.t. x0
x0_ad.derivative = 1.0

y = 2 * x0_ad + x1_ad - x2_ad * x3_ad

print(f"dy/dx0 = {y.derivative}")  # 2.0
```

---

## API Reference

### Active Types (Real)

Both `adj_1st.Real` and `fwd_1st.Real` support the following operations:

#### Construction

| Constructor | Description |
|-------------|-------------|
| `Real()` | Default constructor (value = 0) |
| `Real(value: float)` | Construct with initial value |

#### Arithmetic Operators

| Operator | Supported operand types |
|----------|------------------------|
| `+`, `-`, `*`, `/` | `Real ↔ Real`, `Real ↔ float`, `float ↔ Real` |
| `//` (floor div) | `Real ↔ Real`, `Real ↔ float`, `float ↔ Real` |
| `%` (modulo) | `Real ↔ Real`, `Real ↔ float`, `float ↔ Real` |
| `**` (power) | `Real ↔ Real`, `Real ↔ float`, `float ↔ Real` |
| `divmod()` | `Real ↔ Real`, `Real ↔ float`, `float ↔ Real` |
| `-x` (negation) | Unary |
| `+x` (positive) | Unary |

#### Comparison Operators

| Operator | Supported operand types |
|----------|------------------------|
| `==`, `!=` | `Real ↔ Real`, `Real ↔ float` |
| `<`, `<=`, `>`, `>=` | `Real ↔ Real`, `Real ↔ float` |

#### Built-in Protocol Support

| Method | Return type | Description |
|--------|-------------|-------------|
| `int(x)` | `int` | Integer conversion |
| `bool(x)` | `bool` | Boolean conversion |
| `abs(x)` | `Real` | Absolute value |
| `round(x)` | `int` | Round to nearest integer |
| `round(x, n)` | `Real` | Round to n decimal places |
| `math.ceil(x)` | `int` | Ceiling |
| `math.floor(x)` | `int` | Floor |
| `math.trunc(x)` | `int` | Truncation |
| `repr(x)` | `str` | String representation of value |

#### Value and Derivative Access

| Method | Description |
|--------|-------------|
| `getValue()` | Get the underlying floating-point value |
| `getDerivative()` | Get the derivative (adjoint or tangent) |
| `setDerivative(v: float)` | Set the derivative |
| `conjugate()` | Complex conjugate (returns self for real types) |
| `real()` | Real part (returns self) |
| `imag()` | Imaginary part (returns Real(0.0)) |

#### Adjoint-Only Methods (adj_1st.Real)

| Method | Description |
|--------|-------------|
| `setAdjoint(x: float)` | Set adjoint of this variable |
| `shouldRecord()` | Check if variable is registered on tape |
| `getSlot()` | Get the slot of this variable on the tape |

---

### Tape API

**Module:** `xad.adj_1st.Tape`

The Tape records operations for adjoint (reverse) mode differentiation. It supports Python's context manager protocol for clean activation/deactivation.

#### Construction and Lifecycle

| Method | Description |
|--------|-------------|
| `Tape()` | Construct a tape (initially inactive) |
| `__enter__()` | Context manager entry — activates the tape |
| `__exit__(...)` | Context manager exit — deactivates the tape |
| `activate()` | Manually activate the tape |
| `deactivate()` | Manually deactivate the tape |
| `isActive()` | Check if the tape is currently active |
| `getActive()` | Class method to get reference to currently active tape |

#### Recording and Computation

| Method | Description |
|--------|-------------|
| `registerInput(x: Real)` | Register an input variable for derivative tracking |
| `registerOutput(y: Real)` | Register an output before setting its adjoint |
| `newRecording()` | Start a new recording, marking the differentiation start point |
| `computeAdjoints()` | Roll back the tape to `newRecording()`, propagating all adjoints |
| `computeAdjointsTo(pos)` | Roll back the tape to a specific position |
| `getPosition()` | Get current tape position (for use with `computeAdjointsTo`) |

#### Tape Management

| Method | Description |
|--------|-------------|
| `clearAll()` | Reset tape completely without de-allocating memory (for reuse) |
| `clearDerivatives()` | Clear all stored derivatives |
| `clearDerivativesAfter(pos)` | Clear derivatives after a given position |
| `resetTo(pos)` | Reset tape back to the given position |
| `getMemory()` | Get total memory consumed by the tape in bytes |
| `printStatus()` | Print tape status for debugging |

#### Derivative Access via Tape

| Method | Description |
|--------|-------------|
| `derivative(x: Real)` | Get derivative of a registered variable |
| `derivative(slot: int)` | Get derivative at a given slot position |
| `getDerivative(x: Real)` | Alias for `derivative` |
| `getDerivative(slot: int)` | Alias for `derivative` |
| `setDerivative(x: Real, v: float)` | Set derivative of a registered variable |
| `setDerivative(slot: int, v: float)` | Set derivative at a given slot |

---

### Math Functions

**Module:** `xad.math`

All functions support three input types: `AReal`, `FReal`, and `float`. Functions taking two arguments also support mixed types (`Real ↔ float`).

#### Exponential and Logarithmic

| Function | Description |
|----------|-------------|
| `exp(x)` | Exponential function e^x |
| `exp2(x)` | 2^x |
| `expm1(x)` | e^x - 1 (more precise near zero) |
| `log(x)` | Natural logarithm |
| `log2(x)` | Base-2 logarithm |
| `log10(x)` | Base-10 logarithm |
| `log1p(x)` | log(1 + x) (more precise near zero) |
| `ldexp(x, exp)` | x × 2^exp |

#### Power and Root

| Function | Description |
|----------|-------------|
| `pow(x, y)` | x raised to the power y |
| `sqrt(x)` | Square root |
| `cbrt(x)` | Cubic root |

#### Trigonometric

| Function | Description |
|----------|-------------|
| `sin(x)` | Sine |
| `cos(x)` | Cosine |
| `tan(x)` | Tangent |
| `asin(x)` | Inverse sine |
| `acos(x)` | Inverse cosine |
| `atan(x)` | Inverse tangent |
| `atan2(y, x)` | 4-quadrant inverse tangent |

#### Hyperbolic

| Function | Description |
|----------|-------------|
| `sinh(x)` | Hyperbolic sine |
| `cosh(x)` | Hyperbolic cosine |
| `tanh(x)` | Hyperbolic tangent |
| `asinh(x)` | Inverse hyperbolic sine |
| `acosh(x)` | Inverse hyperbolic cosine |
| `atanh(x)` | Inverse hyperbolic tangent |

#### Rounding

| Function | Description |
|----------|-------------|
| `ceil(x)` | Ceiling (round towards positive infinity) |
| `floor(x)` | Floor (round towards negative infinity) |
| `trunc(x)` | Truncate decimals |

#### Decomposition

| Function | Description |
|----------|-------------|
| `modf(x)` | Decompose into integral and fractional parts — returns `(frac, int)` |
| `frexp(x)` | Decompose into normalized fraction and power of 2 — returns `(frac, exp)` |
| `fmod(x, y)` | Floating point remainder after integer division |
| `remainder(x, y)` | Signed remainder after integer division |

#### Min, Max, and Absolute Value

| Function | Description |
|----------|-------------|
| `min(x, y)` | Minimum of two values |
| `max(x, y)` | Maximum of two values |
| `fmin(x, y)` | Minimum (NaN-safe) |
| `fmax(x, y)` | Maximum (NaN-safe) |
| `abs(x)` | Absolute value |
| `fabs(x)` | Absolute value (float) |

#### Smooth Variants (Well-Defined Derivatives)

| Function | Description |
|----------|-------------|
| `smooth_abs(x)` | Smoothed absolute value |
| `smooth_min(x, y)` | Smoothed minimum |
| `smooth_max(x, y)` | Smoothed maximum |

#### Special Functions

| Function | Description |
|----------|-------------|
| `erf(x)` | Error function |
| `erfc(x)` | Complementary error function |

#### Utility

| Function | Description |
|----------|-------------|
| `copysign(x, y)` | Copy sign of y to x |
| `nextafter(x, y)` | Next representable value from x toward y |
| `degrees(x)` | Convert radians to degrees |
| `radians(x)` | Convert degrees to radians |

---

### Exceptions

**Module:** `xad.exceptions`

All exceptions inherit from the base `XadException` class.

| Exception | When Raised |
|-----------|-------------|
| `XadException` | Base class for all XAD errors |
| `TapeAlreadyActive` | Activating a tape when one is already active in the current thread |
| `OutOfRange` | Setting a derivative at a slot that is out of range of recorded variables |
| `DerivativesNotInitialized` | Setting derivatives on the tape without a recording and registered outputs |
| `NoTapeException` | Performing an operation that requires an active tape when none is active |

---

### Convenience Functions

**Module:** `xad` (top-level)

| Function | Signature | Description |
|----------|-----------|-------------|
| `value(x)` | `(Real \| Any) → float` | Extract value from active type, or return `x` if it's a plain type |
| `derivative(x)` | `(Real) → float` | Extract derivative from active type; raises `TypeError` if not an active type |
| `__version__` | `str` | Package version string |

---

## Build System

### Overview

The build pipeline combines **Poetry** (Python packaging) with **CMake** (C++ compilation):

1. **Poetry** manages the Python package, dependencies, and distribution
2. **`build_extensions.py`** (Poetry build hook) invokes CMake to compile the C++ extension
3. **CMake** (≥3.15.2) builds the pybind11 extension module with C++17
4. **Ninja** is the preferred CMake generator for fast builds
5. **pybind11-stubgen** (≥2.5) generates `.pyi` type stubs for IDE support

### Configuration Files

| File | Purpose |
|------|---------|
| `pyproject.toml` | Poetry configuration, dependencies, build settings, tool configs |
| `CMakeLists.txt` | Top-level CMake build file |
| `src/CMakeLists.txt` | Extension module CMake build config |
| `build_extensions.py` | Poetry build hook connecting Poetry → CMake |
| `.clang-format` | C++ code style configuration |
| `.pre-commit-config.yaml` | Pre-commit hook definitions |

### Dependencies

**Runtime:** None (self-contained compiled extension)

**Build-time:**
- `poetry-core` ≥1.0.0
- `ninja`
- `cmake`
- `setuptools` ≥42
- `pybind11-stubgen` ≥2.5

**Development:**
- `mypy` — static type checking
- `black` — code formatting (line length: 100)
- `flake8` — linting
- `pytest` — testing
- `pre-commit` — git hooks
- `ninja` — fast CMake builds
- `cmake` — C++ build system
- `pybind11-stubgen` ^2.5 — type stub generation

### Building from Source

```bash
# Install Poetry, then:
poetry install

# Run tests:
poetry run pytest

# Build a wheel:
poetry build
```

---

## Testing

**Framework:** pytest (minversion 6.0)
**Test directory:** `tests/`
**CI testing:** `cibuildwheel` with `pytest {project}/tests`

| Test File | Coverage Area |
|-----------|---------------|
| `test_package.py` | Package-level imports and version |
| `test_real_operations.py` | Arithmetic operators, comparisons, conversions for active types |
| `test_math_functions_derivatives.py` | Derivative correctness for all 50+ math functions |
| `test_tape.py` | Tape operations, recording, adjoint computation |
| `test_exceptions.py` | Exception handling and error conditions |

### Running Tests

```bash
poetry run pytest                    # All tests
poetry run pytest tests/test_tape.py # Specific test file
```

---

## Samples

The `samples/` directory contains three example scripts:

### `adj_1st.py` — First-Order Adjoint Mode

Computes `y = x0 + x1 - x2 * x3` and all four partial derivatives using adjoint mode. Demonstrates the full tape workflow: register inputs → record → register output → seed adjoint → compute adjoints.

### `fwd_1st.py` — First-Order Forward Mode

Computes `y = 2*x0 + x1 - x2*x3` and the derivative `dy/dx0` using forward mode. Demonstrates that no tape is needed — simply seed the input derivative and read the output derivative.

### `swap_pricer.py` — Real-World Financial Application

Computes the discount rate sensitivities of a simple interest rate swap pricer. Demonstrates:
- Working with lists of active variables (`registerInputs`)
- Using `xad.math` functions (`math.pow`)
- Real-world financial derivative computation (30 discount rate sensitivities)

---

## Application Areas

Automatic differentiation has broad application areas:

- **Machine Learning and Deep Learning** — Training neural networks and ML models
- **Optimization** — Solving optimization problems in engineering and finance
- **Numerical Analysis** — Enhancing numerical solutions for differential equations
- **Scientific Computing** — Simulating physical systems and processes
- **Risk Management and Quantitative Finance** — Assessing and hedging risk in financial models
- **Computer Graphics** — Optimizing rendering algorithms
- **Robotics** — Improving control and simulation of robotic systems
- **Meteorology** — Enhancing weather prediction models
- **Biotechnology** — Modeling biological processes and systems

---

## Related Projects

| Project | Description |
|---------|-------------|
| [XAD (C++)](https://github.com/auto-differentiation/xad) | Core automatic differentiation library in C++ |
| [XAD-Py](https://github.com/auto-differentiation/xad-py) | Python bindings (this repository) |
| [QuantLib-Risks-Cpp](https://github.com/auto-differentiation/QuantLib-Risks-Cpp) | Fast risk evaluations in C++ |
| [QuantLib-Risks-Py](https://github.com/auto-differentiation/QuantLib-Risks-Py) | Fast risk evaluations in Python |

---

## Changelog

### [1.5.1.1] — 2024-03-29
Minor fixes to allow linking against QuantLib-Risks without duplicate symbols.

### [1.5.1] — 2024-03-28
Initial release of Python bindings for XAD.

---

*Analysis generated from xad-py v1.5.1.3*
