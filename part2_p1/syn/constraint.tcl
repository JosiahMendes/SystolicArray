# complete this file based on the requirements
reset_design

# Create Clock with period 5, unertainty 0.1
create_clock -period 5.0 [get_ports clk]
set_clock_uncertainty 0.1 [get_clocks clk]

# Set input signal properties
set_input_transition 0.1 [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay 0.2 -max -clock clk [remove_from_collection [all_inputs] [get_ports {clk rstnSys}]]

# Set output delay and output capacitance
set_output_delay 0.2 -max -clock clk [all_outputs]
set_load 5 [all_outputs]

set_driving_cell -lib_cell INVX4_RVT [all_inputs]

set_max_area 0

