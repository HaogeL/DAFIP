#pragma once
#include <ap_fixed.h>

const unsigned num_coeff = 61;
typedef ap_fixed<16, 2> TRS_IN;
typedef ap_fixed<16, 1> TRS_COEFF; 
typedef ap_fixed<18, 3> TRS_OUT;

void fir_rrc(TRS_IN in, TRS_OUT & out);