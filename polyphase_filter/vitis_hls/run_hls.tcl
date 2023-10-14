# Create a project
open_project proj -reset 

# Add design files
add_files polyphase_fir_dnsample5.cpp -cflags "-I../../utils"
add_files -tb "polyphase_fir_dnsample5_test.cpp" -cflags "-I../../utils"
add_files -tb "../matlab/testdata.bin"

# Set the top-level function
set_top polyphase_fir_dnsample5 

# ########################################################
# Create a solution
open_solution solution -reset -flow_target vivado

# Define technology and clock rate
set_part {xcvu9p-flga2104-2-i}
create_clock -period 5 -name default

# Set variable to select which steps to execute
set hls_exec 2

csim_design
# Set any optimization directives

set_directive_pipeline -II 1  "polyphase_fir_dnsample5"

# End of directives

if {$hls_exec == 1} {
	# Run C-Simulation, Synthesis and Exit
	csim_design
	csynth_design
} elseif {$hls_exec == 2} {
	# Run Synthesis, RTL Simulation and Exit
	csim_design
	csynth_design
	cosim_design
} elseif {$hls_exec == 3} { 
	# Run Synthesis, RTL Simulation, RTL implementation and Exit
	csim_design
	csynth_design
	cosim_design
	export_design
} else {
	# Default
	csim_design
	csynth_design
}

exit
