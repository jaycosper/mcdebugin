set_global_assignment -entity "softlvds_rx" -library "lib_softlvds_rx" -name IP_TOOL_NAME "altera_soft_lvds"
set_global_assignment -entity "softlvds_rx" -library "lib_softlvds_rx" -name IP_TOOL_VERSION "25.1"
set_global_assignment -entity "softlvds_rx" -library "lib_softlvds_rx" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_softlvds_rx" -name SPD_FILE [file join $::quartus(sip_path) "softlvds_rx.spd"]

set_global_assignment -library "lib_softlvds_rx" -name MISC_FILE [file join $::quartus(sip_path) "softlvds_rx_sim/softlvds_rx.v"]
set_global_assignment -library "lib_softlvds_rx" -name MISC_FILE [file join $::quartus(sip_path) "softlvds_rx_sim/altera_soft_lvds/altera_soft_lvds_rx_uP1RPNs2.v"]
