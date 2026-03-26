//altlvds_rx BUFFER_IMPLEMENTATION="RAM" CBX_DECLARE_ALL_CONNECTED_PORTS="OFF" CBX_SINGLE_OUTPUT_FILE="ON" COMMON_RX_TX_PLL="OFF" CYCLONEII_M4K_COMPATIBILITY="ON" DATA_ALIGN_ROLLOVER=5 DATA_RATE="150.0 Mbps" DESERIALIZATION_FACTOR=10 DEVICE_FAMILY="MAX 10" DPA_INITIAL_PHASE_VALUE=0 DPLL_LOCK_COUNT=0 DPLL_LOCK_WINDOW=0 ENABLE_DPA_ALIGN_TO_RISING_EDGE_ONLY="OFF" ENABLE_DPA_CALIBRATION="ON" ENABLE_DPA_INITIAL_PHASE_SELECTION="OFF" ENABLE_DPA_MODE="OFF" ENABLE_DPA_PLL_CALIBRATION="OFF" ENABLE_SOFT_CDR_MODE="OFF" IMPLEMENT_IN_LES="ON" INCLOCK_BOOST=0 INCLOCK_DATA_ALIGNMENT="EDGE_ALIGNED" INCLOCK_PERIOD=10000 INCLOCK_PHASE_SHIFT=0 INPUT_DATA_RATE=150 LVDS_RX_REG_SETTING="OFF" NUMBER_OF_CHANNELS=1 OUTCLOCK_RESOURCE="AUTO" PLL_SELF_RESET_ON_LOSS_LOCK="OFF" PORT_RX_CHANNEL_DATA_ALIGN="PORT_UNUSED" PORT_RX_DATA_ALIGN="PORT_USED" REGISTERED_DATA_ALIGN_INPUT="OFF" REGISTERED_OUTPUT="OFF" SIM_DPA_IS_NEGATIVE_PPM_DRIFT="OFF" SIM_DPA_NET_PPM_VARIATION=0 SIM_DPA_OUTPUT_CLOCK_PHASE_SHIFT=0 USE_CORECLOCK_INPUT="OFF" USE_DPLL_RAWPERROR="OFF" USE_EXTERNAL_PLL="ON" USE_NO_PHASE_SHIFT="ON" X_ON_BITSLIP="ON" rx_cda_reset rx_channel_data_align rx_data_align rx_data_align_reset rx_data_reset rx_in rx_inclock rx_locked rx_out CARRY_CHAIN="MANUAL" CARRY_CHAIN_LENGTH=48 LOW_POWER_MODE="AUTO" ALTERA_INTERNAL_OPTIONS=AUTO_SHIFT_REGISTER_RECOGNITION=OFF
//VERSION_BEGIN 25.1 cbx_altaccumulate 2025:10:22:10:31:18:SC cbx_altclkbuf 2025:10:22:10:31:18:SC cbx_altddio_in 2025:10:22:10:31:18:SC cbx_altddio_out 2025:10:22:10:31:18:SC cbx_altera_syncram_nd_impl 2025:10:22:10:31:18:SC cbx_altiobuf_bidir 2025:10:22:10:31:18:SC cbx_altiobuf_in 2025:10:22:10:31:18:SC cbx_altiobuf_out 2025:10:22:10:31:18:SC cbx_altlvds_rx 2025:10:22:10:31:18:SC cbx_altpll 2025:10:22:10:31:18:SC cbx_altsyncram 2025:10:22:10:31:18:SC cbx_arriav 2025:10:22:10:31:18:SC cbx_cyclone 2025:10:22:10:31:18:SC cbx_cycloneii 2025:10:22:10:31:18:SC cbx_lpm_add_sub 2025:10:22:10:31:18:SC cbx_lpm_compare 2025:10:22:10:31:18:SC cbx_lpm_counter 2025:10:22:10:31:18:SC cbx_lpm_decode 2025:10:22:10:31:18:SC cbx_lpm_mux 2025:10:22:10:31:18:SC cbx_lpm_shiftreg 2025:10:22:10:31:18:SC cbx_maxii 2025:10:22:10:31:18:SC cbx_mgl 2025:10:22:10:38:57:SC cbx_nadder 2025:10:22:10:31:18:SC cbx_stratix 2025:10:22:10:31:18:SC cbx_stratixii 2025:10:22:10:31:18:SC cbx_stratixiii 2025:10:22:10:31:18:SC cbx_stratixv 2025:10:22:10:31:18:SC cbx_util_mgl 2025:10:22:10:31:18:SC  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2025  Altera Corporation. All rights reserved.
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and any partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, the Altera Quartus Prime License Agreement,
//  the Altera IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Altera and sold by Altera or its authorized distributors.  Please
//  refer to the Altera Software License Subscription Agreements 
//  on the Quartus Prime software download page.




