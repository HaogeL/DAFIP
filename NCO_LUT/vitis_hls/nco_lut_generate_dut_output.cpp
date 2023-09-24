#include "utils.h"
#include "nco_lut.h"
#include <complex>
#include <vector>


int main() {
  std::vector<double> out_vec_real;
  std::vector<double> out_vec_imag;
  SIG_OUT_TC out;
  auto v = utils::matread("testdata.bin");
  uint32_t num_samples = v[0].size();
  for (unsigned int i = 0; i < num_samples; i++) {
    nco_lut_hls(v[0][i], out);
    #ifdef DOUBLE_SIMULATION
    out_vec_real.push_back(out.real());
    out_vec_imag.push_back(out.imag());
    #else
    out_vec_real.push_back(out.real().to_double());
    out_vec_imag.push_back(out.imag().to_double());
    #endif
  }
  utils::matwrite_double("dut_output_real.bin", out_vec_real);
  utils::matwrite_double("dut_output_imag.bin", out_vec_imag);
  return 0;
}
