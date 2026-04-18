#' @title xad: High-Performance Automatic Differentiation for R
#' @description
#' Provides R bindings to the high-performance XAD automatic differentiation
#' library. Supports both forward and adjoint (reverse) mode automatic
#' differentiation with expression templates and tape-based recording.
#'
#' @docType package
#' @name xad-package
#' @useDynLib xad, .registration = TRUE
#' @importFrom Rcpp evalCpp
NULL

# Load the Rcpp module on package load
.onLoad <- function(libname, pkgname) {
  # Load the xad module
  loadModule("xad_module", TRUE)
}
