module tb;
    logic clk = 0, rst_n = 0;
    wire lvds_clk_p, lvds_clk_n, lvds_tx_p, lvds_tx_n;
    logic lvds_rx_p = 1, lvds_rx_n = 0;

    system_registers_pkg::general_registers_t regs_in = '0;
    logic [35:0] pin_in = 36'hABC_DEF012345;
    logic [35:0] pin_out;

    max10_lvds_protocol dut (.*);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("protocol_tb.vcd"); $dumpvars(0, tb);
        rst_n = 0; repeat(20) @(posedge clk); rst_n = 1;

        regs_in.status.status = 32'hDEADBEEF;
        regs_in.status.hash   = 32'h1234567F; // dirty

        // Test 1: STATUS (0x01)
        send_normal(8'h01, 0);

        // Test 2: Set Mode (0x02)
        send_normal(8'h02, 0);

        // Test 3: Read Memory (0x03)
        send_normal(8'h03, 0);

        // Test 4: Write Memory (0x04) with dummy payload
        send_normal(8'h04, 4); // example 4-byte payload

        // Test 5: Reset (0x05)
        send_normal(8'h05, 0);

        // Test 6: Fast pin write
        send_fast_pin(36'hFEDCBA9876543210);

        repeat(500) @(posedge clk);
        $display("All tests sent – check waveform!");
        $finish;
    end

    task send_normal(logic [7:0] cmd_val, logic [7:0] payload_len);
        send_byte(8'hBC); // SOF
        send_byte(cmd_val);
        send_byte(8'h00); // Resp state
        send_byte(8'h00); // Len MSB
        send_byte(payload_len); // Len LSB
        repeat(payload_len) send_byte($random[7:0]); // dummy payload
        send_byte(8'h00); send_byte(8'h00); send_byte(8'h00); send_byte(8'h00); // dummy CRC
        send_byte(8'hBC); // EOF
    endtask

    task send_fast_pin(logic [35:0] pins);
        send_byte(8'hFE); // fast SOF
        send_byte(8'h01); // fast write
        for (int i=4; i>=0; i--) send_byte(pins[i*8 +:8]);
        send_byte(8'hBC); // EOF
    endtask

    task send_byte(logic [7:0] b);
        for (int i=7; i>=0; i--) begin
            lvds_rx_p = b[i]; lvds_rx_n = ~b[i];
            #10;
        end
    endtask
endmodule
