clear all
clc
close all
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


sig = randn(1,500);

sig_delayed0 = sig;              
sig_delayed1 = [zeros(1,1), sig];
sig_delayed2 = [zeros(1,2), sig];
sig_delayed3 = [zeros(1,3), sig];
sig_delayed4 = [zeros(1,4), sig];

sig_delayed_dwsmped0 = downsample(sig_delayed0, 5);
sig_delayed_dwsmped1 = downsample(sig_delayed1, 5);
sig_delayed_dwsmped2 = downsample(sig_delayed2, 5);
sig_delayed_dwsmped3 = downsample(sig_delayed3, 5);
sig_delayed_dwsmped4 = downsample(sig_delayed4, 5);

E0 = downsample(fir_coe, 5);
E1 = downsample(fir_coe, 5, 1);
E2 = downsample(fir_coe, 5, 2);
E3 = downsample(fir_coe, 5, 3);
E4 = downsample(fir_coe, 5, 4);

E0M = upsample(downsample(fir_coe, 5)   , 5);
E1M = upsample(downsample(fir_coe, 5, 1), 5);
E2M = upsample(downsample(fir_coe, 5, 2), 5);
E3M = upsample(downsample(fir_coe, 5, 3), 5);
E4M = upsample(downsample(fir_coe, 5, 4), 5);

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
X0 = downsample(X0, 5);
X1 = downsample(X1, 5);
X2 = downsample(X2, 5);
X3 = downsample(X3, 5);
X4 = downsample(X4, 5);
len = smallest_length({X0, X1, X2, X3, X4});
y = X0(1:len) + X1(1:len) + X2(1:len) + X3(1:len) + X4(1:len);
y1 = downsample(y1, 5);
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