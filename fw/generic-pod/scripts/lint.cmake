cmake_minimum_required(VERSION 3.10)

# Define the linter executable
set(LINTER_APP_NAME verilator)
find_program(VERILOG_CODE_LINTER ${LINTER_APP_NAME})

if(NOT VERILOG_CODE_LINTER)
    message(FATAL_ERROR "Code linter ${LINTER_APP_NAME} not found. Please install it or ensure it's in your PATH.")
endif()

set(GLOBAL_LINT_OPTIONS --lint-only)
