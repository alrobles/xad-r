# Math function dispatchers for xadr
# These generic functions dispatch to the appropriate adj_* or fwd_* C++
# binding based on the class of the argument.  Regular numeric arguments
# fall back to base R math functions.

# Helper: determine whether an object is an active adjoint variable
.is_adj <- function(x) inherits(x, "xad_adj_real")

# Helper: determine whether an object is an active forward variable
.is_fwd <- function(x) inherits(x, "xad_fwd_real")

# Helper: determine whether an object is any kind of active variable
.is_active <- function(x) .is_adj(x) || .is_fwd(x)

#' @export
sin.xad_adj_real  <- function(x) adj_sin(x)
#' @export
sin.xad_fwd_real  <- function(x) fwd_sin(x)
#' @export
cos.xad_adj_real  <- function(x) adj_cos(x)
#' @export
cos.xad_fwd_real  <- function(x) fwd_cos(x)
#' @export
tan.xad_adj_real  <- function(x) adj_tan(x)
#' @export
tan.xad_fwd_real  <- function(x) fwd_tan(x)
#' @export
asin.xad_adj_real <- function(x) adj_asin(x)
#' @export
asin.xad_fwd_real <- function(x) fwd_asin(x)
#' @export
acos.xad_adj_real <- function(x) adj_acos(x)
#' @export
acos.xad_fwd_real <- function(x) fwd_acos(x)
#' @export
atan.xad_adj_real <- function(x) adj_atan(x)
#' @export
atan.xad_fwd_real <- function(x) fwd_atan(x)
#' @export
exp.xad_adj_real  <- function(x) adj_exp(x)
#' @export
exp.xad_fwd_real  <- function(x) fwd_exp(x)
#' @export
log.xad_adj_real  <- function(x, base = exp(1)) {
  if (base == exp(1)) return(adj_log(x))
  adj_div(adj_log(x), adj_Real(log(base)))
}
#' @export
log.xad_fwd_real  <- function(x, base = exp(1)) {
  if (base == exp(1)) return(fwd_log(x))
  fwd_div(fwd_log(x), fwd_Real(log(base)))
}
#' @export
log10.xad_adj_real <- function(x) adj_log10(x)
#' @export
log10.xad_fwd_real <- function(x) fwd_log10(x)
#' @export
log2.xad_adj_real  <- function(x) adj_log2(x)
#' @export
log2.xad_fwd_real  <- function(x) fwd_log2(x)
#' @export
sqrt.xad_adj_real  <- function(x) adj_sqrt(x)
#' @export
sqrt.xad_fwd_real  <- function(x) fwd_sqrt(x)
#' @export
abs.xad_adj_real   <- function(x) adj_abs(x)
#' @export
abs.xad_fwd_real   <- function(x) fwd_abs(x)
#' @export
sinh.xad_adj_real  <- function(x) adj_sinh(x)
#' @export
sinh.xad_fwd_real  <- function(x) fwd_sinh(x)
#' @export
cosh.xad_adj_real  <- function(x) adj_cosh(x)
#' @export
cosh.xad_fwd_real  <- function(x) fwd_cosh(x)
#' @export
tanh.xad_adj_real  <- function(x) adj_tanh(x)
#' @export
tanh.xad_fwd_real  <- function(x) fwd_tanh(x)
#' @export
floor.xad_adj_real <- function(x) adj_floor(x)
#' @export
floor.xad_fwd_real <- function(x) fwd_floor(x)
#' @export
ceiling.xad_adj_real <- function(x) adj_ceil(x)
#' @export
ceiling.xad_fwd_real <- function(x) fwd_ceil(x)
#' @export
round.xad_adj_real <- function(x, digits = 0) {
  if (digits != 0) stop("xad round() only supports digits=0")
  adj_round(x)
}
