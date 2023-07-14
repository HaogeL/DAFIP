#include "QamMod.h"
#include "QamMod4.h"

void QamMod4_normalized(const BITS_T bits, CSTL_FIXED_CT& constellation){
  constellation = qam_mod::QamMod_normalized<CSTL_FIXED_CT, NUMBITSPERSYMB>(bits, QAM4NorRatio);
}
