#include "iir.h"
#include <ap_fixed.h>
using namespace current_hls;
void iir_hls(const DATA_T in, DATA_T &out){
	static iir::iir_first_order<A, DATA_T> iir_obj; // A = 3
	out = iir_obj.filter1(in);
}


