#ifndef _UTILS_H
#define _UTILS_H
#include <fstream>
#include <vector>

namespace utils{
using namespace std;

static vector<vector<double>> matread(const string& filename) {
	ifstream fs(filename, fstream::binary);
	// Header
	uint32_t rows, cols;
	uint64_t type_strings;
	fs.read((char*)&rows, 4);         // rows
	fs.read((char*)&cols, 4);         // cols
	fs.read((char*)&type_strings, 8); // data type in string
				
	//data
	vector<double> col_vector(rows);
	vector<vector<double>> ret(cols, col_vector);
	for (int i = 0; i < cols; i++){
		fs.read((char*)ret[i].data(), 8*rows);
	}
	fs.close();
	return ret;
}

static void matwrite_double(const string& filename, const vector<double> &vec){
	ofstream fs(filename, ios::out | ios::binary);
	fs.write((char*)vec.data(), vec.size()*8);
    fs.close();
}

//return floor(log2(n)) + 1
constexpr unsigned long log2_num_of_bits(unsigned long n){
	return ( (n<2) ? 1 : 1+log2_num_of_bits(n/2));
}

//return a^b (b>0)
constexpr long int_pow(int a, int b){
	return b==0? 1:int_pow(a, b-1)*a;
}

//return ceil(log2(n))
constexpr unsigned long ceil_log2(unsigned long n){
	unsigned int floorplus1 = log2_num_of_bits(n);
	return int_pow(2, floorplus1-1) == n ? floorplus1-1:floorplus1;
}
template<class T>
using base_type_t = typename T::value_type;
}//end namespace utils
#endif
