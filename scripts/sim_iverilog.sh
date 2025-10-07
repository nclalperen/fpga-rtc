#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
TB=${1:-tb/smoke_tb.v}
echo "Running Icarus Verilog on $TB"
iverilog -g2012 -o build/sim.out "$TB" src/*.v src/*.sv
vvp build/sim.out +dump
echo "OK"

