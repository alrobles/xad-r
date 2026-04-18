# Forward mode R interface for xadr
# Provides S3 class "xad_fwd_real" with operator overloading and a
# high-level gradient_forward() function.

# ============================================================
# S3 methods for xad_fwd_real class
# ============================================================

#' @export
print.xad_fwd_real <- function(x, ...) {
  cat(sprintf("<xad_fwd_real value=%g derivative=%g>\n",
              fwd_getValue(x), fwd_getDerivative(x)))
  invisible(x)
}

#' @export
as.double.xad_fwd_real <- function(x, ...) fwd_getValue(x)

#' @export
as.numeric.xad_fwd_real <- function(x, ...) fwd_getValue(x)

#' Arithmetic operators for forward-mode active reals
#'
#' These operators enable transparent use of forward-mode active variables
#' (\code{xad_fwd_real}) in arithmetic expressions. Derivatives are propagated
#' forward alongside the function value.
#'
#' @param e1 First operand (xad_fwd_real or numeric)
#' @param e2 Second operand (xad_fwd_real or numeric)
#' @return A new \code{xad_fwd_real} object
#' @name fwd_ops
NULL

#' @rdname fwd_ops
#' @export
`+.xad_fwd_real` <- function(e1, e2) {
  if (missing(e2)) return(e1)
  if (is.numeric(e1)) e1 <- fwd_Real(e1)
  if (is.numeric(e2)) return(fwd_add_scalar(e1, e2))
  fwd_add(e1, e2)
}

#' @rdname fwd_ops
#' @export
`-.xad_fwd_real` <- function(e1, e2) {
  if (missing(e2)) return(fwd_neg(e1))
  if (is.numeric(e1)) {
    # scalar - active: -(active - scalar)
    return(fwd_neg(fwd_sub_scalar(e2, e1)))
  }
  if (is.numeric(e2)) return(fwd_sub_scalar(e1, e2))
  fwd_sub(e1, e2)
}

#' @rdname fwd_ops
#' @export
`*.xad_fwd_real` <- function(e1, e2) {
  if (is.numeric(e1)) {
    e_tmp <- e1; e1 <- e2; e2 <- e_tmp
  }
  if (is.numeric(e2)) return(fwd_mul_scalar(e1, e2))
  fwd_mul(e1, e2)
}

#' @rdname fwd_ops
#' @export
`/.xad_fwd_real` <- function(e1, e2) {
  if (is.numeric(e1)) {
    # scalar / active: scalar * active^(-1)
    return(fwd_mul_scalar(fwd_pow_scalar(e2, -1.0), e1))
  }
  if (is.numeric(e2)) return(fwd_div_scalar(e1, e2))
  fwd_div(e1, e2)
}

#' @rdname fwd_ops
#' @export
`^.xad_fwd_real` <- function(e1, e2) {
  if (is.numeric(e2)) return(fwd_pow_scalar(e1, e2))
  fwd_pow(e1, e2)
}


# ============================================================
# High-level gradient computation
# ============================================================

#' Compute the gradient of a function using forward mode
#'
#' Evaluates the function \code{f} with active forward-mode variables at the
#' given input values and returns the full gradient vector
#' \eqn{(df/dx_1, \ldots, df/dx_n)} by running the function once per input.
#'
#' Forward mode requires one function evaluation per input variable, making it
#' efficient for functions with few inputs.
#'
#' @param f A function of one or more \code{xad_fwd_real} arguments that
#'   returns a scalar \code{xad_fwd_real}. The function may use standard R
#'   arithmetic operators and the \code{fwd_*} math functions exported by this
#'   package.
#' @param x A numeric vector of input values at which to compute the gradient.
#'
#' @return A named numeric vector of partial derivatives
#'   \eqn{(df/dx_1, \ldots, df/dx_n)}.
#'
#' @examples
#' \dontrun{
#' # f(x1, x2) = x1^2 + x1 * x2
#' # grad_f = (2*x1 + x2, x1)
#' f <- function(x1, x2) x1^2 + x1 * x2
#' gradient_forward(f, c(3.0, 4.0))
#' # [1] 10  3
#' }
#'
#' @seealso \code{\link{gradient_adjoint}} for adjoint mode.
#' @export
gradient_forward <- function(f, x) {
  n <- length(x)
  grads <- numeric(n)
  nms   <- if (!is.null(names(x))) names(x) else paste0("x", seq_len(n))

  for (i in seq_len(n)) {
    # Create active variables with all derivatives zero
    xs <- lapply(x, fwd_Real)

    # Seed the i-th input derivative
    fwd_setDerivative(xs[[i]], 1.0)

    # Evaluate function
    y <- do.call(f, xs)

    # Collect derivative of output w.r.t. x_i
    grads[i] <- fwd_getDerivative(y)
  }

  names(grads) <- nms
  grads
}
