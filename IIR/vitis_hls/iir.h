#ifndef _IIR_H
#define _IIR_H

#include <ap_fixed.h>
#include <cmath>
namespace current_hls{
	const int A = 3;
	typedef ap_fixed<16,2> DATA_T;
	const double err_lower = -std::pow(2, -18) * 8;
	const double err_upper = (std::pow(2,-20)+std::pow(2,-19)) * 8 + std::pow(2,-15) + std::pow(2,-16) + std::pow(2,-17);
}

void iir_hls(const current_hls::DATA_T in, current_hls::DATA_T &out);

namespace iir {
// DATA_t:
//   data type of input signal
// A:
//   decides the coefficients in the difference equation.
// Note:
//   Coefficients are in powers of 2, so that multiplication can be implemented
//   by shift operations.
template <int A, class DATA_T> 
class iir_first_order {
private:
  // Add one integer bit for margin in case DATA_T is unsigned.
  typedef ap_fixed<A + DATA_T::width, DATA_T::iwidth, AP_RND> INTERNAL_T;
  typedef ap_fixed<A + DATA_T::width + 1, DATA_T::iwidth> INTERNAL_EXT_T;
  INTERNAL_T y_reg_;

public:
  iir_first_order() : y_reg_(0) {}

  DATA_T filter1(DATA_T in) {
  // difference equation is Y[n] = a*X[n]-(a-1)*Y[n-1], where a = 2^(-A)
    //INTERNAL_EXT_T diff = (in - INTERNAL_EXT_T(y_reg_)) >> A;
    INTERNAL_T diff = (in - INTERNAL_EXT_T(y_reg_))>>A;
    y_reg_ = y_reg_ + diff; //mad_down_with_round(y_reg_, diff, A);
    return y_reg_;
  }
};
} // namespace iir
#endif
