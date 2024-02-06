function out = cubicLagrangeInterpolation(input_vec, nNextSamples)
%input_vec(1): oldest sample
%input_vec(4): latest sample
%nNextSamples: percentage of sample period

% For example, cubicLagrangeInterpolation([A0, A1, A2, A3], 0.1) returns
% interpolant at time of A1 + 0.1(A2-A1)
% cubicLagrangeInterpolation([A0, A1, A2, A3], 1) returns interpolant at
% time of A2, which has the same value as A2
% cubicLagrangeInterpolation([A0, A1, A2, A3], 1.5) returns interpolant at
% time of A2 + 0.5(A3-A2)
% cubicLagrangeInterpolation([A0, A1, A2, A3], 2) returns interpolant at
% time of A3, which has the same value as A3

samples = zeros(1, 4);
for i=1:1:length(input_vec)
    samples(i) = input_vec(i);
end

param1 = [-1/6;0.5;-0.5;1/6];

param2 = [0.5;-1;0.5;0];

param3 = [-1/3;-1/2;1;-1/6];

param4 = [0;1;0;0];
out = samples*param1*(nNextSamples.^3) + samples*param2*(nNextSamples.^2) + samples*param3*nNextSamples + samples*param4;

end

