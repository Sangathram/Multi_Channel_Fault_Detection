#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
STA_BIN="${STA_BIN:-/home/vsduser/Desktop/work/tools/vsdflow/work/tools/OpenSTA/app/sta}"
LIB_DIR="${SKY130_LIB_DIR:-/home/vsduser/Desktop/work/tools/openlane_working_dir/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib}"
RUN_DIR="${OPENLANE_RUN_DIR:-$ROOT/openlane/fault_detection/runs/08-10_15-55}"
NETLIST="$RUN_DIR/results/lvs/fault_detection.lvs.powered.v"
SPEF="$RUN_DIR/results/routing/fault_detection.spef"
OUT_DIR="$ROOT/reports/sta/routed_corners"

for f in "$STA_BIN" "$NETLIST" "$SPEF"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Required file not found: $f"
        exit 1
    fi
done

: > "$OUT_DIR/summary.txt"

for spec in \
    "TT:sky130_fd_sc_hd__tt_025C_1v80.lib" \
    "SS:sky130_fd_sc_hd__ss_100C_1v60.lib" \
    "FF:sky130_fd_sc_hd__ff_n40C_1v95.lib"
do
    corner="${spec%%:*}"
    lib_name="${spec#*:}"
    lib="$LIB_DIR/$lib_name"
    tcl="/tmp/fault_detection_sta_${corner}.tcl"
    log="$OUT_DIR/${corner,,}.log"

    if [ ! -f "$lib" ]; then
        echo "ERROR: Timing library not found: $lib"
        exit 1
    fi

    cat > "$tcl" <<TCL
read_liberty "$lib"
read_verilog "$NETLIST"
link_design fault_detection
read_spef "$SPEF"
create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay 2.0 -clock clk [get_ports {ch1 ch2 ch3 ch4 rst}]
set_output_delay 2.0 -clock clk [all_outputs]
report_checks -path_delay min_max -fields {slew cap input_pin nets fanout} -group_count 20
report_wns
report_tns
exit
TCL

    if "$STA_BIN" -exit "$tcl" > "$log" 2>&1; then
        rc=0
    else
        rc=$?
    fi

    warnings="$(grep -c '^Warning:' "$log" || true)"

    {
        echo "Corner: $corner"
        echo "Library: $lib_name"
        echo "Netlist: $NETLIST"
        echo "Parasitics: $SPEF"
        echo "Clock period: 10 ns"
        echo "OpenSTA exit code: $rc"
        echo "Warning count: $warnings"
        echo
        echo "Reported WNS/TNS:"
        grep -E '^wns |^tns ' "$log" || true
        echo
        echo "Displayed paths:"
        grep -E 'slack \(MET\)|slack \(VIOLATED\)|^Error:' "$log" || true
        echo
    } > "$OUT_DIR/${corner,,}_summary.txt"

    cat "$OUT_DIR/${corner,,}_summary.txt" >> "$OUT_DIR/summary.txt"
    echo "$corner complete: exit=$rc, warnings=$warnings, log=$log"

    if [ "$rc" -ne 0 ]; then
        echo "ERROR: OpenSTA failed for corner $corner. Review $log"
        exit "$rc"
    fi
done

echo "Summary saved to $OUT_DIR/summary.txt"
