#include <ap_fixed.h>
#include "polyphase_fir.h"
#include "polyphase_fir_dnsample5.h"


void polyphase_fir_dnsample5(TSF_SIG_IN sig_in, TSF_SIG_OUT &sig_out){
    static polyphase_fir_dn<TSF_SIG_IN, TSF_SIG_COE, TSF_SIG_OUT, NUM_COEFF, DN_RATE> local_polyphase_fir(coeff);
    sig_out = local_polyphase_fir.run_fir(sig_in);
}