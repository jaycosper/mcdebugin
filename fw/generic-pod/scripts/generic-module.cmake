# Generic CMake module
## intended to be included in other CMake files to define a module's targets and dependencies.
function(create_module_targets)

    # Define the arguments
    set(options)
    set(oneValueArgs MODULE_NAME MODULE_DIR TESTBENCH)
    set(multiValueArgs SOURCES)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Check for required arguments
    if(NOT ARG_MODULE_NAME)
        message(FATAL_ERROR "MODULE_NAME is required")
    endif()

    if(NOT ARG_MODULE_DIR)
        message(FATAL_ERROR "MODULE_DIR is required")
    endif()

    # Set local variables from arguments
    set(fMODULE_NAME ${ARG_MODULE_NAME})
    set(fMODULE_DIR ${ARG_MODULE_DIR})

    # Handle optional sources
    if(ARG_SOURCES)
        set(fSOURCES ${ARG_SOURCES})
        message(STATUS "Creating targets for module '${fMODULE_NAME}' with sources: ${fSOURCES}")
    else()
        set(fSOURCES "")
        message(STATUS "Creating targets for module '${fMODULE_NAME}' with no sources")
    endif()

    # Handle optional testcases
    if(ARG_TESTBENCH)
        set(fMODULE_SIM_TESTBENCH ${ARG_TESTBENCH})
        get_filename_component(TB_NAME ${fMODULE_SIM_TESTBENCH} NAME_WE)
        set(SIM_ARTIFACTS_DIR "${TB_NAME}_sim_objs")
        message(STATUS "Creating targets for module '${fMODULE_NAME}' with testbench: ${fMODULE_SIM_TESTBENCH}")
    else()
        set(fMODULE_SIM_TESTBENCH "")
        message(STATUS "No testbench defined for module '${fMODULE_NAME}'; Creating dummy targets")
    endif()

    # Define simulation artifacts directory
    set(SIM_ARTIFACTS_PATH ${CMAKE_BINARY_DIR}/${SIM_ARTIFACTS_DIR})

    # Add the module name to the global MODULES list
    list(APPEND GLOBAL_MODULES ${fMODULE_NAME})
    set(GLOBAL_MODULES ${GLOBAL_MODULES} PARENT_SCOPE)
    list(APPEND GLOBAL_SOURCES ${fSOURCES})
    set(GLOBAL_SOURCES ${GLOBAL_SOURCES} PARENT_SCOPE)

    list(APPEND MODULE_LINT_OPTIONS ${GLOBAL_LINT_OPTIONS})
    list(APPEND MODULE_SVLINT_OPTIONS ${GLOBAL_SVLINT_OPTIONS})
    set(SIM_EXE_NAME V${fMODULE_NAME}-sim)
    list(APPEND MODULE_SIM_OPTIONS ${GLOBAL_SIM_OPTIONS} -o ${SIM_EXE_NAME} --Mdir ${SIM_ARTIFACTS_DIR})
    list(APPEND MODULE_AUTO_SIM_OPTIONS ${GLOBAL_SIM_OPTIONS} -c -do)

    # Add a custom target for SV linting the library's sources
    add_custom_target(
        svlint-${fMODULE_NAME}
        COMMAND ${SV_CODE_LINTER} ${MODULE_SVLINT_OPTIONS} ${fSOURCES}
        WORKING_DIRECTORY ${fMODULE_DIR}
        COMMENT "Running SV linter on ${fMODULE_NAME} sources: ${fSOURCES}"
        VERBATIM
    )

    # Add a custom target for linting the library's sources
    add_custom_target(
        lint-${fMODULE_NAME}
        COMMAND ${VERILOG_CODE_LINTER} ${MODULE_LINT_OPTIONS} ${fSOURCES}
        WORKING_DIRECTORY ${fMODULE_DIR}
        COMMENT "Running linter on ${fMODULE_NAME} sources: ${fSOURCES}"
        VERBATIM
    )

    # Add a custom target for the main file formatting
    add_custom_target(
        format-${fMODULE_NAME}
        COMMAND ${VERILOG_CODE_FORMATTER} ${GLOBAL_FORMAT_OPTIONS} ${fSOURCES}
        WORKING_DIRECTORY ${fMODULE_DIR}
        COMMENT "Running code formatter on ${fMODULE_NAME} sources: ${fSOURCES}"
        VERBATIM
    )

    if (fMODULE_SIM_TESTBENCH)
        # Add a target to run all testcases
        add_custom_target(
            sim-${fMODULE_NAME}
            COMMAND ${VERILOG_SIMULATOR} ${fSOURCES} ${fMODULE_SIM_TESTBENCH} ${MODULE_SIM_OPTIONS}
            COMMAND ${SIM_ARTIFACTS_PATH}/${SIM_EXE_NAME}
            COMMENT "Running all simulation testcases for ${fMODULE_NAME}"
        )

        # Add a target to clean simulation data
        # Create the custom clean-sim target
        add_custom_target(
            clean-sim-${fMODULE_NAME}
            COMMAND ${CMAKE_COMMAND} -E remove_directory ${SIM_ARTIFACTS_PATH}
            COMMENT "Cleaning simulation artifacts for ${fMODULE_NAME}"
            VERBATIM
        )

        # Add simulation artifacts directory to CMake's built-in clean target
        set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
            ${SIM_ARTIFACTS_PATH}
        )
    else()
        # No testbench defined, create a placeholder target that just prints a message notifying the user
        add_custom_target(
            sim-${fMODULE_NAME}
            COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --yellow --bold "No simulation testbench was defined for module ${fMODULE_NAME}."
        )
        add_custom_target(
            clean-sim-${fMODULE_NAME}
        )
    endif()

endfunction()
