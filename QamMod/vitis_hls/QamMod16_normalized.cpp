#include "QamMod.h"
#include "QamMod16.h"

void QamMod16_normalized(const BITS_T bits, CSTL_FIXED_CT& constellation){
  constellation = qam_mod::QamMod_normalized<CSTL_FIXED_CT, NUMBITSPERSYMB>(bits, QAM16NorRatio);
}
