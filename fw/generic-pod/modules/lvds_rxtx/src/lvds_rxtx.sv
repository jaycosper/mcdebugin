`timescale 1ns / 1ps
`default_nettype none

module lvds_rxtx (
    input   logic i_clk,
    input   logic i_rst_n,
    input   logic i_frame_clk,

    output  logic o_lvds_clk,
    input   logic i_lvds_rx,
    output  logic o_lvds_tx,

    // clocked in i_frame_clk domain
    output  logic o_data_locked,
    input   logic [9:0] i_datain,
    output  logic [9:0] o_dataout
);

    logic locked;
    logic advance_align;
    logic [9:0] rcvd_data;

    logic [3:0] align_cntr;
    logic reset_cntr;
    logic inc_cntr;

    // data_rate = 250 Mbps
    // fast clock = data_rate / 2 (DDR) = 250Mbps / 2 = 125MHz = sys_clk
    // slow clock = data_rate / bits_per_symbol = 250Mbps / 10 = 25MHz
    assign o_lvds_clk = i_clk;

    softlvds_tx u_tx (
        .tx_inclock(i_clk),
        .tx_syncclock(i_frame_clk),
        .tx_data_reset(!i_rst_n),
        .tx_in (i_datain),
        .tx_out(o_lvds_tx)
    );

    softlvds_rx u_rx(
        .rx_inclock(i_clk),
        .rx_in(i_lvds_rx),
        .rx_out (rcvd_data),
        .rx_data_reset(!i_rst_n),
        .rx_data_align(advance_align)
    );

    always_ff @(posedge i_frame_clk) begin
        o_dataout <= rcvd_data;
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
                if (o_dataout == i_datain) begin
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

    assign o_data_locked = locked;

endmodule

`default_nettype wire
