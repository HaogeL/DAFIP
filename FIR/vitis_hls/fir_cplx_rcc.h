#pragma once
#include <ap_fixed.h>
#include <complex>

const unsigned num_coeff = 61;
typedef std::complex<ap_fixed<16, 2>> TCS_IN;
typedef std::complex<ap_fixed<16, 1>> TCS_COEFF; 
typedef std::complex<ap_fixed<18, 3>> TCS_OUT;

void fir_cplx_rrc(TCS_IN in, TCS_OUT & out);