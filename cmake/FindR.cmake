##############################################################################
#
#  FindR.cmake - Locate the R installation
#
#  Searches for the R executable, headers, and shared library.
#  Sets the following variables:
#
#    R_FOUND          - TRUE if R was found
#    R_EXECUTABLE     - Path to the R executable
#    R_HOME           - R installation prefix (R.home())
#    R_INCLUDE_DIR    - Path to R headers (R.h, Rinternals.h, etc.)
#    R_LIBRARY        - Path to the R shared library (libR.so / R.dll)
#    R_VERSION        - R version string
#
##############################################################################

find_program(R_EXECUTABLE
    NAMES R R.exe
    PATHS
        /usr/bin
        /usr/local/bin
        /opt/homebrew/bin
        $ENV{R_HOME}/bin
    DOC "Path to the R executable")

if(R_EXECUTABLE)
    # Get R home directory
    execute_process(
        COMMAND ${R_EXECUTABLE} RHOME
        OUTPUT_VARIABLE R_HOME
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    # Get include directory
    execute_process(
        COMMAND ${R_EXECUTABLE} -e "cat(R.home('include'))"
        OUTPUT_VARIABLE R_INCLUDE_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    # Get library directory
    execute_process(
        COMMAND ${R_EXECUTABLE} -e "cat(R.home('lib'))"
        OUTPUT_VARIABLE _r_lib_dir
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    # Get R version
    execute_process(
        COMMAND ${R_EXECUTABLE} --version
        OUTPUT_VARIABLE _r_version_raw
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REGEX MATCH "R version ([0-9]+\\.[0-9]+\\.[0-9]+)"
           _r_ver_match "${_r_version_raw}")
    set(R_VERSION "${CMAKE_MATCH_1}")

    # Find the R shared library
    if(WIN32)
        find_library(R_LIBRARY
            NAMES R
            PATHS "${_r_lib_dir}" "${R_HOME}/bin/x64" "${R_HOME}/bin/i386"
            NO_DEFAULT_PATH)
    else()
        find_library(R_LIBRARY
            NAMES R
            PATHS "${_r_lib_dir}"
            NO_DEFAULT_PATH)
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(R
    REQUIRED_VARS R_EXECUTABLE R_INCLUDE_DIR
    VERSION_VAR   R_VERSION)

mark_as_advanced(R_EXECUTABLE R_HOME R_INCLUDE_DIR R_LIBRARY)
