#include "fir_rcc.h"
#include "../../utils/utils.h"
#include "fir.h"

TRS_COEFF half_coeff[num_coeff/2 + 1] = {
#include "../testData/coeff_rrc.coe"
};

void fir_rrc(TRS_IN in, TRS_OUT & out)
{
  out = fir_filter<TRS_IN, TRS_COEFF, TRS_OUT, num_coeff>(in, half_coeff); 
}
