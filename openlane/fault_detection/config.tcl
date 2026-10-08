set ::env(DESIGN_NAME) "fault_detection"

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/../../rtl/fault_detection.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) "clk"
set ::env(CLOCK_PERIOD) "10.0"

set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set ::env(FP_CORE_UTIL) 25
set ::env(FP_ASPECT_RATIO) 1
set ::env(FP_CORE_MARGIN) 2

set ::env(PL_TARGET_DENSITY) 0.7
set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(RUN_CTS) 1
set ::env(RUN_DRT) 1
set ::env(RUN_LVS) 1
set ::env(RUN_MAGIC) 1
