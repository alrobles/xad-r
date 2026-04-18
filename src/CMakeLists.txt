cmake_minimum_required(VERSION 3.15)

# Sources for the R package shared library
set(SOURCES
  init.cpp
  rcpp_module.cpp
)

# Create the shared library for R
add_library(xad SHARED ${SOURCES})

# Link against R
target_link_libraries(xad ${R_LIBRARIES})

# Set output properties
set_target_properties(xad PROPERTIES
  PREFIX ""
  SUFFIX ".so"
  OUTPUT_NAME "xad"
)

# On Windows, use .dll extension
if(WIN32)
  set_target_properties(xad PROPERTIES SUFFIX ".dll")
endif()

# On macOS, use .so extension (R convention, not .dylib)
if(APPLE)
  set_target_properties(xad PROPERTIES SUFFIX ".so")
endif()

# Install the shared library
install(TARGETS xad
  LIBRARY DESTINATION libs
  RUNTIME DESTINATION libs
)
