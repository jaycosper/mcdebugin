cmake_minimum_required(VERSION 3.10)

# Define the simulation executable
set(SIMULATION_APP_NAME verilator)
find_program(VERILOG_SIMULATOR ${SIMULATION_APP_NAME})

if(NOT VERILOG_SIMULATOR)
    message(WARNING "Code simulator ${SIMULATION_APP_NAME} not found. Please install it or ensure it's in your PATH.")
endif()

set(GLOBAL_SIM_OPTIONS -cc --exe --build --timing --trace -j 0 --main)
