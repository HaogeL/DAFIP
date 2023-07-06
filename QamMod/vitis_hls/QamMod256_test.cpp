#include "QamMod256.h"
#include "utils.h"
#include <vector>
int main() {
  std::vector<double> real;
  std::vector<double> imag;
  std::vector<double> binary;
  CSTL_T constellation;
  for (int i = 0; i < std::pow(2, NUMBITSPERSYMB); i++) {
    QamMod256(BITS_T(i), constellation);
    real.push_back(constellation.real().to_double());
    imag.push_back(constellation.imag().to_double());
    binary.push_back(double(i));
  }
  utils::matwrite_double("QamMod256_real.bin", real);
  utils::matwrite_double("QamMod256_imag.bin", imag);
  utils::matwrite_double("QamMod256_binary.bin", binary);

  return 0;
}
