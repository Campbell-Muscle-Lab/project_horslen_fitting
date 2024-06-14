function tse

x = 0:100;

k = 1e3;
sigma = 10000;
L = 40;

for i = 1 : numel(x)
    y_lin(i) = k * x(i);
    y_exp(i) = sigma * (exp(x(i)/L)-1);
end

figure(2);
clf
hold on;
plot(x, y_lin, 'b-o');
plot(x, y_exp, 'r-s');

ylim([0 1e5])