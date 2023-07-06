#include "QamMod.h"
#include "QamMod64.h"
void QamMod64(const BITS_T bits, CSTL_T& constellation){
  constellation = qam_mod::QamMod_fixed<CSTL_T, NUMBITSPERSYMB>(bits);
}
