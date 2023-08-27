#include <iostream>
#include "utils.h"
#include <vector>
#include "fir_cplx_rcc.h"

//not actually checking the result.
//drive the DUT and store the result and compare the result with Matlab's ideal model.
int main(){
    auto v = utils::matread("testdata_cplx.bin");
    uint32_t num_samples = v[0].size(); 
    TCS_IN in;
    TCS_OUT out;
    std::vector<double> out_vec_real;
    std::vector<double> out_vec_imag;
	for(uint32_t i=0; i<num_samples; i++){
		in = std::complex<double>(v[0][i], v[1][i]);
		fir_cplx_rrc(in, out);
		out_vec_real.push_back(out.real().to_double());
        out_vec_imag.push_back(out.imag().to_double());
	}
    //dut_output.bin will be generated in <vitis-proj-path>/solution/csim/build
    utils::matwrite_double("dut_output_real.bin", out_vec_real); 
    utils::matwrite_double("dut_output_imag.bin", out_vec_imag); 
    return 0;
}
