`timescale 1ns / 1ps
`default_nettype none

import protocol_pkg::*;

module msg_encoder (
    input   wire        i_clk,
    input   wire        i_rst_n,

    // System response interface
    input   cmd_rsp_t   i_rsp,
    input   wire        i_rsp_ready,
    output  logic       o_rsp_sent,

    // FIFO interface signals
    output   wire       o_msg_wren,
    output   wire [pMSG_DATA_WIDTH-1:0] o_msg_data,
    input  logic        i_msg_stall
);

    // State machine for decoding incoming messages
    // Once locked, data transmission is expected to be stable
    typedef enum logic[1:0] {stIDLE, stHEADER, stSEND, stCRC} state_t;
    state_t nstate, cstate;

    logic [7:0] data_length; // maximum payload + header + CRC is 256 bytes, so 8 bits is sufficient to count data words
    logic latch_payload_length;
    logic rsp_complete;

    // State transition logic
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            cstate <= stIDLE;
        end else begin
            cstate <= nstate;
        end
    end

    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
        end else begin
            if (latch_payload_length) begin
                data_length <= i_rsp.hdr.payload_length + $bits(data_length)'(1); // latch payload length from header, add 1 for header
            end
        end
    end
    // Counter logic for counting payload data words
    logic reset_cntr, inc_cntr;
    logic [pPAYLOAD_LENGTH_WIDTH-1:0] data_cntr;

    always_ff @(posedge i_clk) begin
        if (reset_cntr) begin
            data_cntr <= 'h0;
        end else if (inc_cntr) begin
            data_cntr <= data_cntr + 1'b1;
        end
    end

    // Counter logic for logging errors (e.g. CRC mismatch, invalid header, etc.)
    logic reset_error;
    logic inc_error;
    logic [7:0] error_cntr;

    assign reset_error = !i_rst_n; // || <TBD>

    always_ff @(posedge i_clk) begin
        if (reset_error) begin
            error_cntr <= 'h0;
        end else if (inc_error) begin
            error_cntr <= error_cntr + 1'b1;
        end
    end

    // State transition logic
    always_comb begin
        nstate = cstate;
        o_msg_data = '0;
        o_msg_wren = 1'b0;
        latch_payload_length = 1'b0;
        reset_cntr = 1'b0;
        inc_cntr = 1'b0;
        rsp_complete = 1'b0;
        inc_error = 1'b0;

        case (cstate)
            stIDLE: begin
                nstate = stIDLE;
                if (i_rsp_ready && !i_msg_stall) begin
                    nstate = stHEADER;
                end
            end
            stHEADER: begin
                // wait for time before checking data
                nstate = stHEADER;
                latch_payload_length = 1'b1;
                reset_cntr = 1'b1;
                if (!i_msg_stall) begin
                    nstate = stSEND;
                end
            end
            stSEND: begin
                nstate = stSEND;
                o_msg_wren = i_msg_stall ? 1'b0 : 1'b1;
                o_msg_data = (data_cntr == 0) ? i_rsp.hdr : i_rsp.payload[pPAYLOAD_LENGTH_WIDTH'(data_cntr-1'b1)];
                inc_cntr = i_msg_stall ? 1'b0 : 1'b1;
                if (!i_msg_stall && data_cntr >= data_length-1) begin
                    nstate = stCRC;
                end
                if (data_length > $size(data_length)'(pMAX_PAYLOAD_DW)+1'b1) begin // payload length + header exceeds max
                    nstate = stIDLE;
                    inc_error = 1'b1;
                    rsp_complete = 1'b1;
                end
            end
            stCRC: begin
                nstate = stCRC;
                o_msg_wren = i_msg_stall ? 1'b0 : 1'b1;
                o_msg_data = pMSG_DATA_WIDTH'('hCAFED00D);
                if (!i_msg_stall) begin
                    nstate = stIDLE;
                    rsp_complete = 1'b1;
                end
            end
            default: begin
                nstate = stIDLE;
                inc_error = 1'b1;
            end
        endcase
    end

    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            o_rsp_sent <= 1'b0;
        end else begin
            o_rsp_sent <= 1'b0;
            if (rsp_complete) begin
                o_rsp_sent <= 1'b1;
            end
        end
    end

endmodule

`default_nettype wire
