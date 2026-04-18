/***************************************************************************
 * xad-r - R bindings for the XAD automatic differentiation library
 *
 * Main header file - include this to use xad-r
 ***************************************************************************/

#ifndef XAD_R_HPP
#define XAD_R_HPP

// Core configuration
#include "xad_r_config.hpp"

// Utilities
#include "rutils.hpp"

// XAD integration (if available)
#if XAD_R_HAS_XAD
#include <XAD/XAD.hpp>
#endif

namespace xad {
namespace r {

// Placeholder for future container classes
// Will add RArray, RTensor, etc. in future phases

} // namespace r
} // namespace xad

#endif // XAD_R_HPP
