`timescale 1ns / 1ps
`default_nettype none

module tb_stream_decoder;

    // ────────────────────────────────────────────────
    // Signals
    // ────────────────────────────────────────────────
    logic clk   = 0;
    logic rst_n = 0;

    protocol_pkg::rxtx_data_t data;
    logic wren;
    logic [7:0] wr_data;
    logic [7:0] error_count;

    // ────────────────────────────────────────────────
    // DUT
    // ────────────────────────────────────────────────
    stream_decoder dut (
        .i_clk  (clk),
        .i_rst_n(rst_n),
        .i_data (data),
        .o_wren (wren),
        .o_wr_data (wr_data),
        .o_error_count (error_count)
    );

    // 100 MHz clock (just for style — not required for this DUT)
    localparam int CLK_FREQ_MHZ = 25;
    localparam int CLK_PERIOD_NS = 1000 / CLK_FREQ_MHZ;
    always #CLK_PERIOD_NS clk = ~clk;

    // ────────────────────────────────────────────────
    // Reset & stimulus
    // ────────────────────────────────────────────────
    protocol_pkg::rxtx_data_t test_data;

    initial begin
        $dumpfile("tb_stream_decoder.vcd");
        $dumpvars(0, tb_stream_decoder);

        // Reset phase
        rst_n = 0;
        repeat (4) @(negedge clk);
        rst_n = 1;
        repeat (4) @(negedge clk);

        $display("┌──────────────────────────────┐");
        $display("│   Starting self-check test   │");
        $display("└──────────────────────────────┘");

        // Test 1: all IDLE control characters (K28.5)
        $display("Test 1: all IDLE control characters (K28.5)");
        // load queue
        test_data = '{default:0, valid: 1'b1, is_k: 1'b1, data: 8'hBC}; // K28.5
        for (int i=0; i<8; i++) begin
            queue_in.push_back(test_data);
        end
        // clock DUT and check output
        repeat (16) @(negedge clk);
        if (queue_in.size() != 0) begin
            $display("ERROR: Expected input data to be read out but found %0d items remaining", queue_in.size());
            errors += queue_in.size();
        end
        if (queue_out.size() != 0) begin
            $display("ERROR: Expected no output for IDLE control characters, but found %0d items", queue_out.size());
            errors += queue_out.size();
        end

        repeat (10) @(negedge clk);
        // Test 2: all IDLE control characters (K28.5)
        $display("Test 2: Simple message stream (K28.1 followed by data bytes) and then IDLE characters");
        // load queue
        test_data = '{default:0, valid: 1'b1, is_k: 1'b1, data: 8'hBC}; // K28.5
        for (int i=0; i<2; i++) begin
            queue_in.push_back(test_data);
        end
        test_data = '{default:0, valid: 1'b1, is_k: 1'b1, data: 8'h3C}; // K28.1
        queue_in.push_back(test_data);
        for (int i=0; i<8; i++) begin
            test_data = '{default:0, valid: 1'b1, is_k: 1'b0, data: 8'(i+1)}; // data bytes
            queue_in.push_back(test_data);
        end
        test_data = '{default:0, valid: 1'b1, is_k: 1'b1, data: 8'hBC}; // K28.5
        for (int i=0; i<2; i++) begin
            queue_in.push_back(test_data);
        end
        // clock DUT and check output
        repeat (100) @(negedge clk);
        if (queue_in.size() != 0) begin
            $display("ERROR: Expected input data to be read out but found %0d items remaining", queue_in.size());
            errors += queue_in.size();
        end
        if (queue_out.size() != 8) begin
            $display("ERROR: Expected 8 items in output, but found %0d items", queue_out.size());
            errors += queue_out.size();
        end

        // repeat (8) begin
        //     i_in = #1 ~i_in;
        //     @(posedge clk);
        //     check_output();
        // end

        // // Test pattern 2: random-like sequence
        // $display("Test 2: pseudo-random sequence");
        // for (int i = 0; i < 32; i++) begin
        //     i_in = #1 1'($random & 32'h1);     // LSB of random
        //     @(posedge clk);
        //     check_output();
        // end

        // // Test pattern 3: long stable periods
        // $display("Test 3: long stable values");
        // i_in = #1 0; repeat (20) @(posedge clk); check_output();
        // i_in = #1 1; repeat (20) @(posedge clk); check_output();
        // i_in = #1 0; repeat (10) @(posedge clk); check_output();

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
    protocol_pkg::rxtx_data_t queue_in [$];
    logic [7:0] queue_out [$];

    always_ff @(negedge clk) begin
        if (queue_in.size() > 0) begin
            data <= queue_in.pop_front();
        end
    end

    always_ff @(posedge clk) begin
        if (wren) begin
            queue_out.push_back(wr_data);
        end
    end

    // protocol_pkg::rxtx_data_t test_data_2 [0:7] = '{
    //     '{valid: 1'b1, is_k: 1'b1, data: 8'hBC}, // MESSAGE_START
    //     '{valid: 1'b1, is_k: 1'b0, data: 8'h55}, // data byte 1
    //     '{valid: 1'b1, is_k: 1'b0, data: 8'hAA}, // data byte 2
    //     '{valid: 1'b1, is_k: 1'b0, data: 8'hFF}, // data byte 3
    //     '{valid: 1'b1, is_k: 1'b0, data: 8'h00}, // data byte 4
    //     '{valid: 1'b1, is_k: 1'b0, data: 8'h7E}, // data byte 5
    //     '{valid: 1'b1, is_k: 1'b0, data: 8'h81}, // data byte 6
    //     '{valid: 1'b1, is_k: 1'b0, data: 8'h42}  // data byte 7
    // };


    // task automatic check_output();
    //     @(negedge clk);  // check just before next edge (combinational delay model)
    //     if (o_wr_data !== i_data.data) begin
    //         $display("ERROR at time %0t:\ti_data.data=%b  o_wr_data=%b  (expected %b)",
    //                  $time, i_data.data, o_wr_data, i_data.data);
    //         errors++;
    //     end
    // endtask

    // // Optional: concurrent assertion (modern simulators)
    // assert property (@(posedge clk) disable iff (!rst_n)
    //     o_out == i_in)
    //     else $error("Combinational path failed: o_out != i_in");

endmodule
