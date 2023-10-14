#pragma once

#include <ap_fixed.h>

const unsigned int NUM_COEFF = 53;
const unsigned int DN_RATE = 5;

// depends on practical application, addjust the following datatype
typedef ap_fixed<20, 2> TSF_SIG_IN; // datatype for input signal
typedef ap_fixed<20, 2, AP_RND, AP_SAT> TSF_SIG_OUT; // datatype for output signal
typedef ap_fixed<20, -1> TSF_SIG_COE; // datatype for fir coefficients

// import coeff
const static TSF_SIG_COE coeff[NUM_COEFF] = {
#include "../matlab/fir.coeff"
};

void polyphase_fir_dnsample5(TSF_SIG_IN sig_in, TSF_SIG_OUT &sig_out);