// Top-level Verilog module for MAX10 EK-10M08E144 Development Kit
`default_nettype none

module top (
    input  logic       i_clk,       // Clock input
    input  logic       i_resetn,    // reset input

    output logic       o_lvds_clk,  // LVDS clock output
    input  logic       i_lvds_rx,   // LVDS receive input
    output logic       o_lvds_tx,   // LVDS transmit input

    input  logic [5:1] i_switch,    // switch output
    output logic [5:1] o_leds       // LED output
);

    logic sys_clk, sys_rst_n;
    logic lvds_clk_fast, lvds_clk_slow;
    main_pll u_clk (
        .areset(!i_resetn),
        .inclk0(i_clk),
        .c0(sys_clk),
        .c1(lvds_clk_fast),
        .c2(lvds_clk_slow),
        .locked(sys_rst_n)
    );

    logic [ 5:1] sw_state = 'h0;
    logic [23:0] counter = 0;  // 24-bit counter;

    // Instantiate the debounce module
    generate
        genvar g_index;
        for (g_index = 1; g_index <= 5; g_index++) begin : g_debounce_regs
            debounce #(
                .SYNC_STAGES  (3),
                .CLK_CYCLES_L2(8)
            ) u_sw_debounce (
                .i_clk   (sys_clk),
                .i_rst   (1'b0),
                .i_rst_n (sys_rst_n),
                .i_din   (i_switch[g_index]),
                .o_dout  (sw_state[g_index]),
                .o_onlow (),
                .o_onhigh()
            );
        end
    endgenerate

    always_ff @(posedge sys_clk) begin
        if (sw_state[1]) begin
            // increment counter on each clock cycle
            counter <= counter + 1'b1;
        end else begin
            // decrement counter on each clock cycle
            counter <= counter - 1'b1;
        end
    end

    // use upper bits of counter to drive LEDs, creating a slow counting effect
    assign o_leds = (sw_state[2]) ? counter[23:19] : rcvd_data[9:5]; // switch between counter and received data for LEDs

    logic lvds_clk;
    logic [9:0] gen_data, rcvd_data;

    always_ff @(posedge lvds_clk_fast) begin
        if (!sys_rst_n) begin
            gen_data <= 'h0; // Reset the data to be transmitted
        end else begin
            if (sw_state[3]) begin
                gen_data <= 10'h2A5;
            end else begin
                gen_data <= gen_data + 1'b1; // Increment the data to be transmitted
            end
        end
    end

    assign o_lvds_clk = lvds_clk_fast;
    softlvds_tx u_tx (
        .tx_inclock(lvds_clk_fast),
        .tx_syncclock(lvds_clk_slow),
        .tx_in (gen_data),
        .tx_out(o_lvds_tx)
    );

    softlvds_rx u_rx(
        .rx_inclock(lvds_clk_fast),
        .rx_in(i_lvds_rx),
        .rx_out (rcvd_data)
    );

endmodule

`default_nettype wire
