#ifndef _QAMMOD_H
#define _QAMMOD_H

#include "../../utils/utils.h"
#include "ap_fixed.h"
#include "ap_int.h"
namespace qam_mod {
/*
bits per symbol   modulation format (M)
2                 4
<<<<<<< HEAD
4                 16
6                 64
8                 256
10                1k
12                4k
*/

/*
Qam mode is determined by template [num_bits_symb]. template [DATA_CSTLT_C] should be aligned with [num_bits_symb]
16 Qam is provide below as an example
  #define NUMBITSPERSYMB 4
  #include "ap_int.h"
  typedef ap_uint<NUMBITSPERSYMB> BITS_T;
  typedef std::complex<ap_int<NUMBITSPERSYMB/2+1>> CSTL_T;
  void QamMod16(const BITS_T bits, CSTL_T& constellation);
=======
4				  16
6				  64
8				  256
10                1k
12				  4k
>>>>>>> baccee830ebdb5ed5f3d7aa3bc40286e12a7b1b2
*/
template <class DATA_CSTLT_C, unsigned int num_bits_symb>
DATA_CSTLT_C QamMod_fixed(ap_uint<num_bits_symb> bits) {
  constexpr unsigned int halfBitsPerSymb = num_bits_symb / 2;
  constexpr unsigned int shift = utils::int_pow(2, halfBitsPerSymb) - 1;
  ap_uint<halfBitsPerSymb> shift_distance(shift);
  ap_uint<halfBitsPerSymb + 1> imag = bits.range(halfBitsPerSymb - 1, 0);
  ap_uint<halfBitsPerSymb + 1> real =
      bits.range(num_bits_symb - 1, halfBitsPerSymb); 
  /* the following cast looks strange, but it avoids unnecessary calculation
  For example: for 64 QAM, [halfBitsPerSymb] is 3, [real] and [imag] are 4-bit uint
  Given [bits] is [0-63], [real] and [image] can have 2^3 different values, [0-7].
  real << 1 and imag << 1 produce value [0, 2, 4, ..., 14], [shift_distance] is 7.
  Then [cord_real] and [cord_imag] are [-7, -5, ..., -1, 1, ... 7] accordingly
  */
  ap_int<halfBitsPerSymb + 1> cord_real = (real << 1) - shift_distance;
  ap_int<halfBitsPerSymb + 1> cord_imag = (imag << 1) - shift_distance;
  // so far the average power is (M-1)*(d^2)/6, where M is modulation formation,
  // d is 2. Needs to use shrink_ratio to generate unit power constellation, but unfortunately
  // C++ doesn't support constexpr of sqrt, which needs to be pre-calculated and hard
  // coded

  // constexpr double shrink_ratio = std::sqrt(6/(M-1)/d^2);
  DATA_CSTLT_C cstlt = DATA_CSTLT_C(cord_real, cord_imag);
  return cstlt;
  /*
  ap_uint<7> real = bits.range(5, 0);
  ap_uint<7> imag = bits.range(11, 6);

  double_real = real << 2;
  double_imag = imag << 2;
  */
};
<<<<<<< HEAD


template <class DATA_CSTLT_C, unsigned int num_bits_symb>
ap_uint<num_bits_symb> DeQamMod_fixed(DATA_CSTLT_C cstlt) {
  constexpr unsigned int halfBitsPerSymb = num_bits_symb / 2;
  constexpr unsigned int shift = utils::int_pow(2, halfBitsPerSymb) - 1;
  ap_uint<halfBitsPerSymb> shift_distance(shift);
  ap_int<halfBitsPerSymb + 1> cord_real = cstlt.real() + shift_distance;
  ap_int<halfBitsPerSymb + 1> cord_imag = cstlt.imag() + shift_distance;
  cord_real = cord_real >> 1;
  cord_imag = cord_imag >> 1;
  ap_uint<num_bits_symb> ret = (cord_real.range(halfBitsPerSymb-1, 0), cord_imag.range(halfBitsPerSymb-1, 0));
  return  ret;
};

=======
>>>>>>> baccee830ebdb5ed5f3d7aa3bc40286e12a7b1b2
} // end namespace qam_mod
#endif