`default_nettype none

module debounce #(
    parameter int SYNC_STAGES   = 2,
    parameter int CLK_CYCLES_L2 = 10
) (
    input  logic i_clk,    // clock
    input  logic i_rst,    // active-high reset
    input  logic i_rst_n,  // active-low reset
    input  logic i_din,    // signal input
    output logic o_dout,   // debounced signal output
    output logic o_onlow,  // falling-edge pulse
    output logic o_onhigh  // rising-edge pulse
);

    // global reset
    logic reset;
    assign reset = i_rst || ~i_rst_n;

    // sync with clock and combat metastability
    logic [SYNC_STAGES-1:0] pipe;
    always_ff @(posedge i_clk or posedge reset) begin : pipe_gen
        if (reset) begin
            pipe <= 0;
        end else begin
            // prime pipe
            pipe <= {pipe[SYNC_STAGES-2:0], i_din};
        end
    end

    logic [CLK_CYCLES_L2-1:0] cntr;  // 2^CLK_CYCLES_L2 * 1/Fi_clk = debounce time
    logic idle_signal, cntr_tc;
    always_comb begin
        idle_signal = (o_dout == pipe[SYNC_STAGES-1]);  // no change in input
        cntr_tc     = &cntr;  // terminal count
    end

    // counter
    always_ff @(posedge i_clk or posedge reset) begin : cntr_flop
        if (reset) begin
            cntr <= 0;
        end else if (idle_signal) begin
            cntr <= 0;
        end else begin
            cntr <= cntr + 1;
        end
    end
    // onlow/onhigh event pulses
    always_ff @(posedge i_clk) begin : event_flop
        o_onlow  <= 1'b0;
        o_onhigh <= 1'b0;
        if (cntr_tc) begin
            o_dout   <= ~o_dout;  // why not &pipe? or pipe[SYNC_STAGES-1]?
            o_onlow  <= o_dout;
            o_onhigh <= ~o_dout;
        end
    end

endmodule

`default_nettype wire
