#include "QamMod.h"
#include "QamMod256.h"
void QamMod256(const BITS_T bits, CSTL_T& constellation){
  constellation = qam_mod::QamMod_fixed<CSTL_T, NUMBITSPERSYMB>(bits);
}
