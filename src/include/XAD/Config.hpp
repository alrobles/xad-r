/*******************************************************************************

   Pre-generated configuration settings for xad-r R package.
   Generated from XAD/Config.hpp.in with default settings.

******************************************************************************/

#pragma once

/* These options can be changed in client code, after XAD has already been compiled */

// Use strong inlining for higher performance - but compiles significantly slower
#ifndef XAD_USE_STRONG_INLINE
/* #undef XAD_USE_STRONG_INLINE */
#endif

// Allow conversion operator from active type to integers, potentially missing some
// AAD variable dependency tracking
#ifndef XAD_ALLOW_INT_CONVERSION
/* #undef XAD_ALLOW_INT_CONVERSION */
#endif


/******* The following options should not be touched after compilation of XAD */

// keep track of freed-up slots in the tape and re-use them
/* #undef XAD_TAPE_REUSE_SLOTS */

// Disable thread-local tape usage
/* #undef XAD_NO_THREADLOCAL */

// Reduce memory usage in the tape, at a slight performance cost
/* #undef XAD_REDUCED_MEMORY */

// Enable codegen (JIT compilation) support
/* #undef XAD_ENABLE_CODEGEN */
// Internal: set when codegen is enabled
/* #undef XAD_ENABLE_JIT */
