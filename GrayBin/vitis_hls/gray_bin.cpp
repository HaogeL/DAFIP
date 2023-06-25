#include "gray_bin.h"
#include <ap_int.h>
using namespace current_hls;

void bin2gray_hls(const DATA_T in, DATA_T &out){
	out = gray_bin::bin2gray(in);
}

//bad timing violation if the following requirements are desired.
void gray2bin_hls (const DATA_T in, DATA_T &out){
#pragma HLS PIPELINE II=1
#pragma HLS LATENCY max=1
	out = gray_bin::gray2bin(in);
}

void gray2bin_paral_hls (const DATA_T in, DATA_T &out){
#pragma HLS PIPELINE II=1
#pragma HLS LATENCY max=1
	out = gray_bin::gray2bin_paral(in);
}


