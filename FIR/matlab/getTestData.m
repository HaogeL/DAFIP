addpath('../../utils');

rf = 0.3;
span = 30;
sps = 2;
h1 = rcosdesign(rf,span,sps,"sqrt");

fileID = fopen('../testData/coeff_rrc.coe','w');
for i = 1:ceil(length(h1)/2)-1
    fprintf(fileID, "%1.10f, ", h1(i));
end
fprintf(fileID, "%1.10f", h1(ceil(length(h1)/2)));
fclose(fileID);

x = randi([-2e5, 2e5-1], 10240, 1) ./ 1e5;

y = filter(h1, 1, x);

writeToC([x, y], '../testData/testdata.bin');