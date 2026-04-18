/*******************************************************************************

   Rcpp bindings for the XAD automatic differentiation library.

   This file is part of xad-r, R bindings for XAD.

   Copyright (C) 2010-2026 Xcelerit Computing Ltd.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU Affero General Public License as published
   by the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

******************************************************************************/

// [[Rcpp::plugins(cpp17)]]
#include <Rcpp.h>

// XAD headers (submodule at src/xad)
#include <XAD/XAD.hpp>

#include <memory>
#include <stdexcept>
#include <string>

// ============================================================
// Type aliases
// ============================================================

// Adjoint (reverse) mode
typedef xad::adj<double> adj_mode;
typedef adj_mode::active_type AReal;
typedef adj_mode::tape_type   Tape;

// Forward mode
typedef xad::fwd<double> fwd_mode;
typedef fwd_mode::active_type FReal;


// ============================================================
// Helper: throw XAD exceptions as R errors
// ============================================================

[[noreturn]] inline void xad_rethrow(const std::exception& e) {
    Rcpp::stop(e.what());
}

#define XAD_TRY_BEGIN try {
#define XAD_TRY_END } catch (const std::exception& e) { xad_rethrow(e); }


// ============================================================
// Adjoint mode: AReal (external pointer wrapper)
// ============================================================

//' Create an adjoint-mode active real number
//'
//' @param v Initial value (default 0.0)
//' @return An external pointer to an AReal object
//' @export
// [[Rcpp::export]]
SEXP adj_Real(double v = 0.0) {
    XAD_TRY_BEGIN
    auto* ptr = new AReal(v);
    Rcpp::XPtr<AReal> xptr(ptr, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' Get the value of an adjoint-mode active real
//'
//' @param xptr An XPtr to an AReal object (class "xad_adj_real")
//' @return The double value
//' @export
// [[Rcpp::export]]
double adj_getValue(SEXP xptr) {
    Rcpp::XPtr<AReal> x(xptr);
    return xad::value(*x);
}

//' Get the derivative (adjoint) of an adjoint-mode active real
//'
//' @param xptr An XPtr to an AReal object
//' @return The derivative value
//' @export
// [[Rcpp::export]]
double adj_getDerivative(SEXP xptr) {
    Rcpp::XPtr<AReal> x(xptr);
    return xad::derivative(*x);
}

//' Set the derivative (adjoint) of an adjoint-mode active real
//'
//' @param xptr An XPtr to an AReal object
//' @param d Derivative value to set
//' @export
// [[Rcpp::export]]
void adj_setDerivative(SEXP xptr, double d) {
    Rcpp::XPtr<AReal> x(xptr);
    xad::derivative(*x) = d;
}


// ============================================================
// Adjoint mode: Tape
// ============================================================

//' Create an adjoint-mode tape
//'
//' @return An external pointer to a Tape object
//' @export
// [[Rcpp::export]]
SEXP adj_createTape() {
    XAD_TRY_BEGIN
    auto* ptr = new Tape(true);  // activate immediately
    Rcpp::XPtr<Tape> xptr(ptr, true);
    xptr.attr("class") = "xad_tape";
    return xptr;
    XAD_TRY_END
}

//' Deactivate an adjoint-mode tape (but do not destroy it)
//'
//' @param tape_ptr An XPtr to a Tape object
//' @export
// [[Rcpp::export]]
void adj_deactivateTape(SEXP tape_ptr) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<Tape> tape(tape_ptr);
    tape->deactivate();
    XAD_TRY_END
}

//' Deactivate all tapes for the current thread
//'
//' @export
// [[Rcpp::export]]
void adj_deactivateAll() {
    Tape::deactivateAll();
}

//' Register an input variable on the tape
//'
//' @param tape_ptr An XPtr to a Tape object
//' @param xptr An XPtr to an AReal object
//' @export
// [[Rcpp::export]]
void adj_registerInput(SEXP tape_ptr, SEXP xptr) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<Tape> tape(tape_ptr);
    Rcpp::XPtr<AReal> x(xptr);
    tape->registerInput(*x);
    XAD_TRY_END
}

//' Register an output variable on the tape
//'
//' @param tape_ptr An XPtr to a Tape object
//' @param xptr An XPtr to an AReal object
//' @export
// [[Rcpp::export]]
void adj_registerOutput(SEXP tape_ptr, SEXP xptr) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<Tape> tape(tape_ptr);
    Rcpp::XPtr<AReal> x(xptr);
    tape->registerOutput(*x);
    XAD_TRY_END
}

//' Start a new recording on the tape
//'
//' @param tape_ptr An XPtr to a Tape object
//' @export
// [[Rcpp::export]]
void adj_newRecording(SEXP tape_ptr) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<Tape> tape(tape_ptr);
    tape->newRecording();
    XAD_TRY_END
}

