#ifndef _QAMMOD16_H
#define _QAMMOD16_H
#define NUMBITSPERSYMB 4
#include "ap_int.h"
typedef ap_uint<NUMBITSPERSYMB> BITS_T;
typedef std::complex<ap_int<NUMBITSPERSYMB/2+1>> CSTL_T;
void QamMod16(const BITS_T bits, CSTL_T& constellation);
void DeQamMod16(BITS_T & bits, const CSTL_T constellation);

// data type for the constellation outputs of QamMod16_normalized
typedef std::complex<ap_fixed<20, 2>> CSTL_FIXED_CT;  
void QamMod16_normalized(const BITS_T bits, CSTL_FIXED_CT& constellation);
#endif
