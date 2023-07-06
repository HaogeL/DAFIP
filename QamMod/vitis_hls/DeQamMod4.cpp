#include "QamMod.h"
#include "QamMod4.h"
void DeQamMod4(BITS_T& bits, const CSTL_T constellation){
  bits = qam_mod::DeQamMod_fixed<CSTL_T, NUMBITSPERSYMB>(constellation);
}
