clear all
close all
clc
rng('default')
L        = 16;         % Oversampling factor
rollOff  = 0.2;       % Pulse shaping roll-off factor
rcDelay  = 10;        % Raised cosine delay in symbols
M = 64;
num_of_samples = 10000;
en_plot = 1;

x = randi([0 M-1],num_of_samples,1);
timeOffset = 3; % Delay (in samples) added

% Filter:
htx = rcosdesign(rollOff,rcDelay,L,'sqrt');
% Note half of the target delay is used, because when combined
% to the matched filter, the total delay will be achieved.
hrx  = conj(fliplr(htx));

%% tx
symb = qammod(x,M,'UnitAveragePower', true);
symb_upsampled = upsample(symb, L);
avgPower = mean(abs(symb).^2);
avgPower_upsampled = mean(abs(symb_upsampled).^2);
%pulse shaping
tx = filter(htx, 1, symb_upsampled);
%% channel
% only consider delay
% Delayed sequence
rx = [zeros(timeOffset, 1); tx(1:end-timeOffset)];

mfOut = filter(hrx, 1, rx);
mfOut_no_ch_delay = filter(hrx, 1, tx);

if(en_plot == 1) 
    clf
    plot(real(mfOut), '*');
    hold on;
    plot(real(mfOut_no_ch_delay), 'o')
    plot(real(mfOut(1+timeOffset:end)), 'x'); % mfOut without channel delay is equal to shift mfOut with timeOffset samples
    legend("delayed\_mfOut", "mfOut without channel delay", "shifted delayed\_mfOut");

    figure(2)
    clf
    mfOut_no_ch_delay_no_filter_delay = mfOut_no_ch_delay(ceil(length(hrx)/2)*2-1:end);
    plot(real(downsample(mfOut_no_ch_delay_no_filter_delay, L)), '*')
    hold on
    plot(real(symb), 'o')
    legend("mfOut without channel delay", "original symbols");
end

%% Symbol Timing Recovery
% Downsampled symbols without symbol timing recovery
rxNoSync = downsample(mfOut, L);
% Downsampled symbols with perfect symbol timing recovery
%mfOut = mfOut(1+timeOffset+length(htx):end);
rxPerfectSync = downsample(mfOut(1+timeOffset:end), L);

if(en_plot == 1)
    figure(3)
    clf
    stem(1:1:length(mfOut), real(mfOut), 'x');
    hold on
    % stem(upsample(real(rxNoSync), L), '*', 'linewidth', 2);
    plot(1:L:length(real(rxNoSync))*L, real(rxNoSync), '*', 'linewidth', 2);
    % stem([zeros(floor(length(hrx)/2)*2 + timeOffset,1);real(symb_upsampled)], 'linewidth', 2);
    plot(timeOffset + ceil(length(hrx)/2)*2-1 : L: timeOffset + ceil(length(hrx)/2)*2-1 + length(real(symb))*L -1, real(symb), 'o', 'linewidth', 2);
%     legend("mfOut samples", "symbols are actually taken", "correct symbols to be sampled")

    figure(4)
    clf
    stem(real(rxNoSync), '+')
    hold on
    stem(real(rxPerfectSync), '*')
    stem([zeros(floor(length(hrx)/2)*2/L, 1);real(symb)], 'o')
%     legend("rx symbols without sync", "rx symbols with perfect sync", "delayed original symbols")
end
%% pre-filter
t = -30:1:30;
pt = rollOff / 4 * sin(rollOff*pi.*t/L) / rollOff / pi ./t * L .* cos(pi * t / L) ./ (1-(rollOff*t/L) .^ 2);
%% Gardner
g = gardner(1, 1/100, L, 1, -1);
timing_error=[];
number_valid_synced_sample = 0;
synced_sample_index = [];
synced_samples = [];
base_samples = [];
loopFilterOutputs = [];
for i=1:1:length(mfOut)
%     current_sample = inter.run(rxNoSync(i), 0);
    tic
    [sample_valid, uk, base_sample, synced_sample, loopFilterOutput] = g.run(mfOut(i));
    if sample_valid
        number_valid_synced_sample = number_valid_synced_sample + 1;
        timing_error = [timing_error, uk];
        synced_sample_index = [synced_sample_index, i-2];
        synced_samples = [synced_samples, synced_sample];
        base_samples = [base_samples, base_sample];
%         if(number_valid_synced_sample == 10)
%             sprintf("check");
%         end
%         figure(3)
%         hold on;
%         plot(i-2, real(synced_sample), "^", "MarkerSize", 15);
        loopFilterOutputs = [loopFilterOutputs, loopFilterOutput];
    end
    T(i) = toc;
end

figure(3)
hold on
plot(synced_sample_index, real(synced_samples), "^", "MarkerSize", 12);
figure(5)
subplot(2,1,1)
plot(synced_sample_index, timing_error, ".")
subplot(2,1,2)
plot(synced_sample_index, loopFilterOutputs, ".")
%% measure the performance
% mse of unsynchronized symbols
received_sig = synced_samples(floor(end/2):ceil(end*0.75));
figure(6)
plot(received_sig, '*');
received_data = qamdemod(received_sig, M, 'UnitAveragePower', true);
ref_sig = qammod(received_data, M, 'UnitAveragePower', true);
mse_lin = mean(abs(received_sig - ref_sig) .^ 2);
mse_db = 10*log10(mse_lin);
fprintf("synchronized symbols mse %f\n", mse_db);

received_sig = rxNoSync(floor(end/2):ceil(end*0.75));
figure(6)
hold on
plot(received_sig, '.');
legend("synchronized symbols", "unsynchronized symbols")
received_data = qamdemod(received_sig, M, 'UnitAveragePower', true);
ref_sig = qammod(received_data, M, 'UnitAveragePower', true);
mse_lin = mean(abs(received_sig - ref_sig) .^ 2);
mse_db = 10*log10(mse_lin);
fprintf("non-synchronized smaples mse %f\n", mse_db);