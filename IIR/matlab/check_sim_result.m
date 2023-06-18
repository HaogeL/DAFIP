clear all;
clc
run("dut_parameters.m");
addpath('../../utils');
hls_fwidth= hls_width-hls_iwidth;

res = power(2, -hls_fwidth);
shift=A;

%%
% for convenience, read stimuli and ref_output from hls proj csim
fileID = fopen('../vitis_hls/proj/solution/csim/build/testdata.bin','r');
rows = fread(fileID, 1, 'uint32');
cols = fread(fileID, 1, 'uint32');
trash= fread(fileID, 1, 'double');
testdata = fread(fileID,[rows,cols],'double');
fclose(fileID);
in = testdata(:,1);
%%
%read dut output
output_from_dut = readFromC("../vitis_hls/proj/solution/csim/build/dut_output.bin");
%%
%iir starts
% y_reg_quan=zeros(numel(in),1);
% y_reg_double=zeros(numel(in),1);
% diff_double=zeros(size(in));
% diff_quan = zeros(size(in));

% for i=1:numel(in)
%     if i==1
%         diff_double(i) = in(i);
%         diff_quan(i) = in(i);
%     else
%         diff_double(i) = in(i) - y_reg_double(i-1);
%         diff_quan(i) = in(i) - y_reg_quan(i-1);
%     end
%     if i == 1
%         y_reg_double(i) = diff_double(i)/power(2,shift);
%         y_reg_quan_tmp = power(2,-(hls_fwidth+1+A)); %extend 1 to the extend LSB
%     else
%         y_reg_double(i) = y_reg_double(i-1) + diff_double(i)/power(2,shift);
%         y_reg_quan_tmp = y_reg_quan(i-1) + power(2,-(hls_fwidth+1+A)); %extend 1 to the extend LSB
%     end
%     y_reg_quan_tmp = y_reg_quan_tmp + quantizenumeric(diff_quan(i) / power(2, shift), signedness, hls_width+A+1, hls_fwidth+A+1, 'floor', 'wrap');
%     y_reg_quan(i) = quantizenumeric(y_reg_quan_tmp, signedness, hls_width+A, hls_fwidth+A, 'floor', 'wrap');
% end
%%

quan_err = testdata(:,2) - output_from_dut;
plot(quan_err(1:end), '.', 'LineWidth', 2);
hold on;
plot(err_th_up(1:end), '.', 'LineWidth', 2);
plot(err_th_low(1:end), '.', 'LineWidth', 2);
legend('err between golden model and dut output','upper bound err', 'lower bound err')
check_res = bitand(quan_err >= err_th_low', quan_err <= err_th_up');
if sum(check_res) == numel(in)
    display("All dut outputs are verified")
else
    display("dut outputs are out of range")
end
