#ifndef _QAMMOD4_H
#define _QAMMOD4_H
#define NUMBITSPERSYMB 2
#include "ap_int.h"
typedef ap_uint<NUMBITSPERSYMB> BITS_T;
typedef std::complex<ap_int<NUMBITSPERSYMB/2+1>> CSTL_T;
void QamMod4(const BITS_T bits, CSTL_T& constellation);
#endif
