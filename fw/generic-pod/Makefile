# Makefile for building the MAX10 EK-10M08E144 project in Quartus

# Quartus project settings
PROJECT = top
BUILD_DIR = _build

#--------------------------------------------------------------------
# Code Pre-checks
#	Formmatter and Linter
#--------------------------------------------------------------------
include scripts/project.mk

# # Default target
all: compile

# # Compile the project
compile: init-project version
	@echo "+------------- Compiling Project ----------------+"
	@cd ${BUILD_DIR} && make ${PROJECT}_quartus

program: compile
	@echo "+------------- Programming Project ----------------+"
	@cd ${BUILD_DIR} && make ${PROJECT}_program_sof

rebuild: clean compile

sim: init-project version
	@echo "+------------- Running Simulation ----------------+"
	@cd ${BUILD_DIR} && make sim

# Display help
help: project-help
	@echo ""
	@echo "Project-level Makefile Help"
	@echo ""
	@echo "Available Project targets:"
	@echo "	make all      - Build the entire project (default target)"
	@echo "	make compile  - Run all build steps to compile the project"
	@echo "	make program  - Program the project with the generated .sof file (requires JTAG connection)"
	@echo "	make rebuild  - Clean and then compile the project"
	@echo "	make sim      - Run simulation of the project modules (if simulation targets are defined)"
	@echo "	make clean    - Remove generated build files and directories"
	@echo "	make help     - Display this help message"

.PHONY: all compile program clean rebuild help

clean: project-clean

#--------------------------------------------------------------------
# List all targets
# See https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
#--------------------------------------------------------------------
.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
