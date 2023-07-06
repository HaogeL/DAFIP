#include "QamMod.h"
#include "QamMod64.h"
void DeQamMod64(BITS_T& bits, const CSTL_T constellation){
  bits = qam_mod::DeQamMod_fixed<CSTL_T, NUMBITSPERSYMB>(constellation);
}
