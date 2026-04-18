# XAD Architecture Analysis

An analysis of the `alrobles/xad` repository, focusing on the structure and components
that enable XAD's use as a core C++ automatic differentiation library. This document
highlights features that facilitate high-performance computations and integration
mechanisms for bindings.

---

## 1. Build & Package Layer — Designed for Embeddable Library Use

- The project builds a C++ library target (`xad`) and exports it as `XAD::xad`.
  It installs headers and ships CMake package-config files so that downstream
  consumers can use `find_package(XAD)`.
  **(`src/CMakeLists.txt:174-244`, `cmake/XADConfig.cmake.in:25-30`)**

- The root CMake file supports optional codegen/JIT dependency wiring and
  installation into the same export set.
  **(`CMakeLists.txt:52-73`, `CMakeLists.txt:83-102`)**

---

## 2. Public API — Header-Centric with One Main Umbrella Include

- `XAD/XAD.hpp` is the main include and aggregates core AD headers; optional
  JIT/codegen headers are included only behind feature macros.
  **(`src/XAD/XAD.hpp:27-63`)**

- Documentation guidance states that most clients include `XAD/XAD.hpp`, with
  optional specialised headers for complex numbers, `std` compatibility,
  Hessians, Jacobians, and JIT support.
  **(`docs/ref/headers.md:6-9`, `docs/ref/headers.md:27-35`)**

---

## 3. Mode Interface Layer — Clean Separation of AD Configurations

- `Interface.hpp` provides typedef-based mode traits (`adj`, `fwd`, `fwd_adj`,
  etc.) that expose `active_type`, `tape_type`, and `passive_type`, enabling
  stable, type-driven integration from external code.
  **(`src/XAD/Interface.hpp:41-239`)**

- The docs mirror this as the canonical user-facing mode abstraction.
  **(`docs/ref/interface.md:3-7`, `docs/ref/interface.md:128-140`)**

---

## 4. Core AD Data Types and Expression System

- `AReal` (reverse mode) and `FReal` (forward mode) are defined in
  `Literals.hpp`, with expression-template assignment/constructor paths and
  derivative accessors.
  **(`src/XAD/Literals.hpp:190-203`, `src/XAD/Literals.hpp:548-599`,
  `src/XAD/Literals.hpp:658-736`)**

- A CRTP expression base together with unary/binary expression nodes implement
  compile-time derivative propagation and recording decisions.
  **(`src/XAD/Expression.hpp:45-109`, `src/XAD/UnaryExpr.hpp:65-85`,
  `src/XAD/BinaryExpr.hpp:40-79`)**

---

## 5. Components Enabling High-Performance Computation

### 5.1 Tape Engine Optimised for Large Recordings

- The tape stores operations and statements in custom containers and computes
  the reverse sweep in chunk-aware loops.
  **(`src/XAD/Tape.hpp:275-277`, `src/Tape.cpp:534-587`)**

- It supports checkpoint callbacks and nested recordings for large workflows.
  **(`src/XAD/Tape.hpp:197-203`, `src/Tape.cpp:494-531`,
  `src/Tape.cpp:336-365`)**

### 5.2 Memory- and Performance-Oriented Container Internals

- `ChunkContainer` allocates large, 128-byte-aligned chunks and avoids
  `std::vector`-style reallocation churn.
  **(`src/XAD/ChunkContainer.hpp:41-54`, `src/XAD/ChunkContainer.hpp:88-101`)**

- `OperationsContainer` / `OperationsContainerPaired` use chunked append and
  tight iteration for tape operations.
  **(`src/XAD/OperationsContainer.hpp:61-71`,
  `src/XAD/OperationsContainer.hpp:145-209`,
  `src/XAD/OperationsContainerPaired.hpp:125-190`)**

- A build-time switch selects reduced-memory vs. paired operations storage.
  **(`src/XAD/TapeContainer.hpp:43-47`)**

### 5.3 Micro-Optimisation Hooks

- Global macros provide forced-inline, branch-prediction hints, and
  thread-local storage abstraction.
  **(`src/XAD/Macros.hpp:43-81`)**

