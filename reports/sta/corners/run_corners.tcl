# Multi-Channel Fault Detection
# Pre-route library-based timing checks
# Corner: selected through environment variable CORNER_LIB

set lib $::env(CORNER_LIB)
set netlist "/project/openlane/fault_detection/runs/08-10_15-55/results/synthesis/fault_detection.synthesis.v"

read_liberty $lib
read_verilog $netlist
link_design fault_detection

create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay 2.0 -clock clk [get_ports {ch1 ch2 ch3 ch4 rst}]
set_output_delay 2.0 -clock clk [all_outputs]

report_checks -path_delay min_max -fields {slew cap input_pin nets fanout} -group_count 20
report_wns
report_tns

exit
