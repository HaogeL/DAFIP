#ifndef POLYPHASE_FIR_H_
#define POLYPHASE_FIR_H_
#include <ap_fixed.h>
#include "utils.h"

template <typename TRS_IN, typename TRS_COEFF, typename TRS_OUT, unsigned int NUM_COEFF, unsigned int DW_RATE>
class polyphase_fir_dn{
    private:
        typedef ap_fixed<TRS_IN::width + TRS_COEFF::width, TRS_IN::iwidth + TRS_COEFF::iwidth> TTMP_MULTI;
        typedef ap_fixed<TTMP_MULTI::width + utils::ceil_log2(NUM_COEFF-1), TTMP_MULTI::iwidth + utils::ceil_log2(NUM_COEFF-1)> TTMP_ACC;
        typedef ap_uint<utils::ceil_log2(DW_RATE)> TUI_CNT;

        TRS_COEFF coeff[NUM_COEFF];
        TRS_IN  stored_in[NUM_COEFF];
        TUI_CNT cnt;
    public:
        ~polyphase_fir_dn(){}
        polyphase_fir_dn(const TRS_COEFF fir_coeff[NUM_COEFF]){
            // load fir coefficients
            for (int i=0; i < NUM_COEFF; i++){
                coeff[i] = fir_coeff[i];
            }
            reset();
        }

        void reset(){
            cnt = 0;
            for(int i = 0; i < NUM_COEFF; i++){
                stored_in[i] = 0.0;
            }
        }

        TRS_OUT run_fir(TRS_IN const in)
        {
          if (cnt == DW_RATE)
            cnt = 0;

    
          STORE_LOOP:for (int n=NUM_COEFF-1; n>0; n--) {
            stored_in[n] = stored_in[n-1];
          }
          stored_in[0] = in;
    
          TTMP_ACC acc = 0.0;
          if(cnt == 0){
            ACC_LOOP:for(int i = 0; i < NUM_COEFF; i++){
            	acc += coeff[i] * stored_in[i];
            }
          }

          // debug
          // double acc_double = 0.0;
          // if(cnt == 0){
          //   for(int i = 0; i < NUM_COEFF; i++){
          //   	acc_double += coeff[i].to_double() * stored_in[i].to_double();
          //   	printf("%f     %30.20f\n", coeff[i].to_double(), stored_in[i].to_double());
          //   }
          // }
          // debug
          cnt ++;
          TRS_OUT out = acc;

          return out;
        }
};
#endif
