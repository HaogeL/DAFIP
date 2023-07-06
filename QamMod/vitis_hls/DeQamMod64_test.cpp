#include "QamMod64.h"
#include "QamMod.h"
#include "utils.h"
#include <vector>
int main() {
  std::vector<double> real;
  std::vector<double> imag;
  std::vector<double> binary;
  CSTL_T constellation_i;
  BITS_T bits_i;
  for (int i = 0; i < std::pow(2, NUMBITSPERSYMB); i++) {
    constellation_i = qam_mod::QamMod_fixed<CSTL_T, NUMBITSPERSYMB>(i);
    DeQamMod64(bits_i, constellation_i);
    if(bits_i != BITS_T(i)){
      printf("convert (%d + %di) to %d, but got %d, fail!\n", constellation_i.real().to_int(), constellation_i.imag().to_int(), i, bits_i.to_uint());
      return -1;
    }else{
      printf("convert (%d + %di) to %d, success!\n", constellation_i.real().to_int(), constellation_i.imag().to_int(), bits_i.to_uint());
    }
  }
  return 0;
}
