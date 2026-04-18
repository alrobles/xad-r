#' xadr: R Bindings for the XAD Automatic Differentiation Library
#'
#' The xadr package provides R bindings for the XAD C++ automatic
#' differentiation library. It supports both forward (tangent-linear) mode
#' and adjoint (reverse/backpropagation) mode differentiation.
#'
#' @section Forward mode:
#' Forward mode computes the derivative of a function with respect to a single
#' input in a single forward pass. It is efficient when the number of inputs
#' is small relative to the number of outputs.
#'
#' Use \code{\link{fwd_Real}} to create active variables, seed the derivative
#' of interest with \code{\link{fwd_setDerivative}}, compute the function, and
#' read the derivative with \code{\link{fwd_getDerivative}}.
#'
#' For convenience, use \code{\link{gradient_forward}} to compute the full
#' gradient vector.
#'
#' @section Adjoint (reverse) mode:
#' Adjoint mode computes the full gradient of a scalar function in a single
#' backward sweep. It is efficient when the number of inputs is large (as in
#' machine learning or financial risk).
#'
#' Use \code{\link{adj_createTape}} to create a tape, register inputs and
#' outputs with \code{\link{adj_registerInput}} and
#' \code{\link{adj_registerOutput}}, compute the function, seed the output
#' derivative, and call \code{\link{adj_computeAdjoints}}.
#'
#' For convenience, use \code{\link{gradient_adjoint}} to compute the full
#' gradient vector.
#'
#' @section Operator overloading:
#' Both \code{xad_adj_real} and \code{xad_fwd_real} objects support standard
#' arithmetic operators (\code{+}, \code{-}, \code{*}, \code{/}, \code{^}) and
#' many mathematical functions (see \code{\link{adj_sin}}, etc.).
#'
#' @docType package
#' @name xadr-package
#' @aliases xadr
"_PACKAGE"
