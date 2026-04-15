`timescale 1ns / 1ps
`default_nettype none

import protocol_pkg::*;

module pod_protocol (
    input   wire    i_clk,
    input   wire    i_frame_clk,
    input   wire    i_rst_n,
    // physical interface
    output  logic   o_lvds_clk,
    input   wire    i_lvds_rx,
    output  logic   o_lvds_tx,
    // system interfaces - command
    output  logic       o_cmd_valid,
    output  cmd_rsp_t   o_cmd,
    input   wire        i_cmd_complete,
    // system interfaces - response
    input  wire         i_rsp_ready,
    input  cmd_rsp_t    i_rsp,
    output  logic       o_rsp_sent,
    // misc
    output logic        o_link_locked
);

logic link_locked;
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

// In-bound (IB) message path: LVDS RX -> stream decoder -> IB FIFO -> message decoder -> (command FIFO) -> system
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
logic [31:0] ib_fifo_rd_data;
logic ib_ack;

ib_xclk_fifo u_ib_msg_fifo (
    .wrclk  (i_frame_clk),
    .wrreq  (ib_wren),
    .wrfull (ib_fifo_full),
    .data   (ib_data),
    .rdclk  (i_clk),
    .rdreq  (ib_ack),
    .q      (ib_fifo_rd_data),
    .rdempty(ib_fifo_empty)
);

cmd_rsp_t cmd;
logic cmd_valid;
logic cmd_complete = 1'b0;

msg_decoder u_msg_decoder (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_msg_rdy      (!ib_fifo_empty),
    .i_msg          (ib_fifo_rd_data),
    .o_msg_ack      (ib_ack),
    .o_cmd          (o_cmd),
    .o_cmd_valid    (o_cmd_valid),
    .i_cmd_complete (i_cmd_complete)
);

// ******
// Process Commands and generate responses here
//  // TODO: this needs to be in here if I want to test -- maybe TESTMODE/LOOPBACK flag
//  always_ff @(posedge lvds_clk_slow) begin
//      if (!sys_rst_n) begin
//          gen_data <= '0; // Reset the data to be transmitted
//      end else begin
//          if (sw_state[3] || !link_locked) begin
//              gen_data <= pSYNC_STREAM; // Transmit K28.5 until locked or if switch 3 is active
//          end else begin
//              if (gen_data.data == 8'hFF) begin
//                  gen_data <= pMESSAGE_START; // Transmit K28.1 after reaching max data value
//              end else if (gen_data == pMESSAGE_START) begin
//                  gen_data.is_k <= 1'b0;
//                  gen_data.data <= 'h0;
//              end else begin
//                  gen_data.is_k <= 1'b0;
//                  gen_data.data <= gen_data.data + 1'b1; // Increment the data to be transmitted
//              end
//              gen_data.data <= gen_data.data + 1'b1; // Increment the data to be transmitted
//          end
//      end
//  end
// ******

// Out-bound (OB) message path: system -> (response FIFO) -> message encoder -> OB FIFO -> stream encoder -> LVDS TX
logic ob_fifo_wren;
logic [31:0] ob_fifo_wr_data;
logic ob_fifo_full;

msg_encoder u_msg_encoder (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    // System response interface
    .i_rsp          (i_rsp),
    .i_rsp_ready    (i_rsp_ready),
    .o_rsp_sent     (o_rsp_sent),
    // FIFO interface signals
    .o_msg_wren     (ob_fifo_wren),
    .o_msg_data     (ob_fifo_wr_data),
    .i_msg_stall    (ob_fifo_full)
);

logic ob_fifo_empty;
logic [7:0] ob_data;
logic ob_ack;

ob_xclk_fifo u_ob_msg_fifo (
    .wrclk  (i_clk),
    .wrreq  (ob_fifo_wren),
    .wrfull (ob_fifo_full),
    .data   (ob_fifo_wr_data),
    .rdclk  (i_frame_clk),
    .rdreq  (ob_ack),
    .q      (ob_data),
    .rdempty(ob_fifo_empty)
);

logic ob_wren, ob_msg_ready;
logic [7:0] ob_error_count;
assign ob_msg_ready = !ob_fifo_empty;

stream_encoder u_stream_encoder (
    .i_clk          (i_frame_clk),
    .i_rst_n        (i_rst_n),
    .i_msg_ready    (ob_msg_ready),
    .o_rden         (ob_ack),
    .i_rd_data      (ob_data),
    .o_data         (datain)
);

endmodule

`default_nettype wire
