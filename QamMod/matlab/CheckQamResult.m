function fail = CheckQamResult(M)

%% load Vitis Csimulation data
bits_per_symb = log2(M);
addpath('../../utils');
mod_format_instr = ['QamMod', num2str(M)];
currentPath = fileparts(mfilename('fullpath'));
filePath = [currentPath, '/../vitis_hls/',mod_format_instr,'/solution/csim/build/', mod_format_instr, '_real.bin'];
qam_real = readFromC(filePath);

filePath = [currentPath, '/../vitis_hls/',mod_format_instr,'/solution/csim/build/', mod_format_instr, '_imag.bin'];
qam_imag = readFromC(filePath);

filePath = [currentPath, '/../vitis_hls/',mod_format_instr,'/solution/csim/build/', mod_format_instr, '_binary.bin'];
binary = readFromC(filePath);

cstl = complex(qam_real, qam_imag);
plot(cstl, '*');
xlim([-2^(bits_per_symb/2), 2^(bits_per_symb/2)]);
ylim([-2^(bits_per_symb/2), 2^(bits_per_symb/2)]);
axis square;
grid minor;
text(qam_real+0.1, qam_imag+0.1, num2str(binary));
text(qam_real+0.1, qam_imag-0.15, ...
    [char(zeros(size(qam_imag)) + '('), ...
    num2str(qam_real), char(zeros(size(qam_imag)) + ','), ...
    num2str(qam_imag), char(zeros(size(qam_imag)) + ')')]);
xlabel('real');
ylabel('imag');
end

