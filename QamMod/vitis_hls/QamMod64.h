#ifndef _QAMMOD64_H
#define _QAMMOD64_H
#define NUMBITSPERSYMB 6
#include "ap_int.h"
typedef ap_uint<NUMBITSPERSYMB> BITS_T;
typedef std::complex<ap_int<NUMBITSPERSYMB/2+1>> CSTL_T;
void QamMod64(const BITS_T bits, CSTL_T& constellation);
void DeQamMod64(BITS_T & bits, const CSTL_T constellation);
#endif
