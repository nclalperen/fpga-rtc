# vivado_build.tcl — minimal non-GUI flow
set PART "xc7a100tcsg324-1"   ;# Artix-7 100T (Nexys A7-100T)
set TOP  "RTC_7Seg"
set PROJ "fpga_rtc_proj"

create_project $PROJ ./build -part $PART -force
set_property target_language VHDL [current_project]

# Add RTL sources from src/
set vhdl_files [glob -nocomplain ./src/*.vhd]
if {[llength $vhdl_files] > 0} {
  add_files -norecurse $vhdl_files
}
set verilog_files [glob -nocomplain ./src/*.v ./src/*.sv]
if {[llength $verilog_files] > 0} {
  add_files -norecurse $verilog_files
}
if {[llength $vhdl_files] == 0 && [llength $verilog_files] == 0} {
  puts "WARN: no RTL sources in ./src"
}

# Constraints
set xdc_files [glob -nocomplain ./src/*.xdc]
if {[llength $xdc_files] > 0} {
  add_files -fileset constrs_1 -norecurse $xdc_files
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
