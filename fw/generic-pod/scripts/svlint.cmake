cmake_minimum_required(VERSION 3.10)

# Define the linter executable
set(SVLINTER_APP_NAME svlint)
find_program(SV_CODE_LINTER ${SVLINTER_APP_NAME})

if(NOT SV_CODE_LINTER)
    message(FATAL_ERROR "Code linter ${SVLINTER_APP_NAME} not found. Please install it or ensure it's in your PATH.")
endif()

set(SVLINT_RULES_CONFIG ${PROJECT_TOP_DIR}/scripts/.svlint.toml)
#set(GLOBAL_SVLINT_OPTIONS --oneline -v --config=${SVLINT_RULES_CONFIG})
set(GLOBAL_SVLINT_OPTIONS --config=${SVLINT_RULES_CONFIG})
