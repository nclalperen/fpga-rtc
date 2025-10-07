# vivado_build.tcl — minimal non-GUI flow (edit PART and TOP)
set PART "xc7a35tcsg324-1"   ;# TODO: change to your FPGA part
set TOP  "rtc_top"           ;# TODO: change to your top module
set PROJ "fpga_rtc_proj"

create_project $PROJ ./build -part $PART -force
set_property target_language Verilog [current_project]

# Add all Verilog/SystemVerilog files from src/
set src_files [glob -nocomplain ./src/*.v ./src/*.sv]
if {[llength $src_files] == 0} {
  puts "WARN: no RTL sources in ./src"
} else {
  add_files -norecurse $src_files
}

set_property top $TOP [current_fileset]
update_compile_order -fileset sources_1

# Synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Implementation & bitstream (optional)
# launch_runs impl_1 -to_step write_bitstream -jobs 4
# wait_on_run impl_1

# Reports
file mkdir ./build/reports
report_utilization -file ./build/reports/util.rpt -pb
report_timing_summary -file ./build/reports/timing.rpt -pb
puts "DONE."

