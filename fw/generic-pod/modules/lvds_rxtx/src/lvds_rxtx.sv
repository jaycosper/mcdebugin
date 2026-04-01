`timescale 1ns / 1ps
`default_nettype none

import protocol_pkg::*;

module lvds_rxtx (
    input   logic i_clk,
    input   logic i_rst_n,
    input   logic i_frame_clk,

    output  logic o_lvds_clk,
    input   logic i_lvds_rx,
    output  logic o_lvds_tx,

    // clocked in i_frame_clk domain
    output  logic       o_link_locked,
    input   rxtx_data_t i_datain,
    output  rxtx_data_t o_dataout
);

    symbol_t tx_data;
    logic [9:0] rcvd_data;
    rxtx_data_t rx_data;

    logic locked;
    logic advance_align;

    logic [3:0] align_cntr;
    logic reset_cntr;
    logic inc_cntr;

    // data_rate = 250 Mbps
    // fast clock = data_rate / 2 (DDR) = 250Mbps / 2 = 125MHz = sys_clk
    // slow clock = data_rate / bits_per_symbol = 250Mbps / 10 = 25MHz
    assign o_lvds_clk = i_clk;

    encoder_8b10b u_enc (
        .i_clk      (i_frame_clk),
        .i_rst      (!i_rst_n),
        .i_en       (1'b1),
        .i_din      (i_datain.data),
        .i_kin      (i_datain.is_k),
        .o_valid    (tx_data.valid),
        .o_dout     (tx_data.data),
        .o_disp     (tx_data.disp),
        .o_kin_err  (tx_data.kin_err)
    );

    softlvds_tx u_tx (
        .tx_inclock     (i_clk),
        .tx_syncclock   (i_frame_clk),
        .tx_data_reset  (!i_rst_n),
        .tx_in          (tx_data.data),
        .tx_out         (o_lvds_tx)
    );

    softlvds_rx u_rx(
        .rx_inclock     (i_clk),
        .rx_in          (i_lvds_rx),
        .rx_out         (rcvd_data),
        .rx_data_reset  (!i_rst_n),
        .rx_data_align  (advance_align)
    );

    decoder_8b10b u_dec (
        .i_clk      (i_frame_clk),
        .i_rst      (!i_rst_n),
        .i_en       (1'b1),
        .i_din      (rcvd_data),
        .o_valid    (rx_data.valid),
        .o_dout     (rx_data.data),
        .o_kout     (rx_data.is_k),
        .o_code_err (rx_data.code_err),
        .o_disp     (rx_data.disp),
        .o_disp_err (rx_data.disp_err)
    );

    always_ff @(posedge i_frame_clk) begin
        o_dataout <= rx_data;
    end

    // State machine for detecting LVDS data alignment and locking
    // Once locked, data transmission is expected to be stable
    typedef enum logic[1:0] {stINIT, stWAIT, stCHECK, stLOCKED} state_t;
    state_t nstate, cstate;

    // State transition logic
    always_ff @(posedge i_frame_clk) begin
        if (!i_rst_n) begin
            cstate <= stINIT;
        end else begin
            cstate <= nstate;
        end
    end

    // Counter logic for to wait between alignment checks
    always_ff @(posedge i_frame_clk) begin
        if (reset_cntr) begin
            align_cntr <= 'h0;
        end else if (inc_cntr) begin
            align_cntr <= align_cntr + 1'b1;
        end
    end

    // State transition logic
    always_comb begin
        nstate = cstate;
        reset_cntr = 1'b0;
        inc_cntr = 1'b0;
        advance_align = 1'b0;
        locked = 1'b0;
        case (cstate)
            stINIT: begin
                // after reset
                nstate = stWAIT;
                reset_cntr = 1'b1;
            end
            stWAIT: begin
                // wait for time before checking data
                nstate = stWAIT;
                inc_cntr = 1'b1;
                if (align_cntr == {$bits(align_cntr){1'b1}}) begin
                    nstate = stCHECK;
                end
            end
            stCHECK: begin
                // check data alignment
                nstate = stCHECK;
                if (o_dataout.data == SYNC_STREAM.data && o_dataout.is_k == SYNC_STREAM.is_k) begin
                    // properly aligned -- expecting loopback of transmitted data
                    nstate = stLOCKED;
                end else begin
                    // not aligned, advance alignment flag, wait, and check again
                    nstate = stWAIT;
                    advance_align = 1'b1;
                    reset_cntr = 1'b1;
                end
            end
            stLOCKED: begin
                // stay until reset
                nstate = stLOCKED;
                locked = 1'b1;
            end
        endcase
    end

    assign o_link_locked = locked;

endmodule

`default_nettype wire
