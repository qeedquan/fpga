# source /path/to/sim.tcl

#vlib altera_mf_ver
#vmap altera_mf_ver altera_mf_ver
vlog -work altera_mf_ver $::env(ALTERA_MODELSIM)/altera/verilog/src/altera_mf.v
vsim -L altera_mf_ver -t ps work.vgadla_test
add wave -position insertpoint sim:/vgadla_test/v/*
wave zoom range {0 ns} {10000000 ns}
run 10000000ns
