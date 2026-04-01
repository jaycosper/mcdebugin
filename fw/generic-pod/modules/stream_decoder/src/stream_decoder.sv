`timescale 1ns / 1ps
`default_nettype none

import protocol_pkg::*;

module stream_decoder (
    input   logic i_clk,
    input   logic i_rst_n,
    input   protocol_pkg::rxtx_data_t i_data,
    output  logic o_wren,
    output  logic [7:0] o_wr_data,
    output  logic [7:0] o_error_count
);

    logic msg_start_detected;
    logic [7:0] error_cntr;

    // State transition logic
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            error_cntr <= 'h0;
            msg_start_detected <= 1'b0;
            o_wren <= 1'b0;
            o_wr_data <= 'h0;
        end else begin
            o_wren <= 1'b0;
            if (i_data.valid && i_data.is_k && i_data.data == SYNC_STREAM.data) begin
                // end of message or IDLE bus packet -- drop packet
                msg_start_detected <= 1'b0;
            end else if (i_data.valid && i_data.is_k && i_data.data == MESSAGE_START.data) begin
                // start of message -- drop packet
                msg_start_detected <= 1'b1;
            end else if (msg_start_detected) begin
                // write data if valid, not a control character, and we've seen the start of message
                o_wren <= i_data.valid && !i_data.is_k && msg_start_detected;
                o_wr_data <= i_data.data;
            end else begin
                // something else... but not expected
                error_cntr <= error_cntr + 1'b1;
            end
        end
    end

endmodule

`default_nettype wire
