function r

b = 0
mr =1000
x_pos = 5
k_pos = 3
x_neg = -100
k_neg = 1

x = linspace(-10, 10, 100);
for i = 1 : numel(x)
    y(i) = b + mr * ...
        ((1 / (1 + exp(-k_pos * (x(i) - x_pos)))) + ...
        (1 / (1 + exp(k_neg * (x(i) - x_neg)))));
end


figure(1)
clf
plot(x,log10(y),'bo-')
ylim([0 3])
xlim([-10, 10])