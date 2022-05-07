
clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);
paths.mainfolder_path   = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path   = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder       = fullfile(string(paths.mainfolder_path), "Data");
paths.scripts_folder    = fullfile(string(paths.mainfolder_path), "Scripts");
paths.simulation_folder = fullfile(string(paths.mainfolder_path), "Simulation");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));

%% SETTINGS

run('graphics_options.m');
run('m0507_derivative_filter_tests_init.m');

%% PARLOOP

test_order = [1 2 3 4];
test_window = 10:10:500;
iteration_number = length(test_order)*length(test_window);
% Initialize the array of simulations
in_sim(iteration_number) = Simulink.SimulationInput;
for idx1 = 1:length(test_order)
    for idx2 = 1:length(test_window)
        % Need to populate the model name since we get any empty array by default
        in_sim(idx2+(idx1-1)*length(test_window)).ModelName = 's0506_polynomial_filter';
        PARAMS.polyfit.forgetting_factor = (10^-3)^(1/test_window(idx2));
        PARAMS.polyfit.center_idx = floor(test_window(idx2)/2);
        PARAMS.polyfit.time = (0:dt_control:(test_window(idx2)-1)*dt_control)';
        PARAMS.polyfit.time = PARAMS.polyfit.time - PARAMS.polyfit.time(PARAMS.polyfit.center_idx);
        PARAMS.polyfit.powers = test_order(idx1):-1:0;
        for j = 1:(test_order(idx1)+1)
            R(:, j) = (PARAMS.polyfit.time.^(test_order(idx1) - j + 1)) .* (PARAMS.polyfit.forgetting_factor.^((length(PARAMS.polyfit.time)-1):-1:0)');
        end
        PARAMS.polyfit.pinvR = pinv(R);
        clearvars R;
        in_sim(idx2+(idx1-1)*length(test_window)) = in_sim(idx2+(idx1-1)*length(test_window)).setVariable('PARAMS.polyfit.order', test_order(idx1));
        in_sim(idx2+(idx1-1)*length(test_window)) = in_sim(idx2+(idx1-1)*length(test_window)).setVariable('PARAMS.polyfit.window', test_window(idx2));
        in_sim(idx2+(idx1-1)*length(test_window)) = in_sim(idx2+(idx1-1)*length(test_window)).setVariable('PARAMS.polyfit.forgetting_factor', PARAMS.polyfit.forgetting_factor);
        in_sim(idx2+(idx1-1)*length(test_window)) = in_sim(idx2+(idx1-1)*length(test_window)).setVariable('PARAMS.polyfit.center_idx', PARAMS.polyfit.center_idx);
        in_sim(idx2+(idx1-1)*length(test_window)) = in_sim(idx2+(idx1-1)*length(test_window)).setVariable('PARAMS.polyfit.powers', PARAMS.polyfit.powers);
        in_sim(idx2+(idx1-1)*length(test_window)) = in_sim(idx2+(idx1-1)*length(test_window)).setVariable('PARAMS.polyfit.pinvR', PARAMS.polyfit.pinvR);
        in_sim(idx2+(idx1-1)*length(test_window)) = in_sim(idx2+(idx1-1)*length(test_window)).setPreSimFcn(@(x) derivative_filter_presimfcn(x));
    end
end

tic;
parsim_out = parsim(in_sim, 'ShowProgress', 'on', ...
    'SetupFcn', @() derivative_filter_setup_fcn(fullfile(paths.scripts_folder, "m0507_derivative_filter_tests_init.m")));
elapsed_time = toc;

%% DATA ANALYSIS

rms_alpha = nan(length(test_order), length(test_window));
rms_der_alpha = nan(length(test_order), length(test_window));
rms_theta = nan(length(test_order), length(test_window));
rms_der_theta = nan(length(test_order), length(test_window));

for idx1 = 1:length(test_order)
    for idx2 = 1:length(test_window)
        
        i = idx2+(idx1-1)*length(test_window);
        poly_alpha = interp1(parsim_out(i).poly_alpha.Time, parsim_out(i).poly_alpha.Data, dataset.time, 'linear', 'extrap');
        poly_der_alpha = interp1(parsim_out(i).poly_der_alpha.Time, parsim_out(i).poly_der_alpha.Data, dataset.time, 'linear', 'extrap');
        poly_theta = interp1(parsim_out(i).poly_theta.Time, parsim_out(i).poly_theta.Data, dataset.time, 'linear', 'extrap');
        poly_der_theta = interp1(parsim_out(i).poly_der_theta.Time, parsim_out(i).poly_der_theta.Data, dataset.time, 'linear', 'extrap');
        indexes = dataset.time > 0.5;
        rms_alpha(idx1, idx2) = sqrt(mean((poly_alpha(indexes) - dataset.alpha(indexes)).^2));
        rms_der_alpha(idx1, idx2) = sqrt(mean((poly_der_alpha(indexes) - dataset.alpha_dot(indexes)).^2));
        rms_theta(idx1, idx2) = sqrt(mean((poly_theta(indexes) - dataset.theta(indexes)).^2));
        rms_der_theta(idx1, idx2) = sqrt(mean((poly_der_theta(indexes) - dataset.theta_dot(indexes)).^2));
        
    end
end

%% COST FUNCTION

weight.theta = 0;
weight.theta_der = 1;
weight.alpha = 0;
weight.alpha_der = 1;

cost = rms_alpha*weight.alpha + rms_der_alpha*weight.alpha_der + ...
       rms_theta*weight.theta + rms_der_theta*weight.theta_der;

weights_labels = string(fields(weight));
weights_tot_label = "";
for i = 1:length(weights_labels)
    weights_tot_label = weights_tot_label + strrep(weights_labels(i), '_', '\_') + ": " + num2str(weight.(weights_labels(i)));
    if i ~= length(weights_labels)
        weights_tot_label = weights_tot_label + ", ";
    end 
end
figure;
for i = 1:length(test_order)
    plot(test_window, cost(i,:)); hold on; grid on;
end
legend('First Order', 'Second Order', 'Third Order', 'Fourth Order');
% ylim([0.46 0.51]);
xlabel('Window Length');
ylabel('Cost');
title(weights_tot_label);

%% PLOTS

num_plots = [];
for i = 1:length(num_plots)
    figure;
    sgtitle("Simulation Results");

    sub(1) = subplot(2,1,1);
    plot(dataset.time, dataset.theta*180/pi, 'DisplayName', 'Measured'); hold on; grid on;
    plot(parsim_out(i).poly_theta.Time, parsim_out(i).poly_theta.Data*180/pi, 'DisplayName', 'Filtered Signal');
    legend;
    ylabel('$\theta\;[deg]$');

    sub(2) = subplot(2,1,2);
    plot(dataset.time, dataset.alpha*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
    plot(parsim_out(i).poly_alpha.Time, parsim_out(i).poly_alpha.Data*180/pi, 'DisplayName', 'Filtered Signal');
    legend;
    ylabel('$\alpha\;[deg]$');
    xlabel('$time\;[s]$');
    linkaxes(sub, 'x');
    clearvars sub;

    figure;

    sub(2) = subplot(2,1,1);
    plot(dataset.time, dataset.theta_dot*180/pi, 'DisplayName', 'Reconstructed (non causal)'); hold on; grid on;
    plot(parsim_out(i).poly_der_theta.Time, parsim_out(i).poly_der_theta.Data*180/pi, 'DisplayName', 'Filtered Signal');
    legend;
    ylabel('$\dot{\theta}\;[deg/s]$');

    sub(3) = subplot(3,1,3);
    plot(dataset.time, dataset.alpha_dot*180/pi, 'DisplayName', 'Reconstructed (non causal)'); hold on; grid on;
    plot(parsim_out(i).poly_der_alpha.Time, parsim_out(i).poly_der_alpha.Data*180/pi, 'DisplayName', 'Filtered Signal');
    legend;
    ylabel('$\dot{\alpha}\;[deg/s]$');
    xlabel('$time\;[s]$');
    linkaxes(sub, 'x');
end

%% FUNCTIONS
function derivative_filter_setup_fcn(filename)

    evalin('base', "run('" + filename + "');");

end

function derivative_filter_presimfcn(x)

    
end