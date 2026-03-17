// Top-level Verilog module for MAX10 EK-10M08E144 Development Kit
`default_nettype none

module top (
    input  logic       i_clk,     // Clock input
    input  logic       i_resetn,  // reset input
    input  logic [5:1] i_switch,  // switch output
    output logic [5:1] o_leds     // LED output
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
                .i_clk   (i_clk),
                .i_rst   (1'b0),
                .i_rst_n (1'b1),               //resetn), // active-low reset
                .i_din   (i_switch[g_index]),
                .o_dout  (sw_state[g_index]),
                .o_onlow (),
                .o_onhigh()
            );
        end
    endgenerate

    always_ff @(posedge i_clk) begin
        if (sw_state[1]) begin
            // increment counter on each clock cycle
            counter <= counter + 1'b1;
        end else begin
            // decrement counter on each clock cycle
            counter <= counter - 1'b1;
        end
    end

    // use upper bits of counter to drive LEDs, creating a slow counting effect
    assign o_leds = counter[23:19];

endmodule

`default_nettype wire
