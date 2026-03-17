`timescale 1ns/1ps
`default_nettype none

module tb;

    // Clock and reset
    logic clk   = 0;
    logic rst_n = 0;

    // LVDS signals
    wire lvds_clk_p, lvds_clk_n;
    wire lvds_tx_p,  lvds_tx_n;
    reg  lvds_rx_p = 1'b1;   // idle high
    reg  lvds_rx_n = 1'b0;

    // Generic registers input
    system_registers_pkg::general_registers_t regs_in = '0;

    // DUT instantiation
    protocol_lvds #(
        .CLK_FREQ_MHZ(100)
    ) dut (
        .clk,
        .rst_n,
        .lvds_clk_p,
        .lvds_clk_n,
        .lvds_tx_p,
        .lvds_tx_n,
        .lvds_rx_p,
        .lvds_rx_n,
        .registers_in(regs_in)
    );

    // 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    // Stimulus & control
    initial begin
        $dumpfile("lvds_tb.vcd");
        $dumpvars(0, tb);

        // Reset sequence
        repeat (5) @(posedge clk);
        rst_n = 1;

        // Give some idle time
        repeat (20) @(posedge clk);

        // Set some example register values (you can change these)
        regs_in.status.status = 32'hA5A5_A5A5;
        regs_in.status.hash   = 32'h1234_567F;   // low nibble 0xF = dirty repo

        $display("Time %t: Sending STATUS command (0xBC 0x01)", $time);

        // Send SOF + command byte (simple serial injection)
        send_byte(8'hBC);   // SOF
        send_byte(8'h01);   // STATUS command

        // Wait long enough for the response to be sent (~180 cycles for 18-byte packet)
        repeat (300) @(posedge clk);

        $display("Time %t: Test finished – check lvds_tb.vcd in GTKWave", $time);
        $finish;
    end

    // Task to send one byte serially (100 Mb/s = 10 ns per bit)
    task automatic send_byte(input [7:0] b);
        for (int i = 7; i >= 0; i--) begin
            lvds_rx_p =  b[i];
            lvds_rx_n = ~b[i];
            #10;   // one bit time at 100 Mb/s
        end
    endtask

    // Optional: monitor TX activity
    always @(posedge clk) begin
        if (dut.tx_active) begin
            $display("Time %t: TX active, bit %0d = %b (idx=%0d)",
                     $time, dut.tx_bit, dut.tx_bit, dut.tx_idx);
        end
    end

endmodule
