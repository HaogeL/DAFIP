#ifndef _QAMMOD16_H
#define _QAMMOD16_H
#define NUMBITSPERSYMB 4
#include "ap_int.h"
typedef ap_uint<NUMBITSPERSYMB> BITS_T;
typedef std::complex<ap_int<NUMBITSPERSYMB/2+1>> CSTL_T;
void QamMod16(const BITS_T bits, CSTL_T& constellation);
#endif
