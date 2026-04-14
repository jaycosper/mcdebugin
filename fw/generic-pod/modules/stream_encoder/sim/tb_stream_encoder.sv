`timescale 1ns / 1ps
`default_nettype none

module tb_stream_decoder;

    // ────────────────────────────────────────────────
    // Signals
    // ────────────────────────────────────────────────
    logic clk   = 0;
    logic rst_n = 0;

    logic msg_ready, rdack;
    logic [7:0] rd_data;
    protocol_pkg::rxtx_data_t data;

    // ────────────────────────────────────────────────
    // DUT
    // ────────────────────────────────────────────────
    stream_decoder dut (
        .i_clk  (clk),
        .i_rst_n(rst_n),
        // FIFO interface
        .i_msg_ready(msg_ready),
        .o_rden(rdack),
        .i_rd_data(rd_data),
        // PHY interface
        .o_data(data)
    );

    // 25 MHz clock
    localparam int CLK_FREQ_MHZ = 25;
    localparam int CLK_PERIOD_NS = 1000 / CLK_FREQ_MHZ;
    always #CLK_PERIOD_NS clk = ~clk;

    // ────────────────────────────────────────────────
    // Reset & stimulus
    // ────────────────────────────────────────────────
    logic empty;
    int wait_count = 0;

    initial begin
        $dumpfile("tb_stream_encoder.vcd");
        $dumpvars(0, tb_stream_encoder);

        // Reset phase
        rst_n = 0;
        repeat (4) @(negedge clk);
        rst_n = 1;
        repeat (4) @(negedge clk);

        $display("┌──────────────────────────────┐");
        $display("│   Starting self-check test   │");
        $display("└──────────────────────────────┘");

        repeat (10) @(negedge clk);
        // Test 1: all IDLE control characters (K28.5)
        $display("Test 1: all IDLE control characters (K28.5)");
        for (int i = 0; i < 128; i++) begin
            @(negedge clk);
            if (data.is_k != 1'b1 || data.data != 8'hBC) begin
                $display("ERROR: Expected K28.5 control character but found valid=%b, is_k=%b, data=0x%02X", data.valid, data.is_k, data.data);
                errors += 1;
            end
        end

        repeat (10) @(negedge clk);
        $display("Test 2: Simple message");
        // load queue
        @(posedge clk); #1;
        push_simple_message();
        // clock DUT and check output
        wait_count = 0;
        while(data.data != 8'h3C || data.is_k != 1'b1) begin
            @(negedge clk);
            wait_count++;
        end
        if (wait_count != 2) begin
            $display("ERROR: Expected first output to be K28.1 control character, but it took %0d cycles to appear", wait_count);
            errors += 1;
        end
        wait_count = 0;
        while(data.data != 8'hBC || data.is_k != 1'b1) begin
            @(negedge clk);
            wait_count++;
        end
        if (wait_count != (8+1)) begin
            $display("ERROR: Expected %0d data bytes followed by K28.5 control character, but it took %0d cycles to appear after K28.1", 8, wait_count);
            errors += 1;
        end
        if (rd_fifo.size() != 0) begin
            $display("ERROR: Expected FIFO to be empty after reading out message, but found %0d items remaining", rd_fifo.size());
            errors += 1;
        end

        repeat (10) @(negedge clk);
        $display("Test 3: Simple message with Payload");
        repeat (10) @(negedge clk);
        if (data.is_k != 1'b1 || data.data != 8'hBC) begin
            $display("ERROR: Expected K28.5 control character but found valid=%b, is_k=%b, data=0x%02X", data.valid, data.is_k, data.data);
            errors += 1;
        end
        // load queue
        @(posedge clk); #1;
        push_payload_message();
        // clock DUT and check output
        wait_count = 0;
        while(data.data != 8'h3C || data.is_k != 1'b1) begin
            @(negedge clk);
            wait_count++;
        end
        if (wait_count != 2) begin
            $display("ERROR: Expected first output to be K28.1 control character, but it took %0d cycles to appear", wait_count);
            errors += 1;
        end
        wait_count = 0;
        while(data.data != 8'hBC || data.is_k != 1'b1) begin
            @(negedge clk);
            wait_count++;
        end
        if (wait_count != (40+1)) begin
            $display("ERROR: Expected %0d data bytes followed by K28.5 control character, but it took %0d cycles to appear after K28.1", 8, wait_count);
            errors += 1;
        end
        if (rd_fifo.size() != 0) begin
            $display("ERROR: Expected FIFO to be empty after reading out message, but found %0d items remaining", rd_fifo.size());
            errors += 1;
        end

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
    logic [7:0] rd_fifo [$];

    function void push_payload_message();
        // pushes a simple message consisting of header (4B) + payload 32B + CRC (4B) = 40B
        for (int i=0; i<40; i++) begin
            logic [7:0] data_byte;
            data_byte = 8'(40-i); // just fill with repeating byte pattern for testing
            push_byte(data_byte);
        end
    endfunction

    function void push_simple_message();
        // pushes a simple message consisting of header (4B) + CRC (4B) = 8B
        for (int i=0; i<8; i++) begin
            logic [7:0] data_byte;
            data_byte = 8'(i+1);
            push_byte(data_byte);
        end
    endfunction

    function void push_message(logic [7:0] data [0:63], int length);
        for (int i=0; i<length; i++) begin
            push_byte(data[i]);
        end
    endfunction

    function void push_byte(logic [7:0] data);
        rd_fifo.push_back(data);
    endfunction

    // Look-ahead FIFO logic
    always_ff @(posedge clk) begin
        if (rd_fifo.size() > 0) begin
            if (rdack) begin
                rd_fifo.pop_front(); // remove the item after acknowledging it
            end
        end
    end

    always_comb begin
        if (rd_fifo.size() > 0) begin
            rd_data = rd_fifo[0]; // equivalent to a "peek"
            empty = 1'b0;
        end else begin
            rd_data = 'X;
            empty = 1'b1;
        end
    end

    assign msg_ready = !empty;

endmodule
