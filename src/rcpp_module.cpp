// rcpp_module.cpp - Rcpp module definition for xad
#include <Rcpp.h>

// Check if XAD is available
#if __has_include(<XAD/XAD.hpp>)
#include <XAD/XAD.hpp>
#define HAS_XAD 1
#else
#define HAS_XAD 0
#endif

using namespace Rcpp;

// Module definition
RCPP_MODULE(xad_module) {
  #if HAS_XAD
  // XAD is available - we'll add bindings here
  // For now, just expose version information

  function("xad_available", []() {
    return true;
  }, "Check if XAD is available");

  #else
  // XAD not available
  function("xad_available", []() {
    return false;
  }, "Check if XAD is available");
  #endif

  function("xad_version", []() {
    return "0.1.0";
  }, "Get xad-r version");
}

// Export the module boot function
extern "C" SEXP _rcpp_module_boot_xad_module() {
  return Rcpp::internal::module_boot("xad_module");
}
