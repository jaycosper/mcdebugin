cmake_minimum_required(VERSION 3.10)

# Define the formatter executable
set(VERSION_APP_NAME tclsh)
find_program(VERSION_CODE_APP ${VERSION_APP_NAME})

if(NOT VERSION_CODE_APP)
    message(FATAL_ERROR "Code version script app ${VERSION_APP_NAME} not found. Please install it or ensure it's in your PATH.")
endif()

set(VERSION_SCRIPT ${SCRIPTS_DIR}/version.tcl)

# Add a custom target for SV linting the library's sources
add_custom_target(
    version
    COMMAND ${VERSION_APP_NAME} ${VERSION_SCRIPT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    COMMENT "Running Automatic Version Generatation"
    VERBATIM
)

# Add generated files to clean target
set_property(TARGET version APPEND PROPERTY ADDITIONAL_CLEAN_FILES
    "${PROJECT_DIR}/inc/auto_version_pkg.sv"
)
