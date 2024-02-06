clear all
close all
clc

x_real = [-1.5 3 5 10];
x_imag = x_real + 1;
x = complex(x_real, x_imag);
y_real = sin(real(x));
y_imag = sin(imag(x));
y = complex(y_real, y_imag);
y(2:4) = complex(0);
xx_real = x_real(1):.25:x_real(end);
yy_real = spline(x_real,real(y),xx_real);
yy_imag = spline(x_real,imag(y),xx_real);

figure(1)
clf
plot(x_real,real(y),'o',xx_real, yy_real)
hold on

figure(2)
clf
plot(x_real,imag(y),'o',xx_real, yy_imag)
hold on

test_x = 0:0.1:1;
test_y = cubicLagrangeInterpolation(y,test_x);
figure(1)
plot(linspace(real(x(2)), real(x(3)), length(test_x)), real(test_y), '*')
figure(2)
plot(linspace(real(x(2)), real(x(3)), length(test_x)), imag(test_y), '*')

test_x = 1:0.01:2;
test_y = cubicLagrangeInterpolation(y,test_x);
figure(1)
plot(linspace(real(x(3)), real(x(4)), length(test_x)), real(test_y), '*')
figure(2)
plot(linspace(real(x(3)), real(x(4)), length(test_x)), imag(test_y), '*')