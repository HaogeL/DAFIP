#include "QamMod.h"
#include "QamMod256.h"
void DeQamMod256(BITS_T& bits, const CSTL_T constellation){
  bits = qam_mod::DeQamMod_fixed<CSTL_T, NUMBITSPERSYMB>(constellation);
}
