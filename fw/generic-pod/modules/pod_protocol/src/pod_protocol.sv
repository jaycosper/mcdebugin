`timescale 1ns / 1ps
`default_nettype none

module pod_protocol (
    input   wire    i_clk,
    input   wire    i_frame_clk,
    input   wire    i_rst_n,
    // physical interface
    output  logic   o_lvds_clk,
    input   wire    i_lvds_rx,
    output  logic   o_lvds_tx
    // system interfaces - command
    output  logic       o_cmd_ready,
    output  logic [7:0] o_flush_count,
    output  msg_data_t  o_cmd_data,
    input   wire        i_cmd_ack,
    output  logic       o_cmd_fifo_empty,
    // system interfaces - response
    input   wire        i_rsp_ready,
    input   logic [7:0] i_rsp_count,
    input   wire        i_rsp_wren,
    input   msg_data_t  i_rsp_data,
    output  logic       o_rsp_fifo_full
    );

// instaniate modules:
// xclk_fifo
// msg decoder
// cmd_rsp_fifo

logic link_locked,
rxtx_data_t datain, dataout;

// physical interface
lvds_rxtx u_lvds_rxtx (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_frame_clk    (i_frame_clk),

    .o_lvds_clk     (o_lvds_clk),
    .i_lvds_rx      (i_lvds_rx),
    .o_lvds_tx      (o_lvds_tx),

    // clocked in i_frame_clk domain
    .o_link_locked  (link_locked),
    .i_datain       (datain),
    .o_dataout      (dataout)
);

// In-bound (IB) message path: LVDS RX -> stream decoder -> IB FIFO -> message decoder -> command FIFO -> system
logic ib_wren;
logic [7:0] ib_data;
logic [7:0] error_count;

stream_decoder u_stream_decoder (
    .i_clk          (i_frame_clk),
    .i_rst_n        (i_rst_n),
    .i_data         (dataout),
    .o_wren         (ib_wren),
    .o_wr_data      (ib_data),
    .o_error_count  (error_count)
);

logic ib_fifo_full;
logic ib_fifo_empty;
logic [7:0] ib_fifo_rd_data;
logic ib_ack;

xclk_fifo u_ib_msg_fifo (
    .i_clk          (i_frame_clk),
    .i_rst_n        (i_rst_n),
    .i_wren         (ib_wren),
    .i_wr_data      (ib_data),
    .o_full         (ib_fifo_full),
    .o_empty        (ib_fifo_empty),
    .o_rd_data      (ib_fifo_rd_data),
    .i_rden         (ib_ack)
);

logic cmd_wren;
msg_data_t cmd_data;
msg_data_t cmd_fifo_full;

msg_decoder u_msg_decoder (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_msg_rdy  (!ib_fifo_empty),
    .i_msg      (ib_fifo_rd_data),
    .o_msg_ack  (ib_ack),
    .o_header   (),
    .i_datain   ('0),
    .o_wren     (cmd_wren),
    .o_dataout  (cmd_data),
    .o_stall    (cmd_data_full)
);

`ifdef SUPPORT_MULIPLE_COMMANDS
cmd_rsp_fifo u_cmd_fifo (
    .clock(i_clk),
    .wrreq(cmd_wren),
    .data(cmd_data),
    .full(cmd_data_full),
    // to system
    .rdreq,
    .q,
    .empty,
    .usedw()
);
`else
//tbd
`endif

// Out-bound (OB) message path: system -> response FIFO -> message encoder -> OB FIFO -> stream encoder -> LVDS TX

endmodule

`default_nettype wire