- CMake exposes SIMD target flags (`SSE2`/`AVX`/`AVX2`/`AVX512`/`NATIVE`) and
  strong-inline / reduced-memory / tape-slot-reuse toggles.
  **(`cmake/XADSetupOptions.cmake:47-70`,
  `cmake/XADSetupCompiler.cmake:57-87`)**

### 5.4 JIT Path for Record-Once / Replay-Many

- The README and docs position JIT as a replay optimisation for repetitive
  workloads.
  **(`README.md:17-19`, `docs/ref/jit.md:3-5`)**

- `JITCompiler` records to `JITGraph`, compiles via a pluggable backend, then
  executes forward + adjoint passes.
  **(`src/XAD/JITCompiler.hpp:157-166`, `src/XAD/JITCompiler.hpp:219-245`,
  `src/XAD/JITCompiler.hpp:248-266`)**

- JIT is intentionally limited to scalar, first-order mode (`N == 1`).
  **(`src/XAD/JITCompiler.hpp:51`,
  `src/XAD/JITCompilerTLS.cpp:48-54`)**

- The backend abstraction supports different execution engines and SIMD-style
  width reporting via `vectorWidth()`.
  **(`src/XAD/JITBackendInterface.hpp:40-47`,
  `src/XAD/JITBackendInterface.hpp:65-82`)**

---

## 6. Integration Mechanisms Relevant to Bindings / Core Embedding

### 6.1 CMake-Native Consumption

- Consumers link the exported `XAD::` targets through installed config/targets
  files.
  **(`src/CMakeLists.txt:225-244`, `cmake/XADConfig.cmake.in:29-30`)**

- Position-independent code is enabled by default, which aids shared-library
  and binding scenarios.
  **(`cmake/XADSetupOptions.cmake:36`,
  `cmake/XADSetupCompiler.cmake:149-150`)**

### 6.2 Interoperability with External Numeric Ecosystems

- The external-function callback API (`CheckpointCallback`) allows wrapping
  opaque optimised kernels with a custom reverse pass.
  **(`src/XAD/CheckpointCallback.hpp:30-36`,
  `samples/external_function/external_sum_elements.hpp:43-45`,
  `samples/external_function/external_sum_elements.hpp:84-93`)**

- Eigen compatibility is validated in tests using both reverse and forward
  modes.
  **(`test/Eigen_test.cpp:31-38`, `test/Eigen_test.cpp:64-77`,
  `test/Eigen_test.cpp:90-95`)**

### 6.3 JIT Backend Plug-In Seam

- `JITBackend` is a clean virtual interface
  (`compile`/`reset`/`forward`/`forwardAndBackward`) intended for custom
  executors (native codegen, GPU, SIMD backends).
  **(`src/XAD/JITBackendInterface.hpp:59-82`)**

- `JITGraphInterpreter` serves as the reference / fallback backend.
  **(`src/XAD/JITGraphInterpreter.hpp:40-45`,
  `src/XAD/JITGraphInterpreter.hpp:50-66`)**

### 6.4 Control-Flow Recording Support for Reusable Graphs

- `ABool` and `If` encode conditionals as graph nodes so that replay can take
  different branches at runtime — important for stable binding APIs that
  compile once and run with many different inputs.
  **(`src/XAD/ABool.hpp:40-49`, `src/XAD/ABool.hpp:78-107`,
  `samples/jit_tutorial/main.cpp:186-217`)**

---

## 7. Summary

The repository is structured as a **portable C++ core AD library** with:

| Aspect | Key Files |
|---|---|
| Performant tape-based AD engine | `src/XAD/Tape.hpp`, `src/Tape.cpp` |
| Expression-template front-end types | `src/XAD/Literals.hpp`, `src/XAD/Expression.hpp` |
| Optional JIT graph/backend subsystem | `src/XAD/JITCompiler.hpp`, `src/XAD/JITBackendInterface.hpp` |
| Strong packaging / integration seams | `src/CMakeLists.txt`, `src/XAD/CheckpointCallback.hpp` |
| Eigen compatibility | `test/Eigen_test.cpp` |

These layers make XAD suitable for higher-level bindings and host-library
embedding.
