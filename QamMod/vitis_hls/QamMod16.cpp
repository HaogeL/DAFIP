#include "QamMod.h"
#include "QamMod16.h"
void QamMod16(const BITS_T bits, CSTL_T& constellation){
  constellation = qam_mod::QamMod_fixed<CSTL_T, NUMBITSPERSYMB>(bits);
}
