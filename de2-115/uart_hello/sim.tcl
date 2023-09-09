# source /path/to/sim.tcl

#vlib altera_mf_ver
#vmap altera_mf_ver altera_mf_ver
vlog -work altera_mf_ver $::env(ALTERA_MODELSIM)/altera/verilog/src/altera_mf.v
vsim -L altera_mf_ver -t ps work.uart_hello_test
add wave -position insertpoint sim:/uart_hello_test/u0/*
add wave -position insertpoint sim:/uart_hello_test/u0/t0/*
wave zoom range {0 ns} {10000000 ns}
run 10000000ns
