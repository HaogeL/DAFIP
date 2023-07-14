#include "QamMod.h"
#include "QamMod256.h"

void QamMod256_normalized(const BITS_T bits, CSTL_FIXED_CT& constellation){
  constellation = qam_mod::QamMod_normalized<CSTL_FIXED_CT, NUMBITSPERSYMB>(bits, QAM256NorRatio);
}
