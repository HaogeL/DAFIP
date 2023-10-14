clear all
clc
close all

% downsample rate is 5
% coeff length is 53
num_test_samples = 10000;
dnsample_rate = 5;
rng('default');
addpath('../../utils');
fir_coe =   [0.002309248706598785,
  0.014096933201830484,
  0.018828635769809997,
  0.026383352864746017,
  0.029521978086505696,
  0.027134360076108564,
  0.01856961538043785,
  0.005598205417752619,
  -0.008101003513074839,
  -0.017974338873989065,
  -0.020258649100198676,
  -0.013651315575190979,
  -0.00020833142072013895,
  0.014965417634094596,
  0.025336496823333887,
  0.025436882849386645,
  0.013318517015272946,
  -0.007998829315667597,
  -0.030803987586877572,
  -0.04485105849263438,
  -0.040775023377656615,
  -0.013618934982137157,
  0.03477631720424109,
  0.09551396923065877,
  0.1548091828592016,
  0.19794181683885592,
  0.21371186386237248,
  0.19794181683885592,
  0.1548091828592016,
  0.09551396923065877,
  0.03477631720424109,
  -0.013618934982137157,
  -0.040775023377656615,
  -0.04485105849263438,
  -0.030803987586877572,
  -0.007998829315667597,
  0.013318517015272946,
  0.025436882849386645,
  0.025336496823333887,
  0.014965417634094596,
  -0.00020833142072013895,
  -0.013651315575190979,
  -0.020258649100198676,
  -0.017974338873989065,
  -0.008101003513074839,
  0.005598205417752619,
  0.01856961538043785,
  0.027134360076108564,
  0.029521978086505696,
  0.026383352864746017,
  0.018828635769809997,
  0.014096933201830484,
  0.002309248706598785];
fileID = fopen('fir.coeff', 'w');
for i = fir_coe(1:end-1)
    fprintf(fileID, "%30.20f,\n", i);
end
fprintf(fileID, "%30.20f", fir_coe(end));
fclose(fileID);

sig = randn(1,num_test_samples);
%fit the signals to the range of ap_fixed<20, 2>
sig(sig > (2^19-1)/2^18) = [];
sig(sig < -2) = [];

%quantize the signals to ap_fixed<20, 2>;
sig = floor(sig * 2^18);
sig = sig/2^18;
writeToC(sig', 'testdata.bin');

sig_delayed0 = sig;              
sig_delayed1 = [zeros(1,1), sig];
sig_delayed2 = [zeros(1,2), sig];
sig_delayed3 = [zeros(1,3), sig];
sig_delayed4 = [zeros(1,4), sig];

sig_delayed_dwsmped0 = downsample(sig_delayed0, dnsample_rate);
sig_delayed_dwsmped1 = downsample(sig_delayed1, dnsample_rate);
sig_delayed_dwsmped2 = downsample(sig_delayed2, dnsample_rate);
sig_delayed_dwsmped3 = downsample(sig_delayed3, dnsample_rate);
sig_delayed_dwsmped4 = downsample(sig_delayed4, dnsample_rate);

E0 = downsample(fir_coe, dnsample_rate);
E1 = downsample(fir_coe, dnsample_rate, 1);
E2 = downsample(fir_coe, dnsample_rate, 2);
E3 = downsample(fir_coe, dnsample_rate, 3);
E4 = downsample(fir_coe, dnsample_rate, 4);

E0M = upsample(downsample(fir_coe, dnsample_rate)   , dnsample_rate);
E1M = upsample(downsample(fir_coe, dnsample_rate, 1), dnsample_rate);
E2M = upsample(downsample(fir_coe, dnsample_rate, 2), dnsample_rate);
E3M = upsample(downsample(fir_coe, dnsample_rate, 3), dnsample_rate);
E4M = upsample(downsample(fir_coe, dnsample_rate, 4), dnsample_rate);

X0 = conv(sig_delayed0, E0M);
X1 = conv(sig_delayed1, E1M);
X2 = conv(sig_delayed2, E2M);
X3 = conv(sig_delayed3, E3M);
X4 = conv(sig_delayed4, E4M);
len = smallest_length({X0, X1, X2, X3, X4});

y = X0(1:len) + X1(1:len) + X2(1:len) + X3(1:len) + X4(1:len); %polyphase filter output
y1 = conv(sig, fir_coe); %normal fir output
len = smallest_length({y , y1});
figure(1)
clf
plot(y(1:len), '*')
hold on;
plot(y1(1:len), 'o')
title("sig conv. fir\_coe v.s. sig conv. fir\_coe's polyphase form")

%% with downsample in polyphase filter
X0 = downsample(X0, dnsample_rate);
X1 = downsample(X1, dnsample_rate);
X2 = downsample(X2, dnsample_rate);
X3 = downsample(X3, dnsample_rate);
X4 = downsample(X4, dnsample_rate);
len = smallest_length({X0, X1, X2, X3, X4});
y = X0(1:len) + X1(1:len) + X2(1:len) + X3(1:len) + X4(1:len);
y1 = downsample(y1, dnsample_rate);
len = smallest_length({y , y1});
figure(2)
clf
plot(y(1:len), '*')
hold on;
plot(y1(1:len), 'o')
title("With downsample; sig conv. fir\_coe v.s. sig conv. fir\_coe's polyphase form")
%%
y2_0 = conv(sig_delayed_dwsmped0, E0);
y2_1 = conv(sig_delayed_dwsmped1, E1);
y2_2 = conv(sig_delayed_dwsmped2, E2);
y2_3 = conv(sig_delayed_dwsmped3, E3);
y2_4 = conv(sig_delayed_dwsmped4, E4);
len = smallest_length({y2_0, y2_1, y2_2, y2_3, y2_4});
y2 = y2_0(1:len) + y2_1(1:len) + y2_2(1:len) + y2_3(1:len) + y2_4(1:len);
len = smallest_length({y1, y2});
figure(3)
clf
plot(y2(1:len), '*')
hold on
plot(y1(1:len), 'o')
title("downsample sig first v.s. conv. fir\_coe first")
%% check with HLS simulation results
% run vitis_hls
system('cd ../vitis_hls && vitis_hls -f run_hls.tcl');
% get Vitis C-sim DUT output
output_from_dut = readFromC("../vitis_hls/proj/solution/csim/build/dut_output.bin");
%use downsample to remove all the zeros
output_from_dut = downsample(output_from_dut,dnsample_rate);
figure(4)
clf
plot(y1, 'o');
hold on
plot(output_from_dut, '*'); 
legend('Matlab golden output', 'HLS output')
%remove tail and calculate MSE of HLS result v.s. Matlab godlen output
output_from_dut_tmp = output_from_dut(1:num_test_samples/dnsample_rate/2)';
y1_tmp = y1(1:num_test_samples/dnsample_rate/2);
diff = output_from_dut_tmp - y1_tmp;
mse_lin = mean((diff.^2) ./ (y1_tmp.^2));
mse_log = 10*log10(mse_lin);