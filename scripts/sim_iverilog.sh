#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
TB=${1:-tb/smoke_tb.v}
# The RTL under src/ is VHDL, which Icarus cannot compile; include only
# Verilog/SystemVerilog sources when present.
shopt -s nullglob
SRCS=(src/*.v src/*.sv)
echo "Running Icarus Verilog on $TB"
iverilog -g2012 -o build/sim.out "$TB" ${SRCS[@]+"${SRCS[@]}"}
vvp build/sim.out +dump
echo "OK"
