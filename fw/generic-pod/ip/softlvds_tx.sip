set_global_assignment -entity "softlvds_tx" -library "lib_softlvds_tx" -name IP_TOOL_NAME "altera_soft_lvds"
set_global_assignment -entity "softlvds_tx" -library "lib_softlvds_tx" -name IP_TOOL_VERSION "25.1"
set_global_assignment -entity "softlvds_tx" -library "lib_softlvds_tx" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_softlvds_tx" -name SPD_FILE [file join $::quartus(sip_path) "softlvds_tx.spd"]

set_global_assignment -library "lib_softlvds_tx" -name MISC_FILE [file join $::quartus(sip_path) "softlvds_tx_sim/softlvds_tx.v"]
set_global_assignment -library "lib_softlvds_tx" -name MISC_FILE [file join $::quartus(sip_path) "softlvds_tx_sim/altera_soft_lvds/altera_soft_lvds_tx_uS1HUqyJ.v"]
