clear all;
clc;
close all;

addpath('../../utils');

run("dut_parameters.m");

[stimuli, ref_output] = runIdealFIIR(b, a, [-1, 1], 1, hls_width, hls_iwidth, number_testdata, 1, ...
                        '../testData/testdata.bin', 'sin');

fig = figure;
plot(stimuli(1:10000), '.--')
hold on
plot(ref_output(1:10000), '*')
h=legend("input samples", "filtered samples");
set(h,'FontSize',12);
exportgraphics(fig, 'output.png');