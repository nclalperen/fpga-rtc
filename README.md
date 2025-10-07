# FPGA RTC

Real-time clock (FPGA) project with CI + testbench & Vivado TCL.

## Layout
- `src/` — RTL and project sources
- `tb/` — testbenches (`rtc_tb.sv`, `smoke_tb.v`)
- `scripts/` — `sim_iverilog.sh` and `vivado_build.tcl`
- `docs/` — documentation (PDF/logs)
- `.github/workflows/ci.yml` — Icarus Verilog CI (compiles & runs TBs)

## Quick start (local, Ubuntu)
```bash
sudo apt-get update && sudo apt-get install -y iverilog
./scripts/sim_iverilog.sh tb/rtc_tb.sv   # or tb/smoke_tb.v
```

## Vivado non-GUI build
Edit `scripts/vivado_build.tcl` (`PART` and `TOP`) then:
```tcl
vivado -mode batch -source scripts/vivado_build.tcl
```
Artifacts and reports will appear under `build/`.

