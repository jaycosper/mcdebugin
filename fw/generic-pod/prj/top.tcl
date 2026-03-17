# Quartus: Generate Tcl File for Project
# File: top.tcl

# Load Quartus Tcl Project package
package require ::quartus::project

# process arguments passed to the script
proc get_opt {optname default} {
    global argv
    set idx [lsearch -exact $argv $optname]
    if {$idx >= 0 && $idx+1 < [llength $argv]} {
        return [lindex $argv [expr {$idx+1}]]
    }
    return $default
}

# Then use it:
set proj_name [get_opt "--project" "dut"]
set file_list [get_opt "--files" "a.f"]

set need_to_close_project 0
set make_assignments 1

set SYNTHESIS 1

set rev_name $proj_name
set proj_files [list $proj_name.qpf $proj_name.qsf]
set proj_dirs [list db incremental_db]

# Check that no project is open
if {[is_project_open]} {
    project_close
}

# Remove project files so we can rebuild them
foreach i $proj_files {
    if {[file exists $i]} {
        if { [catch {file delete $i} fid] } {
            post_message -type error $fid
            exit 1
        }
    }
}

# Remove project database folders
foreach i $proj_dirs {
    if {[file isdirectory $i]} {
        if { [catch {file delete -force $i} fid] } {
            post_message -type error $fid
            exit 1
        }
    }
}

# Check that the right project is open
if {[is_project_open]} {
    project_close
    if {[string compare $quartus(project) $proj_name]} {
        puts "Target project is not open"
        set make_assignments 0
    }
} else {
    # Only open if not already open
    if {[project_exists $proj_name]} {
        project_open -revision $rev_name $proj_name
    } else {
        project_new -revision $rev_name $proj_name
    }
    set need_to_close_project 0
}

# Make assignments
if {$make_assignments} {
########### PRE Flow TCL Scripts #################################################
    #set_global_assignment -name PRE_FLOW_SCRIPT_FILE quartus_sh:pre-flow-script.tcl
########### Synthesis Options #################################################
    set_global_assignment -name FAMILY "MAX 10"
    set_global_assignment -name DEVICE 10M08SAE144C8GES
    set_global_assignment -name TOP_LEVEL_ENTITY $proj_name
    set_global_assignment -name ORIGINAL_QUARTUS_VERSION 14.1.0
    set_global_assignment -name PROJECT_CREATION_TIME_DATE "15:53:13  FEBRUARY 03, 2015"
    set_global_assignment -name LAST_QUARTUS_VERSION "25.1std.0 Lite Edition"
    set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
    set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
    set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
    set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 2
    set_global_assignment -name EDA_SIMULATION_TOOL "Questa Altera FPGA (Verilog)"
    set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
    set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id $proj_name
    set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id $proj_name
    set_global_assignment -name PARTITION_COLOR 16764057 -section_id $proj_name

    set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED"
    set_global_assignment -name SMART_RECOMPILE ON
    set_global_assignment -name PARALLEL_SYNTHESIS ON
    set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
    set_global_assignment -name SEARCH_PATH ../inc
    set_global_assignment -name SDC_FILE ../prj/${proj_name}.sdc

    if {$SYNTHESIS} {
       set_global_assignment -name VERILOG_MACRO "SYNTHESIS=true"
    }

    # Source Files
    # TODO: find a way to define files in a different file that can be shared between this file and linter
    # Add RTL files from filelist.f
    set fp [open $file_list r]
    while {[gets $fp line] >= 0} {
        if {[string match "*.v" $line]} {
            set_global_assignment -name VERILOG_FILE $line
        } else {
            set_global_assignment -name SYSTEMVERILOG_FILE $line
        }
    }
    close $fp
    #set_global_assignment -name SYSTEMVERILOG_FILE  ../src/top.sv
    #set_global_assignment -name QIP_FILE            <module-name>.qip
    # QIP is just a list of set_global_assignment commands that are added to the project before synthesis.
    # This is useful for IP cores that have a lot of files and assignments, or modular code.
    # mymodule.qip:
    # set_global_assignment -name SYSTEMVERILOG_FILE <file1>.sv
    # set_global_assignment -name SYSTEMVERILOG_FILE <file2>.sv
    # ...

    # Paritions

    # PIN ASSIGNMENTS
    set_location_assignment PIN_27 -to i_clk
    #set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LED*
    set_location_assignment PIN_132 -to o_leds[1]
    set_location_assignment PIN_134 -to o_leds[2]
    set_location_assignment PIN_135 -to o_leds[3]
    set_location_assignment PIN_140 -to o_leds[4]
    set_location_assignment PIN_141 -to o_leds[5]

    # Commit assignments
    export_assignments

    # Close project
    if {$need_to_close_project} {
        project_close
    }
}