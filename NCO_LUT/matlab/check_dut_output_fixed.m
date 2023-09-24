clear all;
clc
close all;
addpath('../../utils');

% generate phase as input to dut

%+infinate snr, because it hits exactally the phases that are used by generating sin table
%phase = 0:2^-9:8-2^-9; 

test_len = 512000;
phase = linspace(0, 8, test_len);

% write phase to bin file
writeToC(phase', '../testData/testdata.bin');
system('cd ../vitis_hls && vitis_hls -f run_hls_fixed.tcl');

% get Vitis C-sim DUT output
output_from_dut_real = readFromC("../vitis_hls/proj_fixed/solution/csim/build/dut_output_real.bin");
output_from_dut_imag = readFromC("../vitis_hls/proj_fixed/solution/csim/build/dut_output_imag.bin");
plot(output_from_dut_real, '.'); %cos
hold on;
plot(output_from_dut_imag, '.'); %sin

sin_ideal = sin(phase.*pi/2)';
cos_ideal = cos(phase.*pi/2)';

plot(cos_ideal, 'o');
plot(sin_ideal, 'o');

pow_err_sin = sum((sin_ideal - output_from_dut_imag).^2)/length(phase);

pow_err_cos = sum((cos_ideal - output_from_dut_real).^2)/length(phase);

pow_sin = sum(sin_ideal.^2)/length(phase);
pow_cos = sum(cos_ideal.^2)/length(phase);

snr_sin = 10*log10(pow_sin/pow_err_sin);
snr_cos = 10*log10(pow_cos/pow_err_cos);