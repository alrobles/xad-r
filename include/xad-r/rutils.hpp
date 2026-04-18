/***************************************************************************
 * xad-r - R bindings for the XAD automatic differentiation library
 *
 * This file provides utilities for R memory layout and shape handling,
 * following patterns from xtensor-r for zero-copy integration.
 ***************************************************************************/

#ifndef XAD_R_UTILS_HPP
#define XAD_R_UTILS_HPP

#include "xad_r_config.hpp"
#include <vector>
#include <cstddef>

namespace xad {
namespace r {

// Get dimensions from R SEXP
inline std::vector<std::size_t> get_shape(SEXP obj) {
  std::vector<std::size_t> shape;

  // Get dimension attribute
  SEXP dim = Rf_getAttrib(obj, R_DimSymbol);

  if (Rf_isNull(dim)) {
    // No dimension attribute - treat as 1D vector
    shape.push_back(Rf_length(obj));
  } else {
    // Extract dimensions from attribute
    int ndim = Rf_length(dim);
    int* dim_ptr = INTEGER(dim);
    for (int i = 0; i < ndim; ++i) {
      shape.push_back(static_cast<std::size_t>(dim_ptr[i]));
    }
  }

  return shape;
}

// Compute strides for column-major layout (R's native layout)
inline std::vector<std::size_t> compute_strides(const std::vector<std::size_t>& shape) {
  std::vector<std::size_t> strides(shape.size());

  if (shape.empty()) {
    return strides;
  }

  // Column-major: first dimension has stride 1
  strides[0] = 1;
  for (std::size_t i = 1; i < shape.size(); ++i) {
    strides[i] = strides[i-1] * shape[i-1];
  }

  return strides;
}

// Compute total size from shape
inline std::size_t compute_size(const std::vector<std::size_t>& shape) {
  std::size_t size = 1;
  for (auto s : shape) {
    size *= s;
  }
  return size;
}

// Check if SEXP is a numeric type suitable for AD
inline bool is_numeric_type(SEXP obj) {
  int type = TYPEOF(obj);
  return (type == REALSXP || type == INTSXP);
}

} // namespace r
} // namespace xad

#endif // XAD_R_UTILS_HPP
