#include "QamMod.h"
#include "QamMod64.h"

void QamMod64_normalized(const BITS_T bits, CSTL_FIXED_CT& constellation){
  constellation = qam_mod::QamMod_normalized<CSTL_FIXED_CT, NUMBITSPERSYMB>(bits, QAM64NorRatio);
}
