#include <iostream>
#include "utils.h"
int main(void){
	auto v = matread("testdata.bin");
	for(int i=0;i<v.size();i++){
		for(int j=0;j<v[i].size();j++)
			cout<<v[i][j]<<" ";
		cout<<endl;
	}
	cout << v[0].size() << endl;

	std::vector<double> vec = {1,2,3};
	matwrite_double("test_matwrite.bin", vec);
}

