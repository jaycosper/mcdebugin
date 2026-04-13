cmake_minimum_required(VERSION 3.10)

# Define the linter executable
set(VLINTER_APP_NAME verible-verilog-lint)
find_program(VERIBLE_CODE_LINTER ${VLINTER_APP_NAME})

if(NOT VERIBLE_CODE_LINTER)
    message(FATAL_ERROR "Code linter ${VLINTER_APP_NAME} not found. Please install it or ensure it's in your PATH.")
endif()

set(VLINT_RULES_CONFIG ${PROJECT_TOP_DIR}/scripts/sv-lint.rules)
set(GLOBAL_VLINT_OPTIONS --lint_fatal=false --parse_fatal=false --rules_config=${VLINT_RULES_CONFIG})
