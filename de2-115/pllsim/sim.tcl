# simulates a clock outputting a PLL to create phases differences
# sees the effects of the output of the new clocks relative to the PLL
# observation: 
# -90 and 90 degree acts as a sort of delay
# 180 degrees flip the original clock upside down
# 270 is kind of like 90 degrees
# the async reset provides restarts the PLL at a later point in time
# if there is no async reset, the PLL has its own delay before starting

#vlib altera_mf_ver
#vmap altera_mf_ver altera_mf_ver
vlog -work altera_mf_ver $::env(ALTERA_MODELSIM)/altera/verilog/src/altera_mf.v
vsim -L altera_mf_ver -t ps work.pllsim_test
add wave -position insertpoint sim:/pllsim_test/p/*
wave zoom range {0 ns} {1000 ns}
run 1000ns