//alt_lvds_ddio_in ADD_LATENCY_REG="TRUE" CBX_DECLARE_ALL_CONNECTED_PORTS="OFF" CBX_SINGLE_OUTPUT_FILE="ON" LVDS_RX_REG_SETTING="OFF" WIDTH=1 aclr clock datain dataout_h dataout_l
//VERSION_BEGIN 25.1 cbx_altaccumulate 2025:10:22:10:31:18:SC cbx_altclkbuf 2025:10:22:10:31:18:SC cbx_altddio_in 2025:10:22:10:31:18:SC cbx_altddio_out 2025:10:22:10:31:18:SC cbx_altera_syncram_nd_impl 2025:10:22:10:31:18:SC cbx_altiobuf_bidir 2025:10:22:10:31:18:SC cbx_altiobuf_in 2025:10:22:10:31:18:SC cbx_altiobuf_out 2025:10:22:10:31:18:SC cbx_altlvds_rx 2025:10:22:10:31:18:SC cbx_altpll 2025:10:22:10:31:18:SC cbx_altsyncram 2025:10:22:10:31:18:SC cbx_arriav 2025:10:22:10:31:18:SC cbx_cyclone 2025:10:22:10:31:18:SC cbx_cycloneii 2025:10:22:10:31:18:SC cbx_lpm_add_sub 2025:10:22:10:31:18:SC cbx_lpm_compare 2025:10:22:10:31:18:SC cbx_lpm_counter 2025:10:22:10:31:18:SC cbx_lpm_decode 2025:10:22:10:31:18:SC cbx_lpm_mux 2025:10:22:10:31:18:SC cbx_lpm_shiftreg 2025:10:22:10:31:18:SC cbx_maxii 2025:10:22:10:31:18:SC cbx_mgl 2025:10:22:10:38:57:SC cbx_nadder 2025:10:22:10:31:18:SC cbx_stratix 2025:10:22:10:31:18:SC cbx_stratixii 2025:10:22:10:31:18:SC cbx_stratixiii 2025:10:22:10:31:18:SC cbx_stratixv 2025:10:22:10:31:18:SC cbx_util_mgl 2025:10:22:10:31:18:SC  VERSION_END

