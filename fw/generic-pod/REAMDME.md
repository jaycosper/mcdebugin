Use the same filelist.f for quick checks:

Verilator:Bashverilator --lint-only -Wall -Wno-fatal --top-module top_module `cat filelist.f`
# Or with -f (if you add +incdir+include/ to filelist.f lines)
verilator --lint-only -Wall -Wno-fatal -f filelist.f(Add --default-language 1800-2017 if needed.)
Verible:Bashverible-verilog-lint --ruleset=all `cat filelist.f`
# Or for syntax only:
verible-verilog-syntax `cat filelist.f`(Use xargs if too many files: cat filelist.f | xargs verible-verilog-lint --ruleset=all)
In CI/Makefile (for automation):makefilelint: filelist.f
	verilator --lint-only -Wall -Wno-fatal `cat filelist.f`
	verible-verilog-lint --ruleset=all `cat filelist.f`