`timescale 1ns / 1ps
`default_nettype none

module tb_msg_decoder;

    // ────────────────────────────────────────────────
    // Signals
    // ────────────────────────────────────────────────
    logic clk   = 0;
    logic rst_n = 0;

    protocol_pkg::msg_data_t data, wr_data;
    logic rdack, empty;
    logic [7:0] error_count;

    // ────────────────────────────────────────────────
    // DUT
    // ────────────────────────────────────────────────
    msg_decoder dut (
        .i_clk      (clk),
        .i_rst_n    (rst_n),
        .i_msg_rdy  (!empty),
        .i_msg      (data),
        .o_msg_ack  (rdack),
        .o_header   (),
        .i_datain   ('X),
        .o_dataout  ()
    );

    // 100 MHz clock (just for style — not required for this DUT)
    localparam int CLK_FREQ_MHZ = 125;
    localparam int CLK_PERIOD_NS = 1000 / CLK_FREQ_MHZ;
    always #CLK_PERIOD_NS clk = ~clk;

    // ────────────────────────────────────────────────
    // Reset & stimulus
    // ────────────────────────────────────────────────
    protocol_pkg::msg_data_t test_data;

    typedef struct {
        protocol_pkg::header_t hdr;
        protocol_pkg::msg_data_t data [0:protocol_pkg::pMAX_PAYLOAD_DW-1];
        protocol_pkg::crc_t crc;
    } message_t;
    message_t test_msg;

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

        $display("Test 1: Simple message with no payload");
        // load queue
        test_msg.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_msg.hdr.payload_length = 0;
        test_msg.hdr.tag = 1;
        test_msg.hdr.cmd_rsp = 7;
        test_msg.crc = 'hDEADBEEF; // dummy CRC for now

        //for (int i=0; i<8; i++) begin
            fifo.push_back(test_msg.hdr);
            fifo.push_back(test_msg.crc);
        //end
        // clock DUT and check output
        repeat (16) @(negedge clk);
        if (fifo.size() != 0) begin
            $display("ERROR: Expected input data to be read out but found %0d items remaining", fifo.size());
            errors += fifo.size();
        end

        repeat (10) @(negedge clk);
        $display("Test 2: Simple message with nominal payload");
        // load queue
        test_msg.hdr.marker = protocol_pkg::pHEADER_MARKER_VALID;
        test_msg.hdr.payload_length = 4;
        test_msg.hdr.tag = 2;
        test_msg.hdr.cmd_rsp = 7;
        test_msg.crc = 'hDEADBEEF; // dummy CRC for now

        fifo.push_back(test_msg.hdr);
        for (int i=0; i<test_msg.hdr.payload_length; i++) begin
            test_msg.data[i] = i+1; // incrementing payload data
            fifo.push_back(test_msg.data[i]);
        end
        fifo.push_back(test_msg.crc);

        // clock DUT and check output
        repeat (32) @(negedge clk);
        if (fifo.size() != 0) begin
            $display("ERROR: Expected input data to be read out but found %0d items remaining", fifo.size());
            errors += fifo.size();
        end

        // repeat (10) @(negedge clk);
        // // Test 2: all IDLE control characters (K28.5)
        // $display("Test 2: Simple message stream (K28.1 followed by data bytes) and then IDLE characters");
        // // load queue
        // test_data = '{default:0, valid: 1'b1, is_k: 1'b1, data: 8'hBC}; // K28.5
        // for (int i=0; i<2; i++) begin
        //     queue_in.push_back(test_data);
        // end
        // test_data = '{default:0, valid: 1'b1, is_k: 1'b1, data: 8'h3C}; // K28.1
        // queue_in.push_back(test_data);
        // for (int i=0; i<8; i++) begin
        //     test_data = '{default:0, valid: 1'b1, is_k: 1'b0, data: 8'(i+1)}; // data bytes
        //     queue_in.push_back(test_data);
        // end
        // test_data = '{default:0, valid: 1'b1, is_k: 1'b1, data: 8'hBC}; // K28.5
        // for (int i=0; i<2; i++) begin
        //     queue_in.push_back(test_data);
        // end
        // // clock DUT and check output
        // repeat (100) @(negedge clk);
        // if (queue_in.size() != 0) begin
        //     $display("ERROR: Expected input data to be read out but found %0d items remaining", queue_in.size());
        //     errors += queue_in.size();
        // end
        // if (queue_out.size() != 8) begin
        //     $display("ERROR: Expected 8 items in output, but found %0d items", queue_out.size());
        //     errors += queue_out.size();
        // end

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
    protocol_pkg::msg_data_t fifo [$];

    // Look-ahead FIFO logic
    always_ff @(posedge clk) begin
        // if (wren) begin
        //     fifo.push_back(wr_data);
        // end

        if (fifo.size() > 0) begin
            empty <= 1'b0;
            if (rdack) begin
                fifo.pop_front(); // remove the item after acknowledging it
            end
        end else begin
            empty <= 1'b1;
        end
    end

    always_comb begin
        if (fifo.size() > 0) begin
            data = fifo[0]; // equivalent to a "peek"
        end else begin
            data = 'X;
        end
    end

endmodule
