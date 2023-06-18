clear all;
clc;
close all;

addpath('../../utils');

run("dut_parameters.m");

[stimuli, ref_output] = runIdealFIIR(b, a, [-1, 1], signedness, hls_width, hls_iwidth, number_testdata, 1, ...
                        '../testData/testdata.bin', 'rand');
fig = figure;
plot(stimuli(1:10000), '.--')
hold on
plot(ref_output(1:10000), '*')
legend("input samples", "filtered samples")
%exportgraphics(fig, 'output.pdf', 'ContentType', 'vector');