clear all
close all
clc
rng('default')
L        = 16;         % Oversampling factor
rollOff  = 0.2;       % Pulse shaping roll-off factor
rcDelay  = 10;        % Raised cosine delay in symbols
M = 16;
num_of_samples = 100;
en_plot = 1;

x = randi([0 M-1],num_of_samples,1);
timeOffset = 0; % Delay (in samples) added

% Filter:
htx = rcosdesign(rollOff,rcDelay,L,'normal');
plot(htx, '*')
%% tx
symb = qammod(x,M,'UnitAveragePower', true);
symb_upsampled = upsample(symb, L);
zero_arr = zeros(size(symb_upsampled));
avgPower = mean(abs(symb).^2);
avgPower_upsampled = mean(abs(symb_upsampled).^2);
%pulse shaping
figure(1)
hold on
for i = 1:1:num_of_samples*L
    current_sample = zero_arr;
    current_sample(i) = symb_upsampled(i);
    val = conv(current_sample, htx);
    plot(real(val));
end
