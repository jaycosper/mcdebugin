`timescale 1ns / 1ps
`default_nettype none

module tb_msg_encoder;

    // ────────────────────────────────────────────────
    // Signals
    // ────────────────────────────────────────────────
    logic clk   = 0;
    logic rst_n = 0;

    protocol_pkg::msg_data_t msg, fifo_wdata;
    logic fifo_wren, fifo_full, msg_stall, enable_stall;
    protocol_pkg::cmd_rsp_t test_rsp;
    logic test_rsp_ready, rsp_sent;
    logic [7:0] error_count;

    // ────────────────────────────────────────────────
    // DUT
    // ────────────────────────────────────────────────
    msg_encoder dut (
        .i_clk          (clk),
        .i_rst_n        (rst_n),
        // Response
        .i_rsp          (test_rsp),
        .i_rsp_ready    (test_rsp_ready),
        .o_rsp_sent     (rsp_sent),
        // FIFO interface signals
        .o_msg_wren     (fifo_wren),
        .o_msg_data     (fifo_wdata),
        .i_msg_stall    (msg_stall)
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
    int signed expected_msg_size = 0;
    protocol_pkg::msg_data_t test_data;

    function automatic int check_output(protocol_pkg::cmd_rsp_t expected_msg);
        int errors = 0;
        protocol_pkg::header_t hdr;
        protocol_pkg::msg_data_t data;
        protocol_pkg::crc_t crc;

        $display("*** Checking output message... ***");

        hdr = fifo.pop_front(); // header
        if (hdr != expected_msg.hdr) begin
            $display("%0t: ERROR! Header mismatch. Expected %h but got %h", $time, expected_msg.hdr, hdr);
            errors++;
        end
        if (hdr.payload_length > 0) begin
            for (int i=0; i<hdr.payload_length; i++) begin
                data = fifo.pop_front(); // payload data
                if (data != expected_msg.payload[i]) begin
                    $display("%0t: ERROR! Payload data mismatch at index %0d. Expected %h but got %h", $time, i, expected_msg.payload[i], data);
                    errors++;
                end
            end
        end
        crc = fifo.pop_front(); // CRC
        if (crc != expected_msg.crc) begin
            $display("%0t: ERROR! CRC mismatch. Expected %h but got %h", $time, expected_msg.crc, crc);
            errors++;
        end
        if (errors == 0) $display("\t\t... OK!");
        return errors;
    endfunction

    initial begin
        $dumpfile("tb_msg_encoder.vcd");
        $dumpvars(0, tb_msg_encoder);

        // Reset phase
        rst_n = 0;
        repeat (4) @(negedge clk);
        rst_n = 1;
        repeat (4) @(negedge clk);

        $display("┌──────────────────────────────┐");
        $display("│   Starting self-check test   │");
        $display("└──────────────────────────────┘");

        test_num = 1;
        $display("Test %0d: Simple response with no payload", test_num);
        enable_stall = 1'b0; // no stalls for this test
        // load queue
        test_rsp.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_rsp.hdr.payload_length = 0;
        test_rsp.hdr.tag = 1;
        test_rsp.hdr.cmd_rsp = 10;
        test_rsp.crc = 'hCAFE_D00D; // dummy CRC for now
        test_rsp_ready = 1'b1; // indicate response is ready
        expected_msg_size = 2; // header + CRC only, no payload

        // clock DUT and check output
        while (!rsp_sent) @(negedge clk); // wait for DUT to finish processing
        test_rsp_ready = 1'b0;
        if (fifo.size() != expected_msg_size) begin
            $display("%0t: ERROR! Unexpected message data packets to be sent! Found %0d, expected %0d items", $time, fifo.size(), expected_msg_size);
            test_errors += (expected_msg_size > fifo.size()) ? (expected_msg_size - fifo.size()) : fifo.size() - expected_msg_size;
        end
        test_errors += check_output(test_rsp);

        repeat (10) @(negedge clk);
        test_num = 2;
        $display("");
        $display("Test %0d: Simple response with nominal payload", test_num);
        // load queue
        test_rsp.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_rsp.hdr.payload_length = 4;
        test_rsp.hdr.tag = 2;
        test_rsp.hdr.cmd_rsp = 11;
        test_rsp.payload[0] = 'h1122_3344;
        test_rsp.payload[1] = 'h5566_7788;
        test_rsp.payload[2] = 'h99AA_BBCC;
        test_rsp.payload[3] = 'hDDEE_FF00;
        test_rsp.crc = 'hCAFE_D00D; // dummy CRC for now
        test_rsp_ready = 1'b1; // indicate response is ready
        expected_msg_size = 6; // header + 4 payload items + CRC

        // clock DUT and check output
        while (!rsp_sent) @(negedge clk); // wait for DUT to finish processing
        test_rsp_ready = 1'b0;
        if (fifo.size() != expected_msg_size) begin
            $display("%0t: ERROR! Unexpected message data packets to be sent! Found %0d, expected %0d items", $time, fifo.size(), expected_msg_size);
            test_errors += (expected_msg_size > fifo.size()) ? (expected_msg_size - fifo.size()) : fifo.size() - expected_msg_size;
        end
        test_errors += check_output(test_rsp);

        repeat (10) @(negedge clk);
        test_num = 3;
        $display("");
        $display("Test %0d: Response with payload length at max limit", test_num);
        // load queue
        test_rsp.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_rsp.hdr.payload_length = $size(test_rsp.hdr.payload_length)'(protocol_pkg::pMAX_PAYLOAD_DW); // max payload length
        test_rsp.hdr.tag = 3;
        test_rsp.hdr.cmd_rsp = 12;
        for (int i=0; i<protocol_pkg::pMAX_PAYLOAD_DW; i++) begin
            test_rsp.payload[i] = $urandom; // random payload data
        end
        test_rsp.crc = 'hCAFE_D00D; // dummy CRC for now
        test_rsp_ready = 1'b1; // indicate response is ready
        expected_msg_size = 1 + protocol_pkg::pMAX_PAYLOAD_DW + 1; // header + max payload items + CRC

        // clock DUT and check output
        while (!rsp_sent) @(negedge clk); // wait for DUT to finish processing
        test_rsp_ready = 1'b0;
        if (fifo.size() != expected_msg_size) begin
            $display("%0t: ERROR! Unexpected message data packets to be sent! Found %0d, expected %0d items", $time, fifo.size(), expected_msg_size);
            test_errors += (expected_msg_size > fifo.size()) ? (expected_msg_size - fifo.size()) : fifo.size() - expected_msg_size;
        end
        test_errors += check_output(test_rsp);

        repeat (10) @(negedge clk);
        test_num = 4;
        $display("");
        $display("Test %0d: Response with payload and random data stalls", test_num);
        enable_stall = 1'b1; // random stalls for this test
        // load queue
        test_rsp.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_rsp.hdr.payload_length = 8;
        test_rsp.hdr.tag = 4;
        test_rsp.hdr.cmd_rsp = 13;
        for (int i=0; i<test_rsp.hdr.payload_length; i++) begin
            test_rsp.payload[i] = $urandom; // random payload data
        end
        test_rsp.crc = 'hCAFE_D00D; // dummy CRC for now
        test_rsp_ready = 1'b1; // indicate response is ready
        expected_msg_size = 1 + 32'(test_rsp.hdr.payload_length) + 1; // header + payload items + CRC

        // clock DUT and check output
        while (!rsp_sent) @(negedge clk); // wait for DUT to finish processing
        test_rsp_ready = 1'b0;
        if (fifo.size() != expected_msg_size) begin
            $display("%0t: ERROR! Unexpected message data packets to be sent! Found %0d, expected %0d items", $time, fifo.size(), expected_msg_size);
            test_errors += (expected_msg_size > fifo.size()) ? (expected_msg_size - fifo.size()) : fifo.size() - expected_msg_size;
        end
        test_errors += check_output(test_rsp);
        enable_stall = 1'b0;

        repeat (10) @(negedge clk);
        test_num = 5;
        $display("");
        $display("Test %0d: Response with full payload and random data stalls", test_num);
        enable_stall = 1'b1; // random stalls for this test
        // load queue
        test_rsp.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_rsp.hdr.payload_length = $size(test_rsp.hdr.payload_length)'(protocol_pkg::pMAX_PAYLOAD_DW); // max payload length
        test_rsp.hdr.tag = 5;
        test_rsp.hdr.cmd_rsp = 14;
        for (int i=0; i<protocol_pkg::pMAX_PAYLOAD_DW; i++) begin
            test_rsp.payload[i] = $urandom; // random payload data
        end
        test_rsp.crc = 'hCAFE_D00D; // dummy CRC for now
        test_rsp_ready = 1'b1; // indicate response is ready
        expected_msg_size = 1 + protocol_pkg::pMAX_PAYLOAD_DW + 1; // header + max payload items + CRC

        // clock DUT and check output
        while (!rsp_sent) @(negedge clk); // wait for DUT to finish processing
        test_rsp_ready = 1'b0;
        if (fifo.size() != expected_msg_size) begin
            $display("%0t: ERROR! Unexpected message data packets to be sent! Found %0d, expected %0d items", $time, fifo.size(), expected_msg_size);
            test_errors += (expected_msg_size > fifo.size()) ? (expected_msg_size - fifo.size()) : fifo.size() - expected_msg_size;
        end
        test_errors += check_output(test_rsp);
        enable_stall = 1'b0;

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
    protocol_pkg::msg_data_t fifo [$];

    // FIFO logic
    always_ff @(posedge clk) begin
        if (fifo_wren) begin
            if (fifo_full) begin
                fifo.push_back('X);
            end else begin
                fifo.push_back(fifo_wdata); // add the item to the FIFO
            end
        end
    end

    assign msg_stall = fifo_full;

    always_ff @(posedge clk) begin
        if (enable_stall) begin
            if ($urandom_range(0, 1) == 1) begin
                fifo_full <= 1'b1;
            end else begin
                fifo_full <= 1'b0;
            end
        end else begin
            fifo_full <= 1'b0;
        end
    end

endmodule
