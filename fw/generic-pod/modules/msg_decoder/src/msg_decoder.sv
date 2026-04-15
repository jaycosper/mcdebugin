`timescale 1ns / 1ps
`default_nettype none

import protocol_pkg::*;

module msg_decoder (
    input   wire    i_clk,
    input   wire    i_rst_n,

    // Input message interface
    input   wire    i_msg_rdy,
    input   wire [pMSG_DATA_WIDTH-1:0] i_msg,
    output  logic   o_msg_ack,

    // command output
    output  cmd_rsp_t o_cmd,
    output  logic   o_cmd_valid,
    input   wire    i_cmd_complete
);

    // State machine for decoding incoming messages
    // Once locked, data transmission is expected to be stable
    typedef enum logic[2:0] {stIDLE, stHEADER, stPAYLOAD, stCRC, stCHECKCRC} state_t;
    state_t nstate, cstate;

    cmd_rsp_t cmd;
    logic latch_hdr, latch_payload, latch_crc;
    logic set_cmd_in_progress, clear_cmd_in_progress, cmd_in_progress;

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
            cmd.hdr <= '0;
            cmd.crc <= '0;
            cmd_in_progress <= 1'b0;
        end else begin
            if (latch_hdr) begin
                cmd.hdr <= i_msg; // latch header
            end
            if (latch_payload) begin
                cmd.payload[payload_cntr[4:0]] <= i_msg; // latch payload data
            end
            if (latch_crc) begin
                cmd.crc <= i_msg; // latch CRC
            end
            if (set_cmd_in_progress) begin
                cmd_in_progress <= 1'b1; // set command ready after CRC check
            end
            if (clear_cmd_in_progress) begin
                cmd_in_progress <= 1'b0; // clear command ready after processing
            end
        end
    end
    // Counter logic for counting payload data words
    logic reset_cntr, inc_cntr;
    logic [pPAYLOAD_LENGTH_WIDTH-1:0] payload_cntr;

    always_ff @(posedge i_clk) begin
        if (reset_cntr) begin
            payload_cntr <= 'h0;
        end else if (inc_cntr) begin
            payload_cntr <= payload_cntr + 1'b1;
        end
    end

    // Counter logic for logging errors (e.g. CRC mismatch, invalid header, etc.)
    logic reset_error, inc_error;
    logic [7:0] error_cntr;

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
        reset_error = 1'b0;
        reset_cntr = 1'b0;
        inc_cntr = 1'b0;
        o_msg_ack = 1'b0;
        latch_hdr = 1'b0;
        latch_payload = 1'b0;
        latch_crc = 1'b0;
        inc_error = 1'b0;
        set_cmd_in_progress = 1'b0;
        case (cstate)
            stIDLE: begin
                nstate = stIDLE;
                if (i_msg_rdy && !cmd_in_progress) begin
                    nstate = stHEADER;
                    o_msg_ack = 1'b1; // ack header
                    latch_hdr = 1'b1; // latch header
                end
            end
            stHEADER: begin
                // wait for time before checking data
                reset_cntr = 1'b1;
                if (cmd.hdr.marker == pHEADER_MARKER_VALID) begin
                    if (i_msg_rdy) begin
                        if (cmd.hdr.payload_length > pPAYLOAD_LENGTH_WIDTH'(pMAX_PAYLOAD_DW)) begin
                            inc_error = 1'b1;
                            nstate = stIDLE;
                        end else if (cmd.hdr.payload_length == 0) begin
                            // no playload, skip to CRC check
                            o_msg_ack = 1'b1; // keep acking data while available
                            nstate = stCHECKCRC;
                            latch_crc = 1'b1; // latch CRC data
                        end else begin
                            nstate = stPAYLOAD;
                        end
                    end
                end else begin
                    // invalid header, go back to idle
                    inc_error = 1'b1;
                    nstate = stIDLE;
                end
            end
            stPAYLOAD: begin
                nstate = stPAYLOAD;
                o_msg_ack = i_msg_rdy; // ack data while available
                if (i_msg_rdy && o_msg_ack) begin
                    inc_cntr = 1'b1;
                    latch_payload = 1'b1; // latch payload data
                    if (payload_cntr == cmd.hdr.payload_length-1) begin
                        nstate = stCRC;
                    end
                end
            end
            stCRC: begin
                nstate = stCRC;
                o_msg_ack = i_msg_rdy; // ack data while available
                if (i_msg_rdy && o_msg_ack) begin
                    latch_crc = 1'b1; // latch CRC data
                    nstate = stCHECKCRC;
                end
            end
            stCHECKCRC: begin
                // Calc CRC and compare with expected value (stubbed for now)
                nstate = stIDLE; // go back to idle after CRC check
                if (cmd.crc != 'hDEADBEEF) begin // dummy CRC check
                    inc_error = 1'b1; // increment error counter on CRC mismatch
                end else begin
                    set_cmd_in_progress = 1'b1;
                end
            end
            default: begin
                nstate = stIDLE;
                inc_error = 1'b1;
            end
        endcase
    end

    assign o_cmd = cmd;
    assign o_cmd_valid = cmd_in_progress;
    assign clear_cmd_in_progress = i_cmd_complete;

endmodule

`default_nettype wire
