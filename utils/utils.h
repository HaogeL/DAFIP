#include <fstream>
#include <vector>

using namespace std;

vector<vector<double>> matread(const string& filename) {
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

void matwrite_double(const string& filename, const vector<double> &vec){
	ofstream fs(filename, ios::out | ios::binary);
  fs.write((char*)vec.data(), vec.size()*8);
}
