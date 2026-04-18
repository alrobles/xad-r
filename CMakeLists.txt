cmake_minimum_required(VERSION 3.15)
project(xad-r VERSION 0.1.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add cmake modules path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Find R
find_package(R REQUIRED)
message(STATUS "Found R: ${R_EXECUTABLE} (version ${R_VERSION_STRING})")
message(STATUS "R_HOME: ${R_HOME}")
message(STATUS "R_INCLUDE_DIRS: ${R_INCLUDE_DIRS}")

# Find Rcpp
execute_process(
  COMMAND ${R_EXECUTABLE} --slave --vanilla -e "cat(system.file('include', package='Rcpp'))"
  OUTPUT_VARIABLE RCPP_INCLUDE_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(NOT EXISTS ${RCPP_INCLUDE_DIR})
  message(FATAL_ERROR "Rcpp package not found. Please install it in R: install.packages('Rcpp')")
endif()

message(STATUS "Rcpp include directory: ${RCPP_INCLUDE_DIR}")

# XAD library (will be added as submodule)
# For now, we'll set up the structure to find it
set(XAD_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/xad")
if(EXISTS ${XAD_INCLUDE_DIR})
  message(STATUS "XAD include directory: ${XAD_INCLUDE_DIR}")
else()
  message(WARNING "XAD submodule not found at ${XAD_INCLUDE_DIR}. Please run: git submodule update --init --recursive")
endif()

# Include directories
include_directories(
  ${R_INCLUDE_DIRS}
  ${RCPP_INCLUDE_DIR}
  ${XAD_INCLUDE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Add subdirectories
add_subdirectory(src)

# Enable testing
enable_testing()
add_subdirectory(tests)

# Installation
install(DIRECTORY include/xad-r
  DESTINATION include
  FILES_MATCHING PATTERN "*.hpp"
)

# Package configuration
include(CMakePackageConfigHelper)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/xad-rConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/xad-rConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/xad-rConfig.cmake"
  INSTALL_DESTINATION lib/cmake/xad-r
)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/xad-rConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/xad-rConfigVersion.cmake"
  DESTINATION lib/cmake/xad-r
)
