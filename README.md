# xad-r: High-Performance Automatic Differentiation for R

R bindings for the [XAD](https://github.com/auto-differentiation/xad) automatic differentiation library, bringing production-ready, high-performance automatic differentiation to R.

## Overview

`xad-r` provides seamless integration between R and the XAD C++ library, enabling:

- **Forward mode** automatic differentiation
- **Adjoint (reverse) mode** automatic differentiation
- **Expression templates** for efficient computation
- **Zero-copy integration** with R memory through column-major layouts
- **NA/missing value support** for robust statistical computing
- **High-performance** computation suitable for production environments

## Features

### Current Status (v0.1.0 - Initial Infrastructure)

- ✅ R package structure with CMake-based build system
- ✅ XAD library integration via git submodule
- ✅ Header-only binding layer foundation
- ✅ Basic Rcpp module infrastructure
- ✅ Test infrastructure with testthat

### Planned Features

Phase 2: R-to-xad Data Container Layer
- RArray and RTensor containers
- Zero-copy SEXP memory mapping
- Shape, stride, and broadcasting support

Phase 3: Expression Tree Semantics
- R-side construction of XAD expression graphs
- Operator overloading for vector/matrix operations
- Math function mapping

Phase 4: Optional/NA Support
- NA-masked container variants
- Reliable missing-value propagation

Phase 5: High-fidelity Testing
- Port XAD C++ core tests
- Integration tests mirroring xad-py patterns
- Cross-platform CI

Phase 6: Documentation & Examples
- Usage guides mapping R idioms to XAD workflows
- Forward/adjoint mode derivative examples
- Monte Carlo differentiation examples
- Real-world financial/engineering scenarios

## Installation

### Prerequisites

- R >= 3.5.0
- C++17 compatible compiler
- CMake >= 3.15
- Rcpp package

### From Source

```r
# Install Rcpp if not already installed
install.packages("Rcpp")

# Clone the repository with submodules
git clone --recursive https://github.com/alrobles/xad-r.git

# Build and install
R CMD build xad-r
R CMD INSTALL xad_0.1.0.tar.gz
```

### Development Build

```bash
# Clone with submodules
git clone --recursive https://github.com/alrobles/xad-r.git
cd xad-r

# Initialize submodules if already cloned
git submodule update --init --recursive

# Build with CMake (optional, for development)
mkdir build && cd build
cmake ..
make

# Or build as R package
cd ..
R CMD INSTALL .
```

## Quick Start

```r
library(xad)

# Check XAD availability
xad_info()

# Get version
xad_version()
```

## Architecture

The project follows proven patterns from similar binding projects:

- **xtensor-r**: Header-only C++ binding layer with CRTP patterns for zero-copy R memory integration
- **xad-py**: Module organization separating forward and adjoint modes
- **XAD**: Core automatic differentiation engine with expression templates

### Directory Structure

```
xad-r/
├── CMakeLists.txt           # Root CMake configuration
├── DESCRIPTION              # R package metadata
├── NAMESPACE                # R package exports
├── R/                       # R wrapper functions
│   ├── xad-package.R        # Package documentation and loading
│   └── utils.R              # Utility functions
├── src/                     # C++ binding sources
│   ├── CMakeLists.txt       # Source build configuration
│   ├── init.cpp             # R package initialization
│   ├── rcpp_module.cpp      # Rcpp module definitions
│   ├── Makevars             # R build configuration
│   └── xad/                 # XAD library (git submodule)
├── include/xad-r/           # Header-only binding layer
│   ├── xad-r.hpp            # Main header
│   ├── xad_r_config.hpp     # Configuration
│   └── rutils.hpp           # R memory utilities
├── tests/                   # Test suite
│   ├── testthat.R           # testthat entry point
│   ├── testthat/            # R tests
│   └── test_main.cpp        # C++ tests
├── cmake/                   # CMake modules
│   ├── FindR.cmake          # R detection
│   └── xad-rConfig.cmake.in # Package config
└── docs/                    # Documentation and analysis
```

## Documentation

- [Development Roadmap](docs/roadmap_xad-r.md) - Detailed development plan
- [XAD Analysis](docs/analysis_xad.md) - XAD C++ library architecture
- [xtensor-r Analysis](docs/analysis_xtensor-r.md) - R binding patterns

## Contributing

Contributions are welcome! Please see the [development roadmap](docs/roadmap_xad-r.md) for planned features and current progress.

### Development Phases

1. **Phase 1: Core Infrastructure** ✅ (Current)
   - R package structure, CMake build system, XAD submodule integration

2. **Phase 2: Data Container Layer** (Next)
   - RArray/RTensor containers with zero-copy R memory mapping

3. **Phase 3: Expression Semantics**
   - Expression tree construction and operator overloading

4. **Phase 4: Optional/NA Support**
   - NA-aware containers for statistical computing

5. **Phase 5: Testing Infrastructure**
   - Comprehensive test suite mirroring XAD and xad-py

6. **Phase 6: Documentation & Examples**
   - User guides, API reference, practical examples

7. **Phase 7: Pre-release Quality**
   - Benchmarks, performance tuning, beta testing

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0).

## Acknowledgments

- [XAD](https://github.com/auto-differentiation/xad) - High-performance automatic differentiation library
- [xtensor-r](https://github.com/xtensor-stack/xtensor-r) - Inspiration for R memory integration patterns
- [xad-py](https://github.com/auto-differentiation/xad-python) - Python bindings providing module organization patterns

## References

- XAD Documentation: https://auto-differentiation.github.io/xad/
- Automatic Differentiation: https://en.wikipedia.org/wiki/Automatic_differentiation
- R Package Development: https://r-pkgs.org/

## Contact

- Issues: https://github.com/alrobles/xad-r/issues
- Repository: https://github.com/alrobles/xad-r
