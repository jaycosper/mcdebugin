cmake_minimum_required(VERSION 3.10)

# Define the formatter executable
set(FORMATTER_APP_NAME verible-verilog-format)
find_program(VERILOG_CODE_FORMATTER ${FORMATTER_APP_NAME})

if(NOT VERILOG_CODE_FORMATTER)
    message(FATAL_ERROR "Code formatter ${FORMATTER_APP_NAME} not found. Please install it or ensure it's in your PATH.")
endif()

set(FORMAT_FLAGFILE ${PROJECT_TOP_DIR}/scripts/sv-format.rules)
set(GLOBAL_FORMAT_OPTIONS --flagfile ${FORMAT_FLAGFILE})
