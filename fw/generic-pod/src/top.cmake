# ###############################
# #### User Defined Section #####
# ###############################
# module name
set(MODULE_NAME top)
# # module source files
set(SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/${MODULE_NAME}.sv
)
# # module-specific lint options
set(MODULE_SVLINT_OPTIONS -I${CMAKE_CURRENT_LIST_DIR}/../inc)
# # module-specific lint options
set(MODULE_LINT_OPTIONS )
# # module-specific lint exceptions
set(MODULE_LINT_EXCEPTIONS )
# # module-specific format options
set(MODULE_FORMAT_OPTIONS )
# ###############################

create_module_targets(
    MODULE_NAME ${MODULE_NAME}
    MODULE_DIR ${CMAKE_CURRENT_LIST_DIR}
    TESTBENCH ${MODULE_SIM_TESTBENCH}
    SOURCES ${SOURCES}
)

find_package(Quartus REQUIRED)
include(${PROJECT_TOP_DIR}/scripts/quartus-flow.cmake)

add_quartus_custom_flow(
    PROJECT      ${MODULE_NAME}
    TCL_SCRIPT   ${PROJECT_TOP_DIR}/prj/top.tcl
    SOURCES      ${FPGA_SOURCES}
    #PFG_CONFIG   flash_config.pfg          # ← add this line if you want POF
)
