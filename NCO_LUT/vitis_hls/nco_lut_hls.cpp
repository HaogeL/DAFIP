#include "nco_lut.h"

void nco_lut_hls(PHASE_TR phase_in, SIG_OUT_TC& cossin){
    cossin = nco_lut<PHASE_TR, SIG_OUT_TC>(phase_in);
}