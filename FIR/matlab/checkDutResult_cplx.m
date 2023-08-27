clear all;
clc
addpath('../../utils');

% get stimulus and reference output
fileID = fopen('../vitis_hls/proj_cplx/solution/csim/build/testdata_cplx.bin','r');
if fileID<0
    error("need to run Vitis C simulation to get DUT output first.\n");
end
rows = fread(fileID, 1, 'uint32');
cols = fread(fileID, 1, 'uint32');
trash= fread(fileID, 1, 'double');
testdata = fread(fileID,[rows,cols],'double');
fclose(fileID);
in = complex(testdata(:,1), testdata(:,2));
reference_output_real = testdata(:, 3);
reference_output_imag = testdata(:, 4);

% get Vitis C-sim DUT output
output_from_dut_real = readFromC("../vitis_hls/proj_cplx/solution/csim/build/dut_output_real.bin");
output_from_dut_imag = readFromC("../vitis_hls/proj_cplx/solution/csim/build/dut_output_imag.bin");
% plot
figure(1)
clf;
plot(reference_output_real(1:256), 'o');
hold on;
plot(output_from_dut_real(1:256), '*');
legend('Matlab ideal model output of real part', 'DUT model output of real part')

figure(2)
clf;
plot(reference_output_imag(1:256), 'o');
hold on;
plot(output_from_dut_imag(1:256), '*');
legend('Matlab ideal model output of imag part', 'DUT model output of imag part')

% check quantization error
diff_real_lin = mean((output_from_dut_real - reference_output_real).^2)
diff_real_log = 10*log10(abs(diff_real_lin))
diff_imag_lin = mean((output_from_dut_imag - reference_output_imag).^2)
diff_imag_log = 10*log10(abs(diff_imag_lin))