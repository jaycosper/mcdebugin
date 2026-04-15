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
    logic lvds_clk_slow;
    main_pll u_clk (
        .areset(!i_resetn),
        .inclk0(i_clk),
        .c0(sys_clk),       // 125MHz
        .c1(lvds_clk_slow), // 25MHz for LVDS
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

    protocol_pkg::rxtx_data_t gen_data;
    protocol_pkg::rxtx_data_t rcvd_data;
    logic link_locked;

    always_ff @(posedge sys_clk) begin
        if (sw_state[1]) begin
            // increment counter on each clock cycle
            counter <= counter + 1'b1;
        end else begin
            // decrement counter on each clock cycle
            counter <= counter - 1'b1;
        end
    end

    // Active low LEDs
    localparam logic LED_ON = 1'b0;
    localparam logic LED_OFF = 1'b1;
    // use upper bits of counter to drive LEDs, creating a slow counting effect
    assign o_leds[4:1] = (sw_state[2]) ? counter[23:20] : rcvd_data.data[7:4]; // switch between counter and received data for LEDs
    assign o_leds[5] = (link_locked) ? LED_ON : LED_OFF; // LED 5 indicates link lock status

    // Received command from host
    logic cmd_valid;
    cmd_rsp_t cmd;
    logic cmd_complete = 1'b0;
    // Generated response to host
    logic rsp_ready = 1'b0;
    cmd_rsp_t rsp = '{default:0};
    logic rsp_sent;

    typedef enum logic[1:0] {stIDLE, stCMD, stRSP, stRSPSENT} test_sm_t;
    test_sm_t cstate;
    // Testing loopback
    always_ff @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            cstate <= stIDLE;
            cmd_complete <= 1'b0;
            rsp_ready <= 1'b0;
            rsp <= '{default:0};
        end else begin
            cmd_complete <= 1'b0; // default to not complete, will be set to 1 when a command is processed
            rsp_ready <= 1'b0;
            case(cstate)
                stIDLE: begin
                    if (cmd_valid) begin
                        cstate <= stCMD;
                    end
                end
                stCMD: begin
                    rsp <= cmd; // Loopback: echo the command as the response
                    cstate <= stRSP;
                end
                stRSP: begin
                    rsp_ready <= 1'b1; // Indicate that response is ready to be sent
                    cstate <= stRSPSENT;
                end
                stRSPSENT: begin
                    if (rsp_sent) begin
                        cstate <= stIDLE;
                    end
                end
            endcase
        end
    end

    pod_protocol u_pod_protocol (
        .i_clk          (sys_clk),
        .i_frame_clk    (lvds_clk_slow),
        .i_rst_n        (sys_rst_n),
        // physical interface
        .o_lvds_clk     (o_lvds_clk),
        .i_lvds_rx      (i_lvds_rx),
        .o_lvds_tx      (o_lvds_tx),
        // system interfaces - command
        .o_cmd_valid    (cmd_valid),
        .o_cmd          (cmd),
        .i_cmd_complete (cmd_complete),
        // system interfaces - response
        .i_rsp_ready    (rsp_ready),
        .i_rsp          (rsp),
        .o_rsp_sent     (rsp_sent), // not sure if this is necessary
        // misc
        .o_link_locked  (link_locked)
    );
endmodule

`default_nettype wire
