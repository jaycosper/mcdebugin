# quartus-flow.cmake
# Usage: include(quartus-flow) then call add_quartus_custom_flow(...)
# Enhanced: supports .sof (debug/JTAG) + optional .pof (flash burning)

function(add_quartus_custom_flow)
    set(options "")
    set(oneValueArgs
        PROJECT
        TCL_SCRIPT
        # FAMILY
        # DEVICE
        PFG_CONFIG          # ← NEW: path to .pfg file (recommended for POF)
    )

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_PROJECT OR NOT ARG_TCL_SCRIPT)
        message(FATAL_ERROR "add_quartus_custom_flow requires PROJECT and TCL_SCRIPT")
    endif()

    set(PROJ ${ARG_PROJECT})
    set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})

    # === STEP 1: Run TCL → create .qsf / .qpf ===
    add_custom_command(
        OUTPUT ${BUILD_DIR}/${PROJ}.qsf ${BUILD_DIR}/${PROJ}.qpf
        COMMAND ${QUARTUS_SH_EXECUTABLE}
                -t ${ARG_TCL_SCRIPT}
                --project ${PROJ}
                --files ${BUILD_DIR}/${PROJ}-generated.f
                # these are handled in TCL
                # -family "${ARG_FAMILY}"
                # -device "${ARG_DEVICE}"
        DEPENDS ${ARG_TCL_SCRIPT}
        # DEPENDS ${ARG_TCL_SCRIPT} ${ARG_SOURCES} ${ARG_DEPENDS}
        WORKING_DIRECTORY ${BUILD_DIR}
        COMMENT "Generating Quartus project files via TCL"
        VERBATIM
    )

    # === STEP 2: Full compile → produces .sof ===
    set(SOF_FILE ${BUILD_DIR}/output_files/${PROJ}.sof)   # typical location after --flow compile

    add_custom_command(
        OUTPUT ${SOF_FILE}
        COMMAND ${QUARTUS_SH_EXECUTABLE} --flow compile ${PROJ}.qsf -c ${PROJ}
        DEPENDS ${BUILD_DIR}/${PROJ}.qsf ${BUILD_DIR}/${PROJ}.qpf
        WORKING_DIRECTORY ${BUILD_DIR}
        COMMENT "Quartus full compile → generating ${PROJ}.sof"
        VERBATIM
    )

    # Main target: depends on .sof (fast debug flow)
    add_custom_target(${PROJ}_quartus ALL
        DEPENDS ${SOF_FILE}
    )

    # === OPTIONAL: POF generation (for flash / CPLD permanent programming) ===
    if(ARG_PFG_CONFIG)
        set(PFG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${ARG_PFG_CONFIG})
        set(POF_FILE ${BUILD_DIR}/output_files/${PROJ}.pof)

        add_custom_command(
            OUTPUT ${POF_FILE}
            COMMAND ${QUARTUS_SH_EXECUTABLE} quartus_pfg
                    -c ${PFG_FILE} ${SOF_FILE} ${POF_FILE}
            DEPENDS ${SOF_FILE} ${PFG_FILE}
            COMMENT "Converting .sof → .pof using ${ARG_PFG_CONFIG}"
            VERBATIM
        )

        add_custom_target(${PROJ}_pof
            DEPENDS ${POF_FILE}
        )

        add_dependencies(${PROJ}_quartus ${PROJ}_pof)   # optional: build POF always
        # Or keep separate: user does cmake --build . --target my_design_pof when needed
    endif()

    # Programming targets (JTAG)
    add_custom_target(${PROJ}_program_sof
        COMMAND ${QUARTUS_PGM_EXECUTABLE} -c \"USB-Blaster\" -m JTAG -o \"P\;${SOF_FILE}\"
        DEPENDS ${SOF_FILE}
        COMMENT "Program ${PROJ}.sof via JTAG (volatile)"
    )

    if(ARG_PFG_CONFIG)
        add_custom_target(${PROJ}_program_pof
            COMMAND ${QUARTUS_PGM_EXECUTABLE} -m jtag -o "BI;${POF_FILE}"   # BI = burn indirect / flash
            DEPENDS ${POF_FILE}
            COMMENT "Burn ${PROJ}.pof to flash (non-volatile)"
        )
    endif()

    set(${PROJ}_SOF ${SOF_FILE} PARENT_SCOPE)
    if(ARG_PFG_CONFIG)
        set(${PROJ}_POF ${POF_FILE} PARENT_SCOPE)
    endif()
endfunction()
