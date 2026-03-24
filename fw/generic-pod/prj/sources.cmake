# Add each library's CMake file

include(${IP_DIR}/ip.cmake)
include(${PROJECT_TOP_DIR}/src/top.cmake)
include(${MODULES_DIR}/protocol_lvds/protocol_lvds.cmake)
include(${MODULES_DIR}/debounce/debounce.cmake)
