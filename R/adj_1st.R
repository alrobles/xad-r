# Adjoint (reverse) mode R interface for xadr
# Provides S3 class "xad_adj_real" with operator overloading and a
# high-level gradient_adjoint() function.

# ============================================================
# S3 methods for xad_adj_real class
# ============================================================

#' @export
print.xad_adj_real <- function(x, ...) {
  cat(sprintf("<xad_adj_real value=%g derivative=%g>\n",
              adj_getValue(x), adj_getDerivative(x)))
  invisible(x)
}

#' @export
as.double.xad_adj_real <- function(x, ...) adj_getValue(x)

#' @export
as.numeric.xad_adj_real <- function(x, ...) adj_getValue(x)

#' Arithmetic operators for adjoint-mode active reals
#'
#' These operators enable transparent use of adjoint-mode active variables
#' (\code{xad_adj_real}) in arithmetic expressions. They record operations
#' on the active tape for subsequent adjoint computation.
#'
#' @param e1 First operand (xad_adj_real or numeric)
#' @param e2 Second operand (xad_adj_real or numeric)
#' @return A new \code{xad_adj_real} object
#' @name adj_ops
NULL

#' @rdname adj_ops
#' @export
`+.xad_adj_real` <- function(e1, e2) {
  if (missing(e2)) return(e1)
  if (is.numeric(e1)) e1 <- adj_Real(e1)
  if (is.numeric(e2)) return(adj_add_scalar(e1, e2))
  adj_add(e1, e2)
}

#' @rdname adj_ops
#' @export
`-.xad_adj_real` <- function(e1, e2) {
  if (missing(e2)) return(adj_neg(e1))
  if (is.numeric(e1)) {
    # scalar - active: -(active - scalar)
    return(adj_neg(adj_sub_scalar(e2, e1)))
  }
  if (is.numeric(e2)) return(adj_sub_scalar(e1, e2))
  adj_sub(e1, e2)
}

#' @rdname adj_ops
#' @export
`*.xad_adj_real` <- function(e1, e2) {
  if (is.numeric(e1)) {
    e_tmp <- e1; e1 <- e2; e2 <- e_tmp
  }
  if (is.numeric(e2)) return(adj_mul_scalar(e1, e2))
  adj_mul(e1, e2)
}

#' @rdname adj_ops
#' @export
`/.xad_adj_real` <- function(e1, e2) {
  if (is.numeric(e1)) {
    # scalar / active: use pow(-1)
    return(adj_mul_scalar(adj_pow_scalar(e2, -1.0), e1))
  }
  if (is.numeric(e2)) return(adj_div_scalar(e1, e2))
  adj_div(e1, e2)
}

#' @rdname adj_ops
#' @export
`^.xad_adj_real` <- function(e1, e2) {
  if (is.numeric(e2)) return(adj_pow_scalar(e1, e2))
  adj_pow(e1, e2)
}


# ============================================================
# High-level gradient computation
# ============================================================

#' Compute the gradient of a function using adjoint (reverse) mode
#'
#' Evaluates the function \code{f} with active adjoint variables at the given
#' input values and returns the full gradient vector \eqn{df/dx_i} for all
#' inputs in a single backward sweep.
#'
#' Adjoint mode requires only one forward evaluation and one backward sweep to
#' compute all partial derivatives, making it highly efficient for functions
#' with many inputs and a scalar output.
#'
#' @param f A function of one or more \code{xad_adj_real} arguments that
#'   returns a scalar \code{xad_adj_real}. The function may use standard R
#'   arithmetic operators (\code{+}, \code{-}, \code{*}, \code{/}, \code{^})
#'   and the \code{adj_*} math functions exported by this package.
#' @param x A numeric vector of input values at which to compute the gradient.
#'
#' @return A named numeric vector of partial derivatives
#'   \eqn{(df/dx_1, \ldots, df/dx_n)}.
#'
#' @examples
#' \dontrun{
#' # f(x1, x2) = x1 * x2 + sin(x1)
#' # grad_f = (x2 + cos(x1), x1)
#' f <- function(x1, x2) x1 * x2 + adj_sin(x1)
#' gradient_adjoint(f, c(1.0, 2.0))
#' # [1] 2.540302  1.000000
#' }
#'
#' @seealso \code{\link{gradient_forward}} for forward mode.
#' @export
gradient_adjoint <- function(f, x) {
  n <- length(x)
  tape <- adj_createTape()
  on.exit(adj_deactivateTape(tape), add = TRUE)

  # Create active variables and register as inputs
  xs <- lapply(x, function(xi) {
    ax <- adj_Real(xi)
    adj_registerInput(tape, ax)
    ax
  })

  adj_newRecording(tape)

  # Evaluate function
  y <- do.call(f, xs)

  # Register output and seed
  adj_registerOutput(tape, y)
  adj_setDerivative(y, 1.0)

  # Backward sweep
  adj_computeAdjoints(tape)

  # Collect gradients
  grads <- vapply(xs, adj_getDerivative, numeric(1))
  names(grads) <- if (!is.null(names(x))) names(x) else paste0("x", seq_len(n))
  grads
}
