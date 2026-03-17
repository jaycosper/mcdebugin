`default_nettype none
`timescale 1ns/1ps

import system_registers_pkg::*;

// ===================================================================
// LVDS protocol – forwarded clock, full header decode + CRC check
// ===================================================================
module protocol_lvds #(
    parameter int CLK_FREQ_MHZ = 100
) (
    input  wire                         clk,          // 100 MHz
    input  wire                         rst_n,

    // LVDS pins
    output wire                         lvds_clk_p,
    output wire                         lvds_clk_n,
    output wire                         lvds_tx_p,
    output wire                         lvds_tx_n,
    input  wire                         lvds_rx_p,
    input  wire                         lvds_rx_n,

    // All system registers (agnostic to emulation target)
    input  system_registers_pkg::general_registers_t  registers_in
);

    // ------------------------------------------------------------------
    // Forwarded clock (100 MHz differential)
    // ------------------------------------------------------------------
    logic clk_out;
    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n) clk_out <= 1'b0;
        else        clk_out <= ~clk_out;

    assign lvds_clk_p =  clk_out;
    assign lvds_clk_n = ~clk_out;

    // ------------------------------------------------------------------
    // RX FSM + packet parser
    // States: IDLE → SOF → TYPE → RESP_STATE → LEN_MSB → LEN_LSB → PAYLOAD → CRC → EOF
    // ------------------------------------------------------------------
    typedef enum logic [3:0] {
        RX_IDLE,
        RX_SOF,
        RX_TYPE,
        RX_RESP_STATE,
        RX_LEN_MSB,
        RX_LEN_LSB,
        RX_PAYLOAD,
        RX_CRC,
        RX_EOF,
        RX_ERROR
    } rx_state_t;

    rx_state_t rx_state, rx_next;

    logic [7:0]  rx_byte;           // current assembled byte
    logic [2:0]  rx_bit_cnt;        // bit counter within byte
    logic [15:0] rx_shift;          // sliding window for SOF detection

    logic [7:0]  rx_type;
    logic [7:0]  rx_resp_state;     // from header (ignored for commands)
    logic [15:0] rx_length;         // big-endian
    logic [7:0]  rx_payload [0:MAX_PAYLOAD_BYTES-1];
    logic [$clog2(MAX_PAYLOAD_BYTES)-1:0] rx_payload_idx;
    logic [31:0] rx_crc_received;
    logic [31:0] rx_crc_calc;

    logic rx_valid_packet;
    logic rx_bad_crc;
    logic rx_bad_length;
    logic rx_unknown_cmd;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_state       <= RX_IDLE;
            rx_bit_cnt     <= 3'd0;
            rx_shift       <= 16'h0000;
            rx_byte        <= 8'h00;
            rx_type        <= 8'h00;
            rx_resp_state  <= 8'h00;
            rx_length      <= 16'h0000;
            rx_payload_idx <= 'h0;
            rx_crc_received<= 32'h00000000;
            rx_crc_calc    <= 32'hFFFFFFFF;
            rx_valid_packet<= 1'b0;
            rx_bad_crc     <= 1'b0;
            rx_bad_length  <= 1'b0;
            rx_unknown_cmd <= 1'b0;
        end else begin
            rx_shift <= {rx_shift[14:0], lvds_rx_p};

            // Bit counter & byte assembly
            rx_bit_cnt <= rx_bit_cnt + 1'd1;
            if (rx_bit_cnt == 3'd7) begin
                rx_byte <= {rx_shift[6:0], lvds_rx_p};
                rx_bit_cnt <= 3'd0;
            end

            // FSM
            rx_state <= rx_next;

            case (rx_state)
                RX_IDLE: begin
                    if (rx_shift[15:8] == 8'hBC) begin
                        rx_valid_packet <= 1'b0;
                        rx_bad_crc      <= 1'b0;
                        rx_bad_length   <= 1'b0;
                        rx_unknown_cmd  <= 1'b0;
                        rx_payload_idx  <= 'h0;
                        rx_crc_calc     <= 32'hFFFFFFFF;
                    end
                end

                RX_TYPE: begin
                    rx_type <= rx_byte;
                    // Start CRC with Type byte
                    rx_crc_calc <= rx_crc_calc ^ {24'h0, rx_byte};
                    for (int j=0; j<8; j++) rx_crc_calc <= rx_crc_calc[0] ? (rx_crc_calc >> 1) ^ CRC_POLY : (rx_crc_calc >> 1);
                end

                RX_RESP_STATE: begin
                    rx_resp_state <= rx_byte;
                    rx_crc_calc   <= rx_crc_calc ^ {24'h0, rx_byte};
                    for (int j=0; j<8; j++) rx_crc_calc <= rx_crc_calc[0] ? (rx_crc_calc >> 1) ^ CRC_POLY : (rx_crc_calc >> 1);
                end

                RX_LEN_MSB: begin
                    rx_length[15:8] <= rx_byte;
                    rx_crc_calc     <= rx_crc_calc ^ {24'h0, rx_byte};
                    for (int j=0; j<8; j++) rx_crc_calc <= rx_crc_calc[0] ? (rx_crc_calc >> 1) ^ CRC_POLY : (rx_crc_calc >> 1);
                end

                RX_LEN_LSB: begin
                    rx_length[7:0] <= rx_byte;
                    rx_crc_calc    <= rx_crc_calc ^ {24'h0, rx_byte};
                    for (int j=0; j<8; j++) rx_crc_calc <= rx_crc_calc[0] ? (rx_crc_calc >> 1) ^ CRC_POLY : (rx_crc_calc >> 1);

                    if ({rx_length[15:8], rx_byte} > 16'(MAX_PAYLOAD_BYTES))
                        rx_bad_length <= 1'b1;
                end

                RX_PAYLOAD: begin
                    if (rx_payload_idx < rx_length[$bits(rx_payload_idx)-1:0]) begin
                        rx_payload[rx_payload_idx] <= rx_byte;
                        rx_crc_calc <= rx_crc_calc ^ {24'h0, rx_byte};
                        for (int j=0; j<8; j++) rx_crc_calc <= rx_crc_calc[0] ? (rx_crc_calc >> 1) ^ CRC_POLY : (rx_crc_calc >> 1);
                        rx_payload_idx <= rx_payload_idx + 1'd1;
                    end
                end

                RX_CRC: begin
                    // Collect 4-byte CRC (MSB first)
                    case (rx_payload_idx)
                        0: rx_crc_received[31:24] <= rx_byte;
                        1: rx_crc_received[23:16] <= rx_byte;
                        2: rx_crc_received[15:8]  <= rx_byte;
                        3: begin
                            rx_crc_received[7:0] <= rx_byte;
                            rx_bad_crc <= (rx_crc_received != ~rx_crc_calc);
                        end
                    endcase
                    rx_payload_idx <= rx_payload_idx + 1'd1;
                end

                RX_EOF: begin
                    if (rx_byte == 8'hBC && !rx_bad_length && !rx_bad_crc) begin
                        rx_valid_packet <= 1'b1;
                        rx_unknown_cmd  <= (rx_type != 8'h01);  // only STATUS supported now
                    end
                end

                default: rx_state <= RX_IDLE;
            endcase
        end
    end

    // Next-state logic (simplified – full FSM in production would use case)
    always_comb begin
        rx_next = rx_state;
        case (rx_state)
            RX_IDLE:     if (rx_shift[15:8] == 8'hBC) rx_next = RX_TYPE;
            RX_TYPE:     rx_next = RX_RESP_STATE;
            RX_RESP_STATE: rx_next = RX_LEN_MSB;
            RX_LEN_MSB:  rx_next = RX_LEN_LSB;
            RX_LEN_LSB:  rx_next = (rx_length == 0) ? RX_CRC : RX_PAYLOAD;
            RX_PAYLOAD:  if (rx_payload_idx == rx_length[$bits(rx_payload_idx)-1:0]) rx_next = RX_CRC;
            RX_CRC:      if (rx_payload_idx == 3) rx_next = RX_EOF;
            RX_EOF:      rx_next = RX_IDLE;
            default:     rx_next = RX_IDLE;
        endcase
    end

    // ------------------------------------------------------------------
    // TX – response generation (STATUS only for now)
    // ------------------------------------------------------------------
    localparam int STATUS_PAYLOAD_BYTES = $bits(system_status_t) / 8;  // 8

    logic [7:0]  tx_buf [0:17];   // enough for current STATUS
    logic [7:0]  tx_idx;
    logic        tx_active;
    logic [7:0]  tx_resp_state;

    always_comb begin
        tx_resp_state = 8'h00;  // OK
        if (rx_bad_crc)     tx_resp_state = 8'h02;  // CRC error
        else if (rx_bad_length) tx_resp_state = 8'h03;  // invalid length
        else if (rx_unknown_cmd) tx_resp_state = 8'h01; // unknown command
    end

    automatic logic [31:0] crc;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_active <= 1'b0;
            tx_idx    <= 8'd0;
        end else if (rx_valid_packet && !tx_active) begin
            tx_buf[0] = 8'hBC;                          // SOF
            tx_buf[1] = rx_type | 8'h80;                // Response type = cmd + 0x80
            tx_buf[2] = tx_resp_state;                  // OK / error code
            tx_buf[3] = 8'h00;                          // Len MSB

            if (tx_resp_state == 8'h00 && rx_type == 8'h01) begin
                tx_buf[4] = 8'(STATUS_PAYLOAD_BYTES);   // Len LSB = 8 for STATUS

                // Payload = registers_in.status
                {tx_buf[5], tx_buf[6], tx_buf[7], tx_buf[8]}  = registers_in.status.status;
                {tx_buf[9], tx_buf[10], tx_buf[11], tx_buf[12]} = registers_in.status.hash;
            end else begin
                tx_buf[4] = 8'h00;                      // error response = 0-byte payload
            end

            // CRC over Type + RespState + Len + Payload
            crc = 32'hFFFFFFFF;
            for (int i=1; i<= (1+1+2 + 32'(tx_buf[4])); i++) begin
                crc ^= {24'h0, tx_buf[i]};
                for (int j=0; j<8; j++)
                    crc = crc[0] ? (crc >> 1) ^ CRC_POLY : (crc >> 1);
            end
            crc = ~crc;

            tx_buf[13] = crc[31:24];
            tx_buf[14] = crc[23:16];
            tx_buf[15] = crc[15:8];
            tx_buf[16] = crc[7:0];
            tx_buf[17] = 8'hBC;                         // EOF

            tx_active <= 1'b1;
            tx_idx    <= 8'd0;
        end else if (tx_active) begin
            tx_idx <= tx_idx + 1'd1;
            if (tx_idx == 8'd17) tx_active <= 1'b0;
        end
    end

    // Serializer
    logic tx_bit;
    assign tx_bit = tx_buf[tx_idx[7:3]][~tx_idx[2:0]];

    assign lvds_tx_p = tx_active ? tx_bit : 1'b0;
    assign lvds_tx_n = tx_active ? ~tx_bit : 1'b1;

endmodule
