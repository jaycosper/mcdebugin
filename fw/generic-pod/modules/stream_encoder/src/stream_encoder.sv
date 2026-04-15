`timescale 1ns / 1ps
`default_nettype none

import protocol_pkg::*;

module stream_encoder (
    input   logic i_clk,
    input   logic i_rst_n,
    // FIFO interface
    input  logic i_msg_ready,
    output  logic o_rden,
    input  logic [pRXTX_DATA_WIDTH-1:0] i_rd_data,
    // PHY interface
    output  protocol_pkg::rxtx_data_t o_data
);

    logic msg_frame;
    logic rden;

    // Message framing logic:
    // detect rising edge of msg_ready to indicate start of message, and falling edge to indicate end of message
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            msg_frame <= 1'b0;
        end else begin
            msg_frame <= i_msg_ready;
        end
    end

    // Data output logic:
    // if we're in a message frame, output the data from the FIFO; otherwise, output the SYNC
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            rden <= 1'b0;
            o_data <= '{default:0, data:pSYNC_STREAM.data, is_k:1'b1};
        end else begin
            rden <= 1'b0;
            if (i_msg_ready) begin
                if (!msg_frame) begin
                    // first data output MESSAGE_START control character
                    rden <= 1'b1;
                    o_data <= '{default:0, data:pMESSAGE_START.data, is_k:1'b1};
                end else begin
                    // output data from FIFO if we're in a message frame
                    rden <= 1'b1;
                    o_data <= '{default:0, data:i_rd_data, is_k:1'b0};
                end
            end else begin
                // otherwise, output SYNC
                o_data <= '{default:0, data:pSYNC_STREAM.data, is_k:1'b1};
            end
        end
    end

    assign o_rden = rden && i_msg_ready;

endmodule

`default_nettype wire
