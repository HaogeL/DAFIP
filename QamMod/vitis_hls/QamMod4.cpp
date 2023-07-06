#include "QamMod.h"
#include "QamMod4.h"
void QamMod4(const BITS_T bits, CSTL_T& constellation){
  constellation = qam_mod::QamMod_fixed<CSTL_T, NUMBITSPERSYMB>(bits);
}
