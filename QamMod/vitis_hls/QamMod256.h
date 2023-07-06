#ifndef _QAMMOD256_H
#define _QAMMOD256_H
#define NUMBITSPERSYMB 8
#include "ap_int.h"
typedef ap_uint<NUMBITSPERSYMB> BITS_T;
typedef std::complex<ap_int<NUMBITSPERSYMB/2+1>> CSTL_T;
void QamMod256(const BITS_T bits, CSTL_T& constellation);
void DeQamMod256(BITS_T & bits, const CSTL_T constellation);
#endif
