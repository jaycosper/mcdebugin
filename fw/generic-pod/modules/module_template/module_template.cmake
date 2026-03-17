# ###############################
# #### User Defined Section #####
# ###############################
# module name
set(MODULE_NAME module_template)
# # module source files
set(SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/src/${MODULE_NAME}.sv
)
# # module-specific lint options
set(MODULE_SVLINT_OPTIONS )
# # module-specific lint options
set(MODULE_LINT_OPTIONS )
# # module-specific lint exceptions
set(MODULE_LINT_EXCEPTIONS )
# # module-specific format options
set(MODULE_FORMAT_OPTIONS )
# # module-specific simulation options
set(MODULE_SIM_OPTIONS )
# # module-specific testbench
set(MODULE_SIM_TESTBENCH
    ${CMAKE_CURRENT_LIST_DIR}/sim/tb_${MODULE_NAME}.sv
)
# ###############################

create_module_targets(
    MODULE_NAME ${MODULE_NAME}
    MODULE_DIR ${CMAKE_CURRENT_LIST_DIR}
    TESTBENCH ${MODULE_SIM_TESTBENCH}
    SOURCES ${SOURCES}
)
