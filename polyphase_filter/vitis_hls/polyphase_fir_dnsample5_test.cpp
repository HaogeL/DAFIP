#include "utils.h"
#include <vector>
#include "polyphase_fir_dnsample5.h"

int main() {
  std::vector<double> out_vec_real;
  TSF_SIG_OUT out_hls;
  auto v = utils::matread("testdata.bin");
  uint32_t num_samples = v[0].size();
  for (unsigned int i = 0; i < num_samples; i++) {
    polyphase_fir_dnsample5(v[0][i], out_hls);
    out_vec_real.push_back(out_hls.to_double());
  }
  utils::matwrite_double("dut_output.bin", out_vec_real);
  return 0;
}