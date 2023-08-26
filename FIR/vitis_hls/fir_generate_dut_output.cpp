#include <iostream>
#include "utils.h"
#include <vector>
#include "fir_rcc.h"

//not actually checking the result.
//drive the DUT and store the result and compare the result with Matlab's ideal model.
int main(){
    auto v = utils::matread("testdata.bin");
    uint32_t num_samples = v[0].size(); 
    TRS_IN in;
    TRS_OUT out;
    std::vector<double> out_vec;
	for(uint32_t i=0; i<num_samples; i++){
		in = v[0][i];
		fir_rrc(in, out);
		double out_double = out.to_double();
		out_vec.push_back(out_double);
	}
    //dut_output.bin will be generated in <vitis-proj-path>/solution/csim/build
    utils::matwrite_double("dut_output.bin", out_vec); 
    return 0;
}