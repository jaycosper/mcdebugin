# Add each library's CMake file

include(${IP_DIR}/ip.cmake)

include(${MODULES_DIR}/debounce/debounce.cmake)
include(${MODULES_DIR}/lvds_rxtx/lvds_rxtx.cmake)
include(${MODULES_DIR}/protocol_lvds/protocol_lvds.cmake)
include(${MODULES_DIR}/v8b10b/v8b10b.cmake)
include(${PROJECT_TOP_DIR}/src/top.cmake)
