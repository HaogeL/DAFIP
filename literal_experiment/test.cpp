#include <ap_fixed.h>

template<class T>
T incre_fun(T in, double val){// although this is declared as double, after synthesis,
	return in + T(val); //val will be directly converted to type T, and double datatype will not appear in HDL
}
void incre(ap_fixed<8,4> in, ap_fixed<8,4> & out){
#pragma HLS interface mode=ap_none port=in
#pragma HLS interface mode=ap_none port=out
#pragma HLS interface mode=ap_ctrl_none port=return
	out = incre_fun<ap_fixed<8,4>>(in, 1.75);
}
/*
void incre(ap_fixed<8,4> in, ap_fixed<8,4> & out){
#pragma HLS interface mode=ap_none port=in
#pragma HLS interface mode=ap_none port=out
#pragma HLS interface mode=ap_ctrl_none port=return
	constexpr double constval = 1.25;
	ap_fixed<8,4> val = constval;
	out = in + val;
}
*/
