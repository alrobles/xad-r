// init.cpp - R package initialization
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <Rcpp.h>

// Forward declarations
extern "C" {
  SEXP _rcpp_module_boot_xad_module();
}

// Register native routines
static const R_CallMethodDef CallEntries[] = {
  {"_rcpp_module_boot_xad_module", (DL_FUNC) &_rcpp_module_boot_xad_module, 0},
  {NULL, NULL, 0}
};

extern "C" void R_init_xad(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
