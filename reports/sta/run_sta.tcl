# Multi-Channel Fault Detection - Static Timing Analysis
# Typical corner (TT)

set lib "/home/vsduser/Desktop/work/tools/openlane_working_dir/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set netlist "/home/vsduser/Multi_Channel_Fault_Detection/openlane/fault_detection/runs/08-10_15-55/results/lvs/fault_detection.lvs.powered.v"
set spef "/home/vsduser/Multi_Channel_Fault_Detection/openlane/fault_detection/runs/08-10_15-55/results/routing/fault_detection.spef"

read_liberty $lib
read_verilog $netlist
link_design fault_detection

read_spef $spef

create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay 2.0 -clock clk [get_ports {ch1 ch2 ch3 ch4 rst}]
set_output_delay 2.0 -clock clk [all_outputs]

report_checks -path_delay min_max -fields {slew cap input_pin nets fanout} -group_count 20
report_wns
report_tns

exit
