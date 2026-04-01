`timescale 1ns / 1ps
`default_nettype none

module tb_module_template;

    // ────────────────────────────────────────────────
    // Signals
    // ────────────────────────────────────────────────
    logic clk   = 0;
    logic rst_n = 0;

    logic i_in  = 0;
    logic o_out;

    // ────────────────────────────────────────────────
    // DUT
    // ────────────────────────────────────────────────
    module_template dut (
        .i_clk  (clk),
        .i_rst_n(rst_n),
        .i_in   (i_in),
        .o_out  (o_out)
    );

    // 100 MHz clock (just for style — not required for this DUT)
    always #5 clk = ~clk;

    // ────────────────────────────────────────────────
    // Reset & stimulus
    // ────────────────────────────────────────────────
    initial begin
        $dumpfile("obj_dir/tb_module_template.vcd");
        $dumpvars(0, tb_module_template);

        // Reset phase
        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (4) @(posedge clk);

        $display("┌──────────────────────────────┐");
        $display("│   Starting self-check test   │");
        $display("└──────────────────────────────┘");

        // Test pattern 1: all 0 → 1 transitions
        $display("Test 1: walking 0 → 1");
        repeat (8) begin
            i_in = #1 ~i_in;
            @(posedge clk);
            check_output();
        end

        // Test pattern 2: random-like sequence
        $display("Test 2: pseudo-random sequence");
        for (int i = 0; i < 32; i++) begin
            i_in = #1 1'($random & 32'h1);     // LSB of random
            @(posedge clk);
            check_output();
        end

        // Test pattern 3: long stable periods
        $display("Test 3: long stable values");
        i_in = #1 0; repeat (20) @(posedge clk); check_output();
        i_in = #1 1; repeat (20) @(posedge clk); check_output();
        i_in = #1 0; repeat (10) @(posedge clk); check_output();

        // Final report
        $display("");
        $display("┌──────────────────────────────┐");
        if (errors == 0)
            $display("│       PASS ─ All checks OK   │");
        else
            $display("│       FAIL ─ %0d errors      │", errors);
        $display("└──────────────────────────────┘");

        #100;
        $finish;
    end

    // ────────────────────────────────────────────────
    // Self-checking logic
    // ────────────────────────────────────────────────
    int errors = 0;

    task automatic check_output();
        @(negedge clk);  // check just before next edge (combinational delay model)
        if (o_out !== i_in) begin
            $display("ERROR at time %0t:\ti_in=%b  o_out=%b  (expected %b)",
                     $time, i_in, o_out, i_in);
            errors++;
        end
    endtask

    // Optional: concurrent assertion (modern simulators)
    assert property (@(posedge clk) disable iff (!rst_n)
        o_out == i_in)
        else $error("Combinational path failed: o_out != i_in");

endmodule
