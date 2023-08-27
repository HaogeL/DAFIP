#include "fir_cplx_rcc.h"
#include "../../utils/utils.h"
#include "fir.h"

TCS_COEFF half_coeff[num_coeff/2 + 1] = {
#include "../testData/coeff_rrc_cplx.coe"
};

void fir_cplx_rrc(TCS_IN in, TCS_OUT & out)
{
  out = fir_filter_complex<TCS_IN, TCS_COEFF, TCS_OUT, num_coeff>(in, half_coeff); 
}