//synthesis_resources = reg 5 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"{-to ddio_h_reg*} PLL_COMPENSATE=ON;ADV_NETLIST_OPT_ALLOWED=\"NEVER_ALLOW\""} *)
module  altera_soft_lvds_rx_uP1RPNs2_lvds_ddio_in_jng
	( 
	aclr,
	clock,
	datain,
	dataout_h,
	dataout_l) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clock;
	input   [0:0]  datain;
	output   [0:0]  dataout_h;
	output   [0:0]  dataout_l;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	reg	[0:0]	dataout_h_reg;
	reg	[0:0]	dataout_l_latch;
	reg	[0:0]	dataout_l_reg;
	(* ALTERA_ATTRIBUTE = {"LVDS_RX_REGISTER=HIGH;PRESERVE_REGISTER=ON;PRESERVE_FANOUT_FREE_NODE=ON"} *)
	reg	[0:0]	ddio_h_reg;
	(* ALTERA_ATTRIBUTE = {"LVDS_RX_REGISTER=LOW;PRESERVE_REGISTER=ON;PRESERVE_FANOUT_FREE_NODE=ON"} *)
	reg	[0:0]	ddio_l_reg;

	// synopsys translate_off
	initial
		dataout_h_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) dataout_h_reg <= 1'b0;
		else  dataout_h_reg <= ddio_h_reg;
	// synopsys translate_off
	initial
		dataout_l_latch = 0;
	// synopsys translate_on
	always @ ( negedge clock or  posedge aclr)
		if (aclr == 1'b1) dataout_l_latch <= 1'b0;
		else  dataout_l_latch <= ddio_l_reg;
	// synopsys translate_off
	initial
		dataout_l_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) dataout_l_reg <= 1'b0;
		else  dataout_l_reg <= dataout_l_latch;
	// synopsys translate_off
	initial
		ddio_h_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) ddio_h_reg <= 1'b0;
		else  ddio_h_reg <= datain;
	// synopsys translate_off
	initial
		ddio_l_reg = 0;
	// synopsys translate_on
	always @ ( negedge clock or  posedge aclr)
		if (aclr == 1'b1) ddio_l_reg <= 1'b0;
		else  ddio_l_reg <= datain;
	assign
		dataout_h = dataout_l_reg,
		dataout_l = dataout_h_reg;
endmodule //altera_soft_lvds_rx_uP1RPNs2_lvds_ddio_in_jng


//dffpipe CBX_DECLARE_ALL_CONNECTED_PORTS="OFF" CBX_SINGLE_OUTPUT_FILE="ON" DELAY=2 WIDTH=1 clock clrn d q ALTERA_INTERNAL_OPTIONS=AUTO_SHIFT_REGISTER_RECOGNITION=OFF
//VERSION_BEGIN 25.1 cbx_mgl 2025:10:22:10:38:57:SC cbx_stratixii 2025:10:22:10:31:18:SC cbx_util_mgl 2025:10:22:10:31:18:SC  VERSION_END

//synthesis_resources = reg 2 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"AUTO_SHIFT_REGISTER_RECOGNITION=OFF"} *)
module  altera_soft_lvds_rx_uP1RPNs2_dffpipe_tmf
	( 
	clock,
	clrn,
	d,
	q) /* synthesis synthesis_clearbox=1 */;
	input   clock;
	input   clrn;
	input   [0:0]  d;
	output   [0:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   clock;
	tri1   clrn;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	reg	[0:0]	dffe7a;
	reg	[0:0]	dffe8a;
	wire ena;
	wire prn;
	wire sclr;

	// synopsys translate_off
	initial
		dffe7a = 0;
	// synopsys translate_on
	always @ ( posedge clock or  negedge prn or  negedge clrn)
		if (prn == 1'b0) dffe7a <= {1{1'b1}};
		else if (clrn == 1'b0) dffe7a <= 1'b0;
		else if  (ena == 1'b1)   dffe7a <= (d & (~ sclr));
	// synopsys translate_off
	initial
		dffe8a = 0;
	// synopsys translate_on
	always @ ( posedge clock or  negedge prn or  negedge clrn)
		if (prn == 1'b0) dffe8a <= {1{1'b1}};
		else if (clrn == 1'b0) dffe8a <= 1'b0;
		else if  (ena == 1'b1)   dffe8a <= (dffe7a & (~ sclr));
	assign
		ena = 1'b1,
		prn = 1'b1,
		q = dffe8a,
		sclr = 1'b0;
endmodule //altera_soft_lvds_rx_uP1RPNs2_dffpipe_tmf


//lpm_counter CBX_DECLARE_ALL_CONNECTED_PORTS="OFF" CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" lpm_modulus=10 lpm_port_updown="PORT_UNUSED" lpm_width=4 aclr clock cnt_en q
//VERSION_BEGIN 25.1 cbx_cycloneii 2025:10:22:10:31:18:SC cbx_lpm_add_sub 2025:10:22:10:31:18:SC cbx_lpm_compare 2025:10:22:10:31:18:SC cbx_lpm_counter 2025:10:22:10:31:18:SC cbx_lpm_decode 2025:10:22:10:31:18:SC cbx_mgl 2025:10:22:10:38:57:SC cbx_nadder 2025:10:22:10:31:18:SC cbx_stratix 2025:10:22:10:31:18:SC cbx_stratixii 2025:10:22:10:31:18:SC  VERSION_END


//lpm_compare CBX_DECLARE_ALL_CONNECTED_PORTS="OFF" CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" LPM_WIDTH=4 ONE_INPUT_IS_CONSTANT="YES" aeb dataa datab
//VERSION_BEGIN 25.1 cbx_cycloneii 2025:10:22:10:31:18:SC cbx_lpm_add_sub 2025:10:22:10:31:18:SC cbx_lpm_compare 2025:10:22:10:31:18:SC cbx_mgl 2025:10:22:10:38:57:SC cbx_nadder 2025:10:22:10:31:18:SC cbx_stratix 2025:10:22:10:31:18:SC cbx_stratixii 2025:10:22:10:31:18:SC  VERSION_END

//synthesis_resources = 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  altera_soft_lvds_rx_uP1RPNs2_cmpr_rge
	( 
	aeb,
	dataa,
	datab) /* synthesis synthesis_clearbox=1 */;
	output   aeb;
	input   [3:0]  dataa;
	input   [3:0]  datab;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [3:0]  dataa;
	tri0   [3:0]  datab;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]  aeb_result_wire;
	wire  [0:0]  aneb_result_wire;
	wire  [9:0]  data_wire;
	wire  eq_wire;

	assign
		aeb = eq_wire,
		aeb_result_wire = (~ aneb_result_wire),
		aneb_result_wire = (data_wire[0] | data_wire[1]),
		data_wire = {datab[3], dataa[3], datab[2], dataa[2], datab[1], dataa[1], datab[0], dataa[0], ((data_wire[6] ^ data_wire[7]) | (data_wire[8] ^ data_wire[9])), ((data_wire[2] ^ data_wire[3]) | (data_wire[4] ^ data_wire[5]))},
		eq_wire = aeb_result_wire;
endmodule //altera_soft_lvds_rx_uP1RPNs2_cmpr_rge

//synthesis_resources = lut 4 reg 4 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  altera_soft_lvds_rx_uP1RPNs2_cntr_lhg
	( 
	aclr,
	clock,
	cnt_en,
	q) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clock;
	input   cnt_en;
	output   [3:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
	tri1   cnt_en;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_counter_comb_bita_0combout;
	wire  [0:0]   wire_counter_comb_bita_1combout;
	wire  [0:0]   wire_counter_comb_bita_2combout;
	wire  [0:0]   wire_counter_comb_bita_3combout;
	wire  [0:0]   wire_counter_comb_bita_0cout;
	wire  [0:0]   wire_counter_comb_bita_1cout;
	wire  [0:0]   wire_counter_comb_bita_2cout;
	wire  [0:0]   wire_counter_comb_bita_3cout;
	wire	[3:0]	wire_counter_reg_bit_d;
	wire	[3:0]	wire_counter_reg_bit_asdata;
	reg	[3:0]	counter_reg_bit;
	wire	[3:0]	wire_counter_reg_bit_ena;
	wire	[3:0]	wire_counter_reg_bit_sload;
	wire  wire_cmpr9_aeb;
	wire  aclr_actual;
	wire clk_en;
	wire  compare_result;
	wire  cout_actual;
	wire [3:0]  data;
	wire  external_cin;
	wire  [3:0]  modulus_bus;
	wire  modulus_trigger;
	wire  [3:0]  s_val;
	wire  [3:0]  safe_q;
	wire sclr;
	wire sload;
	wire sset;
	wire  time_to_clear;
	wire  updown_dir;

	fiftyfivenm_lcell_comb   counter_comb_bita_0
	( 
	.cin(external_cin),
	.combout(wire_counter_comb_bita_0combout[0:0]),
	.cout(wire_counter_comb_bita_0cout[0:0]),
	.dataa(counter_reg_bit[0]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_0.lut_mask = 16'h5A90,
		counter_comb_bita_0.sum_lutc_input = "cin",
		counter_comb_bita_0.lpm_type = "fiftyfivenm_lcell_comb";
	fiftyfivenm_lcell_comb   counter_comb_bita_1
	( 
	.cin(wire_counter_comb_bita_0cout[0:0]),
	.combout(wire_counter_comb_bita_1combout[0:0]),
	.cout(wire_counter_comb_bita_1cout[0:0]),
	.dataa(counter_reg_bit[1]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_1.lut_mask = 16'h5A90,
		counter_comb_bita_1.sum_lutc_input = "cin",
		counter_comb_bita_1.lpm_type = "fiftyfivenm_lcell_comb";
	fiftyfivenm_lcell_comb   counter_comb_bita_2
	( 
	.cin(wire_counter_comb_bita_1cout[0:0]),
	.combout(wire_counter_comb_bita_2combout[0:0]),
	.cout(wire_counter_comb_bita_2cout[0:0]),
	.dataa(counter_reg_bit[2]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_2.lut_mask = 16'h5A90,
		counter_comb_bita_2.sum_lutc_input = "cin",
		counter_comb_bita_2.lpm_type = "fiftyfivenm_lcell_comb";
	fiftyfivenm_lcell_comb   counter_comb_bita_3
	( 
	.cin(wire_counter_comb_bita_2cout[0:0]),
	.combout(wire_counter_comb_bita_3combout[0:0]),
	.cout(wire_counter_comb_bita_3cout[0:0]),
	.dataa(counter_reg_bit[3]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_3.lut_mask = 16'h5A90,
		counter_comb_bita_3.sum_lutc_input = "cin",
		counter_comb_bita_3.lpm_type = "fiftyfivenm_lcell_comb";
	// synopsys translate_off
	initial
		counter_reg_bit[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[0:0] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[0:0] == 1'b1) 
			if (wire_counter_reg_bit_sload[0:0] == 1'b1) counter_reg_bit[0:0] <= wire_counter_reg_bit_asdata[0:0];
			else  counter_reg_bit[0:0] <= wire_counter_reg_bit_d[0:0];
	// synopsys translate_off
	initial
		counter_reg_bit[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[1:1] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[1:1] == 1'b1) 
			if (wire_counter_reg_bit_sload[1:1] == 1'b1) counter_reg_bit[1:1] <= wire_counter_reg_bit_asdata[1:1];
			else  counter_reg_bit[1:1] <= wire_counter_reg_bit_d[1:1];
	// synopsys translate_off
	initial
		counter_reg_bit[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[2:2] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[2:2] == 1'b1) 
			if (wire_counter_reg_bit_sload[2:2] == 1'b1) counter_reg_bit[2:2] <= wire_counter_reg_bit_asdata[2:2];
			else  counter_reg_bit[2:2] <= wire_counter_reg_bit_d[2:2];
	// synopsys translate_off
	initial
		counter_reg_bit[3:3] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[3:3] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[3:3] == 1'b1) 
			if (wire_counter_reg_bit_sload[3:3] == 1'b1) counter_reg_bit[3:3] <= wire_counter_reg_bit_asdata[3:3];
			else  counter_reg_bit[3:3] <= wire_counter_reg_bit_d[3:3];
	assign
		wire_counter_reg_bit_asdata = ({4{(~ sclr)}} & (({4{sset}} & s_val) | ({4{(~ sset)}} & (({4{sload}} & data) | (({4{(~ sload)}} & modulus_bus) & {4{(~ updown_dir)}}))))),
		wire_counter_reg_bit_d = {wire_counter_comb_bita_3combout[0:0], wire_counter_comb_bita_2combout[0:0], wire_counter_comb_bita_1combout[0:0], wire_counter_comb_bita_0combout[0:0]};
	assign
		wire_counter_reg_bit_ena = {4{(clk_en & (((sclr | sset) | sload) | cnt_en))}},
		wire_counter_reg_bit_sload = {4{(((sclr | sset) | sload) | modulus_trigger)}};
	altera_soft_lvds_rx_uP1RPNs2_cmpr_rge   cmpr9
	( 
	.aeb(wire_cmpr9_aeb),
	.dataa(safe_q),
	.datab(modulus_bus));
	assign
		aclr_actual = aclr,
		clk_en = 1'b1,
		compare_result = wire_cmpr9_aeb,
		cout_actual = (wire_counter_comb_bita_3cout[0:0] | (time_to_clear & updown_dir)),
		data = {4{1'b0}},
		external_cin = 1'b1,
		modulus_bus = 4'b1001,
		modulus_trigger = cout_actual,
		q = safe_q,
		s_val = {4{1'b1}},
		safe_q = counter_reg_bit,
		sclr = 1'b0,
		sload = 1'b0,
		sset = 1'b0,
		time_to_clear = compare_result,
		updown_dir = 1'b1;
endmodule //altera_soft_lvds_rx_uP1RPNs2_cntr_lhg


//lpm_mux CBX_DECLARE_ALL_CONNECTED_PORTS="OFF" CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" LPM_SIZE=10 LPM_WIDTH=1 LPM_WIDTHS=4 data result sel
//VERSION_BEGIN 25.1 cbx_lpm_mux 2025:10:22:10:31:18:SC cbx_mgl 2025:10:22:10:38:57:SC  VERSION_END

//synthesis_resources = lut 7 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  altera_soft_lvds_rx_uP1RPNs2_mux_fod
	( 
	data,
	result,
	sel) /* synthesis synthesis_clearbox=1 */;
	input   [9:0]  data;
	output   [0:0]  result;
	input   [3:0]  sel;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [9:0]  data;
	tri0   [3:0]  sel;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [9:0]  muxlut_data0w;
	wire  muxlut_result0w;
	wire  [3:0]  muxlut_select0w;
	wire  [0:0]  result_node;
	wire  [3:0]  sel_ffs_wire;
	wire  [3:0]  sel_node;
	wire  [3:0]  w186w;
	wire  [1:0]  w188w;
	wire  [3:0]  w211w;
	wire  [1:0]  w213w;
	wire  [1:0]  w234w;
	wire  [0:0]  w236w;
	wire  [1:0]  w247w;
	wire  [2:0]  w_mux_outputs184w;

	assign
		muxlut_data0w = {data[9:0]},
		muxlut_result0w = (((~ w247w[1]) | ((~ w247w[0]) & w_mux_outputs184w[2])) & ((w247w[1] | (w247w[0] & w_mux_outputs184w[1])) | ((~ w247w[0]) & w_mux_outputs184w[0]))),
		muxlut_select0w = sel_node,
		result = result_node,
		result_node = {muxlut_result0w},
		sel_ffs_wire = {sel[3:0]},
		sel_node = {sel_ffs_wire[3:2], sel[1:0]},
		w186w = muxlut_data0w[3:0],
		w188w = muxlut_select0w[1:0],
		w211w = muxlut_data0w[7:4],
		w213w = muxlut_select0w[1:0],
		w234w = muxlut_data0w[9:8],
		w236w = muxlut_select0w[0],
		w247w = muxlut_select0w[3:2],
		w_mux_outputs184w = {((w234w[0] & (~ w236w[0])) | (w234w[1] & w236w[0])), ((((~ w213w[1]) | (w213w[0] & w211w[3])) | ((~ w213w[0]) & w211w[2])) & ((w213w[1] | (w213w[0] & w211w[1])) | ((~ w213w[0]) & w211w[0]))), ((((~ w188w[1]) | (w188w[0] & w186w[3])) | ((~ w188w[0]) & w186w[2])) & ((w188w[1] | (w188w[0] & w186w[1])) | ((~ w188w[0]) & w186w[0])))};
endmodule //altera_soft_lvds_rx_uP1RPNs2_mux_fod

//synthesis_resources = lut 18 reg 37 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"AUTO_SHIFT_REGISTER_RECOGNITION=OFF"} *)
module  altera_soft_lvds_rx_uP1RPNs2
	( 
	rx_cda_reset,
	rx_channel_data_align,
	rx_data_align,
	rx_data_align_reset,
	rx_data_reset,
	rx_in,
	rx_inclock,
	rx_locked,
	rx_out) /* synthesis synthesis_clearbox=1 */;
	input   [0:0]  rx_cda_reset;
	input   [0:0]  rx_channel_data_align;
	input   rx_data_align;
	input   rx_data_align_reset;
	input   rx_data_reset;
	input   [0:0]  rx_in;
	input   rx_inclock;
	output   rx_locked;
	output   [9:0]  rx_out;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [0:0]  rx_cda_reset;
	tri0   [0:0]  rx_channel_data_align;
	tri0   rx_data_align;
	tri0   rx_data_align_reset;
	tri0   rx_data_reset;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_ddio_in_dataout_h;
	wire  [0:0]   wire_ddio_in_dataout_l;
	reg	[3:0]	cda_h_shiftreg3a;
	reg	[4:0]	cda_l_shiftreg4a;
	reg	[4:0]	h_shiftreg2a;
	reg	int_bitslip_reg;
	reg	int_da_reset_reg0;
	reg	int_da_reset_reg1;
	reg	int_sync_reg0;
	reg	int_sync_reg1;
	reg	[4:0]	l_shiftreg1a;
	wire  [0:0]   wire_h_dffpipe_q;
	wire  [0:0]   wire_l_dffpipe_q;
	wire  [3:0]   wire_bitslip_cntr_q;
	wire  [0:0]   wire_h_mux5a_result;
	wire  [0:0]   wire_l_mux6a_result;
	wire  bitslip;
	wire  [3:0]  bitslip_en;
	wire  [0:0]  ddio_dataout_h;
	wire  [0:0]  ddio_dataout_h_int;
	wire  [0:0]  ddio_dataout_l;
	wire  [0:0]  ddio_dataout_l_int;
	wire  fast_clock;
	wire  int_bitslip;
	wire  [9:0]  rx_out_wire;
	wire  w_reset;

	altera_soft_lvds_rx_uP1RPNs2_lvds_ddio_in_jng   ddio_in
	( 
	.aclr(w_reset),
	.clock(fast_clock),
	.datain(rx_in),
	.dataout_h(wire_ddio_in_dataout_h),
	.dataout_l(wire_ddio_in_dataout_l));
	// synopsys translate_off
	initial
		cda_h_shiftreg3a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) cda_h_shiftreg3a <= 4'b0;
		else  cda_h_shiftreg3a <= {cda_h_shiftreg3a[2:0], ddio_dataout_h[0]};
	// synopsys translate_off
	initial
		cda_l_shiftreg4a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) cda_l_shiftreg4a <= 5'b0;
		else  cda_l_shiftreg4a <= {cda_l_shiftreg4a[3:0], ddio_dataout_l[0]};
	// synopsys translate_off
	initial
		h_shiftreg2a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) h_shiftreg2a <= 5'b0;
		else  h_shiftreg2a <= {h_shiftreg2a[3:0], wire_l_mux6a_result};
	// synopsys translate_off
	initial
		int_bitslip_reg = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		  int_bitslip_reg <= int_bitslip;
	// synopsys translate_off
	initial
		int_da_reset_reg0 = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		  int_da_reset_reg0 <= rx_data_align_reset;
	// synopsys translate_off
	initial
		int_da_reset_reg1 = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		  int_da_reset_reg1 <= int_da_reset_reg0;
	// synopsys translate_off
	initial
		int_sync_reg0 = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		  int_sync_reg0 <= rx_data_align;
	// synopsys translate_off
	initial
		int_sync_reg1 = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		  int_sync_reg1 <= int_sync_reg0;
	// synopsys translate_off
	initial
		l_shiftreg1a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) l_shiftreg1a <= 5'b0;
		else  l_shiftreg1a <= {l_shiftreg1a[3:0], wire_h_mux5a_result};
	altera_soft_lvds_rx_uP1RPNs2_dffpipe_tmf   h_dffpipe
	( 
	.clock(fast_clock),
	.clrn((~ w_reset)),
	.d(ddio_dataout_h_int),
	.q(wire_h_dffpipe_q));
	altera_soft_lvds_rx_uP1RPNs2_dffpipe_tmf   l_dffpipe
	( 
	.clock(fast_clock),
	.clrn((~ w_reset)),
	.d(ddio_dataout_l_int),
	.q(wire_l_dffpipe_q));
	altera_soft_lvds_rx_uP1RPNs2_cntr_lhg   bitslip_cntr
	( 
	.aclr(int_da_reset_reg1),
	.clock(fast_clock),
	.cnt_en(bitslip),
	.q(wire_bitslip_cntr_q));
	altera_soft_lvds_rx_uP1RPNs2_mux_fod   h_mux5a
	( 
	.data({cda_l_shiftreg4a[4], cda_h_shiftreg3a[3], cda_l_shiftreg4a[3], cda_h_shiftreg3a[2], cda_l_shiftreg4a[2], cda_h_shiftreg3a[1], cda_l_shiftreg4a[1], cda_h_shiftreg3a[0], cda_l_shiftreg4a[0], ddio_dataout_h[0]}),
	.result(wire_h_mux5a_result),
	.sel(bitslip_en));
	altera_soft_lvds_rx_uP1RPNs2_mux_fod   l_mux6a
	( 
	.data({cda_h_shiftreg3a[3], cda_l_shiftreg4a[3], cda_h_shiftreg3a[2], cda_l_shiftreg4a[2], cda_h_shiftreg3a[1], cda_l_shiftreg4a[1], cda_h_shiftreg3a[0], cda_l_shiftreg4a[0], ddio_dataout_h[0], ddio_dataout_l[0]}),
	.result(wire_l_mux6a_result),
	.sel(bitslip_en));
	assign
		bitslip = ((~ int_bitslip_reg) & int_bitslip),
		bitslip_en = wire_bitslip_cntr_q,
		ddio_dataout_h = wire_h_dffpipe_q,
		ddio_dataout_h_int = wire_ddio_in_dataout_h,
		ddio_dataout_l = wire_l_dffpipe_q,
		ddio_dataout_l_int = wire_ddio_in_dataout_l,
		fast_clock = rx_inclock,
		int_bitslip = int_sync_reg1,
		rx_out = rx_out_wire,
		rx_out_wire = {l_shiftreg1a[4], h_shiftreg2a[4], l_shiftreg1a[3], h_shiftreg2a[3], l_shiftreg1a[2], h_shiftreg2a[2], l_shiftreg1a[1], h_shiftreg2a[1], l_shiftreg1a[0], h_shiftreg2a[0]},
		w_reset = rx_data_reset;
endmodule //altera_soft_lvds_rx_uP1RPNs2
//VALID FILE
