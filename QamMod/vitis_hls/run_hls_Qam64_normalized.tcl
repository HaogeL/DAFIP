set proj_ QamMod64_normalized
set degisn_file_ ${proj_}.cpp
set Ctest_file_ ${proj_}_test.cpp
set clock_ 5

# Create a project
open_project $proj_ -reset 

# Add design files
add_files $degisn_file_
add_files -tb $Ctest_file_ -cflags "-I../../utils"

# Set the top-level function
set_top $proj_

# ########################################################
# Create a solution
open_solution solution -reset -flow_target vivado

# Define technology and clock rate
set_part {xcvu9p-flga2104-2-i}
create_clock -period $clock_ -name default
set_clock_uncertainty 0.0

# directives
#set_directive_interface -mode ap_none $proj_ bits
#set_directive_interface -mode ap_none $proj_ constellation
#set_directive_interface -mode ap_ctrl_none $proj_
#set_directive_pipeline -off $proj_
#set_directive_latency -min=1 -max=1 $proj_

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
