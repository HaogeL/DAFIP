A = 3;
b = [2^(-A)];
a = [1, b(1)-1];
hls_width = 16;
hls_iwidth= 2;
signedness=1;

number_testdata = 100000;

err_th_low = -power(2,-18)*8*(1-power(7/8,1:1:number_testdata));
err_th_up = (power(2,-20)+power(2,-19))*8*(1-power(7/8,1:1:number_testdata)) + power(2,-15) + power(2,-16) + power(2,-17);