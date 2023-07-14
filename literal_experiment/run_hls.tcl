# Create a project
open_project test -reset 

# Add design files
add_files test.cpp 

# Set the top-level function
set_top incre 

# ########################################################
# Create a solution
open_solution solution -reset -flow_target vivado

# Define technology and clock rate
set_part {xcvu9p-flga2104-2-i}
create_clock -period 5 -name default
exit