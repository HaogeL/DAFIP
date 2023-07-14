#ifndef _QAMMOD4_H
#define _QAMMOD4_H
#define NUMBITSPERSYMB 2
#include "ap_int.h"
#include "ap_fixed.h"
typedef ap_uint<NUMBITSPERSYMB> BITS_T;
typedef std::complex<ap_int<NUMBITSPERSYMB/2+1>> CSTL_T;
void QamMod4(const BITS_T bits, CSTL_T& constellation);
void DeQamMod4(BITS_T& bits, const CSTL_T constellation);

// data type for the constellation outputs of QamMod4_normalized
typedef std::complex<ap_fixed<20, 2>> CSTL_FIXED_CT;  
void QamMod4_normalized(const BITS_T bits, CSTL_FIXED_CT& constellation);
#endif
