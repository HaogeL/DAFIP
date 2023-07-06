#include "QamMod.h"
#include "QamMod16.h"
void DeQamMod16(BITS_T& bits, const CSTL_T constellation){
  bits = qam_mod::DeQamMod_fixed<CSTL_T, NUMBITSPERSYMB>(constellation);
}
