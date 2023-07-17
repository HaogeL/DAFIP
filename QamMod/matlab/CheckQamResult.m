function CheckQamResult(M, normalized)

%% load Vitis Csimulation data
bits_per_symb = log2(M);
addpath('../../utils');
if(normalized == 0)
    mod_format_instr = ['QamMod', num2str(M)];
else
    mod_format_instr = ['QamMod', num2str(M),'_normalized'];
end
currentPath = fileparts(mfilename('fullpath'));
filePath = [currentPath, '/../vitis_hls/',mod_format_instr,'/solution/csim/build/', mod_format_instr, '_real.bin'];
qam_real = readFromC(filePath);

filePath = [currentPath, '/../vitis_hls/',mod_format_instr,'/solution/csim/build/', mod_format_instr, '_imag.bin'];
qam_imag = readFromC(filePath);

filePath = [currentPath, '/../vitis_hls/',mod_format_instr,'/solution/csim/build/', mod_format_instr, '_binary.bin'];
binary = readFromC(filePath);

cstl = complex(qam_real, qam_imag);
figure(1)
clf
plot(cstl, '*');
if(normalized == 0)
    xlim([-2^(bits_per_symb/2), 2^(bits_per_symb/2)]);
    ylim([-2^(bits_per_symb/2), 2^(bits_per_symb/2)]);
else
    xlim([-1.3, 1.8]);
    ylim([-1.3, 1.3]);
end
axis square;
grid minor;
text(qam_real+0.1, qam_imag+0.1, num2str(binary));
text(qam_real+0.1, qam_imag-0.15, ...
    [char(zeros(size(qam_imag)) + '('), ...
    num2str(qam_real), char(zeros(size(qam_imag)) + ','), ...
    num2str(qam_imag), char(zeros(size(qam_imag)) + ')')]);
xlabel('real');
ylabel('imag');

if(normalized == 1)
    fprintf(['For normolized', num2str(M), 'QAM\n']);
    fprintf("average power of HLS QAM output is %16.15f\n", mean(abs(cstl) .^ 2));
    index_col = sqrt(M)-1 - [0:1:sqrt(M)-1];
    int_index = [];
    for(i=0:sqrt(M)-1)
        int_index = [int_index, index_col];
        index_col = index_col + sqrt(M);
    end
    y = qammod(int_index, M, 'bin', 'UnitAveragePower',true);
    ideal_avg_power = mean(abs(y) .^ 2);
    fprintf("average power of ideal QAM output is %16.15f\n", ideal_avg_power);
    diff_err = y - cstl.';
    mse = mean(abs(diff_err) .^ 2);
    mse_db = 10*log10(mse);
    fprintf("quantization mse %20.18f db\n", mse_db);
    
    figure(2)
    clf;
    plot(y, 'o');
    hold on
    plot(cstl, '*');
    legend("ideal QAM constellation", "HLS QAM constellation")
end
end

