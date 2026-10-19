# Project Proposal: Multi-Channel Digital Fault Detection and Isolation System

## 1. Project Title and Real-World Application

This project implements a compact digital fault-detection and priority-encoding circuit intended for equipment-monitoring controllers. Four monitored subsystems provide digital fault flags to the circuit.

## 2. Problem Statement and Proposed Solution

An equipment controller may receive fault flags from multiple subsystems at the same time. It needs a consistent way to indicate whether a fault exists and identify the highest-priority active channel.

The proposed circuit accepts four digital fault inputs, applies a fixed priority order, and registers the fault status and corresponding fault code. The priority is CH1 > CH2 > CH3 > CH4.

The circuit processes digital fault flags. It does not directly measure analog quantities or independently diagnose the underlying physical fault.

## 3. Main Functionality

- Detect whether any of four fault inputs is active.
- Prioritize CH1 over CH2, CH2 over CH3, and CH3 over CH4.
- Assert the `fault` output when a fault is detected.
- Encode the highest-priority active channel in `fault_code`.
- Clear both outputs on a synchronous, active-high reset.
- Return to the no-fault state when all fault inputs are inactive.

## 4. Inputs, Outputs, Clock, and Reset

Inputs:
- `clk`: system clock.
- `rst`: synchronous, active-high reset.
- `ch1`, `ch2`, `ch3`, `ch4`: digital fault flags.

Outputs:
- `fault`: indicates whether a fault is detected.
- `fault_code[3:0]`: identifies the highest-priority active channel.

| Condition | fault | fault_code |
|---|---:|---|
| Reset asserted at active clock edge | 0 | 0000 |
| No fault input active | 0 | 0000 |
| CH1 has highest priority | 1 | 1000 |
| CH2 has highest priority | 1 | 0100 |
| CH3 has highest priority | 1 | 0010 |
| CH4 is the only active channel | 1 | 0001 |

## 5. Sequential Logic

The design uses clocked registers for `fault` and `fault_code`. An active-high synchronous reset clears these registers. The core function requires no processor, operating system, cloud service, or large memory.

## 6. Test Cases

The implemented testbench covers:
- Reset behaviour.
- No-fault operation.
- Individual faults on CH1, CH2, CH3, and CH4.
- Priority when multiple channels are active.
- All four channels active simultaneously.
- Clearing a fault and returning to the no-fault state.
- All 16 combinations of the four digital fault inputs.

The recorded simulation result is 28 passing checks: 12 original checks and 16 exhaustive input combinations.

## 7. Technical Feasibility and Practical Value

The design is implemented in synthesizable Verilog and has a small, fixed interface with limited combinational and sequential logic. A dedicated hardware circuit can provide deterministic, clock-synchronized priority selection locally without requiring software execution for this function.

Existing project evidence includes RTL simulation, Yosys synthesis, OpenLane physical-design results, timing reports, physical-verification reports, and the generated GDSII layout.

The intended role is as a component within a larger equipment-monitoring controller, not as a complete monitoring product or certified safety system.

## Verification and Timing Notes

The recorded Magic DRC report shows zero violations, and the LVS report records a unique circuit match.

Supplementary routed-SPEF timing checks were run for TT, SS, and FF using a temporary timing-analysis copy of the post-CTS netlist, with tap-cell instances omitted because their timing models were unavailable in the selected library. Each run exited successfully with zero warnings and zero errors. The minimum slack among the ten displayed setup paths was +7.38 ns (TT), +6.79 ns (SS), and +7.59 ns (FF). The minimum slack among the ten displayed hold paths was +1.96 ns (TT), +1.97 ns (SS), and +1.97 ns (FF).

These results apply to the displayed paths under the selected 10 ns clock and 2 ns input/output delay assumptions. The same routed SPEF was reused for all three libraries, so these supplementary checks do not establish signoff-quality multi-corner timing closure.

The post-CTS netlist and routed SPEF used by the analysis are included under `reports/sta/routed_corners/inputs/`. Re-running the script requires OpenSTA and the matching SKY130 HD timing libraries.

## Intended Users and Deployment

The intended users are digital hardware designers and engineers integrating fault-monitoring logic into equipment controllers. The circuit would sit inside a larger controller that receives digital fault flags from monitored subsystems and needs a registered fault indication and priority code.

## Required One-Sentence Project Definition

My project is a **four-channel digital fault-detection and priority-encoding circuit** that solves **the problem of identifying the highest-priority active fault among four monitored digital channels** by taking **clk, rst, ch1, ch2, ch3, and ch4** as inputs and producing **fault and fault_code[3:0]** as outputs. It uses **clocked registers with synchronous reset** as its main sequential logic.
