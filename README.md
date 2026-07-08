# fpga-rtc

**A real-time clock in VHDL for the Digilent Nexys A7-100T, displayed on the board's 7-segment displays.**

[![FPGA CI (iverilog)](https://github.com/nclalperen/fpga-rtc/actions/workflows/ci.yml/badge.svg)](https://github.com/nclalperen/fpga-rtc/actions/workflows/ci.yml)
![Language](https://img.shields.io/badge/language-VHDL-purple)
![Target](https://img.shields.io/badge/target-Artix--7%20xc7a100t-red)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-green)](LICENSE)

The design (`RTC_7Seg`) divides the board's 100 MHz system clock down to a
1 Hz timebase for the HH:MM:SS counters and a 1 kHz scan clock that
multiplexes the time across six of the eight 7-segment digits. Push buttons
drive a small state machine that selects the status LEDs, and the 16 slide
switches are available as inputs.

## Hardware

- **Board:** Digilent Nexys A7-100T (Artix-7 `xc7a100tcsg324-1`)
- **Inputs:** 100 MHz clock, synchronous reset, BTNC/BTNU/BTNL/BTND buttons, `SW[15:0]`
- **Outputs:** 7-segment segments `CA–CG` + `DP`, digit anodes `AN[7:0]`, `LED[3:0]`

## Design

```
src/
  Top_module.vhd         RTC_7Seg top: time counters, 7-seg mux, button FSM
  ClockDivider_1Hz.vhd   100 MHz → 1 Hz (RTC tick)
  ClockDivider_1kHz.vhd  100 MHz → 1 kHz (display scan)
  *.xdc                  pin constraints
tb/
  rtc_tb.sv              SystemVerilog testbench scaffold (clock/reset/VCD helpers)
  smoke_tb.v             minimal CI smoke test
scripts/
  vivado_build.tcl       non-GUI Vivado synthesis flow
  sim_iverilog.sh        Icarus Verilog testbench runner
```

## Build (Vivado, non-GUI)

```tcl
vivado -mode batch -source scripts/vivado_build.tcl
```

The script creates the project for the `xc7a100tcsg324-1` part, adds the VHDL
sources and constraints, runs synthesis, and writes utilization/timing
reports under `build/reports/`. Uncomment the implementation lines in the
script to produce a bitstream.

## Simulation & CI

```bash
sudo apt-get install -y iverilog
./scripts/sim_iverilog.sh tb/smoke_tb.v
./scripts/sim_iverilog.sh tb/rtc_tb.sv
```

GitHub Actions runs every testbench under `tb/` with Icarus Verilog on each
push and uploads the resulting VCD waveforms as artifacts. The VHDL RTL
itself is verified through the Vivado flow (Icarus is Verilog-only); the
SystemVerilog benches provide the CI scaffold and smoke coverage.

## Limitations / roadmap

- Hours currently count 0–9 (no 24-hour rollover yet)
- Button debouncing is not implemented
- Time-set mode via switches is planned

## License

[GPL-3.0](LICENSE)
