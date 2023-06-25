#include <iostream>
#include "iir.h"
#include "utils.h"
#include <vector>
#include <cmath>
using namespace current_hls;
int main(){
	//get test data
	auto v = utils::matread("testdata.bin");
	DATA_T in = 0;
	DATA_T out = 0;
	std::vector<double> out_vec;
	uint32_t num_samples = v[0].size();
	double resolution = std::pow(2, -(DATA_T::width-DATA_T::iwidth));
	double out_double;
	uint32_t num_error=0;
	printf("error upper bound is %lf\n", err_upper);
	printf("error lower bound is %lf\n", err_lower);
	double sim_err_upper = 0;
	double sim_err_lower = 0;
	for(uint32_t i=0; i<num_samples; i++){
		in = v[0][i];
		iir_hls(in, out);
		out_double = out.to_double();
		out_vec.push_back(out_double);
		double err = v[1][i] - out_double; //ref - dut_out
		if(err > sim_err_upper)
			sim_err_upper = err;
		if(err < sim_err_lower)
			sim_err_lower = err;
		if(err > err_upper || err < err_lower){
			printf("i=%d; ref=%lf; sim=%lf\n", i, v[1][i], out_double);
			num_error ++;
		}
	}
	if(num_error > 0){
		fprintf(stdout, "%d samples do not match reference value \n", num_error);
	}else{
		fprintf(stdout, "%d samples all match reference value \n", num_samples);
	}
	printf("Simulation err_upper is %lf.\nSimulation err_lower is %lf\n", sim_err_upper, sim_err_lower);

	utils::matwrite_double("dut_output.bin", out_vec); //dut_output.bin will be generated in <vitis-proj-path>/solution/csim/build
	return num_error;
}
