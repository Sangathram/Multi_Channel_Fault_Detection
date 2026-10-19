#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
STA_BIN="${STA_BIN:-/home/vsduser/Desktop/work/tools/vsdflow/work/tools/OpenSTA/app/sta}"
LIB_DIR="${SKY130_LIB_DIR:-/home/vsduser/Desktop/work/tools/openlane_working_dir/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib}"
RUN_DIR="${OPENLANE_RUN_DIR:-$ROOT/openlane/fault_detection/runs/08-10_15-55}"

OUT_DIR="$ROOT/reports/sta/routed_corners"
BUNDLED_DIR="$OUT_DIR/inputs"
CTS_NETLIST="$RUN_DIR/results/synthesis/fault_detection.synthesis_cts.v"
SPEF="$RUN_DIR/results/routing/fault_detection.spef"
TIMING_NETLIST="/tmp/fault_detection_timing_only.v"

# Fall back to bundled copies when the original OpenLane run is unavailable.
if [ ! -f "$CTS_NETLIST" ]; then
    CTS_NETLIST="$BUNDLED_DIR/fault_detection.synthesis_cts.v"
fi
if [ ! -f "$SPEF" ]; then
    SPEF="$BUNDLED_DIR/fault_detection.spef"
fi

for f in "$STA_BIN" "$CTS_NETLIST" "$SPEF"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Required file not found: $f"
        exit 1
    fi
done

mkdir -p "$OUT_DIR"

# Create a timing-analysis-only copy. Do not modify the physical netlist.
# The library has no timing model for these tap-cell instances.
grep -v 'sky130_fd_sc_hd__tapvpwrvgnd_1 PHY_' \
    "$CTS_NETLIST" > "$TIMING_NETLIST"

# Remove unused supply-only top-level ports from this timing-only copy.
# Do not change the original CTS netlist, physical netlist, or GDS.
python3 - "$TIMING_NETLIST" <<'PY_PORTS'
from pathlib import Path
import sys

p = Path(sys.argv[1])
lines = p.read_text().splitlines()
remove = {"VPWR,", "VGND,", "input VPWR;", "input VGND;"}
lines = [line for line in lines if line.strip() not in remove]
text = "\n".join(lines) + "\n"
if any(line.strip() in remove for line in text.splitlines()):
    raise SystemExit("ERROR: Unused supply ports remain in timing-only copy.")
p.write_text(text)
PY_PORTS

if grep -q 'sky130_fd_sc_hd__tapvpwrvgnd_1 PHY_' "$TIMING_NETLIST"; then
    echo "ERROR: Tap-cell removal from temporary timing netlist failed."
    exit 1
fi

overall_fail=0
: > "$OUT_DIR/summary.txt"

{
    echo "Multi-corner routed-SPEF timing checks"
    echo "Netlist: post-CTS synthesis netlist, temporary timing-only copy"
    echo "Netlist source: $CTS_NETLIST"
    echo "Parasitics source: $SPEF"
    echo "Tap-cell instances omitted only from temporary timing-analysis copy"
    echo "Clock period: 10 ns"
    echo "Input and output delays: 2 ns"
    echo "Reported slack values are minima across returned setup and hold paths, with up to 1000 paths per timing group"
    echo "These checks are not signoff-quality STA."
    echo
} >> "$OUT_DIR/summary.txt"

for spec in \
    "TT:sky130_fd_sc_hd__tt_025C_1v80.lib" \
    "SS:sky130_fd_sc_hd__ss_100C_1v60.lib" \
    "FF:sky130_fd_sc_hd__ff_n40C_1v95.lib"
do
    corner="${spec%%:*}"
    lib_name="${spec#*:}"
    lib="$LIB_DIR/$lib_name"
    corner_lc="$(printf '%s' "$corner" | tr '[:upper:]' '[:lower:]')"
    tcl="/tmp/fault_detection_sta_${corner}.tcl"
    log="$OUT_DIR/${corner_lc}.log"

    if [ ! -f "$lib" ]; then
        echo "ERROR: Timing library not found: $lib"
        exit 1
    fi

    cat > "$tcl" <<TCL
