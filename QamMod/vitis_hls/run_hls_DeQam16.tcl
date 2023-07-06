# Create a project
open_project DeQamMod16 -reset 

# Add design files
add_files DeQamMod16.cpp 
add_files -tb "DeQamMod16_test.cpp" -cflags "-I../../utils"

# Set the top-level function
set_top DeQamMod16

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
# End of directives

if {$hls_exec == 1} {
	# Run Synthesis and Exit
	csynth_design
	
} elseif {$hls_exec == 2} {
	# Run Synthesis, RTL Simulation and Exit
	csynth_design
	
	cosim_design
} elseif {$hls_exec == 3} { 
	# Run Synthesis, RTL Simulation, RTL implementation and Exit
	csynth_design
	
	cosim_design
	export_design
} else {
	# Default is to exit after setup
	csynth_design
}

exit
