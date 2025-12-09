create_clock -name clk_i -period 1.0 -waveform { 0 0.5 } [get_ports clk_i]


# ------------------------- Input constraints ----------------------------------

#set_input_delay -clock clk -max 0.2 [get_ports {din start rstb wr_ctrl_test_crtl}]
#set_input_delay -clock clk -min -0.2 [get_ports {din start rstb wr_ctrl_test_crtl}]

# Set input delays for all input ports
set_input_delay -clock clk_i -max 0.2 [get_ports {start_i rst_i ifmap_wr_addr_i ifmap_wr_en_i ifmap_data_i weight_wr_addr_i weight_wr_en_i weight_data_i}]
set_input_delay -clock clk_i -min -0.2 [get_ports {start_i rst_i ifmap_wr_addr_i ifmap_wr_en_i ifmap_data_i weight_wr_addr_i weight_wr_en_i weight_data_i}]

# ------------------------- Output constraints ---------------------------------

# Set output delays for psum_o elements
set_output_delay -clock clk_i -max 0.2 [get_ports {psum_o[0] psum_o[1] psum_o[2] psum_o[3] psum_o[4] psum_o[5] psum_empty_o}]
set_output_delay -clock clk_i -min -0.2 [get_ports {psum_o[0] psum_o[1] psum_o[2] psum_o[3] psum_o[4] psum_o[5] psum_empty_o}]


set_max_delay 1.0 -from [all_inputs] -to [all_outputs]

# Assume 50fF load capacitances everywhere:
set_load 0.050 [get_ports {psum_o[0] psum_o[1] psum_o[2] psum_o[3] psum_o[4] psum_o[5] psum_empty_o}]
# Set 10fF maximum capacitance on all inputs
set_max_capacitance 0.010 [all_inputs]

# set clock uncertainty of the system clock (skew and jitter)
set_clock_uncertainty -setup 0.03 [get_clocks clk_i]
set_clock_uncertainty -hold 0.06 [get_clocks clk_i]


# set maximum transition at output ports
set_max_transition 0.07 [current_design]

# set_attr use_scan_seqs_for_non_dft false