read_liberty "$lib"
read_verilog "$TIMING_NETLIST"
link_design fault_detection
read_spef "$SPEF"
create_clock -name clk -period 10.0 [get_ports clk]
set_propagated_clock [all_clocks]
set_input_delay 2.0 -clock clk [get_ports {ch1 ch2 ch3 ch4 rst}]
set_output_delay 2.0 -clock clk [all_outputs]
puts "=== CONSTRAINT CHECK ==="
check_setup -verbose
puts "=== SETUP PATHS ==="
report_checks -path_delay max -fields {slew cap input_pin nets fanout} -group_count 1000
puts "=== HOLD PATHS ==="
report_checks -path_delay min -fields {slew cap input_pin nets fanout} -group_count 1000
puts "=== WNS / TNS SUMMARY ==="
report_wns
report_tns
exit
TCL

    "$STA_BIN" -exit "$tcl" > "$log" 2>&1
    rc=$?
    warnings="$(grep -c '^Warning:' "$log" || true)"
    errors="$(grep -Ec '^(Error:|ERROR:)' "$log" || true)"

    metrics="$(awk '
        /^=== SETUP PATHS ===/ { section="setup"; next }
        /^=== HOLD PATHS ===/ { section="hold"; next }
        /slack \(/ {
            value=$1+0
            if (section=="setup") {
                if (nsetup==0 || value<smin) smin=value
                nsetup++
            } else if (section=="hold") {
                if (nhold==0 || value<hmin) hmin=value
                nhold++
            }
        }
        END {
            if (nsetup>0) printf "%.2f %d ", smin, nsetup
            else printf "NA 0 "
            if (nhold>0) printf "%.2f %d\n", hmin, nhold
            else printf "NA 0\n"
        }' "$log")"

    read -r setup_min setup_count hold_min hold_count <<< "$metrics"

    {
        echo "Corner: $corner"
        echo "Library: $lib_name"
        echo "OpenSTA exit code: $rc"
        echo "Warning count: $warnings"
        echo "Error count: $errors"
        echo "Displayed setup paths: $setup_count"
        echo "Minimum displayed setup slack (ns): $setup_min"
        echo "Displayed hold paths: $hold_count"
        echo "Minimum displayed hold slack (ns): $hold_min"
        echo "WNS/TNS commands:"
        grep -E '^wns |^tns ' "$log" || true
        echo "Timing log: $log"
        echo
    } > "$OUT_DIR/${corner_lc}_summary.txt"

    cat "$OUT_DIR/${corner_lc}_summary.txt" >> "$OUT_DIR/summary.txt"

    echo "========== $corner =========="
    cat "$OUT_DIR/${corner_lc}_summary.txt"

    if [ "$rc" -ne 0 ] || [ "$warnings" -ne 0 ] ||
       [ "$errors" -ne 0 ] || [ "$setup_count" -eq 0 ] ||
       [ "$hold_count" -eq 0 ] ||
       [ "$setup_min" = "NA" ] || [ "$hold_min" = "NA" ]; then
        overall_fail=1
    else
        positive="$(awk -v s="$setup_min" -v h="$hold_min" \
            'BEGIN { print (s>0 && h>0) ? 1 : 0 }')"
        [ "$positive" -eq 1 ] || overall_fail=1
    fi
done

# Normalize generated reports without changing timing values.
python3 - "$OUT_DIR" <<'PY_CLEAN'
from pathlib import Path
import sys

out = Path(sys.argv[1])
for path in out.iterdir():
    if not path.is_file():
        continue
    if path.suffix == ".log" or path.name.endswith("_summary.txt") or path.name == "summary.txt":
        lines = [line.rstrip() for line in path.read_text(errors="replace").splitlines()]
        while lines and not lines[-1]:
            lines.pop()
        path.write_text("\n".join(lines) + "\n")
PY_CLEAN

echo "=== COMBINED SUMMARY ==="
cat "$OUT_DIR/summary.txt"

if [ "$overall_fail" -ne 0 ]; then
    echo "MULTI_CORNER_RESULT=FAIL_OR_REVIEW_REQUIRED"
    exit 1
fi

echo "MULTI_CORNER_RESULT=PASS_FOR_REPORTED_PATHS"
