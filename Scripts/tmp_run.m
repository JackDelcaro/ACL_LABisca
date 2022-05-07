
clearvars;
clear tmp_fit;
clc;
close all;
set(0,'DefaultFigureWindowStyle','docked');

order = 3;

load('DataExample2');
time = (0:2e-3:2e-3*(length(X)-1))';
data = X';

%% COMPUTE RHO

% Add noise to points
data = data + 1e-5*rand(size(data));
time_short = time(1:end);
data_short = data(1:end);
coeffs = polynomial_fit(time_short,data_short,order,0.9);

powers = (length(coeffs)-1):-1:0;
center_idx = floor(length(time_short)/2);
time_tmp = time_short - time_short(center_idx);
% data_tmp = data_short - data_short(center_idx);
data_reconstr = (repmat(time_tmp, 1, length(coeffs)).^repmat(powers, length(data_short), 1))*coeffs;
data_reconstr = data_reconstr + data_short(center_idx);
figure;
plot(time_short, data_short); hold on; grid on;
plot(time_short, data_reconstr);

der_data = gradient(data_short, time_short);
approx_der = gradient(data_reconstr, time_short);
figure;
plot(time_short, der_data); hold on; grid on;
plot(time_short, approx_der);



