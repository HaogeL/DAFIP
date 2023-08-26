#ifndef FIR_FILTER_H_
#define FIR_FILTER_H_

#include <ap_fixed.h>
#include "../../utils/utils.h"

/*
 * Normal fir filter
 * Half coeff as input.
 * Coeff has to be symmetric.
 * If coeff is an odd number, the middle coeff has to be included as the last coeff in the input array
 * templates:
     * num_coeff: number of coeff
     * TRS_IN: input type e.g. typedef ap_fixed<16, 2>
     * TRS_COEFF: ceoff type e.g. typedef ap_fixed<8,  1>
     * TRS_OUT: output type e.g. typedef ap_fixed<16, 2, AP_RND>
 * NOTE: If output range is unknown, TRS_OUT is worth having a overflow mode (e.g. AP_SAT) for better accuracy
 */

template <typename TRS_IN, typename TRS_COEFF, typename TRS_OUT, unsigned num_coeff>
TRS_OUT fir_filter(TRS_IN const in, TRS_COEFF half_coeff[num_coeff/2+1])
{
  typedef ap_fixed<TRS_IN::width + TRS_COEFF::width, TRS_IN::iwidth + TRS_COEFF::iwidth - 1> TTMP_MULTI;
  typedef ap_fixed<TTMP_MULTI::width + utils::ceil_log2(num_coeff-1), TTMP_MULTI::iwidth + utils::ceil_log2(num_coeff-1)> TTMP_ACC;

  TRS_OUT out;
  static TRS_IN  stored_in[num_coeff];

  STORE_LOOP:for (int n=num_coeff-1; n>0; n--) {
    stored_in[n] = stored_in[n-1];
  }
  stored_in[0] = in;

  TTMP_ACC acc = 0;

  ACC_LOOP:for ( unsigned int inc=0, dec=num_coeff-1; // HLS tool can adjust the data type for the counters
    inc<num_coeff/2;
    inc++, dec--
  ) {
    acc += (stored_in[inc] + stored_in[dec]) * half_coeff[inc];
  }

  if (num_coeff%2 != 0) {
    acc += stored_in[num_coeff/2] * half_coeff[num_coeff/2];
  }

  out = acc;
  return out;
}

#endif 
