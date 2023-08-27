clear all;
clc
addpath('../../utils');

% get stimulus and reference output
fileID = fopen('../vitis_hls/proj/solution/csim/build/testdata.bin','r');
if fileID<0
    error("need to run Vitis C simulation to get DUT output first.\n");
end
rows = fread(fileID, 1, 'uint32');
cols = fread(fileID, 1, 'uint32');
trash= fread(fileID, 1, 'double');
testdata = fread(fileID,[rows,cols],'double');
fclose(fileID);
in = testdata(:,1);
reference_output = testdata(:,2);

% get Vitis C-sim DUT output
output_from_dut = readFromC("../vitis_hls/proj/solution/csim/build/dut_output.bin");

% plot
figure(1)
clf;
plot(reference_output(1:128), 'o');
hold on;
plot(output_from_dut(1:128), '*');
legend('Matlab ideal model output', 'DUT model output')
% check quantization error
diff_lin = mean((output_from_dut - reference_output).^2)
diff_log = 10*log10(abs(diff_lin))