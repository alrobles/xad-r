# Roadmap for xad-r Development

This document outlines a structured approach to developing the xad-r package, enabling seamless bindings of the C++ library xad for R. The roadmap leverages patterns observed in similar projects like xtensor-r and xad-py.

## Objective
The xad-r project will extend the xad library functionalities to the R ecosystem, maintaining efficiency and extensibility. The goals include zero-copy data exchange, expression compatibility, and idiomatic R representations.

## Milestones

### 1. Initial Setup
**Deliverables:**
- Establish repository structure: Include directories for `src`, `tests`, and `docs`.
- Add xad as a git submodule for efficient library integration.
- Create a CMake build system for compiling R bindings.
- Integrate `FindR.cmake` script to locate R environments.

### 2. Mapping R Memory to xad Containers
**Deliverables:**
- Implement container classes (e.g., `RArray`, `RTensor`) analogous to xtensor constructs.
- Maintain a column-major memory layout, adapting R memory (`SEXP`) to xad while avoiding unnecessary copies.
- Add tests validating zero-copy data transfers.

### 3. Expression Semantics
**Deliverables:**
- Build support for xad expression trees within the R environment.
- Adapt traits and template parameters to allow R-specific operations without compromising core xad functionalities.
- Enable mathematical expressions and broadcasting consistent with idiomatic R functionality.

### 4. Interoperability with Rcpp
**Deliverables:**
- Craft Rcpp exporter and wrapper specializations to handle R object conversion.
- Facilitate copy-free expression input/output bindings to and from R.

### 5. Optional Values
**Deliverables:**
- Develop NA-aware containers using optional traits to transparently manage missing values in R.
- Test cases for edge conditions, e.g., arrays with legitimate NA data.

### 6. Build and Test Pipeline
**Deliverables:**
- Deploy CI pipelines for major platforms (Linux, macOS, Windows).
- Automate tests comparing computational results with direct xad calls.

### 7. Documentation and Examples
**Deliverables:**
- Write comprehensive documentation focusing on bridging R concepts with xad operations.
- Provide example scripts: numerical differentiation, Monte Carlo simulations.

### 8. Pre-Release
**Deliverables:**
- Ensure core functionality completeness via unit and integration tests.
- Preliminary performance benchmarks and comparisons with Rcpp/xtensor-r.

### 9. Release and Community Engagement
**Deliverables:**
- Initiate beta release and invite community feedback.
- Incorporate user-reported suggestions/bugs pre-production.
- Publish the xad-r package to CRAN.

## Design Considerations
- The project reuses xad components via CRTP patterns and `xbuffer_adaptors` for memory efficiency.
- A clean abstraction layer guarantees R-compliant semantics overlayed on xad constructs.


By following this roadmap structure, xad functionalities can be brought to R developers with style, performance, and scalability. Feedback-driven iterative refinement will ensure the tool remains on par.