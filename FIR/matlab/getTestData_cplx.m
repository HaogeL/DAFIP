addpath('../../utils');

rf = 0.3;
span = 30;
sps = 2;
h1 = rcosdesign(rf,span,sps,"sqrt");

fileID = fopen('../testData/coeff_rrc_cplx.coe','w');
for i = 1:ceil(length(h1)/2)-1
    fprintf(fileID, "std::complex<double>(%1.10f, %1.10f),\n", real(h1(i)), imag(h1(i)));
end
fprintf(fileID, "std::complex<double>(%1.10f, %1.10f)\n", real(h1(i+1)), imag(h1(i+1)));
fclose(fileID);

x_r = randi([-2e5, 2e5-1], 10240, 1) ./ 1e5;
x_i = randi([-2e5, 2e5-1], 10240, 1) ./ 1e5;
x = complex(x_r, x_i);

y = filter(h1, 1, x);

writeToC([real(x), imag(x), real(y), imag(y)], '../testData/testdata_cplx.bin');