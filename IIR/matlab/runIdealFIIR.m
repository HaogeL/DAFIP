function [input_samples, y] = runIdealFIIR(b, a, input_range_lin, signedness, width, iwidth, n, plot_en, file_name, type)

%%input arguments
%difference equation of DUT is Y[n] = a*X[n]-(a-1)*Y[n-1], where a = 2^(-A)
%A = 3;
%b = [2^(-A)];
%a = [1, b(1)-1];
%input range in linear [-1, 1]
%input_range_lin = [-1, 1];
%number of input samples
%n = 10000;
%file_name: bin file path, storing test vector
%plot_en: plot switch
%type: stimuli type: rand or sin

%%parse input arguments
%generate sinc signal and add noise
switch type
    case 'sin'
        input_samples = sin((1:n)/100)' + randn(n, 1)*0.5;
    case 'rand'
        input_samples = randn(n, 1);
    otherwise
        error("unknown type");
end
%rescale to input_range_lin
input_samples = rescale(input_samples, input_range_lin(1), input_range_lin(2));
%quantize to fixed precision 
input_samples = quantizenumeric(input_samples, signedness, width, width-iwidth, 'floor', 'wrap');

%%run the filter
y = filter(b, a, input_samples);

if plot_en ==1
    plot(input_samples, '.--')
    hold on
    plot(y, '*')
    legend("input samples", "filtered samples")
end

writeToC([input_samples, y], file_name);
end




