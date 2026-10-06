# Multi-Channel Digital Fault Detection and Isolation System

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
