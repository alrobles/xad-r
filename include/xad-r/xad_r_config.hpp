/***************************************************************************
 * xad-r - R bindings for the XAD automatic differentiation library
 *
 * Copyright (C) 2026 xad-r contributors
 *
 * This file is part of xad-r, which provides R bindings to the XAD
 * automatic differentiation library.
 *
 * xad-r is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * xad-r is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 ***************************************************************************/

#ifndef XAD_R_CONFIG_HPP
#define XAD_R_CONFIG_HPP

#define XAD_R_VERSION_MAJOR 0
#define XAD_R_VERSION_MINOR 1
#define XAD_R_VERSION_PATCH 0

// Check for XAD availability
#if __has_include(<XAD/XAD.hpp>)
#define XAD_R_HAS_XAD 1
#else
#define XAD_R_HAS_XAD 0
#endif

// R and Rcpp includes
#include <R.h>
#include <Rinternals.h>
#include <Rcpp.h>

// Standard library
#include <cstddef>
#include <array>
#include <vector>
#include <algorithm>

namespace xad {
namespace r {

// Version information
inline constexpr int version_major() { return XAD_R_VERSION_MAJOR; }
inline constexpr int version_minor() { return XAD_R_VERSION_MINOR; }
inline constexpr int version_patch() { return XAD_R_VERSION_PATCH; }

} // namespace r
} // namespace xad

#endif // XAD_R_CONFIG_HPP
