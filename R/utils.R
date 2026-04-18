#' Check if XAD is available
#'
#' @return Logical value indicating whether XAD library is available
#' @export
#' @examples
#' xad_available()
xad_available <- function() {
  .Call("_rcpp_module_boot_xad_module")
  # This will be implemented through the module
  TRUE
}

#' Get xad-r version
#'
#' @return Character string with the xad-r version
#' @export
#' @examples
#' xad_version()
xad_version <- function() {
  "0.1.0"
}

#' Print package information
#'
#' @export
xad_info <- function() {
  cat("xad-r: R bindings for XAD automatic differentiation library\n")
  cat("Version:", xad_version(), "\n")
  cat("XAD available:", xad_available(), "\n")
  invisible(NULL)
}
