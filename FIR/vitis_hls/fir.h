#ifndef FIR_FILTER_H_
#define FIR_FILTER_H_

#include <ap_fixed.h>
#include "../../utils/utils.h"
#include <complex>
/*
 * Normal fir filter for real input and output
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
  typedef ap_fixed<TRS_IN::width + TRS_COEFF::width, TRS_IN::iwidth + TRS_COEFF::iwidth> TTMP_MULTI;
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

/*
 * Normal fir filter for complex input and output
 * Half coeff as input.
 * Coeff has to be symmetric and complex as well.
 * If coeff is an odd number, the middle coeff has to be included as the last coeff in the input array
 * templates:
     * num_coeff: number of coeff
     * TCS_IN: input type e.g. typedef std::complex<ap_fixed<16, 2>>
     * TCS_COEFF: ceoff type e.g. typedef std::complex<ap_fixed<8,  1>>
     * TCS_OUT: output type e.g. typedef std::complex<ap_fixed<16, 2, AP_RND>>
 * NOTE: If output range is unknown, TCS_OUT is worth having a overflow mode (e.g. AP_SAT) for better accuracy
 */

template <typename TCS_IN, typename TCS_COEFF, typename TCS_OUT, unsigned num_coeff>
TCS_OUT fir_filter_complex(TCS_IN const in, TCS_COEFF half_coeff[num_coeff/2+1])
{
  typedef ap_fixed<TCS_IN::value_type::width + TCS_COEFF::value_type::width, TCS_IN::value_type::iwidth + TCS_COEFF::value_type::iwidth> TTMP_MULTI;
  typedef ap_fixed<TTMP_MULTI::width + utils::ceil_log2(num_coeff-1), TTMP_MULTI::iwidth + utils::ceil_log2(num_coeff-1)> TTMP_ACC;
  typedef std::complex<TTMP_ACC> TCTMP_ACC;
  typedef std::complex<ap_fixed<TCS_IN::value_type::width + 1, TCS_IN::value_type::iwidth + 1>> TCTMP_SUM;

  TCS_OUT out;
  static TCS_IN  stored_in[num_coeff];

  STORE_LOOP:for (int n=num_coeff-1; n>0; n--) {
    stored_in[n] = stored_in[n-1];
  }
  stored_in[0] = in;

  TCTMP_ACC acc = std::complex<double>(0, 0);

  ACC_LOOP:for ( unsigned int inc=0, dec=num_coeff-1; // HLS tool can adjust the data type for the counters
    inc<num_coeff/2;
    inc++, dec--
  ) {
	/*
	// vitis bug with complex addition?
    TCTMP_SUM sum = stored_in[inc] + stored_in[dec];
    double sum_real = sum.real().to_double();
    double sum_imag = sum.imag().to_double();
    double inc_real = stored_in[inc].real().to_double();
    double inc_imag = stored_in[inc].imag().to_double();
    double dec_real = stored_in[dec].real().to_double();
    double dec_imag = stored_in[dec].imag().to_double();
    */
    TCTMP_SUM sum = TCTMP_SUM(stored_in[inc].real() + stored_in[dec].real(),
    	                      stored_in[inc].imag() + stored_in[dec].imag());

    acc += TCTMP_ACC(sum.real()*half_coeff[inc].real() - sum.imag()*half_coeff[inc].imag(),
                     sum.imag()*half_coeff[inc].real() + sum.real()*half_coeff[inc].imag());
  }

  if (num_coeff%2 != 0) {
    acc += TCTMP_ACC(stored_in[num_coeff/2].real()*half_coeff[num_coeff/2].real() - stored_in[num_coeff/2].imag()*half_coeff[num_coeff/2].imag(),
                     stored_in[num_coeff/2].imag()*half_coeff[num_coeff/2].real() + stored_in[num_coeff/2].real()*half_coeff[num_coeff/2].imag());
  }

  out = acc;
  return out;
}
#endif 
