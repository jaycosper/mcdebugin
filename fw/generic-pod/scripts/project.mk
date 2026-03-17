# create CMake targets for project
init-project:
	@echo "+------------ initialize project ----------------+"
	@mkdir -p _build && cd _build && cmake ../
	@echo "+------------------------------------------------+"

# create version target
version : init-project
	@echo "+------------- version --------------------------+"
	@cd _build && make version
	@echo "+------------------------------------------------+"

# create sv lint target
sv-lint : init-project
	@echo "+--------------- SV lint ------------------------+"
	# The -k option allows SVLint to continue after first failure.
	@cd _build && make -k svlint
	@echo "+------------------------------------------------+"

# create verible-verilog-lint target
verible-lint : init-project
	@echo "+---------- verible-verilog-lint ----------------+"
	@cd _build && make lint
	@echo "+------------------------------------------------+"

# create general lint target; pick desired linter, or both
lint: verible-lint sv-lint

# create format target
format : init-project
	@echo "+-------------- format --------------------------+"
	@cd _build && make format
	@echo "+------------------------------------------------+"

# create project clean target
project-clean:
	@echo "+------------- project-clean -------------------+"
	@echo Removing generated build directory and version file
	@rm -rf _build && rm -f inc/auto_version_pkg.sv
	@echo "+------------------------------------------------+"

.PHONY : version format lint precheck precheck_clean
precheck : version format lint

.PHONY : sim-test
sim-test : init-project
	@echo "+------------- simulation tests -----------------+"
	@cd _build && make sim
	@echo "+------------------------------------------------+"

.PHONY : project-helpfull
project-helpfull : init-project
	@echo "+------------ Full Project Help ----------------+"
	@echo "	The following targets are only available from within the CMake build directory (../_build):"
	@cd _build && make help
	@echo "+------------------------------------------------+"

.PHONY : project-help
project-help :
	@echo "Project Makefile Help"
	@echo "	The following targets are only available from within the CMake build directory (../_build):"
	@echo ""
	@echo "Available Project targets:"
	@echo "	make init-project       - creates and configures CMake targets for the project"
	@echo "	make precheck           - run all precheck tasks (version, format, lint)"
	@echo "	make version            - generate version package"
	@echo "	make format             - format source files"
	@echo "	make lint               - run all linters (verible-verilog-lint, sv-lint)"
	@echo "	make ver-lint           - run verible-verilog-lint"
	@echo "	make sv-lint            - run sv-lint"
	@echo "	make sim-test           - run simulation tests"
	@echo "	make project-clean      - clean up generated files and directories"
	@echo "	make project-helpfull   - display detailed help for project targets"
