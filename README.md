# Multi-Channel Digital Fault Detection and Isolation System
[![RTL Simulation](https://github.com/Sangathram/Multi_Channel_Fault_Detection/actions/workflows/simulation.yml/badge.svg)](https://github.com/Sangathram/Multi_Channel_Fault_Detection/actions/workflows/simulation.yml)

**RTL-to-GDSII ASIC Implementation using Open-Source VLSI Tools**

## Overview

This project focuses on the design and implementation of a digital fault detection and isolation system for multiple monitored channels.

The system monitors four independent digital channels and detects whether a fault is present. When a fault is detected, the system identifies the affected channel using a priority-based fault isolation mechanism.

The complete project is intended to follow an ASIC RTL-to-GDSII design flow using open-source VLSI tools.

## Project Objectives

- Design a multi-channel digital fault detection system.
- Detect faults across four monitored channels.
- Isolate the affected channel using priority logic.
- Verify the RTL functionality using simulation.
- Perform logic synthesis and physical design.
- Complete the ASIC flow up to GDSII generation.
- Analyze timing and physical design results.

## System Specification

### Inputs

| Signal | Description |
|--------|-------------|
| `clk` | System clock |
| `rst` | Synchronous reset |
| `ch1` | Channel 1 fault input |
| `ch2` | Channel 2 fault input |
| `ch3` | Channel 3 fault input |
| `ch4` | Channel 4 fault input |

### Outputs

| Signal | Description |
|--------|-------------|
| `fault` | Indicates whether a fault is detected |
| `fault_code[3:0]` | Identifies the detected fault channel |

## Fault Code Mapping

| Channel Condition | Fault Code | Meaning |
|-------------------|------------|---------|
| No fault | `0000` | No fault detected |
| CH1 | `1000` | Channel 1 fault |
| CH2 | `0100` | Channel 2 fault |
| CH3 | `0010` | Channel 3 fault |
| CH4 | `0001` | Channel 4 fault |

### Fault Priority

When multiple channels are faulty simultaneously, the system uses the following priority:

```text
CH1 > CH2 > CH3 > CH4
```

## Architecture

Four fault inputs feed priority-based detection logic. Clocked registers store the fault status and code, with synchronous reset.

## Tools and Technology

- Verilog HDL
- Icarus Verilog and GTKWave
- Yosys synthesis
- OpenLane RTL-to-GDSII flow
- SKY130A `sky130_fd_sc_hd` standard-cell library
- OpenSTA, Magic, and Netgen

## Verification Results

### RTL Simulation
**RTL simulation passed 28 checks:** one reset check and eleven functional test cases, plus exhaustive verification of all 16 combinations of the four channel inputs. The tests cover no fault, individual channel faults, priority handling, simultaneous faults, and reset during an active fault.

### Synthesis
Yosys synthesis completed successfully. The recorded synthesis report lists 11 cells.

### Physical Design
The OpenLane flow completed floorplanning, placement, clock-tree synthesis, routing, and GDSII generation.

- Core dimensions: approximately 25.76 × 24.48 µm
- Core area: approximately 630.60 µm²
- Die dimensions: approximately 36.84 × 47.56 µm
- Die area: approximately 1751.51 µm²

### Physical Verification
- Magic DRC report: `COUNT: 0`
- LVS: circuits match uniquely, with 34 devices and 34 nets on each side.
- Recorded antenna checks: zero violating pins and zero violating nets.

### Static Timing Analysis

Pre-route, library-based checks were performed using a 10 ns clock period.

| Corner | Input-to-register slack | Register-to-output slack |
|---|---:|---:|
| TT | +7.81 ns | +7.73 ns |
| SS | +7.59 ns | +7.42 ns |
| FF | +7.88 ns | +7.83 ns |

The displayed paths are marked MET. The logs report WNS = 0.00 and TNS = 0.00.

**Limitation:** These are pre-route checks using the synthesized netlist and one Liberty library per run, not routed-parasitic STA for all three corners. A separate existing SPEF-based report records +6.63 ns slack for its reported maximum-delay path.

## Project Structure

RTL, testbench, simulation, synthesis, physical-design, and timing files are organized in their respective folders. Screenshots are stored in `images/`, reports in `reports/`, and the generated layout at `gds/fault_detection.gds`.

## Routed-SPEF Multi-Corner Timing Checks

OpenSTA 2.3.0 was run with the existing routed SPEF and a temporary timing-analysis copy of the post-CTS netlist. Tap-cell instances were omitted from this temporary copy because the selected timing library does not provide their timing models. The original physical netlist, layout, and GDS were not modified by this analysis.

The checks used a 10 ns clock period, 2 ns input and output delays, and propagated clock timing.

| Corner | Library | Minimum displayed setup slack | Minimum displayed hold slack | Warnings | Errors |
|---|---|---:|---:|---:|---:|
| TT | 25 °C, 1.80 V | +7.38 ns | +1.96 ns | 0 | 0 |
| SS | 100 °C, 1.60 V | +6.79 ns | +1.97 ns | 0 | 0 |
| FF | -40 °C, 1.95 V | +7.59 ns | +1.97 ns | 0 | 0 |

OpenSTA exited successfully for all three runs. Ten setup paths and ten hold paths were reported per corner; all displayed paths were marked MET. These values are the minimum slack among the displayed paths, not a claim that every possible path has been checked.

The analysis can be rerun using `./reports/sta/routed_corners/run_routed_sta.sh`. Logs and summaries are stored in `reports/sta/routed_corners/`.

The timing inputs are bundled in `reports/sta/routed_corners/inputs/`: `fault_detection.synthesis_cts.v` and `fault_detection.spef`. The script falls back to these copies when the original OpenLane run files are unavailable. Re-running the analysis still requires OpenSTA and the matching SKY130 HD timing libraries; set `STA_BIN` and `SKY130_LIB_DIR` if they are installed in different locations.

**Limitations:** The same routed SPEF was reused with all three timing libraries rather than using separately extracted corner-specific parasitics. The timing-only netlist excludes physical-only tap-cell instances. These checks are useful comparative routed-parasitic checks but do not establish full signoff-quality multi-corner timing closure. The reported WNS/TNS commands show `0.00`; they should not be interpreted as the positive slack margins listed above.

## Conclusion

The four-channel fault detection design was simulated, synthesized, and taken through the OpenLane physical-design flow to GDSII generation. The recorded reports show zero Magic DRC count and a unique LVS circuit match. Pre-route timing checks and supplementary routed-SPEF timing checks for TT, SS, and FF are documented above, with the limitations of the supplementary analysis stated explicitly.
## Project Gallery

### Architecture
![Architecture](images/01_architecture.png)

### RTL Verification
![RTL Verification](images/02_rtl_verification.png)

### Synthesis
![Synthesis](images/03_synthesis.png)

### Physical Design
![Floorplan](images/04_floorplan.png)
![Placement](images/05_placement.png)
![Clock Tree Synthesis](images/06_cts.png)
![Routing](images/07_routing.png)

### Timing and Physical Verification
![Timing Analysis](images/08_timing.png)
![DRC Results](images/09_drc.png)
![LVS Results](images/10_lvs.png)

### GDSII and Final Results
![GDSII Layout](images/11_gdsii.png)
![Final Results](images/12_final_results.png)

## 🎥 Project Demo Video

[▶ Watch Project Demo Video](https://drive.google.com/file/d/15PHm3GQmn11X-GNwm3llYZ4FIPNgh8tN/view)

[📁 View Demo Folder](https://github.com/Sangathram/Multi_Channel_Fault_Detection/tree/main/demo)

[📁 View Video Folder](https://github.com/Sangathram/Multi_Channel_Fault_Detection/tree/main/video)
