create_clock -name {clk50} -period 20.000 -waveform { 0.000 10.000 } [get_ports { clk50 }]
derive_pll_clocks -create_base_clocks
derive_clock_uncertainty
