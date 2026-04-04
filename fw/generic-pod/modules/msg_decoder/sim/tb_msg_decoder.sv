`timescale 1ns / 1ps
`default_nettype none

module tb_msg_decoder;

    // ────────────────────────────────────────────────
    // Signals
    // ────────────────────────────────────────────────
    logic clk   = 0;
    logic rst_n = 0;

    protocol_pkg::msg_data_t msg, wr_data;
    logic rdack, empty;
    logic [7:0] error_count;

    // ────────────────────────────────────────────────
    // DUT
    // ────────────────────────────────────────────────
    msg_decoder dut (
        .i_clk      (clk),
        .i_rst_n    (rst_n),
        .i_msg_rdy  (!empty),
        .i_msg      (msg),
        .o_msg_ack  (rdack),
        .o_header   (),
        .i_datain   ('X),
        .o_dataout  ()
    );

    // 100 MHz clock (just for style — not required for this DUT)
    localparam int lpCLK_FREQ_MHZ = 125;
    localparam int lpCLK_PERIOD_NS = 2 * 1000 / lpCLK_FREQ_MHZ;
    always #(lpCLK_PERIOD_NS/2) clk = ~clk;

    // Test timeout logic to prevent infinite simulation runs
    localparam int lpTB_TEST_TIMEOUT_NS = 100_000; // 100 microseconds
    int to_counter = 0;
    always_ff @(posedge clk) begin
        if (to_counter >= lpTB_TEST_TIMEOUT_NS) begin
            $display("%0t: ERROR! Testbench timeout reached. Ending simulation.", $time);
            $finish;
        end else begin
            to_counter += lpCLK_PERIOD_NS;
        end
    end

    // ────────────────────────────────────────────────
    // Reset & stimulus
    // ────────────────────────────────────────────────
    int test_errors = 0;
    int test_num = 0;
    protocol_pkg::msg_data_t test_data;

    typedef struct {
        protocol_pkg::header_t hdr;
        protocol_pkg::msg_data_t data [0:protocol_pkg::pMAX_PAYLOAD_DW-1];
        protocol_pkg::crc_t crc;
    } message_t;
    message_t test_msg;

    function automatic int check_output(message_t expected_msg);
        int errors = 0;
        if (dut.hdr == expected_msg.hdr) begin
            //$display("Header correctly decoded: %h", dut.hdr);
        end else begin
            $display("%0t: ERROR! Header mismatch. Expected %h but got %h", $time, expected_msg.hdr, dut.hdr);
            errors++;
        end
        if (dut.crc == expected_msg.crc) begin
            //$display("CRC correctly decoded: %h", dut.crc);
        end else begin
            $display("%0t: ERROR! CRC mismatch. Expected %h but got %h", $time, expected_msg.crc, dut.crc);
            errors++;
        end
        return errors;
    endfunction

    initial begin
        $dumpfile("tb_msg_decoder.vcd");
        $dumpvars(0, tb_msg_decoder);

        // Reset phase
        rst_n = 0;
        repeat (4) @(negedge clk);
        rst_n = 1;
        repeat (4) @(negedge clk);

        $display("┌──────────────────────────────┐");
        $display("│   Starting self-check test   │");
        $display("└──────────────────────────────┘");

        test_num = 1;
        $display("Test %0d: Simple message with no payload", test_num);
        // load queue
        test_msg.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_msg.hdr.payload_length = 0;
        test_msg.hdr.tag = 1;
        test_msg.hdr.cmd_rsp = 10;
        test_msg.crc = 'hDEADBEEF; // dummy CRC for now

        push_message(test_msg.hdr, 0); // header with no stall
        push_message(test_msg.crc, 0); // CRC with no stall
        // clock DUT and check output
        while (!dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing
        if (fifo.size() != 0) begin
            $display("%0t: ERROR! Expected input data to be read out but found %0d items remaining", $time, fifo.size());
            test_errors += fifo.size();
        end
        test_errors += check_output(test_msg);
        while (dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing

        repeat (10) @(negedge clk);
        test_num = 2;
        $display("");
        $display("Test %0d: Simple message with nominal payload", test_num);
        // load queue
        test_msg.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_msg.hdr.payload_length = 4;
        test_msg.hdr.tag = 2;
        test_msg.hdr.cmd_rsp = 11;
        test_msg.crc = 'hDEADBEEF; // dummy CRC for now

        push_message(test_msg.hdr, 0); // header with no stall
        for (int i=0; i<test_msg.hdr.payload_length; i++) begin
            test_msg.data[i] = i+1; // incrementing payload data
            push_message(test_msg.data[i], 0); // payload data with no stall
        end
        push_message(test_msg.crc, 0); // CRC with no stall

        // clock DUT and check output
        while (!dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing
        if (fifo.size() != 0) begin
            $display("%0t: ERROR! Expected input data to be read out but found %0d items remaining", $time, fifo.size());
            test_errors += fifo.size();
        end
        test_errors += check_output(test_msg);
        while (dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing

        repeat (10) @(negedge clk);
        test_num = 3;
        $display("");
        $display("Test %0d: Message with payload length at max limit", test_num);
        // load queue
        test_msg.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_msg.hdr.payload_length = $size(test_msg.hdr.payload_length)'(protocol_pkg::pMAX_PAYLOAD_DW); // max payload length
        test_msg.hdr.tag = 3;
        test_msg.hdr.cmd_rsp = 12;
        test_msg.crc = 'hDEADBEEF; // dummy CRC for now

        push_message(test_msg.hdr, 0); // header with no stall
        for (int i=0; i<test_msg.hdr.payload_length; i++) begin
            test_msg.data[i] = {16'(i), 16'(protocol_pkg::pMAX_PAYLOAD_DW-i-1)}; // decrementing payload data
            push_message(test_msg.data[i], 0); // payload data with no stall
        end
        push_message(test_msg.crc, 0); // CRC with no stall

        // clock DUT and check output
        while (!dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing
        if (fifo.size() != 0) begin
            $display("%0t: ERROR! Expected input data to be read out but found %0d items remaining", $time, fifo.size());
            test_errors += fifo.size();
        end
        test_errors += check_output(test_msg);
        while (dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing

        repeat (10) @(negedge clk);
        test_num = 4;
        $display("");
        $display("Test %0d: Message with payload and fixed data stalls", test_num);
        // load queue
        test_msg.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_msg.hdr.payload_length = 8;
        test_msg.hdr.tag = 4;
        test_msg.hdr.cmd_rsp = 13;
        test_msg.crc = 'hDEADBEEF; // dummy CRC for now

        push_message(test_msg.hdr, 2);
        for (int i=0; i<test_msg.hdr.payload_length; i++) begin
            test_msg.data[i] = {4{ 8'($urandom_range(0, 255) )}}; // random payload data
            push_message(test_msg.data[i], 2);
        end
        push_message(test_msg.crc, 2);

        // clock DUT and check output
        while (!dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing
        if (fifo.size() != 0) begin
            $display("%0t: ERROR! Expected input data to be read out but found %0d items remaining", $time, fifo.size());
            test_errors += fifo.size();
        end
        test_errors += check_output(test_msg);
        while (dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing

        repeat (10) @(negedge clk);
        test_num = 5;
        $display("");
        $display("Test %0d: Message with payload and random data stalls", test_num);
        // load queue
        test_msg.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_msg.hdr.payload_length = 8;
        test_msg.hdr.tag = 5;
        test_msg.hdr.cmd_rsp = 14;
        test_msg.crc = 'hDEADBEEF; // dummy CRC for now

        push_message(test_msg.hdr, $urandom_range(0, 5));
        for (int i=0; i<test_msg.hdr.payload_length; i++) begin
            test_msg.data[i] = $urandom_range(0, 255); // random payload data
            push_message(test_msg.data[i], $urandom_range(0, 5));
        end
        push_message(test_msg.crc, $urandom_range(0, 5));

        // clock DUT and check output
        while (!dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing
        if (fifo.size() != 0) begin
            $display("%0t: ERROR! Expected input data to be read out but found %0d items remaining", $time, fifo.size());
            test_errors += fifo.size();
        end
        test_errors += check_output(test_msg);
        while (dut.cmd_ready) @(negedge clk); // wait for DUT to finish processing

        // Final report
        $display("");
        $display("%d Test(s) completed at %0t", test_num, $time);
        $display("┌──────────────────────────────┐");
        if (test_errors == 0)
            $display("│       PASS ─ All checks OK   │");
        else
            $display("│       FAIL ─ %0d errors      │", test_errors);
        $display("└──────────────────────────────┘");

        #100;
        $finish;
    end

    // ────────────────────────────────────────────────
    // Self-checking logic
    // ────────────────────────────────────────────────
    int errors = 0;
    typedef struct packed {
        int stall_cycles;
        protocol_pkg::msg_data_t data;
    } generated_data_t;
    generated_data_t fifo [$];

    function void push_message(protocol_pkg::msg_data_t data, int stall_cycles);
        generated_data_t item;
        item.data = data;
        item.stall_cycles = stall_cycles;
        repeat(stall_cycles) @(negedge clk); // simulate data stall by waiting before pushing to FIFO
        fifo.push_back(item);
    endfunction

    // Look-ahead FIFO logic
    always_ff @(posedge clk) begin
        if (fifo.size() > 0) begin
            if (rdack) begin
                fifo.pop_front(); // remove the item after acknowledging it
            end
        end
    end

    always_comb begin
        if (fifo.size() > 0) begin
            msg = fifo[0].data; // equivalent to a "peek"
            empty = 1'b0;
        end else begin
            msg = 'X;
            empty = 1'b1;
        end
    end

endmodule
