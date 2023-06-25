//this testbench assume DATA_T is shorter than 64 bits

#include "gray_bin.h"
#include <random>
//generate NUMOFRUN random numbers to test
#define NUMOFRUN 1000000
using namespace current_hls;

template <class DATA_T>
DATA_T max_ap_uint(){
	return ((ap_uint<DATA_T::width+1>)1<<DATA_T::width)-1;
}

int main(){

	//It takes much time for the following for-loop to finish when DATA_T is longer than 20 bits, use rand instead
	/*
	ap_uint<DATA_T::width+1> bin;
	DATA_T gray;
	DATA_T bin_tmp;
	for (bin = 0; bin < ((ap_uint<DATA_T::width+1>)1<<DATA_T::width); bin++){
		bin2gray_hls(bin, gray);
		gray2bin_hls(gray, bin_tmp);
		printf("bin %x \t----> gray %x\n", bin.to_uint64(), gray.to_uint64());
		if(DATA_T(bin) != bin_tmp){
			printf("ERROR found at bin is %x; expected bin is %x\n", bin_tmp.to_uint64(), bin.to_uint64());
			return 1;
		}
	}
	*/
	unsigned long maxi_DATA_T = max_ap_uint<DATA_T>().to_uint();
	//using fixed seed, otherwise C post checking fails
	std::mt19937 gen(static_cast<long unsigned int>(123));

	//std::random_device rd;  // a seed source for the random number engine
	//std::mt19937 gen(rd());

	std::uniform_int_distribution<unsigned long> unirand(0, maxi_DATA_T);

	DATA_T bin;
	DATA_T gray;
	DATA_T bin_tmp1;
	DATA_T bin_tmp2;
	//test 1 million random number
	for (int i = 0; i<NUMOFRUN; i++){
		bin = unirand(gen);
		bin2gray_hls(bin, gray);
		gray2bin_hls(gray, bin_tmp1);

		printf("bin %x \t----> gray %x \t----> bin %x\n", bin.to_uint64(), gray.to_uint64(), bin_tmp1.to_uint64());
		if(DATA_T(bin) != bin_tmp1){
			printf("ERROR found: bin is %x; expected bin is %x\n", bin_tmp1.to_uint64(), bin.to_uint64());
			return 1;
		}

		gray2bin_paral_hls(gray, bin_tmp2);
		if(bin_tmp1 != bin_tmp2){
			printf("ERROR found: two bin_tmp are different\n bin_tmp1 is %x; bin_tmp2 is %x\n", bin_tmp1.to_uint64(), bin_tmp2.to_uint64());
			return 1;
		}
	}

	return 0;
}
