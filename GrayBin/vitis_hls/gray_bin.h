#ifndef _GRAYBIN_H
#define _GRAYBIN_H

#include <ap_int.h>
#include "../../utils/utils.h"


namespace current_hls{
	typedef ap_uint<32> DATA_T;
}

using namespace current_hls;
void bin2gray_hls(const DATA_T in, DATA_T &out);
void gray2bin_hls(const DATA_T in, DATA_T &out);
void gray2bin_paral_hls (const DATA_T in, DATA_T &out);


namespace gray_bin {
	
/*
constexpr int GETMSB (int n){
	int msb = 0;
    n = n / 2;
    while (n != 0) {
        n = n / 2;
        msb++;
    }
   	return (1 << msb);
}
*/

template <class DATA_T> 
DATA_T bin2gray(DATA_T bin) {
  DATA_T gray = bin ^ (bin >> 1);
  return gray;
}

template <class DATA_T> 
DATA_T gray2bin(DATA_T gray){
	constexpr unsigned char width = DATA_T::width;
	DATA_T bin;
	bool tmp = gray[width-1];
	bin[width-1] = tmp;
	for(int i=width-2; i>=0; i--){
		tmp = tmp ^ gray[i];
		bin[i] = tmp;
	}
	return bin;
}
/*
template <class DATA_T> 
DATA_T gray2bin_wiki(DATA_T gray){
	
    gray ^= gray >> 16;
    gray ^= gray >>  8;
    gray ^= gray >>  4;
    gray ^= gray >>  2;
    gray ^= gray >>  1;
    return gray;
}
*/
template <class DATA_T> 
DATA_T gray2bin_paral(DATA_T gray){
	/* test the correctness of constexpr
	constexpr int floorplus1_1 = utils::log2_num_of_bits(1);
	constexpr int floorplus1_2 = utils::log2_num_of_bits(2);
	constexpr int floorplus1_3 = utils::log2_num_of_bits(3);
	constexpr int floorplus1_4 = utils::log2_num_of_bits(4);
	constexpr int floorplus1_5 = utils::log2_num_of_bits(5);
	constexpr int floorplus1_6 = utils::log2_num_of_bits(6);
	constexpr int floorplus1_7 = utils::log2_num_of_bits(7);
	constexpr int floorplus1_8 = utils::log2_num_of_bits(8);
	constexpr int floorplus1_9 = utils::log2_num_of_bits(9);
	constexpr int floorplus1_10 = utils::log2_num_of_bits(10);
	constexpr int ceil_1 = utils::ceil_log2(1);
	constexpr int ceil_2 = utils::ceil_log2(2);
	constexpr int ceil_3 = utils::ceil_log2(3);
	constexpr int ceil_4 = utils::ceil_log2(4);
	constexpr int ceil_5 = utils::ceil_log2(5);
	constexpr int ceil_6 = utils::ceil_log2(6);
	constexpr int ceil_7 = utils::ceil_log2(7);
	constexpr int ceil_8 = utils::ceil_log2(8);
	constexpr int ceil_9 = utils::ceil_log2(9);
	constexpr int ceil_10 = utils::ceil_log2(10);
	*/
	constexpr int init_shift = utils::int_pow(2, utils::ceil_log2(DATA_T::width)-1);
	for(int shift = init_shift; shift>0; shift = shift/2)
		gray ^= gray >> shift;
    return gray;
}
} // namespace gray_bin
#endif