//' Compute adjoints (backpropagate derivatives) on the tape
//'
//' @param tape_ptr An XPtr to a Tape object
//' @export
// [[Rcpp::export]]
void adj_computeAdjoints(SEXP tape_ptr) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<Tape> tape(tape_ptr);
    tape->computeAdjoints();
    XAD_TRY_END
}

//' Clear all adjoints on the tape (keeping the recording)
//'
//' @param tape_ptr An XPtr to a Tape object
//' @export
// [[Rcpp::export]]
void adj_clearDerivatives(SEXP tape_ptr) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<Tape> tape(tape_ptr);
    tape->clearDerivatives();
    XAD_TRY_END
}


// ============================================================
// Adjoint mode: Arithmetic operations
// ============================================================

//' Add two adjoint-mode active reals
//' @param a First XPtr to AReal
//' @param b Second XPtr to AReal
//' @return New XPtr to AReal (result)
//' @export
// [[Rcpp::export]]
SEXP adj_add(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(*xa + *xb);
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' Add an adjoint-mode active real and a scalar
//' @param a XPtr to AReal
//' @param b Scalar double
//' @return New XPtr to AReal (result)
//' @export
// [[Rcpp::export]]
SEXP adj_add_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(*xa + b);
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' Subtract two adjoint-mode active reals
//' @param a First XPtr to AReal
//' @param b Second XPtr to AReal
//' @return New XPtr to AReal (result)
//' @export
// [[Rcpp::export]]
SEXP adj_sub(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(*xa - *xb);
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' Subtract a scalar from an adjoint-mode active real
//' @param a XPtr to AReal
//' @param b Scalar double
//' @return New XPtr to AReal (result)
//' @export
// [[Rcpp::export]]
SEXP adj_sub_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(*xa - b);
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' Multiply two adjoint-mode active reals
//' @param a First XPtr to AReal
//' @param b Second XPtr to AReal
//' @return New XPtr to AReal (result)
//' @export
// [[Rcpp::export]]
SEXP adj_mul(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(*xa * *xb);
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' Multiply an adjoint-mode active real by a scalar
//' @param a XPtr to AReal
//' @param b Scalar double
//' @return New XPtr to AReal (result)
//' @export
// [[Rcpp::export]]
SEXP adj_mul_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(*xa * b);
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' Divide two adjoint-mode active reals
//' @param a First XPtr to AReal (numerator)
//' @param b Second XPtr to AReal (denominator)
//' @return New XPtr to AReal (result)
//' @export
// [[Rcpp::export]]
SEXP adj_div(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(*xa / *xb);
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' Divide an adjoint-mode active real by a scalar
//' @param a XPtr to AReal (numerator)
//' @param b Scalar double (denominator)
//' @return New XPtr to AReal (result)
//' @export
// [[Rcpp::export]]
SEXP adj_div_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(*xa / b);
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' Negate an adjoint-mode active real
//' @param a XPtr to AReal
//' @return New XPtr to AReal (negated)
//' @export
// [[Rcpp::export]]
SEXP adj_neg(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(-(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}


// ============================================================
// Adjoint mode: Math functions
// ============================================================

#define ADJ_MATH_UNARY(fname, xfunc) \
//' @rdname adj_math \
//' @export \
// [[Rcpp::export]] \
SEXP fname(SEXP a) { \
    XAD_TRY_BEGIN \
    Rcpp::XPtr<AReal> xa(a); \
    auto* res = new AReal(xad::xfunc(*xa)); \
    Rcpp::XPtr<AReal> xptr(res, true); \
    xptr.attr("class") = "xad_adj_real"; \
    return xptr; \
    XAD_TRY_END \
}

//' @export
// [[Rcpp::export]]
SEXP adj_sin(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::sin(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_cos(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::cos(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_tan(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::tan(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_asin(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::asin(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_acos(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::acos(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_atan(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::atan(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_atan2(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::atan2(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_exp(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::exp(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_exp2(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::exp2(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_expm1(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::expm1(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_log(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::log(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_log2(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::log2(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_log10(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::log10(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_log1p(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::log1p(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_sqrt(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::sqrt(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_cbrt(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::cbrt(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_pow(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::pow(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_pow_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::pow(*xa, b));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_abs(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::abs(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_fabs(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::fabs(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_sinh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::sinh(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_cosh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::cosh(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_tanh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::tanh(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_asinh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::asinh(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_acosh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::acosh(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_atanh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::atanh(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_erf(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::erf(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_erfc(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::erfc(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_floor(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::floor(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_ceil(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::ceil(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_round(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::round(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_trunc(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::trunc(*xa));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_min(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::min(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_max(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::max(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_fmax(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::fmax(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_fmin(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::fmin(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_hypot(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::hypot(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_ldexp(SEXP a, int exp) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    auto* res = new AReal(xad::ldexp(*xa, exp));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_fmod(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::fmod(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_remainder(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::remainder(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP adj_copysign(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<AReal> xa(a);
    Rcpp::XPtr<AReal> xb(b);
    auto* res = new AReal(xad::copysign(*xa, *xb));
    Rcpp::XPtr<AReal> xptr(res, true);
    xptr.attr("class") = "xad_adj_real";
    return xptr;
    XAD_TRY_END
}


// ============================================================
// Forward mode: FReal
// ============================================================

//' Create a forward-mode active real number
//'
//' @param v Initial value (default 0.0)
//' @return An external pointer to an FReal object
//' @export
// [[Rcpp::export]]
SEXP fwd_Real(double v = 0.0) {
    XAD_TRY_BEGIN
    auto* ptr = new FReal(v);
    Rcpp::XPtr<FReal> xptr(ptr, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' Get the value of a forward-mode active real
//'
//' @param xptr An XPtr to an FReal object (class "xad_fwd_real")
//' @return The double value
//' @export
// [[Rcpp::export]]
double fwd_getValue(SEXP xptr) {
    Rcpp::XPtr<FReal> x(xptr);
    return xad::value(*x);
}

//' Get the derivative of a forward-mode active real
//'
//' @param xptr An XPtr to an FReal object
//' @return The derivative value
//' @export
// [[Rcpp::export]]
double fwd_getDerivative(SEXP xptr) {
    Rcpp::XPtr<FReal> x(xptr);
    return xad::derivative(*x);
}

//' Set the derivative seed of a forward-mode active real
//'
//' @param xptr An XPtr to an FReal object
//' @param d Derivative value to set (seed)
//' @export
// [[Rcpp::export]]
void fwd_setDerivative(SEXP xptr, double d) {
    Rcpp::XPtr<FReal> x(xptr);
    xad::derivative(*x) = d;
}


// ============================================================
// Forward mode: Arithmetic operations
// ============================================================

//' @export
// [[Rcpp::export]]
SEXP fwd_add(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    Rcpp::XPtr<FReal> xb(b);
    auto* res = new FReal(*xa + *xb);
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_add_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(*xa + b);
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_sub(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    Rcpp::XPtr<FReal> xb(b);
    auto* res = new FReal(*xa - *xb);
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_sub_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(*xa - b);
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_mul(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    Rcpp::XPtr<FReal> xb(b);
    auto* res = new FReal(*xa * *xb);
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_mul_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(*xa * b);
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_div(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    Rcpp::XPtr<FReal> xb(b);
    auto* res = new FReal(*xa / *xb);
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_div_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(*xa / b);
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_neg(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(-(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_pow(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    Rcpp::XPtr<FReal> xb(b);
    auto* res = new FReal(xad::pow(*xa, *xb));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_pow_scalar(SEXP a, double b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::pow(*xa, b));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}


// ============================================================
// Forward mode: Math functions
// ============================================================

//' @export
// [[Rcpp::export]]
SEXP fwd_sin(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::sin(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_cos(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::cos(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_tan(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::tan(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_asin(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::asin(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_acos(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::acos(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_atan(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::atan(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_atan2(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    Rcpp::XPtr<FReal> xb(b);
    auto* res = new FReal(xad::atan2(*xa, *xb));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_exp(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::exp(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_exp2(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::exp2(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_expm1(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::expm1(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_log(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::log(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_log2(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::log2(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_log10(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::log10(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_log1p(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::log1p(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_sqrt(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::sqrt(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_cbrt(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::cbrt(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_abs(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::abs(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_sinh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::sinh(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_cosh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::cosh(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_tanh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::tanh(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_asinh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::asinh(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_acosh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::acosh(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_atanh(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::atanh(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_erf(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::erf(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_erfc(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::erfc(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_floor(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::floor(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_ceil(SEXP a) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    auto* res = new FReal(xad::ceil(*xa));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_hypot(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    Rcpp::XPtr<FReal> xb(b);
    auto* res = new FReal(xad::hypot(*xa, *xb));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_min(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    Rcpp::XPtr<FReal> xb(b);
    auto* res = new FReal(xad::min(*xa, *xb));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}

//' @export
// [[Rcpp::export]]
SEXP fwd_max(SEXP a, SEXP b) {
    XAD_TRY_BEGIN
    Rcpp::XPtr<FReal> xa(a);
    Rcpp::XPtr<FReal> xb(b);
    auto* res = new FReal(xad::max(*xa, *xb));
    Rcpp::XPtr<FReal> xptr(res, true);
    xptr.attr("class") = "xad_fwd_real";
    return xptr;
    XAD_TRY_END
}


// ============================================================
// Version info
// ============================================================

//' Get the XAD library version string
//'
//' @return A character string with the XAD version
//' @export
// [[Rcpp::export]]
std::string xad_version() {
    return XAD_VERSION_STRING;
}
