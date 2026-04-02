`timescale 1ns / 1ps
`default_nettype none

import protocol_pkg::*;

module msg_decoder (
    input   logic i_clk,
    input   logic i_rst_n,

    input   logic i_msg_rdy,
    input   logic [pMSG_DATA_WIDTH-1:0] i_msg,
    output  logic o_msg_ack,

    // clocked in i_frame_clk domain
    output  header_t o_header,
    input   rxtx_data_t i_datain,
    output  rxtx_data_t o_dataout
);

    // State machine for decoding incoming messages
    // Once locked, data transmission is expected to be stable
    typedef enum logic[2:0] {stIDLE, stHEADER, stPAYLOAD, stCRC, stCHECKCRC} state_t;
    state_t nstate, cstate;

    header_t hdr;
    msg_data_t payload [0:pMAX_PAYLOAD_DW-1];
    crc_t crc;
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
            hdr <= '0;
            crc <= '0;
            cmd_ready <= 1'b0;
        end else begin
            if (latch_hdr) begin
                hdr <= i_msg; // latch header
            end
            if (latch_payload) begin
                payload[payload_cntr[4:0]] <= i_msg; // latch payload data
            end
            if (latch_crc) begin
                crc <= i_msg; // latch CRC
            end else if (clear_crc) begin
                crc <= '0; // test code
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
                if (hdr.marker == pHEADER_MARKER_VALID) begin
                    if (i_msg_rdy) begin
                        if (hdr.payload_length == 0) begin
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
                    if (payload_cntr == hdr.payload_length-1) begin
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
                if (crc != 'hDEADBEEF) begin // dummy CRC check
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

endmodule

`default_nettype wire

// `default_nettype none
// `timescale 1ns/1ps
//
// package system_registers_pkg;
//   typedef struct packed {
//     logic [31:0] status;   // general status word
//     logic [31:0] hash;     // [31:4] = 28-bit Git hash, [3:0] = repo state nibble (0x0 clean, 0xF dirty)
//   } system_status_t;
//
//   typedef struct packed {
//     system_status_t status;
//     // Add more groups later (pins, errors, version, etc.)
//   } general_registers_t;
//
//   localparam int MAX_PAYLOAD_BYTES = 64;
//   localparam logic [31:0] CRC_POLY = 32'h04C11DB7;
// endpackage
//
// module max10_lvds_protocol #(
//     parameter int CLK_FREQ_MHZ = 100
// ) (
//     input  wire                         clk,
//     input  wire                         rst_n,
//
//     // LVDS pairs (MAX10 drives clock)
//     output wire                         lvds_clk_p,
//     output wire                         lvds_clk_n,
//     output wire                         lvds_tx_p,
//     output wire                         lvds_tx_n,
//     input  wire                         lvds_rx_p,
//     input  wire                         lvds_rx_n,
//
//     // Registers input
//     input  system_registers_pkg::general_registers_t  registers_in,
//
//     // Fast pin interface (36 bits)
//     input  wire [35:0]                  pin_states_in,   // current pin values for read response
//     output wire [35:0]                  pin_states_out   // new pin values from fast write
// );
//
//     import system_registers_pkg::*;
//
//     // ===================================================================
//     // Forwarded clock (always running at 100 MHz)
//     // ===================================================================
//     logic clk_out;
//     always_ff @(posedge clk or negedge rst_n)
//         if (!rst_n) clk_out <= 1'b0;
//         else        clk_out <= ~clk_out;
//
//     assign lvds_clk_p =  clk_out;
//     assign lvds_clk_n = ~clk_out;
//
//     // ===================================================================
//     // 8b/10b Encoder / Decoder (simple, open-source style)
//     // ===================================================================
//     // Encoder ports (from mcjtag/v8b10b style)
//     logic [7:0]  enc_din;
//     logic        enc_kin;
//     logic [9:0]  enc_dout;
//     logic        enc_disp;   // running disparity out
//
//     // Decoder ports
//     logic [9:0]  dec_din;
//     logic [7:0]  dec_dout;
//     logic        dec_kout;
//     logic        dec_disp_err;
//     logic        dec_code_err;
//
//     // Simple placeholder 8b/10b (replace with full open-source module)
//     // For brevity: this is a stub — in real use, instantiate mcjtag/v8b10b or similar
//     always_comb begin
//         enc_dout = {enc_din, enc_kin ? 2'b11 : 2'b00}; // dummy – use real encoder
//         dec_dout = dec_din[7:0];
//         dec_kout = dec_din[9];
//         dec_disp_err = 1'b0;
//         dec_code_err = 1'b0;
//     end
//
//     // ===================================================================
//     // RX FSM – 8b/10b decoded stream → packet parse
//     // ===================================================================
//     typedef enum logic [3:0] {
//         RX_IDLE, RX_HEADER, RX_PAYLOAD, RX_CRC, RX_EOF, RX_FAST
//     } rx_state_t;
//
//     rx_state_t rx_state = RX_IDLE;
//     logic [7:0]  rx_data;
//     logic        rx_k;
//     logic [15:0] rx_length = 0;
//     logic [7:0]  rx_payload [0:MAX_PAYLOAD_BYTES-1];
//     logic [7:0]  rx_payload_idx = 0;
//     logic [31:0] rx_crc_calc = 32'hFFFFFFFF;
//     logic [7:0]  cmd = 0;
//
//     logic fast_pin_write_valid = 0;
//     logic [35:0] fast_pin_data = 0;
//
//     // RX data from 8b/10b decoder
//     assign rx_data = dec_dout;
//     assign rx_k    = dec_kout;
//
//     always_ff @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             rx_state <= RX_IDLE;
//             rx_payload_idx <= 0;
//             rx_crc_calc <= 32'hFFFFFFFF;
//             fast_pin_write_valid <= 0;
//         end else if (!dec_disp_err && !dec_code_err) begin
//             case (rx_state)
//                 RX_IDLE: begin
//                     if (rx_k && rx_data == 8'hBC) begin  // K28.5 comma = SOF
//                         rx_state <= RX_HEADER;
//                         rx_payload_idx <= 0;
//                         rx_crc_calc <= 32'hFFFFFFFF;
//                     end
//                 end
//
//                 RX_HEADER: begin
//                     cmd <= rx_data;
//                     if (rx_data == 8'hFE) rx_state <= RX_FAST;  // fast path
//                     else                   rx_state <= RX_PAYLOAD; // normal
//                     rx_crc_calc <= rx_crc_calc ^ {24'h0, rx_data};
//                     for (int j=0; j<8; j++) rx_crc_calc <= rx_crc_calc[0] ? (rx_crc_calc >> 1) ^ CRC_POLY : (rx_crc_calc >> 1);
//                 end
//
//                 RX_PAYLOAD: begin
//                     if (rx_payload_idx < rx_length) begin
//                         rx_payload[rx_payload_idx] <= rx_data;
//                         rx_payload_idx <= rx_payload_idx + 1;
//                         rx_crc_calc <= rx_crc_calc ^ {24'h0, rx_data};
//                         for (int j=0; j<8; j++) rx_crc_calc <= rx_crc_calc[0] ? (rx_crc_calc >> 1) ^ CRC_POLY : (rx_crc_calc >> 1);
//                     end else rx_state <= RX_CRC;
//                 end
//
//                 RX_CRC: begin
//                     // Collect 4-byte CRC (MSB first) – stubbed for now
//                     rx_state <= RX_EOF;
//                 end
//
//                 RX_EOF: begin
//                     if (rx_k && rx_data == 8'hBC) rx_state <= RX_IDLE;
//                 end
//
//                 RX_FAST: begin
//                     if (rx_payload_idx < 5) begin
//                         fast_pin_data[rx_payload_idx*8 +:8] <= rx_data;
//                         rx_payload_idx <= rx_payload_idx + 1;
//                     end else begin
//                         fast_pin_write_valid <= 1'b1;
//                         rx_state <= RX_IDLE;
//                     end
//                 end
//             endcase
//         end else begin
//             rx_state <= RX_IDLE; // error recovery
//         end
//     end
//
//     assign pin_states_out = fast_pin_write_valid ? fast_pin_data : pin_states_out; // latch
//
//     // ===================================================================
//     // TX – 8b/10b encoded responses (normal + fast)
//     // ===================================================================
//     logic [7:0]  tx_raw_byte;
//     logic        tx_k;
//     logic [9:0]  tx_encoded;
//     logic [7:0]  tx_buf [0:31];
//     logic [7:0]  tx_idx;
//     logic        tx_active;
//
//     // 8b/10b encoder stub – replace with real one
//     // https://github.com/mcjtag/v8b10b
//     // Two modules: v8b10b_enc and v8b10b_dec
//     always_comb begin
//         tx_encoded = {tx_raw_byte, tx_k ? 2'b11 : 2'b00}; // dummy
//     end
//
//     always_ff @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             tx_active <= 0;
//             tx_idx    <= 0;
//         end else if ((cmd != 0 || fast_pin_write_valid) && !tx_active) begin
//             // Build response (simplified – add your command cases here)
//             tx_buf[0] = 8'hBC; // K28.5 SOF
//             tx_buf[1] = cmd | 8'h80;
//             tx_buf[2] = 8'h00; // OK
//             tx_buf[3] = 8'h00;
//             tx_buf[4] = 8'h08; // example length
//             // payload from registers_in.status
//             {tx_buf[5],tx_buf[6],tx_buf[7],tx_buf[8]}  = registers_in.status.status;
//             {tx_buf[9],tx_buf[10],tx_buf[11],tx_buf[12]} = registers_in.status.hash;
//             tx_buf[13] = 8'hBC; // EOF
//
//             tx_active <= 1;
//             tx_idx    <= 0;
//         end else if (tx_active) begin
//             tx_idx <= tx_idx + 1;
//             if (tx_idx == 13) tx_active <= 0;
//         end
//     end
//
//     assign lvds_tx_p = tx_active ? tx_encoded[0] : 1'b0; // LSB first
//     assign lvds_tx_n = tx_active ? ~tx_encoded[0] : 1'b1;
//
// endmodule
//