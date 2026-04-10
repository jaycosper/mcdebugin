`timescale 1ns / 1ps
`default_nettype none

import protocol_pkg::*;

module msg_decoder (
    input   logic i_clk,
    input   logic i_rst_n,

    input   logic i_msg_rdy,
    input   logic [pMSG_DATA_WIDTH-1:0] i_msg,
    output  logic o_msg_ack,
    output  cmd_rsp_t o_cmd,

    // clocked in i_frame_clk domain
    output  header_t o_header,
    input   rxtx_data_t i_datain,
    output  rxtx_data_t o_dataout
);

    // State machine for decoding incoming messages
    // Once locked, data transmission is expected to be stable
    typedef enum logic[2:0] {stIDLE, stHEADER, stPAYLOAD, stCRC, stCHECKCRC} state_t;
    state_t nstate, cstate;

    // header_t hdr;
    msg_data_t payload [0:pMAX_PAYLOAD_DW-1];
    // crc_t crc;
    cmd_rsp_t cmd;
    logic latch_hdr, latch_payload, latch_crc, clear_crc;
    logic set_cmd_ready, clear_cmd_ready, cmd_ready;

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
            cmd_ready <= 1'b0;
        end else begin
            if (latch_hdr) begin
                cmd.hdr <= i_msg; // latch header
            end
            if (latch_payload) begin
                cmd.payload[payload_cntr[4:0]] <= i_msg; // latch payload data
                payload[payload_cntr[4:0]] <= i_msg; // latch payload data
            end
            if (latch_crc) begin
                cmd.crc <= i_msg; // latch CRC
            end else if (clear_crc) begin
                cmd.crc <= '0; // test code
            end
            if (set_cmd_ready) begin
                cmd_ready <= 1'b1; // set command ready after CRC check
            end
            if (clear_cmd_ready) begin
                cmd_ready <= 1'b0; // clear command ready after processing
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
        reset_cntr = 1'b0;
        inc_cntr = 1'b0;
        o_msg_ack = 1'b0;
        latch_hdr = 1'b0;
        latch_payload = 1'b0;
        latch_crc = 1'b0;
        inc_error = 1'b0;
        set_cmd_ready = 1'b0;
        case (cstate)
            stIDLE: begin
                if (i_msg_rdy && !cmd_ready) begin
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
                    set_cmd_ready = 1'b1;
                end
            end
            default: begin
                nstate = stIDLE;
                inc_error = 1'b1;
            end
        endcase
    end

    logic [3:0] delay;
    // process decoded command (stubbed for now)
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            delay <= '0;
            clear_cmd_ready <= 1'b0;
            clear_crc <= 1'b0;
        end else if (cmd_ready) begin
            delay <= delay + 1'b1;
            clear_cmd_ready <= 1'b0;
            clear_crc <= 1'b0;
            if (delay == 'hF) begin
                clear_cmd_ready <= 1'b1;
                clear_crc <= 1'b1;
                delay <= '0;
            end
        end
    end

    assign o_cmd = cmd;

endmodule

`default_nettype wire
