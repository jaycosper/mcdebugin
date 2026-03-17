## Generated SDC file "LED_Flash.sdc"

## Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions
## and other software and tools, and its AMPP partner logic
## functions, and any output files from any of the foregoing
## (including device programming or simulation files), and any
## associated documentation or information are expressly subject
## to the terms and conditions of the Altera Program License
## Subscription Agreement, the Altera Quartus II License Agreement,
## the Altera MegaCore Function License Agreement, or other
## applicable license agreement, including, without limitation,
## that your use is for the sole purpose of programming logic
## devices manufactured by Altera and sold by Altera or its
## authorized distributors.  Please refer to the applicable
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 14.0.2 Build 209 09/17/2014 SJ Full Version"

## DATE    "Wed Oct 15 09:44:32 2014"

##
## DEVICE  "10M08SAE144C8GES"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {i_clk} -period 20.000 -waveform { 0.000 0.500 } [get_ports {i_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {i_clk}] -rise_to [get_clocks {i_clk}]  0.020
set_clock_uncertainty -rise_from [get_clocks {i_clk}] -fall_to [get_clocks {i_clk}]  0.020
set_clock_uncertainty -fall_from [get_clocks {i_clk}] -rise_to [get_clocks {i_clk}]  0.020
set_clock_uncertainty -fall_from [get_clocks {i_clk}] -fall_to [get_clocks {i_clk}]  0.020


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {i_clk}]  0.000 [get_ports {i_clk}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {i_clk}]  1.000 [get_ports {o_leds[1]}]
set_output_delay -add_delay  -clock [get_clocks {i_clk}]  1.000 [get_ports {o_leds[2]}]
set_output_delay -add_delay  -clock [get_clocks {i_clk}]  1.000 [get_ports {o_leds[3]}]
set_output_delay -add_delay  -clock [get_clocks {i_clk}]  1.000 [get_ports {o_leds[4]}]
set_output_delay -add_delay  -clock [get_clocks {i_clk}]  1.000 [get_ports {o_leds[5]}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************

#set_max_delay -from [get_ports {i_clk}] -to [get_ports {LED1 LED2 LED3 LED4 LED5}] 10.000


#**************************************************************
# Set Minimum Delay
#**************************************************************

#set_min_delay -from [get_ports {i_clk}] -to [get_ports {LED1 LED2 LED3 LED4 LED5}] 0.000


#**************************************************************
# Set Input Transition
#**************************************************************