`timescale 1ns / 1ps
`default_nettype none

module module_template (
    input   logic i_clk,
    input   logic i_rst_n,
    input   logic i_in,
    output  logic o_out
    );

    //assign o_out = i_in;
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            o_out <= 0;
        end else begin
            o_out <= i_in;
        end
    end

endmodule

`default_nettype wire
