cmake_minimum_required(VERSION 3.10)

set(CMAKE_VERBOSE_MAKEFILE off)

project(top LANGUAGES NONE)

# For debug, use
# make VERBOSE=1 <target-name>
# message(${variable-name})

# Path variables
#   Project top
set(PROJECT_TOP_DIR ${CMAKE_CURRENT_LIST_DIR})
set(INCLUDE_DIR ${PROJECT_TOP_DIR}/inc)
set(IP_DIR ${PROJECT_TOP_DIR}/ip)
set(MODULES_DIR ${PROJECT_TOP_DIR}/modules)
set(PROJECT_DIR ${PROJECT_TOP_DIR}/prj)
set(SCRIPTS_DIR ${PROJECT_TOP_DIR}/scripts)

# Include Lint and Format handlers
include(${SCRIPTS_DIR}/generic-module.cmake)
include(${SCRIPTS_DIR}/version.cmake)
include(${SCRIPTS_DIR}/lint.cmake)
include(${SCRIPTS_DIR}/vlint.cmake)
include(${SCRIPTS_DIR}/svlint.cmake)
include(${SCRIPTS_DIR}/format.cmake)
include(${SCRIPTS_DIR}/sim.cmake)

# Add a main target that depends on all module targets
add_custom_target(svlint)
add_custom_target(vlint)
add_custom_target(lint)
add_custom_target(format)
add_custom_target(sim)
add_custom_target(clean-sim)

# Initialize the global MODULES list
set(GLOBAL_MODULES "" CACHE INTERNAL "global project list of modules")
set(GLOBAL_SOURCES "" CACHE INTERNAL "global project list of sources")
set(GLOBAL_IP "" CACHE INTERNAL "global project list of vendor ip")

# Point to your custom modules (in this case, FindQuartus.cmake)
list(APPEND CMAKE_MODULE_PATH ${SCRIPTS_DIR})

# Include CMake files for the sources
include(${PROJECT_DIR}/sources.cmake)

# Iterate over the GLOBAL_MODULES list and add dependencies
foreach(MODULE ${GLOBAL_MODULES})
    message("Adding module ${MODULE}")
    add_dependencies(svlint svlint-${MODULE})
    add_dependencies(vlint vlint-${MODULE})
    add_dependencies(lint lint-${MODULE})
    add_dependencies(format format-${MODULE})
    add_dependencies(sim sim-${MODULE})
    add_dependencies(clean-sim clean-sim-${MODULE})
endforeach()

# Generate .f for source files
foreach(SRC ${GLOBAL_SOURCES})
    message("Global Source file: ${SRC}")
endforeach()
list(SORT GLOBAL_SOURCES)
string(REPLACE ";" "\n" file_content "${GLOBAL_SOURCES}")
file(WRITE "${CMAKE_BINARY_DIR}/${PROJECT_NAME}-src-generated.f" "${file_content}\n")
message(STATUS "Generated file list: ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-src-generated.f")

# Generate .f for IP files
foreach(SRC ${GLOBAL_IP})
    message("Global IP file: ${SRC}")
endforeach()
list(SORT GLOBAL_IP)
string(REPLACE ";" "\n" file_content "${GLOBAL_IP}")
file(WRITE "${CMAKE_BINARY_DIR}/${PROJECT_NAME}-ip-generated.f" "${file_content}\n")
message(STATUS "Generated file list: ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-ip-generated.f")
