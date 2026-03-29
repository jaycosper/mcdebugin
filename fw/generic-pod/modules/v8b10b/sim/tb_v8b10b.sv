`timescale 1ns / 1ps
`default_nettype none

module tb_v8b10b;

    // -------------------------------------------------
    // Signals
    // -------------------------------------------------
    logic clk   = 0;
    logic rst   = 0;

    // Encoder
	logic       enc_en;
    logic [7:0] enc_din;
    logic       enc_kin;
    logic       enc_dvalid;
    logic [9:0] enc_dout;
	logic       enc_disp;
	logic       enc_kin_err;

    // Decoder
	logic       dec_en;
    logic [9:0] dec_din;
    logic       dec_dvalid;
    logic [7:0] dec_dout;
    logic       dec_kout;
    logic       dec_code_err;
    logic       dec_disp;
    logic       dec_disp_err;

    int         tests_run   = 0;
    int         errors      = 0;
    int         expected_errors = 0;

    // -------------------------------------------------
    // DUTs
    // -------------------------------------------------
    encoder_8b10b u_enc (
        .i_clk      (clk),
        .i_rst      (rst),
        .i_en       (enc_en),
        .i_din      (enc_din),
        .i_kin      (enc_kin),
        .o_valid    (enc_dvalid),
        .o_dout     (enc_dout),
        .o_disp     (enc_disp),
        .o_kin_err  (enc_kin_err)
    );

    decoder_8b10b u_dec (
        .i_clk      (clk),
        .i_rst      (rst),
        .i_en       (dec_en),
        .i_din      (dec_din),
        .o_valid    (dec_dvalid),
        .o_dout     (dec_dout),
        .o_kout     (dec_kout),
        .o_code_err (dec_code_err),
        .o_disp     (dec_disp),
        .o_disp_err (dec_disp_err)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // Optional override for decoder input (to test error conditions)
    logic dec_in_sel;
    logic [9:0] dec_in_override;
    always_comb begin
        if (dec_in_sel) begin
            dec_din = dec_in_override;
        end else begin
            dec_din = enc_dout;
        end
    end

    assign dec_en = enc_dvalid; // Decoder enabled when encoder output is valid

    // -------------------------------------------------
    // Main test sequence
    // -------------------------------------------------
    initial begin
        $dumpfile("tb_v8b10b.vcd");
        $dumpvars(0, tb_v8b10b);

        dec_in_sel = 0; // By default, decoder input comes from encoder output
        enc_en = 0;
        enc_dvalid = 0;
        rst = 1;
        repeat (10) @(negedge clk);

        rst = 0;
        repeat (5) @(negedge clk);

        enc_en = 1;
        repeat (5) @(negedge clk);

        $display("========================================");
        $display("   v8b10b Encoder/Decoder Full Testbench");
        $display("========================================");

        // // Happy path tests
        // simple test
        test_character(8'hBC, 1'b1); // K28.5 (comma) - most important
        #100;
        test_all_data_characters();
        #100;
        test_control_characters();

        // // Negative / error injection tests
        // test_code_errors();
        #100;
        // test_disparity_errors();
        #100;

        // Final report
        $display("\n========================================");
        if (errors == expected_errors)
            $display("   PASSED - %0d tests, %0d errors (all expected)", tests_run, errors);
        else
            $display("   FAILED - %0d errors (expected %0d)", errors, expected_errors);
        $display("========================================");

        #100;
        $finish;
    end

    // ================================================================
    // Happy Path Tests
    // ================================================================

    task automatic test_all_data_characters();
        $display("\n%0t [TEST] All 256 data characters (K=0)", $time);
        for (int i = 0; i < 256; i++) begin
            test_character(8'(i), 1'b0);
        end
    endtask

    task automatic test_control_characters();
        $display("\n%0t [TEST] Common control (K) characters", $time);
        test_character(8'hBC, 1'b1); // K28.5 (comma) - most important
        test_character(8'h1C, 1'b1);
        test_character(8'h3C, 1'b1);
        test_character(8'h5C, 1'b1);
        test_character(8'h7C, 1'b1);
        test_character(8'h9C, 1'b1);
        test_character(8'hFC, 1'b1); // K28.7
    endtask

    // ================================================================
    // Negative Tests - Error Injection
    // ================================================================

    task automatic test_code_errors();
        $display("\n%0t [TEST] Code error injection (invalid 10b codes)", $time);
        expected_errors += 4;

        // Invalid 10b patterns that should trigger code_err
        test_invalid_code(10'b0000000000);
        test_invalid_code(10'b1111111111);
        test_invalid_code(10'b0101010101);
        test_invalid_code(10'b1010101010);
    endtask

    task automatic test_disparity_errors();
        $display("\n%0t [TEST] Disparity error injection", $time);
        expected_errors += 3;

        // Send valid code but force wrong disparity by feeding it directly
        // (bypass encoder)
        test_invalid_disparity(8'b00000000); // valid D0.0 but wrong disparity
        test_invalid_disparity(8'b11111111); // valid D0.0 negative disparity
        test_invalid_disparity(8'hBC, 1'b1);    // K28.5 with forced bad disparity
    endtask

    // ================================================================
    // Helper tasks
    // ================================================================

    task automatic test_character(input [7:0] data, input logic is_k);
        @(negedge clk);
        enc_en = 1'b1;
        enc_din = data;
        enc_kin = is_k;
        @(negedge clk); // pulse enable
        enc_en = 1'b0;
        repeat(2)@(negedge clk);    // allow encode + decode

        tests_run++;
        if (dec_code_err || dec_disp_err) begin
            $display("%0t ERROR (happy path): 0x%02h K=%b → code_err=%b disp_err=%b",
                     $time, data, is_k, dec_dout, dec_kout);
            errors++;
        end else if (dec_dout !== data || dec_kout !== is_k) begin
            $display("%0t ERROR (mismatch): 0x%02h K=%b → got 0x%02h K=%b",
                     $time, data, is_k, dec_dout, dec_kout);
            errors++;
        end
    endtask

    task automatic test_invalid_code(input [9:0] bad_code);
        dec_in_sel = 1; // Override decoder input to inject bad code
        dec_in_override = bad_code;
        @(negedge clk);
        tests_run++;
        if (!dec_code_err) begin
            $display("%0t ERROR: Invalid code 10'b%b did not trigger code_err", $time, bad_code);
            errors++;
        end
        dec_in_sel = 0; // Return to normal operation
    endtask

    task automatic test_invalid_disparity(input [7:0] data = 8'h00, input logic is_k = 1'b0);
        // For disparity test we drive decoder directly with a valid-looking code
        // but force wrong running disparity by using the opposite polarity version
        dec_in_sel = 1;
        dec_in_override = (is_k) ? 10'b0011111010 : 10'b1100000101; // deliberately wrong disparity
        @(negedge clk);
        tests_run++;
        if (!dec_disp_err) begin
            $display("%0t ERROR: Disparity error not detected for data 0x%02h K=%b", $time, data, is_k);
            errors++;
        end
        dec_in_sel = 0; // Return to normal operation
    endtask

endmodule
