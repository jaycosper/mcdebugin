# Add each library's CMake file

include(${IP_DIR}/ip.cmake)

include(${MODULES_DIR}/debounce/debounce.cmake)
include(${MODULES_DIR}/lvds_rxtx/lvds_rxtx.cmake)
include(${MODULES_DIR}/v8b10b/v8b10b.cmake)
include(${MODULES_DIR}/stream_decoder/stream_decoder.cmake)
include(${MODULES_DIR}/stream_encoder/stream_encoder.cmake)
include(${MODULES_DIR}/msg_decoder/msg_decoder.cmake)
include(${MODULES_DIR}/msg_encoder/msg_encoder.cmake)
include(${MODULES_DIR}/pod_protocol/pod_protocol.cmake)
include(${PROJECT_TOP_DIR}/src/top.cmake)
